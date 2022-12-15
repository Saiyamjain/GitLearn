public with sharing class ManageSubscriptionController {
    @AuraEnabled(cacheable=true)
    public static LightningResult getActiveSubscriptionByAccountId(Id accountId) {
        try {
            if (String.isBlank(accountId)) {
                return LightningResult.addErrorMsg(Label.Missing_Argument);
            }
            List<Subscription__c> activeSubscriptions = SubscriptionSelector.newInstance().getActiveSubscriptionsByAccountId(new Set<Id>{accountId});
            if (activeSubscriptions.isEmpty()) {
                return LightningResult.addErrorMsg(Label.SubscriptionServiceErrorMessageNoActiveSubscriptions);
            }
            return LightningResult.setResult(activeSubscriptions[0]);
        } catch (Exception e) {
            LightningResult.setError(e);
            LoggerService.logException(e)
                    .setClassName('ManageSubscriptionController')
                    .setMethodName('getActiveSubscriptionByAccountId')
                    .doInsertFutureExceptionLog();
        }
        return LightningResult.getInstance();
    }
}