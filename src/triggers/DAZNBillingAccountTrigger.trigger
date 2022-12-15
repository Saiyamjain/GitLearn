trigger DAZNBillingAccountTrigger on CustomerAccount__c (before insert, before update) {
    fflib_SObjectDomain.triggerHandler(DAZNBillingAccountDomain.class);
}