@IsTest(IsParallel=true)
private class DAZNBillingAccountDomainTest {
    @isTest
    public static void testUpdatePaymentTerm() {
        TestUtils.createAccount('test acc','test@test.com');

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        AccountSelector accSelectorMock = (AccountSelector) mocks.mock(AccountSelector.class);
        DAZNPaymentTermSelector selectorMock = (DAZNPaymentTermSelector) mocks.mock(DAZNPaymentTermSelector.class);

        // Given
        Account accountRecord = TestUtils.createAccount('TestAcc','test@mail.com');
        PaymentTerm__c paymentTermRecord = new PaymentTerm__c(Name = 'Test', Business_Type__c = 'Other');
        Test.startTest();
        insert accountRecord;

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(PaymentTerm__c.SObjectType);
        mocks.when(selectorMock.selectPaymentTermByBusinessType(new Set<String> {paymentTermRecord.Business_Type__c})).thenReturn(new List<PaymentTerm__c> {paymentTermRecord});
        mocks.when(accSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accSelectorMock.selectById(new Set<Id> {accountRecord.Id})).thenReturn(new List<Account> {accountRecord});
        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.Selector.setMock(accSelectorMock);
        Application.UnitOfWork.setMock(uowMock);

        // When

        CustomerAccount__c customerAccount = new CustomerAccount__c(Account__c = accountRecord.Id);
        insert customerAccount;
        Test.stopTest();

        // Then
        ((DAZNPaymentTermSelector) mocks.verify(selectorMock)).selectPaymentTermByBusinessType(new Set<String> {paymentTermRecord.Business_Type__c});
        ((AccountSelector) mocks.verify(accSelectorMock)).selectById(new Set<Id> {accountRecord.Id});
    }
}