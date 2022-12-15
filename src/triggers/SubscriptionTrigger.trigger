trigger SubscriptionTrigger on Subscription__c (before insert, before update, after insert, after update ) {
    fflib_SObjectDomain.triggerHandler(SubscriptionDomain.class);
}