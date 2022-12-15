public inherited sharing class EventDomain extends ApplicationDomain {

    public static EventDomain newInstance(List<Event__c> events) {
        return (EventDomain) Application.Domain.newInstance(events);
    }

    public EventDomain(List<Event__c> events) {
        super(events);
    }

    public override void onAfterInsert() {
        doParseEvents();
    }

    public void doParseEvents() {
        try {
            fflib_ISObjectUnitOfWork uow = (fflib_ISObjectUnitOfWork)Application.UnitOfWork.newInstance();
            List<Event_Parser__e> eventParsers = new List<Event_Parser__e>();
            for (Event__c event : (List<Event__c>)this.records) {
                eventParsers.add(new Event_Parser__e(
                    Related_Record_ID__c = event.Id
                ));
            }
            uow.registerPublishBeforeTransaction(eventParsers);
            uow.commitWork();
        } catch(Exception e){
            doParseEventsInFuture(JSON.serialize((List<Event__c>)this.records));
        }
    }

    public void doParseEventsInFuture(String serializedRecords) {
        if (!System.Test.isRunningTest()) { parseEventsInFuture(serializedRecords); }
    }

    @Future
    public static void parseEventsInFuture(String serializedRecords) {
        List<Event__c> records = (List<Event__c>)JSON.deserialize(serializedRecords, List<Event__c>.class);
        EventDomain.newInstance(records).parseEvents();
    }

    public void parseEvents() {
        try {
            Map<Id,Event__c> eventsById = new Map<Id,Event__c>((List<Event__c>)this.Records);
            List<API_Log__c> logs = ApiLogSelector.newInstance().selectByProcessId(eventsById.keySet());
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new List<SObjectType>{
                    Account.SObjectType,
                    Contact.SObjectType,
                    Lead.SObjectType,
                    Order__c.SObjectType,
                    Order_Item__c.SObjectType,
                    Event__c.SObjectType
            });

            Map<String, Contact> contactByCustomerId = new Map<String, Contact>();
            Map<Id, Contact> contactByAccountId = new Map<Id, Contact>();

            for (Api_Log__c log: logs) {
                if (log?.Request__c != null) {
                    String typeOfEvent = eventsById.get(log.Process_ID__c).Type__c;
                    if (EventType.CUSTOMERCREATED.name().equalsIgnoreCase(typeOfEvent)) {
                        CustomerPayload customerPayload = (CustomerPayload) JSON.deserializeStrict(log.Request__c, CustomerPayload.class);
                        customerPayload.customerData.account.Partner_Account__r = customerPayload.customerType == CustomerType.THIRDPARTY ? new Account(Partner_Unique_Identifier__c = customerPayload.customerData.account.Partner__c) : null;
                        uow.registerNew(customerPayload.customerData.account);
                        uow.registerRelationship(customerPayload.customerData.contact, Contact.AccountId, customerPayload.customerData.account);
                        uow.registerNew(customerPayload.customerData.contact);
                    } else if (EventType.CUSTOMERUPDATED.name().equalsIgnoreCase(typeOfEvent)) {
                        CustomerPayload customerPayload = (CustomerPayload) JSON.deserializeStrict(log.Request__c, CustomerPayload.class);
                        if (customerPayload.customerData.account != null) {
                            if(customerPayload.customerData.account.Id != null) {
                                uow.registerDirty(customerPayload.customerData.account);
                            } else {
                                UpsertUnitOfWorkHelper accountUpsertWork = new UpsertUnitOfWorkHelper(Account.Customer_Id__c);
                                uow.registerWork(accountUpsertWork);
                                accountUpsertWork.registerSObjectUpsert(customerPayload.customerData.account);
                            }
                        }
                        if (customerPayload.customerData.contact != null) {
                            if(customerPayload.customerData.account.Id != null) {
                                contactByAccountId.put(customerPayload.customerData.account.Id, customerPayload.customerData.contact);
                            } else {
                                contactByCustomerId.put(customerPayload.customerData.account.Customer_Id__c, customerPayload.customerData.contact);
                            }
                        }
                    } else if (EventType.LEADCREATED.name().equalsIgnoreCase(typeOfEvent)) {
                        LeadPayload leadPayload = (LeadPayload)JSON.deserializeStrict(log.Request__c, leadPayload.class);
                        LeadService leadService = LeadService.newInstance();
                        leadPayload.leadData.lead.RecordTypeId = leadService.getRecordTypeIdByLeadType(leadPayload.leadType);
                        leadPayload.leadData.lead.LeadSource = leadService.getLeadSourceByLeadType(leadPayload.leadType);
                        leadPayload.leadData.lead.Agency__c = leadService.getAgencyByLeadType(leadPayload.leadType);
                        Database.DMLOptions dmo = new Database.DMLOptions();
                        dmo.assignmentRuleHeader.useDefaultRule = true;
                        leadPayload.leadData.lead.setOptions(dmo);
                        uow.registerNew(leadPayload.leadData.lead);
                    } else if (EventType.ORDERCREATED.name().equalsIgnoreCase(typeOfEvent)) {
                        OrderPayload orderPayload = (OrderPayload) JSON.deserialize(log.Request__c, OrderPayload.class);
                        Account accountReference = new Account(Customer_Id__c = orderPayload.order.Customer_Id__c);
                        orderPayload.order.Account__r = accountReference;
                        uow.registerNew(orderPayload.order);
                        uow.registerDirty(eventsById.get(log.Process_ID__c), Event__c.Related_Record_Id__c, orderPayload.order);
                        for (Order_Item__c orderItem : orderPayload.orderItems) {
                            uow.registerNew(orderItem, Order_Item__c.Order__c, orderPayload.order);
                        }
                    } else if (EventType.ORDERUPDATED.name().equalsIgnoreCase(typeOfEvent)) {
                        OrderPayload orderPayload = (OrderPayload) JSON.deserialize(log.Request__c, OrderPayload.class);
                        if (orderPayload.order != null) {
                            UpsertUnitOfWorkHelper orderUpsertWork = new UpsertUnitOfWorkHelper(Order__c.Order_Id__c);
                            uow.registerWork(orderUpsertWork);
                            orderUpsertWork.registerSObjectUpsert(orderPayload.order);
                        }
                        if (orderPayload.orderItems != null && !orderPayload.orderItems.isEmpty()) {
                            UpsertUnitOfWorkHelper orderItemUpsertWork = new UpsertUnitOfWorkHelper(Order_Item__c.Unique_Id__c);
                            uow.registerWork(orderItemUpsertWork);
                            orderItemUpsertWork.registerSObjectListUpsert(orderPayload.orderItems);
                        }
                    }
                }
            }
            if(!contactByAccountId.isEmpty()) {
                for (Contact con : ContactSelector.newInstance().selectPrimaryContactByAccountIds(contactByAccountId.keySet())) {
                    contactByAccountId.get(con.Account.Id).Id = con.Id;
                    uow.registerDirty(contactByAccountId.get(con.Account.Id));
                }
            }
            if (!contactByCustomerId.isEmpty()) {
                for (Contact con : ContactSelector.newInstance().selectPrimaryContactByCustomerId(contactByCustomerId.keySet())) {
                    contactByCustomerId.get(con.Account.Customer_Id__c).Id = con.Id;
                    uow.registerDirty(contactByCustomerId.get(con.Account.Customer_Id__c));
                }
            }
            uow.commitWork();
        } catch(Exception e) {
            LoggerService.logException(e)
                .doInsertExceptionLog();
        }
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new EventDomain(sObjectList);
        }
    }

    public class CustomerPayload implements IPayload {
        public CustomerType customerType;
        public CustomerData customerData;
        public List<SObject> getRecords() {
            List<SObject> records = new List<SObject>();
            records.add(this.customerData.account);
            records.add(this.customerData.contact);
            return records;
        }
        public String getRecordId() {
            return this
                ?.customerData
                ?.account
                .Id;
        }
        public String getIdentifier() {
            return this
                        ?.customerData
                        ?.account
                        .Customer_ID__c;
        }
        public String getRecordType() {
            for (String recordTypeName : AccountService.ACCOUNT_RECORD_TYPE_NAMES) {
                if (recordTypeName.replaceAll('_', '').equalsIgnoreCase(customerType.name())) {
                    return recordTypeName;
                }
            }
            return null;
        }
    }

    public class CustomerData {
        public Account account {
            get {
                if (account == null) {
                    throw new DomainException(String.format(System.Label.MissingRequiredProperty, new List<String>{'Account'}));
                }
                return account;
            }
            set;
        }
        public Contact contact {
            get {
                if (contact == null) {
                    throw new DomainException(String.format(System.Label.MissingRequiredProperty, new List<String>{'Contact'}));
                }
                return contact;
            }
            set;
        }
    }
    public class LeadPayload implements IPayload {
        public LeadData leadData;
        private LeadService.LeadType leadType {
            get {
                if (leadType == null) {
                    leadType = leadData?.lead?.Country__c == 'jp' ?
                        LeadService.LeadType.Japan_Lead:
                        LeadService.LeadType.Standard;
                }
                return leadType;
            }
            set;
        }
        public List<SObject> getRecords() {
            List<SObject> records = new List<SObject>();
            records.add(this.leadData.lead);
            return records;
        }
        public String getIdentifier() {
            return this
                        ?.leadData
                        ?.lead
                        .Lead_Id__c;
        }

        public String getRecordId() {
            return '';
        }
    }

    public class LeadData {
        public Lead lead {
            get {
                if (lead == null) {
                    throw new DomainException(String.format(System.Label.MissingRequiredProperty, new List<String>{'Lead'}));
                }
                return lead;
            }
            set;
        }
    }

    public class OrderPayload implements IPayload {
        public String originalXml;
        public Order__c order;
        public List<Order_Item__c> orderItems;
        public List<SObject> getRecords() {
            List<SObject> records = new List<SObject>();
            if (order == null) {
                throw new Application.ApplicationException('Failed to parse the Order__c record.');
            }
            records.add(order);
            if (orderItems != null) {
                records.addAll(orderItems);
            }
            return records;
        }
        public String getIdentifier() {
            return this
                    ?.order
                    ?.Order_Id__c;
        }

        public String getRecordId() {
            return '';
        }
    }

    public interface IPayload {
        List<SObject> getRecords();
        String getIdentifier();
        String getRecordId();
    }

    public abstract class Validator {
        void validateRecordExists(EventService.EventServiceWrapper esw) {
            if (selectByExternalId().isEmpty()) {
                if(esw.event.Type__c.containsIgnoreCase('Customer')) {
                    throw new Application.ApplicationException(String.format(System.Label.CustomerNotFound, new List<String>{ esw.payload.getIdentifier() } ));
                } else {
                    throw new Application.ApplicationException(String.format(System.Label.OrderNotFound, new List<String>{ esw.payload.getIdentifier() } ));
                }
            }
        }
        abstract List<SObject> selectByExternalId();
    }

    public class OrderValidator extends Validator {
        public EventService.EventServiceWrapper esw;

        public OrderValidator(EventService.EventServiceWrapper esw) {
            this.esw = esw;
        }

        public override List<SObject> selectByExternalId() {
            return OrderSelector.newInstance().selectByOrderId(new Set<String>{esw.payload.getIdentifier()});
        }

        public void validateRecordExists() {
            super.validateRecordExists(esw);
        }

    }

    public class AccountValidator extends Validator {
        public EventService.EventServiceWrapper esw;

        public AccountValidator(EventService.EventServiceWrapper esw) {
            this.esw = esw;
        }

        public override List<SObject> selectByExternalId() {
            if(esw.payload.getRecordId() != null) {
                return AccountSelector.newInstance().selectById(new Set<Id>{esw.payload.getRecordId()});
            }
            return AccountSelector.newInstance().selectByCustomerId(new Set<String>{esw.payload.getIdentifier()});
        }

        public void validateRecordExists() {
            super.validateRecordExists(esw);
        }

    }

    public enum EventType {
        CUSTOMERCREATED, CUSTOMERUPDATED, LEADCREATED, ORDERCREATED, ORDERUPDATED
    }
    public enum CustomerType {
        INDEPENDENTECOMMERCE, INDEPENDENTBANKTRANSFER, THIRDPARTY
    }

}