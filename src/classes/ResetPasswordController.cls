public with sharing class ResetPasswordController {
    @AuraEnabled
    public static LightningResult resetPassword(String accountId) {
        if (String.isBlank(accountId)) {
            return LightningResult.addErrorMsg(Label.Missing_Argument);
        }

        try {
            AccountService.newInstance().resetPassword(new Set<Id> {accountId});
        } catch(Exception e) {
            LoggerService.logException(e)
                .setClassName('ResetPasswordController')
                .setMethodName('resetPasswordCallout')
                .doInsertExceptionLog();
            LightningResult.setError(e);
        }
        return LightningResult.getInstance();
    }
}