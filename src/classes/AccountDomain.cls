public inherited sharing class AccountDomain extends ApplicationDomain {

    public static final String TEST_DATA_IDENTIFIER = '/TEST/';
    public static final String GENERIC_REQUIRED_FIELDS_FIELDSET_NAME = 'Generic_Required_Fields';
    public static final String INDEPENDENT_ECOMMERCE_REQUIRED_FIELDS_FIELDSET_NAME = 'Independent_Ecommerce_Required_Fields';
    public static final String INDEPENDENT_BANK_TRANSFER_REQUIRED_FIELDS_FIELDSET_NAME = 'Independent_Bank_Transfer_Required_Field';
    public static final String ENTERPRISE_PARENT_REQUIRED_FIELDS_FIELDSET_NAME = 'Enterprise_Parent_Required_Fields';
    public static final String ENTERPRISE_CHILD_REQUIRED_FIELDS_FIELDSET_NAME = 'Enterprise_Child_Required_Fields';
    public static final String THIRD_PARTY_REQUIRED_FIELDS_FIELDSET_NAME = 'Third_Party_Required_Fields';
    public static final String CONTRACT_ENDED_STATUS = 'ContractEnded';

     public enum CustomerType {
         IndependentEcommerce, IndependentBankTransfer, EnterpriseParent, EnterpriseChild, ThirdParty
     }

    public static AccountDomain newInstance(List<Account> recordList) {
        return (AccountDomain) Application.Domain.newInstance(recordList);
    }

    public AccountDomain(List<Account> accounts) {
        super(accounts);
    }

    public override void onBeforeUpdate(Map<Id, SObject> accountsByRecordIds) {
        setPreviousStatusField(accountsByRecordIds);
    }

    public override void onAfterUpdate(Map<Id,SObject> accountsByRecordIds) {
        super.trackSObjectHistory();
    }

    public override void onApplyDefaults() {
        setTestDataFieldIfAccountNameContainsTestIdentifierValue();
        setRecordTypeIdFieldIfCreatedByEvent();
    }

    public override void onValidate() {
        reportIfRequiredFieldsAreMissing();
    }

    public override void onValidate(Map<Id, SObject> existingRecords) {
        reportIfRequiredFieldsAreMissing();
        //reportIfRecordTypeCannotBeChanged(existingRecords); TODO: Change logic so that it works with Rejoin flow also
    }

    public void reportIfRecordTypeCannotBeChanged(Map<Id, SObject> existingRecords) {
        for (Account account : (List<Account>)getChangedRecords(new Set<Schema.SObjectField>{Account.RecordTypeId})) {
            Account existingRecord = (Account)existingRecords.get(account.Id);
            if ( getRecordTypeDeveloperName(existingRecord) == CustomerService.CustomerType.Third_Party.name()
                    && getRecordTypeDeveloperName(account) != CustomerService.CustomerType.Third_Party.name()) {
                account.addError(Account.RecordTypeId, String.format(Label.IllegalRecordTypeChangeException, new List<String>{
                    account.RecordType.Name})); 			
            }
        }
    }

     public void setPreviousStatusField(Map<Id, SObject> accountsByRecordIds) {
         for (Account account : (List<Account>)getChangedRecords(new Set<Schema.SObjectField>{Account.Account_Status__c})) {
             account.Previous_Status__c = ((Account) accountsByRecordIds.get(account.Id)).Account_Status__c;
         }
     }

    public void setTestDataFieldIfAccountNameContainsTestIdentifierValue() {
        for (Account account : (List<Account>)getRecordsWithNotBlankFieldValues(Account.Name)) {
            if (account.Name.containsIgnoreCase(TEST_DATA_IDENTIFIER)) {
                account.Test_Data__c = true;
            }
        }
    }

    public void setRecordTypeIdFieldIfCreatedByEvent() {
        Map<String,Account> accountsByCustomerIds = getAccountRecordsByCustomerIds();
        List<Event__c> events = getRelatedCustomerCreatedEventsByCustomerIds(accountsByCustomerIds.keySet());
        
        for (Event__c event : events) {
            Account account = accountsByCustomerIds.get(event.name);
            account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get(event.Record_Type__c)?.getRecordTypeId();
        }
    }

    public void reportIfRecordTypeCannotBeChanged() {
        for (Account account : (List<Account>)getChangedRecords(new Set<Schema.SObjectField>{Account.RecordTypeId})) {
            if (account.RecordType.DeveloperName != CustomerService.CustomerType.Third_Party.name()) {
                account.addError(Account.RecordTypeId, String.format(Label.IllegalRecordTypeChangeException, new List<String>{
                    account.RecordType.Name})); 			
            }
        }
    }

    private Map<String,Account> getAccountRecordsByCustomerIds() {
        Map<String,Account> accountsByCustomerIds = new Map<String,Account>();
        for (Account account : (List<Account>)getRecordsWithNotBlankFieldValues(Account.Customer_Id__c)) {
            accountsByCustomerIds.put(account.Customer_Id__c, account);
        }
        return accountsByCustomerIds;
    }

    private List<Event__c> getRelatedCustomerCreatedEventsByCustomerIds(Set<String> customerIds) {
        return (List<Event__c>)EventSelector.newInstance().selectByNameAndType(customerIds, EventDomain.EventType.CUSTOMERCREATED);
    }

    public override ApplicationDomain validateRequiredSObjectFieldsForExternal(EventService.EventServiceWrapper esw) {
        Map<SObjectField, String> requiredFieldsNameBySObjectField;
        requiredFieldsNameBySObjectField = getRequiredFieldsNameBySObjectField(esw);
        if (esw.isUpdateEventType()) {
            return validateNonNullableFields(requiredFieldsNameBySObjectField);

        } else {
            return validateFields(requiredFieldsNameBySObjectField);
        }
    }

    private Map<SObjectField, String> getRequiredFieldsNameBySObjectField(EventService.EventServiceWrapper esw) {
        Map<SObjectField, String> requiredFieldsNameBySObjectField;
        String customerType = ((EventDomain.CustomerPayload)esw.payload).customerType.name();
        requiredFieldsNameBySObjectField = getRequiredFieldsInfoBySObjectType();
        requiredFieldsNameBySObjectField.putAll(getFieldSetMap(GENERIC_REQUIRED_FIELDS_FIELDSET_NAME));
        if (customerType.equalsIgnoreCase(AccountService.INDEPENDENT_BANK_TRANSFER_RECORD_TYPE_NAME.replace('_', ''))) {
            requiredFieldsNameBySObjectField.putAll(getFieldSetMap(INDEPENDENT_BANK_TRANSFER_REQUIRED_FIELDS_FIELDSET_NAME));
        } else if (customerType.equalsIgnoreCase(AccountService.ENTERPRISE_CHILD_RECORD_TYPE_NAME.replace('_', ''))) {
            requiredFieldsNameBySObjectField.putAll(getFieldSetMap(ENTERPRISE_CHILD_REQUIRED_FIELDS_FIELDSET_NAME));
        } else if (customerType.equalsIgnoreCase(AccountService.ENTERPRISE_PARENT_RECORD_TYPE_NAME.replace('_', ''))) {
            requiredFieldsNameBySObjectField.putAll(getFieldSetMap(ENTERPRISE_PARENT_REQUIRED_FIELDS_FIELDSET_NAME));
        } else if (customerType.equalsIgnoreCase(AccountService.THIRD_PARTY_RECORD_TYPE_NAME.replace('_', ''))) {
            requiredFieldsNameBySObjectField.putAll(getFieldSetMap(THIRD_PARTY_REQUIRED_FIELDS_FIELDSET_NAME));
        } else {
            requiredFieldsNameBySObjectField.putAll(getFieldSetMap(INDEPENDENT_ECOMMERCE_REQUIRED_FIELDS_FIELDSET_NAME));
        }
        return requiredFieldsNameBySObjectField;
    }

    public override List<String> getPicklistEntries(SObjectField field, String recordTypeName) {
        List<String> returnValues = new List<String>();
        Schema.DescribeFieldResult fieldMetadata = field.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldMetadata.getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistEntries) {
            returnValues.add(picklistEntry.getValue().toLowerCase());
        }
        return returnValues;
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new AccountDomain(sObjectList);
        }
    }
    
}