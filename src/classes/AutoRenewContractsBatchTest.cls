@IsTest(IsParallel=false) // In parallel Apex tests, DML operations aren't permitted on this type of object: CronJobDetail, hence why it is set to FALSE 
private class AutoRenewContractsBatchTest {

    @IsTest
    private static void itShouldHandleExceptionFromSubscriptionService() {
        // Given
        AutoRenewContractsBatch autoRenewBatch = new AutoRenewContractsBatch('/TEST/ Auto Renew Contracts Batch Job');

        // Given
        Subscription__c subscriptionRecord = TestUtils.createSubscriptionRecord();
        fflib_SObjectDomain.getTriggerEvent(SubscriptionDomain.class).disableAll(); 
        insert subscriptionRecord;

        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SubscriptionSelector subscriptionSelectorMock = 
            (SubscriptionSelector) mocks.mock(SubscriptionSelector.class);
        SubscriptionService subscriptionServiceMock = 
            (SubscriptionService) mocks.mock(SubscriptionService.class);
        LoggerService logServiceMock = 
            (LoggerService) mocks.mock(LoggerService.class);

        // Given
        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.sObjectType()).thenReturn(Subscription__c.SObjectType);
        mocks.when(subscriptionSelectorMock.queryLocatorForAutoRenewal()).thenReturn(
            Database.getQueryLocator([SELECT Id FROM Subscription__c WHERE Id =: subscriptionRecord.Id]));
        mocks.when(subscriptionServiceMock.autoRenew((List<Subscription__c>)fflib_Match.anyList()))
            .thenThrow(new fflib_ApexMocks.ApexMocksException(Label.UnexpectedErrorException));
        mocks.when(logServiceMock.logException()).thenReturn(logServiceMock);
        mocks.when(logServiceMock.setRunningUser(fflib_Match.anyId())).thenReturn(logServiceMock);
        mocks.when(logServiceMock.setExceptionMessage(fflib_Match.anyString())).thenReturn(logServiceMock);
        mocks.when(logServiceMock.setTypeName(fflib_Match.anyString())).thenReturn(logServiceMock);
        mocks.when(logServiceMock.setStackTrace(fflib_Match.anyString())).thenReturn(logServiceMock);
        mocks.when(logServiceMock.setClassName(fflib_Match.anyString())).thenReturn(logServiceMock);
        mocks.when(logServiceMock.setMethodName(fflib_Match.anyString())).thenReturn(logServiceMock);
        mocks.when(logServiceMock.doInsertExceptionLog()).thenReturn(logServiceMock);
        mocks.stopStubbing();
        Application.Selector.setMock(subscriptionSelectorMock);
        Application.Service.setMock(SubscriptionService.class, subscriptionServiceMock);
        Application.Service.setMock(LoggerService.class, logServiceMock);

        // // When
        try {
            Test.startTest();		
            Database.executeBatch(autoRenewBatch);
            Test.stopTest();	
        }
        
        // Then
        catch (Exception error) {
            System.assertEquals(error.getMessage(),Label.UnexpectedErrorException);
        }

        // Then
        ((LoggerService) mocks.verify(logServiceMock, 1)).logException();
        ((SubscriptionSelector) mocks.verify(subscriptionSelectorMock, 1)).queryLocatorForAutoRenewal();
        ((SubscriptionService)mocks.verify(subscriptionServiceMock,mocks.times(1)
            .description('Auto renew should be called once')))
            .autoRenew(fflib_Match.sObjectsWith(
                new List<Map<SObjectField,Object>> {
                    new Map<SObjectField,Object> {
                        Subscription__c.Id => subscriptionRecord.Id
                    }
                }
        )); 
    }

    @IsTest
    private static void itShouldScheduleAutoRenewBatch() {
        // When
        Test.startTest();
        AutoRenewContractsBatch.schedule(new AutoRenewContractsBatch('/TEST/ Auto Renew Contracts Batch Job'));
        Test.stopTest();

        // Then
        System.assertEquals(1, [SELECT COUNT() FROM CronTrigger
            WHERE CronJobDetail.Name = '/TEST/ Auto Renew Contracts Batch Job'],
            'Auto renew contracts batch job should be scheduled');
    }

}