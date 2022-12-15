trigger AgentWorkTrigger on AgentWork (after delete, after insert, after update, before delete, before insert, before update) {
    fflib_SObjectDomain.triggerHandler(AgentWorkDomain.class);
}