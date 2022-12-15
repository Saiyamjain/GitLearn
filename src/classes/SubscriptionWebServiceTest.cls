@IsTest(IsParallel=true)
private class SubscriptionWebServiceTest {
    @IsTest
    static void shouldManageSubscriptionSuccessfully() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

        DAZNBillingAccountSelector selectorMock = (DAZNBillingAccountSelector) mocks.mock(DAZNBillingAccountSelector.class);

        SubscriptionWebService.SubscriptionRequest subscriptionRequest = new SubscriptionWebService.SubscriptionRequest();
        subscriptionRequest.CustomerId = '41f06a74435a4f2daa24a1be9515660d';
        subscriptionRequest.BillingAccount = new CustomerAccount__c(Batch__c = 'Test');

        String requestBody = '{\n\t\"' +
                'CustomerId\": \"41f06a74435a4f2daa24a1be9515660d\",' +
                '\n\t\"CurrencyIsoCode\": \"EUR\",\n    ' +
                '\"BillingAccount\": {\n\t\t\"Batch__c\": \"Batch1\",\n\t\t\"BillCycleDay__c\": \"1st of the month\"\n    },' +
                '\n\t\"Subscription\": {\n\t\t\"AutoRenew__c\": true,\n\t\t\"CancelledDate__c\": \"2022-04-02\",\n\t\t\"ContractAcceptanceDate__c\": \"2022-04-02\",' +
                '\n\t\t\"TermSettingType__c\": \"TERMED\",\n\t\t\"TermStartDate__c\": \"2022-04-02\",\n\t\t\"SubPromoCode__c\": \"199OKTSPEZIAL\"\n\t},' +
                '\n\t\"SubscriptionProductCharges\": [{\n\t\t\"ProductRatePlanChargeId__c\": \"8adc8ea17bacc95a017bc155315a351f\",\n\t\t\"RatePlanId__c\": \"8adc8ea17bacc95a017bc155315a351f\",' +
                '\n\t\t\"UpToPeriodsType__c\": \"Billing Periods\",\n\t\t\"UsageRecordRatingOption__c\": \"EndOfBillingPeriod\"\n\t}],' +
                '\n\t\"PaymentMethod\": [{\n\t\t\t\"DefaultPaymentMethod__c\": true,\n\t\t\t\"Zuora__Second_Token_ID__c\": \"5862564145\",' +
                '\n\t\t\t\"Type__c\": \"CreditCardReferenceTransaction\"\n\t\t},\n\t\t{\n\t\t\t\"DefaultPaymentMethod__c\": false,' +
                '\n\t\t\t\"Zuora__Second_Token_ID__c\": \"9955824035\",\n\t\t\t\"Type__c\": \"CreditCardReferenceTransaction\"\n\t\t}\n\t]\n}';

        List<ProductRatePlan__c> productList = new List<ProductRatePlan__c> {new ProductRatePlan__c(Id = fflib_IDGenerator.generate(ProductRatePlan__c.SObjectType), Product__c = fflib_IDGenerator.generate(Product__c.SObjectType))};
        setRestRequest('/subscription/v1.0/', 'POST', requestBody);


        // Given
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(CustomerAccount__c.SObjectType);
        mocks.when(selectorMock.selectBillingAccountByExternalId(new Set<String>{'41f06a74435a4f2daa24a1be9515660d'})).thenReturn(new List<CustomerAccount__c>{subscriptionRequest.BillingAccount});
        mocks.stopStubbing();

        Application.UnitOfWork.setMock(uowMock);
        Application.Selector.setMock(selectorMock);

        // When
        SubscriptionWebService.manageSubscriptions();

        // Then
        ((DAZNBillingAccountSelector) mocks.verify(selectorMock, 1)).selectBillingAccountByExternalId(new Set<String>{'41f06a74435a4f2daa24a1be9515660d'});
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 2)).commitWork();
    }

    @IsTest
    static void shouldHandleDataWithoutExternalId() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

        DAZNBillingAccountSelector selectorMock = (DAZNBillingAccountSelector) mocks.mock(DAZNBillingAccountSelector.class);

        String requestBody = '{\n\t\"' +
                'CustomerId\": \"\",\n\t\"CurrencyIsoCode\": \"EUR\",\n    ' +
                '\"BillingAccount\": {\n\t\t\"Batch__c\": \"Batch1\",\n\t\t\"BillCycleDay__c\": \"1st of the month\"\n    },' +
                '\n\t\"Subscription\": {\n\t\t\"AutoRenew__c\": true,\n\t\t\"CancelledDate__c\": \"2022-04-02\",\n\t\t\"ContractAcceptanceDate__c\": \"2022-04-02\",' +
                '\n\t\t\"TermSettingType__c\": \"TERMED\",\n\t\t\"TermStartDate__c\": \"2022-04-02\",\n\t\t\"SubPromoCode__c\": \"199OKTSPEZIAL\"\n\t},' +
                '\n\t\"SubscriptionProductCharges\": [{\n\t\t\"Name\": \"Subscription fee\",\n\t\t\"BillCycleType__c\": \"SubscriptionStartDay\",' +
                '\n\t\t\"UpToPeriodsType__c\": \"Billing Periods\",\n\t\t\"UsageRecordRatingOption__c\": \"EndOfBillingPeriod\"\n\t}],' +
                '\n\t\"PaymentMethod\": [{\n\t\t\t\"DefaultPaymentMethod__c\": true,\n\t\t\t\"Zuora__Second_Token_ID__c\": \"5862564145\",' +
                '\n\t\t\t\"Type__c\": \"CreditCardReferenceTransaction\"\n\t\t},\n\t\t{\n\t\t\t\"DefaultPaymentMethod__c\": false,' +
                '\n\t\t\t\"Zuora__Second_Token_ID__c\": \"9955824035\",\n\t\t\t\"Type__c\": \"CreditCardReferenceTransaction\"\n\t\t}\n\t]\n}';

        setRestRequest('/subscription/v1.0/', 'POST', String.valueOf(requestBody));

        // Given
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(CustomerAccount__c.SObjectType);
        mocks.when(selectorMock.selectBillingAccountByExternalId(new Set<String>{'41f06a74435a4f2daa24a1be9515660d'})).thenThrow(new fflib_Application.DeveloperException());
        mocks.stopStubbing();

        Application.UnitOfWork.setMock(uowMock);
        Application.Selector.setMock(selectorMock);

        // When
        Api.Response response = SubscriptionWebService.manageSubscriptions();

        // Then
        System.assertEquals(response.status, 400);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 0)).commitWork();
    }

    @IsTest
    static void shouldManageSubscriptionHandleException() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

        DaznBillingAccountSelector selectorMock = (DaznBillingAccountSelector) mocks.mock(DaznBillingAccountSelector.class);

        String requestBody = '{\n\t\"' +
                'CustomerId\": \"41f06a74435a4f2daa24a1be9515660d\",\n\t\"CurrencyIsoCode\": \"EUR\",\n    ' +
                '\"BillingAccount\": {\n\t\t\"Batch__c\": \"Batch1\",\n\t\t\"BillCycleDay__c\": \"1st of the month\"\n    },' +
                '\n\t\"Subscription\": {\n\t\t\"AutoRenew__c\": true,\n\t\t\"CancelledDate__c\": \"2022-04-02\",\n\t\t\"ContractAcceptanceDate__c\": \"2022-04-02\",' +
                '\n\t\t\"TermSettingType__c\": \"TERMED\",\n\t\t\"TermStartDate__c\": \"2022-04-02\",\n\t\t\"SubPromoCode__c\": \"199OKTSPEZIAL\"\n\t},' +
                '\n\t\"SubscriptionProductCharges\": [{\n\t\t\"Name\": \"Subscription fee\",\n\t\t\"BillCycleType__c\": \"SubscriptionStartDay\",' +
                '\n\t\t\"UpToPeriodsType__c\": \"Billing Periods\",\n\t\t\"UsageRecordRatingOption__c\": \"EndOfBillingPeriod\"\n\t}],' +
                '\n\t\"PaymentMethod\": [{\n\t\t\t\"DefaultPaymentMethod__c\": true,\n\t\t\t\"Zuora__Second_Token_ID__c\": \"5862564145\",' +
                '\n\t\t\t\"Type__c\": \"CreditCardReferenceTransaction\"\n\t\t},\n\t\t{\n\t\t\t\"DefaultPaymentMethod__c\": false,' +
                '\n\t\t\t\"Zuora__Second_Token_ID__c\": \"9955824035\",\n\t\t\t\"Type__c\": \"CreditCardReferenceTransaction\"\n\t\t}\n\t]\n}';

        setRestRequest('/subscription/v1.0/', 'POST', String.valueOf(requestBody));

        // Given
        mocks.startStubbing();

        mocks.when(selectorMock.sObjectType()).thenReturn(CustomerAccount__c.SObjectType);
        mocks.when(selectorMock.selectBillingAccountByExternalId(new Set<String>{'41f06a74435a4f2daa24a1be9515660d'})).thenThrow(new fflib_Application.DeveloperException());
        mocks.stopStubbing();

        Application.UnitOfWork.setMock(uowMock);
        Application.Selector.setMock(selectorMock);

        // When
        SubscriptionWebService.manageSubscriptions();

        // Then
        ((DAZNBillingAccountSelector) mocks.verify(selectorMock, 1)).selectBillingAccountByExternalId(new Set<String>{'41f06a74435a4f2daa24a1be9515660d'});
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 0)).commitWork();
    }

    private static void setRestRequest(String uriString, String method, String requestBody) {
        RestRequest restRequest= new RestRequest();
        RestResponse restResponse = new RestResponse();
        restRequest.addHeader('content-type','application/json');
        restRequest.requestURI = uriString;
        restRequest.httpMethod = method;
        restRequest.requestBody = Blob.valueOf(requestBody);
        RestContext.request = restRequest;
        RestContext.response = restResponse;
    }
}