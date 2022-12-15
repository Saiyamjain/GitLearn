public with sharing class AutoRenewContractsBatch implements Database.Batchable<SObject>, Schedulable {
    private String batchJobName = 'Auto Renew Contracts Batch Job';

    public AutoRenewContractsBatch() {}

    public AutoRenewContractsBatch(String batchJobName) {
        this.batchJobName = batchJobName;
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return SubscriptionSelector.newInstance().queryLocatorForAutoRenewal();
    }
       
    public void execute(SchedulableContext SchedulableContext) {
        Database.executeBatch(this, 200);
    }

    public void execute(Database.BatchableContext batchableContext, List<Subscription__c> subscriptions) {
        try {
            SubscriptionService.newInstance().autoRenew(subscriptions);
        } catch(Exception error) {
            LoggerService.newInstance().logException()
                .setRunningUser(UserInfo.getUserId())
                .setExceptionMessage(error.getMessage())
                .setTypeName(error.getTypeName())
                .setStackTrace(error.getStackTraceString())
                .setClassName('SubscriptionService')
                .setMethodName('autoRenew')
                .doInsertExceptionLog();
            throw error;
        }
    }

    public static void schedule(AutoRenewContractsBatch autoRenewBatch) {
        String cronExpression = '1 0 0 * * ?';
        System.schedule(autoRenewBatch.batchJobName, cronExpression, autoRenewBatch);
    }

    public static void schedule() {
        schedule(new AutoRenewContractsBatch());
    }
    
    public void finish(Database.BatchableContext batchableContext) { }

}