@IsTest(isParallel=true)
public class EventDomainTest {

    @IsTest 
    public static void whenCalledDoParseEventsHappyFlow() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
        Application.UnitOfWork.setMock(uowMock);

         // Given
        Event__c event = new Event__c(
            Id = fflib_IDGenerator.generate(Event__c.SObjectType)
        );

        // When
        Test.startTest();
        EventDomain eventDomain = EventDomain.newInstance(new List<Event__c> {event});
        eventDomain.doParseEvents();
        Test.stopTest();

        // Then
       ((fflib_ISObjectUnitOfWork)mocks.verify(uowMock, mocks.times(1).description(
            'Event_Parser__e should be created with Event.Id as Related_Record_Id__c')))
            .registerPublishBeforeTransaction(fflib_Match.sObjectsWith(
                new List<Map<SObjectField,Object>> {
                    new Map<SObjectField,Object> {
                        Event_Parser__e.Related_Record_Id__c => event.Id
                    }
                }
            ));
    }

    @IsTest 
    public static void whenCalledDoParseEventsExceptionShouldBeThrown() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        ApiLogSelector apiLogSelectorMock = (ApiLogSelector) mocks.mock(ApiLogSelector.class);

        // Given
        Event__c event = new Event__c(
            Id = fflib_IDGenerator.generate(Event__c.SObjectType)
        );
        List<Event_Parser__e> eventParsers = new List<Event_Parser__e>{
            new Event_Parser__e(Related_Record_Id__c = event.Id)
        };

        mocks.startStubbing();
        ((fflib_ISObjectUnitOfWork) mocks.doAnswer(
            new VoidAnswer(),uowMock))
            .registerPublishBeforeTransaction(eventParsers);
        ((fflib_ISObjectUnitOfWork)mocks.doThrowWhen(new list<fflib_ApexMocks.ApexMocksException> {
            new fflib_ApexMocks.ApexMocksException('stubbed exception.'), 
            null}, 
            uowMock)).commitWork();
        mocks.stopStubbing(); 
        Application.UnitOfWork.setMock(uowMock);
        Application.Selector.setMock(apiLogSelectorMock);

        EventDomain eventDomain = EventDomain.newInstance(new List<Event__c> {event});
        // When
        Test.startTest();
        eventDomain.doParseEvents();
        Test.stopTest();

        // Then
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock,1)).registerPublishBeforeTransaction(eventParsers);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock,1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock,0)).registerNew(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock,0)).registerRelationship(fflib_Match.anySObject(),fflib_Match.anySObjectField(),fflib_Match.anySObject());
        ((ApiLogSelector) mocks.verify(apiLogSelectorMock,0)).selectByProcessId(new Set<Id>{event.Id});
    }

    @IsTest 
    public static void whenCalledParseEventsCustomerShouldBeCreated() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        ApiLogSelector apiLogSelectorMock = (ApiLogSelector) mocks.mock(ApiLogSelector.class);

        // Given
        Event__c event = new Event__c(
            Id = fflib_IDGenerator.generate(Event__c.SObjectType),
            Type__c = EventDomain.EventType.CUSTOMERCREATED.name(),
            Record_Type__c = AccountService.INDEPENDENT_ECOMMERCE_RECORD_TYPE_NAME
        );
        String jsonRequest = [SELECT Id, Body FROM StaticResource WHERE Name = 'dummyIndependentEcommercePayload' LIMIT 1].Body.toString();
        EventDomain.CustomerPayload customerPayload = (EventDomain.CustomerPayload)JSON.deserializeStrict(jsonRequest, EventDomain.CustomerPayload.class);
        API_Log__c apiLog = new API_Log__c(
            Request__c = jsonRequest,
            Process_ID__c = event.Id
        );
        EventDomain eventDomain = EventDomain.newInstance(new List<Event__c> {event});

        mocks.startStubbing();
        ((fflib_ISObjectUnitOfWork) mocks.doAnswer(
            new VoidAnswer(),uowMock))
            .commitWork();
        mocks.when(apiLogSelectorMock.sObjectType()).thenReturn(API_Log__c.SObjectType);
        mocks.when(apiLogSelectorMock.selectByProcessId(new Set<Id>{event.Id})).thenReturn(new List<API_Log__c>{apiLog});
        mocks.stopStubbing(); 
        Application.UnitOfWork.setMock(uowMock);
        Application.Selector.setMock(apiLogSelectorMock);

        // When
        eventDomain.parseEvents();

        // Then
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock,2)).registerNew(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork)mocks.verify(uowMock,mocks.times(1)
            .description('Account sb created')))
            .registerNew(fflib_Match.sObjectWith(
            new Map<SObjectField,Object> {
                Account.Id => customerPayload.customerData.account.Id
            }
        )); 
        ((fflib_ISObjectUnitOfWork)mocks.verify(uowMock,mocks.times(1)
            .description('Contact sb created')))
            .registerNew(fflib_Match.sObjectWith(
            new Map<SObjectField,Object> {
                Contact.AccountId => customerPayload.customerData.account.Id
            }
        )); 
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock,1)).registerRelationship(fflib_Match.anySObject(),fflib_Match.anySObjectField(),fflib_Match.anySObject());
        ((ApiLogSelector) mocks.verify(apiLogSelectorMock,1)).selectByProcessId(new Set<Id>{event.Id});
    }

    @IsTest
    public static void whenCalledParseEventsCustomerShouldBeUpdated() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        ApiLogSelector apiLogSelectorMock = (ApiLogSelector) mocks.mock(ApiLogSelector.class);
        ContactSelector contactSelectorMock = (ContactSelector) mocks.mock(ContactSelector.class);

        // Given
        Event__c event = new Event__c(
            Id = fflib_IDGenerator.generate(Event__c.SObjectType),
            Type__c = EventDomain.EventType.CUSTOMERUPDATED.name(),
            Record_Type__c = AccountService.INDEPENDENT_ECOMMERCE_RECORD_TYPE_NAME
        );
        String jsonRequest = [SELECT Id, Body FROM StaticResource WHERE Name = 'dummyIndependentEcommercePayload' LIMIT 1].Body.toString();
        EventDomain.CustomerPayload customerPayload = (EventDomain.CustomerPayload)JSON.deserializeStrict(jsonRequest, EventDomain.CustomerPayload.class);
        API_Log__c apiLog = new API_Log__c(
            Request__c = jsonRequest,
            Process_ID__c = event.Id
        );
        EventDomain eventDomain = EventDomain.newInstance(new List<Event__c> {event});

        Contact con = new Contact(
            Id = fflib_IDGenerator.generate(Contact.SObjectType),
            FirstName = customerPayload.customerData.contact.FirstName,
            LastName = customerPayload.customerData.contact.LastName,
            MobilePhone = customerPayload.customerData.contact.MobilePhone,
            Account = new Account(Customer_Id__c = customerPayload.customerData.account.Customer_Id__c)
        );

        mocks.startStubbing();
        ((fflib_ISObjectUnitOfWork) mocks.doAnswer(
            new VoidAnswer(),uowMock))
            .commitWork();
        mocks.when(apiLogSelectorMock.sObjectType()).thenReturn(API_Log__c.SObjectType);
        mocks.when(apiLogSelectorMock.selectByProcessId(new Set<Id>{event.Id})).thenReturn(new List<API_Log__c>{apiLog});
        mocks.when(contactSelectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactSelectorMock.selectPrimaryContactByCustomerId(new Set<String>{customerPayload.customerData.account.Customer_Id__c})).thenReturn(new List<Contact>{con});
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(uowMock);
        Application.Selector.setMock(apiLogSelectorMock);
        Application.Selector.setMock(contactSelectorMock);

        // When
        eventDomain.parseEvents();

        // Then
        ((fflib_ISObjectUnitOfWork)mocks.verify(uowMock,mocks.times(1)
            .description('Contact sb updated')))
            .registerDirty(fflib_Match.sObjectWith(
            new Map<SObjectField,Object> {
                Contact.Id => con.Id,
                Contact.FirstName => customerPayload.customerData.contact.FirstName,
                Contact.LastName => customerPayload.customerData.contact.LastName,
                Contact.MobilePhone => customerPayload.customerData.contact.MobilePhone
            }
        ));
        ((ApiLogSelector) mocks.verify(apiLogSelectorMock,1)).selectByProcessId(new Set<Id>{event.Id});
    }

    @IsTest
    public static void whenCalledParseEventsCustomerShouldBeUpdatedByAccountId() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        ApiLogSelector apiLogSelectorMock = (ApiLogSelector) mocks.mock(ApiLogSelector.class);

        // Given
        Event__c event = new Event__c(
            Id = fflib_IDGenerator.generate(Event__c.SObjectType),
            Type__c = EventDomain.EventType.CUSTOMERUPDATED.name(),
            Record_Type__c = AccountService.INDEPENDENT_ECOMMERCE_RECORD_TYPE_NAME
        );
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);

        String jsonRequest = '{"CustomerType": "IndependentEcommerce", "CustomerData" : {"Account": { "Name": "Test","Id": "'+accountId+'","Customer_Id__c": "CustomerUPDATE099"},"Contact": {"Id":"'+contactId+'", "FirstName":"xyz"}}}';

        EventDomain.CustomerPayload customerPayload = (EventDomain.CustomerPayload)JSON.deserialize(jsonRequest, EventDomain.CustomerPayload.class);
        API_Log__c apiLog = new API_Log__c(
                Request__c = jsonRequest,
                Process_ID__c = event.Id
        );
        EventDomain eventDomain = EventDomain.newInstance(new List<Event__c> {event});

        mocks.startStubbing();
        ((fflib_ISObjectUnitOfWork) mocks.doAnswer(
            new VoidAnswer(),uowMock))
            .commitWork();
        mocks.when(apiLogSelectorMock.sObjectType()).thenReturn(API_Log__c.SObjectType);
        mocks.when(apiLogSelectorMock.selectByProcessId(new Set<Id>{event.Id})).thenReturn(new List<API_Log__c>{apiLog});
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(uowMock);
        Application.Selector.setMock(apiLogSelectorMock);

        // When
        eventDomain.parseEvents();

        // Then
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock,1)).registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork)mocks.verify(uowMock,mocks.times(1)
            .description('Account sb updated')))
            .registerDirty(fflib_Match.sObjectWith(
            new Map<SObjectField,Object> {
                    Account.Id => customerPayload.customerData.account.Id
            }
        ));
        ((ApiLogSelector) mocks.verify(apiLogSelectorMock,1)).selectByProcessId(new Set<Id>{event.Id});
    }

    @IsTest
    static void whenCalledParseEventsOrderShouldBeCreated() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        ApiLogSelector apiLogSelectorMock = (ApiLogSelector) mocks.mock(ApiLogSelector.class);

        // Given
        String orderId = fflib_IDGenerator.generate(Order__c.SObjectType);
        String orderItemId = fflib_IDGenerator.generate(Order_Item__c.SObjectType);
        
        String customerId = '9e1f94ab-712e-a505-eb70-bea6232edc45';
        Event__c event = new Event__c(
                Id = fflib_IDGenerator.generate(Event__c.SObjectType),
                Type__c = EventDomain.EventType.ORDERCREATED.name()
        );
        String xmlRequest = [SELECT Id, Body FROM StaticResource WHERE Name = 'dummyServiceRequestPayload' LIMIT 1].Body.toString();
        xmlRequest = xmlRequest.replace('[orderId]', orderId);
        xmlRequest = xmlRequest.replace('[orderItemId]', orderItemId);
        xmlRequest = xmlRequest.replace('[customerId]', customerId);
        String transformedRequest = XMLParserService.newInstance().transformOrderPayload(xmlRequest);
        EventDomain.OrderPayload orderPayload = (EventDomain.OrderPayload)JSON.deserialize(XMLParserService.newInstance().transformOrderPayload(xmlRequest), EventDomain.OrderPayload.class);
        API_Log__c apiLog = new API_Log__c(
                Request__c = transformedRequest,
                Process_ID__c = event.Id
        );
        EventDomain eventDomain = EventDomain.newInstance(new List<Event__c> {event});

        mocks.startStubbing();
        ((fflib_ISObjectUnitOfWork) mocks.doAnswer(
                new VoidAnswer(),uowMock))
                .commitWork();
        mocks.when(apiLogSelectorMock.sObjectType()).thenReturn(API_Log__c.SObjectType);
        mocks.when(apiLogSelectorMock.selectByProcessId(new Set<Id>{event.Id})).thenReturn(new List<API_Log__c>{apiLog});
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(uowMock);
        Application.Selector.setMock(apiLogSelectorMock);

        // When
        eventDomain.parseEvents();

        // Then
        ((fflib_ISObjectUnitOfWork)
            mocks.verify(uowMock, 1)).registerNew(
            fflib_Match.sObjectWith(
                new Map<SObjectField, Object>{
                    Order__c.Order_Id__c => orderId
                }
            ));
        ((fflib_ISObjectUnitOfWork)
            mocks.verify(uowMock, 1)).registerNew(
            fflib_Match.sObjectWith(
                new Map<SObjectField, Object>{
                    Order_Item__c.Unique_Id__c => orderItemId
                }
            ),
            fflib_Match.eqSObjectField(Order_Item__c.Order__c),
            fflib_Match.sObjectWith(
                new Map<SObjectField, Object>{
                    Order__c.Order_Id__c => orderId
                }
            ));
        ((ApiLogSelector) mocks.verify(apiLogSelectorMock,1)).selectByProcessId(new Set<Id>{event.Id});
    }

    @IsTest
    static void whenCalledParseEventsOrderShouldBeUpdated() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        ApiLogSelector apiLogSelectorMock = (ApiLogSelector) mocks.mock(ApiLogSelector.class);

        // Given
        String orderId = fflib_IDGenerator.generate(Order__c.SObjectType);
        String orderItemId = fflib_IDGenerator.generate(Order_Item__c.SObjectType);
        Event__c event = new Event__c(
                Id = fflib_IDGenerator.generate(Event__c.SObjectType),
                Type__c = EventDomain.EventType.ORDERUPDATED.name()
        );
        String xmlRequest = [SELECT Id, Body FROM StaticResource WHERE Name = 'dummyStatusUpdateAcceptPayload' LIMIT 1].Body.toString();
        xmlRequest = xmlRequest.replace('[orderId]', orderId);
        xmlRequest = xmlRequest.replace('[orderItemId]', orderItemId);
        String transformedRequest = XMLParserService.newInstance().transformOrderPayload(xmlRequest);
        EventDomain.OrderPayload orderPayload = (EventDomain.OrderPayload)JSON.deserialize(XMLParserService.newInstance().transformOrderPayload(xmlRequest), EventDomain.OrderPayload.class);
        API_Log__c apiLog = new API_Log__c(
                Request__c = transformedRequest,
                Process_ID__c = event.Id
        );
        EventDomain eventDomain = EventDomain.newInstance(new List<Event__c> {event});

        mocks.startStubbing();
        mocks.when(apiLogSelectorMock.sObjectType()).thenReturn(API_Log__c.SObjectType);
        mocks.when(apiLogSelectorMock.selectByProcessId(new Set<Id>{event.Id})).thenReturn(new List<API_Log__c>{apiLog});
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(uowMock);
        Application.Selector.setMock(apiLogSelectorMock);

        // When
        eventDomain.parseEvents();

        // Then
        ((ApiLogSelector) mocks.verify(apiLogSelectorMock,1)).selectByProcessId(new Set<Id>{event.Id});
    }

    @IsTest 
    public static void whenCalledParseEventsExceptionShouldBeThrown() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        ApiLogSelector apiLogSelectorMock = (ApiLogSelector) mocks.mock(ApiLogSelector.class);
        LoggerService loggerServiceMock = (LoggerService) mocks.mock(LoggerService.class);

        // Given
        Event__c event = new Event__c(
            Id = fflib_IDGenerator.generate(Event__c.SObjectType)
        );
        Exception testException = new fflib_ApexMocks.ApexMocksException('stubbed exception.');
        EventDomain eventDomain = EventDomain.newInstance(new List<Event__c> {event});

        mocks.startStubbing();
        mocks.when(apiLogSelectorMock.sObjectType()).thenReturn(API_Log__c.SObjectType);
        ((ApiLogSelector)mocks.doThrowWhen(
            testException, apiLogSelectorMock))
            .selectByProcessId(new Set<Id>{event.Id});
        mocks.when(loggerServiceMock.logException()).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setRunningUser(fflib_Match.anyId())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setExceptionMessage(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setTypeName(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setStackTrace(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.doInsertExceptionLog()).thenReturn(loggerServiceMock);
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(uowMock);
        Application.Selector.setMock(apiLogSelectorMock);
        Application.Service.setMock(LoggerService.class, loggerServiceMock);

        // When
        eventDomain.parseEvents();

        // Then
        ((ApiLogSelector) mocks.verify(apiLogSelectorMock,1)).selectByProcessId(new Set<Id>{event.Id});
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock,0)).registerNew(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock,0)).registerRelationship(fflib_Match.anySObject(),fflib_Match.anySObjectField(),fflib_Match.anySObject());
        ((LoggerService) mocks.verify(loggerServiceMock,1)).logException();    
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setRunningUser(UserInfo.getUserId()); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setExceptionMessage(testException.getMessage());  
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setTypeName(testException.getTypeName());   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setStackTrace(fflib_Match.anyString());   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).doInsertExceptionLog();   
        
    }

    class VoidAnswer implements fflib_Answer {
        public Object answer(fflib_InvocationOnMock invocation) {
            return null;
        }
    }
    
}