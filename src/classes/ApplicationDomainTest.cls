@isTest
private class ApplicationDomainTest {
    
    @isTest
    private static void whenValidateRequiredSObjectFieldsForExternalIsCalledWithAllRequiredFields() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ApplicationDomain domainMock = (ApplicationDomain) mocks.mock(ApplicationDomain.class);
        Application.Domain.setMock((fflib_ISObjectDomain)domainMock);

        mocks.startStubbing();
        mocks.when(domainMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.stopStubbing();

        Account acc = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Name = 'test Account',
            Notification_Email__c = 'tes@email.com',
            Account_Status__c = 'ActivePaid',
            Business_Type__c = 'Other',
            Customer_id__c = '1234',
            Viewer_id__c = '1234',
            Notification_Language_Code__c = 'en-GB',
            Notification_Country_Code__c = 'JP'
        );
        List<Account> testAccountList = new List<Account> { acc };

        EventService.EventServiceWrapper esw = new EventService.EventServiceWrapper();
        esw.event = new Event__c(
            Type__c = EventDomain.EventType.CUSTOMERUPDATED.name()
        );

        EventDomain.CustomerPayload customerPayload = new EventDomain.CustomerPayload();
        EventDomain.CustomerType custType = EventDomain.CustomerType.INDEPENDENTECOMMERCE;
        customerPayload.customerType = custType;
        esw.payload = customerPayload;
        
        ApplicationDomain application = (ApplicationDomain) Application.Domain.newInstance(testAccountList);
        Exception thrownException;
        try {
            application.validateRequiredSObjectFieldsForExternal(esw);
        } catch (Exception ex) {
            thrownException = ex;
        }
        system.assertEquals(null, thrownException);
    }

    @isTest
    private static void whenValidateRequiredSObjectFieldsForExternalIsCalledWithoutViewerAndCustomerId() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ApplicationDomain domainMock = (ApplicationDomain) mocks.mock(ApplicationDomain.class);
        Application.Domain.setMock((fflib_ISObjectDomain)domainMock);

        mocks.startStubbing();
        mocks.when(domainMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.stopStubbing();

        Account acc = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Name = 'test Account',
            Notification_Email__c = 'tes@email.com',
            Account_Status__c = 'ActivePaid',
            Business_Type__c = 'Other',
            Notification_Language_Code__c = 'en-GB',
            Notification_Country_Code__c = 'JP',
            Customer_Id__c = ''
        );

        List<Account> testAccountList = new List<Account> { acc };

        EventService.EventServiceWrapper esw = new EventService.EventServiceWrapper();
        esw.event = new Event__c(
            Type__c = EventDomain.EventType.CUSTOMERUPDATED.name()
        );

        EventDomain.CustomerPayload customerPayload = new EventDomain.CustomerPayload();
        EventDomain.CustomerType custType = EventDomain.CustomerType.INDEPENDENTECOMMERCE;
        customerPayload.customerType = custType;
        esw.payload = customerPayload;

        ApplicationDomain application = (ApplicationDomain) Application.Domain.newInstance(testAccountList);
        Exception thrownException;
        try {
            application.validateRequiredSObjectFieldsForExternal(esw);
        } catch (Exception ex) {
            thrownException = ex;
        }
        system.assertEquals(true, thrownException.getMessage().contains('Data Policy Exception'));
    }

    @isTest
    private static void whenValidateSObjectFieldValuesIsCalledWithValidCountryCode() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ApplicationDomain domainMock = (ApplicationDomain) mocks.mock(ApplicationDomain.class);
        Application.Domain.setMock((fflib_ISObjectDomain)domainMock);

        Account acc = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Notification_Country_Code__c = 'JP'
        );
        List<Account> testAccountList = new List<Account> { acc };

        Map<String,SObjectField> fieldsMap = new Map<String,SObjectField>{
            'Notification_Country_Code__c' => Account.Notification_Country_Code__c.getDescribe().getSObjectField()
        };

        mocks.startStubbing();
        mocks.when(domainMock.sObjectType()).thenReturn(Account.SObjectType);
        for(SObjectField field : fieldsMap.values()) {
            mocks.when(domainMock.getRecordsWithNotBlankFieldValues(field)).thenReturn(testAccountList);
        }
        mocks.stopStubbing();
        
        ApplicationDomain application = (ApplicationDomain) Application.Domain.newInstance(testAccountList);
        Exception thrownException;
        try {
            application.validateSObjectFieldValues(null);
        } catch (Exception ex) {
            thrownException = ex;
        }
        system.assertEquals(null, thrownException);
    }

    @isTest
    private static void whenValidateSObjectFieldValuesIsCalledWithInvalidCountryCode() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ApplicationDomain domainMock = (ApplicationDomain) mocks.mock(ApplicationDomain.class);
        Application.Domain.setMock((fflib_ISObjectDomain)domainMock);

        Account acc = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Notification_Country_Code__c = 'x'
        );
        List<Account> testAccountList = new List<Account> { acc };

        Map<String,SObjectField> fieldsMap = new Map<String,SObjectField>{
            'Notification_Country_Code__c' => Account.Notification_Country_Code__c.getDescribe().getSObjectField()
        };

        mocks.startStubbing();
        mocks.when(domainMock.sObjectType()).thenReturn(Account.SObjectType);
        for(SObjectField field : fieldsMap.values()) {
            mocks.when(domainMock.getRecordsWithNotBlankFieldValues(field)).thenReturn(testAccountList);
        }
        mocks.stopStubbing();
        
        ApplicationDomain application = (ApplicationDomain) Application.Domain.newInstance(testAccountList);
        Exception thrownException;
        try {
            application.validateSObjectFieldValues(null);
        } catch (Exception ex) {
            thrownException = ex;
        }
        system.assertNotEquals(null, thrownException);
    }

    @isTest
    private  static void whenValidateSObjectFieldValuesIsCalledWithInvalidEmail() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ApplicationDomain domainMock = (ApplicationDomain) mocks.mock(ApplicationDomain.class);
        Application.Domain.setMock((fflib_ISObjectDomain)domainMock);

        Account acc = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Business_Email__c = 'no-email-address'
        );
        List<Account> testAccountList = new List<Account> { acc };

        Map<String,SObjectField> fieldsMap = new Map<String,SObjectField>{
            'Business_Email__c'=> Account.Notification_Country_Code__c.getDescribe().getSObjectField()
        };

        mocks.startStubbing();
        mocks.when(domainMock.sObjectType()).thenReturn(Account.SObjectType);
        for(SObjectField field : fieldsMap.values()) {
            mocks.when(domainMock.getRecordsWithNotBlankFieldValues(field)).thenReturn(testAccountList);
        }
        mocks.stopStubbing();
        
        ApplicationDomain application = (ApplicationDomain) Application.Domain.newInstance(testAccountList);
        Exception thrownException;
        try {
            application.validateSObjectFieldValues(null);
        } catch (Exception ex) {
            thrownException = ex;
        }
//        system.assertNotEquals(null, thrownException); todo uncomment when email regex is provided by Salesforce
    }

    @isTest
    private static void whenValidateSObjectFieldLengthIsCalledWithValidCustomerIDTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ApplicationDomain domainMock = (ApplicationDomain) mocks.mock(ApplicationDomain.class);
        Application.Domain.setMock((fflib_ISObjectDomain)domainMock);

        Account acc = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Customer_Id__c = '123aav6vdd5d3dafd46es3g34221'
        );
        List<Account> testAccountList = new List<Account> { acc };

        Map<String,SObjectField> fieldsMap = new Map<String,SObjectField>{
            'Customer_Id__c' => Account.Customer_Id__c.getDescribe().getSObjectField()
        };

        mocks.startStubbing();
        mocks.when(domainMock.sObjectType()).thenReturn(Account.SObjectType);
        for(SObjectField field : fieldsMap.values()) {
            mocks.when(domainMock.getRecordsWithNotBlankFieldValues(field)).thenReturn(testAccountList);
        }
        mocks.stopStubbing();
        
        ApplicationDomain application = (ApplicationDomain) Application.Domain.newInstance(testAccountList);
        Exception thrownException;
        try {
            application.validateSObjectFieldLength();
        } catch (Exception ex) {
            thrownException = ex;
        }
        system.assertEquals(null, thrownException);
    }

    @isTest
    private static void whenValidateSObjectFieldLengthIsCalledWithTooLongCustomerIDTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ApplicationDomain domainMock = (ApplicationDomain) mocks.mock(ApplicationDomain.class);
        Application.Domain.setMock((fflib_ISObjectDomain)domainMock);

        Account acc = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Notification_Country_Code__c = 'JP'
        );

        for(Integer i = 0; i < 256; i++) {
            acc.Customer_Id__c += '1';
        }
        List<Account> testAccountList = new List<Account> { acc };

        Map<String,SObjectField> fieldsMap = new Map<String,SObjectField>{
            'Notification_Country_Code__c' => Account.Notification_Country_Code__c.getDescribe().getSObjectField(),
            'Customer_Id__c' => Account.Customer_Id__c.getDescribe().getSObjectField()
        };

        mocks.startStubbing();
        mocks.when(domainMock.sObjectType()).thenReturn(Account.SObjectType);
        for(SObjectField field : fieldsMap.values()) {
            mocks.when(domainMock.getRecordsWithNotBlankFieldValues(field)).thenReturn(testAccountList);
        }
        mocks.stopStubbing();
        
        ApplicationDomain application = (ApplicationDomain) Application.Domain.newInstance(testAccountList);
        Exception thrownException;
        try {
            application.validateSObjectFieldLength();
        } catch (Exception ex) {
            thrownException = ex;
        }
        system.assertNotEquals(null, thrownException);
    }

    @isTest
    private static void whenValidateSObjectFieldLengthIsCalledWithValidRoomOccupancyTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ApplicationDomain domainMock = (ApplicationDomain) mocks.mock(ApplicationDomain.class);
        Application.Domain.setMock((fflib_ISObjectDomain)domainMock);

        Account acc = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Room_Occupancy__c = 10
        );

        List<Account> testAccountList = new List<Account> { acc };

        Map<String,SObjectField> fieldsMap = new Map<String,SObjectField>{
            'Room_Occupancy__c' => Account.Room_Occupancy__c.getDescribe().getSObjectField()
        };

        mocks.startStubbing();
        mocks.when(domainMock.sObjectType()).thenReturn(Account.SObjectType);
        for(SObjectField field : fieldsMap.values()) {
            mocks.when(domainMock.getRecordsWithNotBlankFieldValues(field)).thenReturn(testAccountList);
        }
        mocks.stopStubbing();
        
        ApplicationDomain application = (ApplicationDomain) Application.Domain.newInstance(testAccountList);
        Exception thrownException;
        try {
            application.validateSObjectFieldLength();
        } catch (Exception ex) {
            thrownException = ex;
        }
        system.assertEquals(null, thrownException);
    }

    @isTest
    private static void whenValidateSObjectFieldLengthIsCalledWithExceedingMaxLengthRoomOccupancyTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ApplicationDomain domainMock = (ApplicationDomain) mocks.mock(ApplicationDomain.class);
        Application.Domain.setMock((fflib_ISObjectDomain)domainMock);

        Account acc = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Room_Occupancy__c = 1
        );

        for(Integer i = 0; i < 19; i++) {
            acc.Room_Occupancy__c = acc.Room_Occupancy__c*10;
        }

        List<Account> testAccountList = new List<Account> { acc };

        Map<String,SObjectField> fieldsMap = new Map<String,SObjectField>{
            'Room_Occupancy__c' => Account.Room_Occupancy__c.getDescribe().getSObjectField()
        };

        mocks.startStubbing();
        mocks.when(domainMock.sObjectType()).thenReturn(Account.SObjectType);
        for(SObjectField field : fieldsMap.values()) {
            mocks.when(domainMock.getRecordsWithNotBlankFieldValues(field)).thenReturn(testAccountList);
        }
        mocks.stopStubbing();
        
        ApplicationDomain application = (ApplicationDomain) Application.Domain.newInstance(testAccountList);
        Exception thrownException;
        try {
            application.validateSObjectFieldLength();
        } catch (Exception ex) {
            thrownException = ex;
        }
        system.assertNotEquals(null, thrownException);
    }

    @isTest
    private static void whenValidateSObjectFieldLengthIsCalledWithExceedingFieldLengthNumberOfEmployeesTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ApplicationDomain domainMock = (ApplicationDomain) mocks.mock(ApplicationDomain.class);
        Application.Domain.setMock((fflib_ISObjectDomain)domainMock);

        Account acc = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            NumberOfEmployees = 1
        );

        for(Integer i = 0; i < 9; i++) {
            acc.NumberOfEmployees = acc.NumberOfEmployees*10;
        }

        List<Account> testAccountList = new List<Account> { acc };

        Map<String,SObjectField> fieldsMap = new Map<String,SObjectField>{
            'NumberOfEmployees' => Account.NumberOfEmployees.getDescribe().getSObjectField()
        };

        mocks.startStubbing();
        mocks.when(domainMock.sObjectType()).thenReturn(Account.SObjectType);
        for(SObjectField field : fieldsMap.values()) {
            mocks.when(domainMock.getRecordsWithNotBlankFieldValues(field)).thenReturn(testAccountList);
        }
        mocks.stopStubbing();
        
        ApplicationDomain application = (ApplicationDomain) Application.Domain.newInstance(testAccountList);
        Exception thrownException;
        try {
            application.validateSObjectFieldLength();
        } catch (Exception ex) {
            thrownException = ex;
        }
        system.assertNotEquals(null, thrownException);
    }

    @isTest
    private static void whenValidateSObjectFieldLengthIsCalledWithDecimalRoomOccupancyTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ApplicationDomain domainMock = (ApplicationDomain) mocks.mock(ApplicationDomain.class);
        Application.Domain.setMock((fflib_ISObjectDomain)domainMock);

        Account acc = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Room_Occupancy__c = 5.1
        );

        List<Account> testAccountList = new List<Account> { acc };

        Map<String,SObjectField> fieldsMap = new Map<String,SObjectField>{
            'Room_Occupancy__c' => Account.Room_Occupancy__c.getDescribe().getSObjectField()
        };

        mocks.startStubbing();
        mocks.when(domainMock.sObjectType()).thenReturn(Account.SObjectType);
        for(SObjectField field : fieldsMap.values()) {
            mocks.when(domainMock.getRecordsWithNotBlankFieldValues(field)).thenReturn(testAccountList);
        }
        mocks.stopStubbing();
        
        ApplicationDomain application = (ApplicationDomain) Application.Domain.newInstance(testAccountList);
        Exception thrownException;
        try {
            application.validateSObjectFieldLength();
        } catch (Exception ex) {
            thrownException = ex;
        }
        system.assertNotEquals(null, thrownException);
    }

    @isTest
    private static void whenValidateSObjectDuplicationRulesIsCalledWithTwoDifferentRecords() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ApplicationDomain domainMock = (ApplicationDomain) mocks.mock(ApplicationDomain.class);
        Application.Domain.setMock((fflib_ISObjectDomain)domainMock);

        mocks.startStubbing();
        mocks.when(domainMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.stopStubbing();

        Account acc = new Account(
            Name = 'test Account',
            Notification_Email__c = 'tes@email.com',
            Account_Status__c = 'ActivePaid',
            Business_Type__c = 'Unknown',
            Customer_id__c = '1234',
            Viewer_id__c = '1234',
            Notification_Language_Code__c = 'en-GB',
            Notification_Country_Code__c = 'DE',
            Account_Manager_Id__c = '005000000000001AAA', 
            Bill_To_Email__c = 'your.email+fakedata77415@gmail.com',
            CAF_approved__c = 'Yes', 
            Contract_signed__c = 'Yes'
        );

        insert acc;

        Account acc2 = new Account(
            Name = 'test Account 2',
            Notification_Email__c = 'tes2@email.com',
            Account_Status__c = 'ActivePaid',
            Business_Type__c = 'Unknown',
            Customer_id__c = '123456',
            Viewer_id__c = '123456',
            Notification_Language_Code__c = 'en-GB',
            Notification_Country_Code__c = 'DE',
            Account_Manager_Id__c = '005000000000001AAA', 
            Bill_To_Email__c = 'your.email+fakedata77415@gmail.com',
            CAF_approved__c = 'Yes', 
            Contract_signed__c = 'Yes'
        );

        List<Account> testAccountList = new List<Account> { acc2 };
        
        mocks.when(domainMock.sObjectType()).thenReturn(Account.SObjectType);
        
        ApplicationDomain application = (ApplicationDomain) Application.Domain.newInstance(testAccountList);
        Exception thrownException;
        try {
            application.validateSObjectDuplicationRules();
        } catch (Exception ex) {
            thrownException = ex;
        }
        system.assertEquals(null, thrownException);
    }

    @isTest
    private static void whenValidateSObjectDuplicationRulesIsCalledWithTwoRecordsWithDuplicatedCustomerID() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ApplicationDomain domainMock = (ApplicationDomain) mocks.mock(ApplicationDomain.class);
        Application.Domain.setMock((fflib_ISObjectDomain)domainMock);

        mocks.startStubbing();
        mocks.when(domainMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.stopStubbing();

        Account acc = new Account(
            Name = 'test Account',
            Notification_Email__c = 'tes@email.com',
            Account_Status__c = 'ActivePaid',
            Business_Type__c = 'Unknown',
            Customer_id__c = '1234',
            Viewer_id__c = '1234',
            Notification_Language_Code__c = 'en-GB',
            Notification_Country_Code__c = 'DE',
            Account_Manager_Id__c = '005000000000001AAA', 
            Bill_To_Email__c = 'your.email+fakedata77415@gmail.com',
            CAF_approved__c = 'Yes', 
            Contract_signed__c = 'Yes'
        );

        insert acc;

        Account acc2 = new Account(
            Name = 'test Account 2',
            Notification_Email__c = 'tes2@email.com',
            Account_Status__c = 'ActivePaid',
            Business_Type__c = 'Unknown',
            Customer_id__c = '1234',
            Viewer_id__c = '123456',
            Notification_Language_Code__c = 'en-GB',
            Notification_Country_Code__c = 'DE',
            Account_Manager_Id__c = '005000000000001AAA', 
            Bill_To_Email__c = 'your.email+fakedata77415@gmail.com',
            CAF_approved__c = 'Yes', 
            Contract_signed__c = 'Yes'
        );

        List<Account> testAccountList = new List<Account> { acc2 };
        
        mocks.when(domainMock.sObjectType()).thenReturn(Account.SObjectType);
        
        ApplicationDomain application = (ApplicationDomain) Application.Domain.newInstance(testAccountList);
        Exception thrownException;
        try {
            application.validateSObjectDuplicationRules();
        } catch (Exception ex) {
            thrownException = ex;
        }
        system.assertNotEquals(null, thrownException);
    }

    @isTest
    static void whenTrackSObjectHistory() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        Application.UnitOfWork.setMock(uowMock);

        // GIVEN
        Account acc1 = TestUtils.createAccount('TestAccount1', 'test@email.com');
        acc1.Id = fflib_IDGenerator.generate(Account.SObjectType);
        Map<Id, Account> accMap = new Map<Id, Account> ();
        accMap.put(acc1.Id, acc1);
        Account acc2 = TestUtils.createAccount('TestAccount2', 'test@email.com');
        acc2.Id = acc1.Id;

        fflib_SObjectDomain.Test.Database.onUpdate(new List<Account> {acc2}, accMap);

        ApplicationDomain applicationDomain = (ApplicationDomain) Application.Domain.newInstance(new List<Account> {acc2});
        applicationDomain.trackSObjectHistory();

        // Then
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    @isTest
    static void whenGetFildSetsMap(){
        ApplicationDomain application = (ApplicationDomain) Application.Domain.newInstance(new List<Account>());
        System.assert(application.getFieldSetMap(AccountDomain.GENERIC_REQUIRED_FIELDS_FIELDSET_NAME).values().contains('Name'));
    }
}