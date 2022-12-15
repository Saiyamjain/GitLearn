@IsTest(IsParallel=true)
private class SubscriptionControllerTest {
    
    @IsTest
    private static void itShouldThrowExceptionWhenCancellationMethodsAreCalled() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SubscriptionService subscriptionServiceMock = (SubscriptionService) mocks.mock(SubscriptionService.class);

        // Given
        mocks.startStubbing();
        ((SubscriptionService) mocks.doThrowWhen(new list<fflib_ApexMocks.ApexMocksException> {
            new fflib_ApexMocks.ApexMocksException(Label.UnexpectedErrorException)}, 
        subscriptionServiceMock)).handleSoftCancellation(null);
        ((SubscriptionService) mocks.doThrowWhen(new list<fflib_ApexMocks.ApexMocksException> {
            new fflib_ApexMocks.ApexMocksException(Label.UnexpectedErrorException)}, 
        subscriptionServiceMock)).handleUndoSoftCancellation(null);
        ((SubscriptionService) mocks.doThrowWhen(new list<fflib_ApexMocks.ApexMocksException> {
            new fflib_ApexMocks.ApexMocksException(Label.UnexpectedErrorException)}, 
        subscriptionServiceMock)).handleHardCancellation(null);
        mocks.stopStubbing();
        Application.Service.setMock(SubscriptionService.class, subscriptionServiceMock);

        // When
        try {
            SubscriptionController.handleSoftCancellation(null);
        } catch (Exception error) {
            System.assertEquals(Label.UnexpectedErrorException, error.getMessage());
        } finally {
            try {
                SubscriptionController.handleHardCancellation(null);
            } catch (Exception error) {
                System.assertEquals(Label.UnexpectedErrorException, error.getMessage());
            } finally {
                try {
                    SubscriptionController.handleUndoSoftCancellation(null);
                } catch (Exception error) {
                    System.assertEquals(Label.UnexpectedErrorException, error.getMessage());
                }
            }
        }

        // Then
        ((SubscriptionService) mocks.verify(subscriptionServiceMock, 1))
            .handleSoftCancellation(null);
        ((SubscriptionService) mocks.verify(subscriptionServiceMock, 1))
            .handleUndoSoftCancellation(null);
        ((SubscriptionService) mocks.verify(subscriptionServiceMock, 1))
            .handleHardCancellation(null);
    }

    @IsTest
    private static void itShouldThrowExceptionWhenGetactiveSubscriptionIsCalled() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SubscriptionService subscriptionServiceMock = (SubscriptionService) mocks.mock(SubscriptionService.class);

        // Given
        mocks.startStubbing();
        ((SubscriptionService) mocks.doThrowWhen(new list<fflib_ApexMocks.ApexMocksException> {
            new fflib_ApexMocks.ApexMocksException(Label.NoActiveSubscriptionFoundException)}, 
        subscriptionServiceMock)).selectActiveSubscriptionByCustomerId(null);
        mocks.stopStubbing();
        Application.Service.setMock(SubscriptionService.class, subscriptionServiceMock);

        // When
        try {
            SubscriptionController.getActiveSubscriptionByCustomerId(null);
        } catch (Exception error) {
            System.assertEquals(Label.NoActiveSubscriptionFoundException, error.getMessage());
        } 

        // Then
        ((SubscriptionService) mocks.verify(subscriptionServiceMock, 1))
            .selectActiveSubscriptionByCustomerId(null);
    }

}