trigger LiveChatTranscriptTrigger on LiveChatTranscript (after delete, after insert, before delete, before insert, before update, after update) {
    fflib_SObjectDomain.triggerHandler(LiveChatTranscriptDomain.class);
    // Note : AfterUpdate behaviour must include disableTriggerCRUDSecurity in the domain class for guest site user
    // via chatbot for below exception
    // fflib_SObjectDomain.DomainException: Permission to update an LiveChatTranscript denied.
}