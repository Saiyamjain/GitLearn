trigger EventParserTrigger on Event_Parser__e (after insert) {
    fflib_SObjectDomain.triggerHandler(EventParserDomain.class);
}