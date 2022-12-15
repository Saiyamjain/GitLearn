@IsTest
private class ResetPasswordControllerTest {
    @IsTest
    static void callingTakeOwnershipOnControllerShouldCallService() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // Given
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);

        AccountService mockService = (AccountService) mocks.mock(AccountService.class);

        Application.Service.setMock(AccountService.class, mockService);

        // When
        LightningResult result = ResetPasswordController.resetPassword(accountId);

        // Then
        ((AccountService) mocks.verify(mockService, 1)).resetPassword(new Set<Id>{accountId});

        System.assertEquals(null, result.error);
    }

    @IsTest
    static void callingTakeOwnershipOnControllerWhenExceptionShouldReturnException() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // Given
        mocks.startStubbing();
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Set<Id> testAccountIds = new Set<Id>{accountId};

        AccountService mockService = (AccountService) mocks.mock(AccountService.class);
        ((AccountService) mocks.doThrowWhen(new List<Exception> {new Application.ApplicationException('Some exception')}, mockService)).resetPassword(testAccountIds);
        mocks.stopStubbing();
        Application.Service.setMock(AccountService.class, mockService);

        // When
        LightningResult result = ResetPasswordController.resetPassword(accountId);

        // Then
        ((AccountService) mocks.verify(mockService, 1)).resetPassword(testAccountIds);

        System.assert(result.error != null);
        System.assertEquals('Some exception', result.error.getMessage());
    }

    @IsTest
    static void callingTakeOwnershipOnControllerShouldReturnMissingArgumentError() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // When
        LightningResult result = ResetPasswordController.resetPassword(null);

        // Then
        System.assertEquals(LightningResult.MsgVariant.ERROR.name(), result.msg.variant);
    }
}