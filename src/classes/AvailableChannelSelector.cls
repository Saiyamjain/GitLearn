public inherited sharing class AvailableChannelSelector extends fflib_SObjectSelector {
    public static AvailableChannelSelector newInstance() {
        return (AvailableChannelSelector) Application.Selector.newInstance(Available_Channel__c.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            Available_Channel__c.Id,
            Available_Channel__c.View__c
        };
     }

    public Schema.SObjectType getSObjectType() {
        return Available_Channel__c.SObjectType;
    }

    public List<Available_Channel__c> selectById(Set<Id> idSet){
        return (List<Available_Channel__c>) selectSObjectsById(idSet);
    }

    public List<Available_Channel__c> selectActiveBySubTypeIdOrName(Set<Id> idSet, Set<String> nameSet){
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Is_Active__c = true AND (ContactUs_SubType2__c IN :idSet OR ContactUs_SubType2__r.Name IN :nameSet)');
        return (List<Available_Channel__c>) Database.query(query.toSOQL());
    }
}