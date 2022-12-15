public inherited sharing class EventSelector extends fflib_SObjectSelector {
    public static EventSelector newInstance() {
        return (EventSelector) Application.Selector.newInstance(Event__c.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                Event__c.Status__c,
                Event__c.Name,
                Event__c.Record_Type__c,
                Event__c.Type__c,
                Event__c.Related_Record_Id__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Event__c.SObjectType;
    }

    public List<Event__c> selectById(Set<Id> idSet) {
        return (List<Event__c>) selectSObjectsById(idSet);
    }

    public List<Event__c> selectByRelatedRecordId(Set<Id> relatedRecordIdSet, String eventType) {
        return Database.query(
                newQueryFactory()
                        .setCondition('Related_Record_Id__c IN :relatedRecordIdSet AND Type__c = :eventType')
                        .toSOQL()
        );
    }

    public List<Event__c> selectByNameAndType(Set<String> nameSet, EventDomain.EventType eType) {
        return Database.query(
                newQueryFactory()
                        .setCondition('Name IN :nameSet AND Type__c = \'' + eType.name() + '\'')
                        .toSOQL()
        );
    }
}