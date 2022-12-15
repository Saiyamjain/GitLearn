@IsTest(IsParallel=true)
private class CalloutDetailsSelectorTest {

    @IsTest
    private static void itShouldReturnResetPasswordCalloutDetails() {

        // When
        Callout_Details__mdt calloutDetails = 
            CalloutDetailsSelector.newInstance().selectByDeveloperName(RestCalloutService.CALLOUT_DETAILS_RESET_PASSWORD_NAME);

        // Then
        System.assert(calloutDetails.DEV__c.contains('https://cdn.dev.business.dazn.com/authentication/euc1/v1/password/reset'));
    }

}