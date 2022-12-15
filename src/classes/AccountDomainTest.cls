@IsTest
public with sharing class AccountDomainTest {

    @IsTest
    static void changingStatusUpdatesPreviousStatusFieldTest() {
        Account account = new Account(Name = 'some kind of test', Customer_Id__c = '3214', Business_Type__c = 'Unknown', Notification_Country_Code__c = 'DE', Notification_Language_Code__c = 'de-DE',
                Account_Status__c = 'ActivePaid', Account_Manager_Id__c = '005000000000001AAA', Bill_To_Email__c = 'your.email+fakedata77415@gmail.com', CAF_approved__c = 'Yes', Contract_signed__c = 'Yes');
        insert account;

        account.Account_Status__c = 'ActiveGrace';
        update account;

        System.assertEquals('ActivePaid', [SELECT Account_Status__c, Previous_Status__c FROM Account WHERE Id = :account.Id].Previous_Status__c);
    }

    // @isTest
    // public static void testAccountWithoutEventInsert() {
    //     TestUtils.createAndInsertAccount('test acc','test@test.com');
    //     List<Account> accountsList = [SELECT Id, RecordTypeId FROM Account];

    //     System.assertEquals(1, accountsList.size());
    //     System.assertEquals(TestUtils.getDefaultRecordType(Account.SObjectType), accountsList.get(0).RecordTypeId);
    // }

    @isTest
    public static void testAccountWithEventInsert() {
        Event__c testEvent = new Event__c (
            Name = 'eb32e69e28984400b31d5a2abd075d74',
            Status__c = 'Validated',
            Record_Type__c = 'Independent_Ecommerce',
            Type__c = 'CustomerCreated'
        );

        insert testEvent;

        TestUtils.createAndInsertAccount('test acc','test@test.com');
        List<Account> accountsList = [SELECT Id, RecordType.DeveloperName FROM Account];

        System.assertEquals(1, accountsList.size());
        System.assertEquals(AccountService.INDEPENDENT_ECOMMERCE_RECORD_TYPE_NAME, accountsList.get(0).RecordType.DeveloperName);
    }

    // TODO - Jens - 18/7/2022 - This test needs to be refactored, should use data creation method from TestUtils instead
    // @IsTest
    // private static void whenValidateRequiredSObjectFieldsForExternalIsCalledWithAllRequiredFieldsForCreated() {
    //     fflib_ApexMocks mocks = new fflib_ApexMocks();
    //     ApplicationDomain domainMock = (ApplicationDomain) mocks.mock(ApplicationDomain.class);
    //     Application.Domain.setMock((fflib_ISObjectDomain)domainMock);

    //     mocks.startStubbing();
    //     mocks.when(domainMock.sObjectType()).thenReturn(Account.SObjectType);
    //     mocks.stopStubbing();

    //     Account acc = new Account(
    //         Id = fflib_IDGenerator.generate(Account.SObjectType),
    //         Name = 'test Account',
    //         Notification_Email__c = 'tes@email.com',
    //         Account_Status__c = 'ActivePaid',
    //         Business_Type__c = 'Other',
    //         Customer_id__c = '1234',
    //         Viewer_id__c = '1234',
    //         Notification_Language_Code__c = 'en-GB',
    //         Notification_Country_Code__c = 'JP',
    //         Venue_Address_Street__c = 'Street',
    //         Venue_Address_City__c = 'City',
    //         Venue_Address_Post_Code__c = '12312',
    //         Venue_Address_Country__c = 'JP',
    //         Content_Digest__c = true,
    //         Venue_Address_State_Province__c = 'Utrecht'
    //     );
    //     List<Account> testAccountList = new List<Account> { acc };


    //     String requestBodyMock = [SELECT Id, Body FROM StaticResource WHERE Name = 'dummyIndependentEcommercePayload' LIMIT 1].Body.toString();
    //     EventService.EventServiceWrapper esw = new EventService.EventServiceWrapper();
    //     esw.payload = (EventDomain.CustomerPayload) Json.deserialize(requestBodyMock, EventDomain.CustomerPayload.class);
    //     ((EventDomain.CustomerPayload)esw.payload).customerData.account = acc;
    //     esw.event = new Event__c(
    //         Type__c = EventDomain.EventType.CUSTOMERCREATED.name()
    //     );

    //     ApplicationDomain application = (ApplicationDomain) Application.Domain.newInstance(testAccountList);
    //     Exception thrownException;
    //     try {
    //         application.validateRequiredSObjectFieldsForExternal(esw);
    //     } catch (Exception ex) {
    //         thrownException = ex;
    //     }
    //     system.assertEquals(null, thrownException);
    // }

    @IsTest
    private static void itShouldGetPicklistEntries() {
        Set<String> entries = new Set<String>();
        try {
            entries.addAll(AccountDomain.newInstance(new List<Account>())
                .getPicklistEntries(
                    Schema.Account.Account_Status__c,
                    AccountService.INDEPENDENT_ECOMMERCE_RECORD_TYPE_NAME
            ));
            System.assert(entries.contains('activepaid'),'should contain activepaid.');
        } catch (Exception ex) {
            System.assert(false, 'should not get here.');
        }
    }

}