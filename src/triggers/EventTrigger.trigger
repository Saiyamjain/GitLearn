trigger EventTrigger on Event__c (after insert) {
    fflib_SObjectDomain.triggerHandler(EventDomain.class);
}