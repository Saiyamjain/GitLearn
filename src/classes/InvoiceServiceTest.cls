@IsTest(IsParallel=true)
private class InvoiceServiceTest {
    @IsTest
    static void successfullyDownloadInvoice() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);

        RestCalloutService restCalloutServiceMock = (RestCalloutService) mocks.mock(RestCalloutService.class);

        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/pdf');
        response.setStatusCode(200);

        // Given
        mocks.startStubbing();
        mocks.when(restCalloutServiceMock.get()).thenReturn(null);
        mocks.stopStubbing();

        Application.UnitOfWork.setMock(uowMock);
        Application.Service.setMock(RestCalloutService.class, restCalloutServiceMock);

        // When
        LightningResult lr = InvoiceService.newInstance().downloadInvoice(
                fflib_IDGenerator.generate(Customer_Transaction__c.SObjectType),
                '12345',
                '123'
        );
    }
}