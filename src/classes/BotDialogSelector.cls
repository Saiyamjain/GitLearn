public inherited sharing class BotDialogSelector extends fflib_SObjectSelector {
    public static BotDialogSelector newInstance() {
        return (BotDialogSelector) Application.Selector.newInstance(Bot_Dialog__c.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                Bot_Dialog__c.Dialog_Name__c,
                Bot_Dialog__c.Goal_Name__c,
                Bot_Dialog__c.Type__c,
                Bot_Dialog__c.Bot_Name__c
        };
    }

    public List<Bot_Dialog__c> selectById(Set<Id> idSet) {
        return (List<Bot_Dialog__c>) selectSObjectsById(idSet);
    }

    public List<Bot_Dialog__c> selectByDialogName(Set<String> dialogNames) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Dialog_Name__c IN :dialogNames');
        return (List<Bot_Dialog__c>) Database.query(query.toSOQL());
    }

    public Schema.SObjectType getSObjectType() {
        return Bot_Dialog__c.SObjectType;
    }

}