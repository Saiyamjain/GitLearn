trigger LeadTrigger on Lead (after delete, after insert, after update, before delete, before insert, before update) {
    fflib_SObjectDomain.triggerHandler(LeadDomain.class);
}