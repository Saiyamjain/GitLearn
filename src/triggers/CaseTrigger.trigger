trigger CaseTrigger on Case (after insert, after update, before insert, before update) {
    fflib_SObjectDomain.triggerHandler(CaseDomain.class);
}