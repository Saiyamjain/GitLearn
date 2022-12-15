trigger DAZNSubscriptionProductChargeTrigger on SubscriptionProductCharge__c (before insert, after insert) {
    fflib_SObjectDomain.triggerHandler(DAZNSubscriptionProductChargeDomain.class);
}