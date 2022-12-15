public inherited sharing class BotDialogInstanceSelector extends fflib_SObjectSelector {
    public static BotDialogInstanceSelector newInstance() {
        return (BotDialogInstanceSelector) Application.Selector.newInstance(Bot_Dialog_Instance__c.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                Bot_Dialog_Instance__c.Name,
                Bot_Dialog_Instance__c.Dialog_Name__c,
                Bot_Dialog_Instance__c.Goal_Name__c,
                Bot_Dialog_Instance__c.Type__c,
                Bot_Dialog_Instance__c.Status__c,
                Bot_Dialog_Instance__c.CreatedDate,
                Bot_Dialog_Instance__c.Last_Customer_Input__c,
                Bot_Dialog_Instance__c.Chat_Transcript__c,
                Bot_Dialog_Instance__c.Rating__c,
                Bot_Dialog_Instance__c.Last_Step__c,
                Bot_Dialog_Instance__c.CreatedDate
        };
    }

    public List<Bot_Dialog_Instance__c> selectById(Set<Id> idSet) {
        return (List<Bot_Dialog_Instance__c>) selectSObjectsById(idSet);
    }

    public List<Bot_Dialog_Instance__c> selectByTranscriptId(Set<Id> transcriptIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Chat_Transcript__c IN :transcriptIds AND RecordType.Name = \'Dialog\'');
        query.addOrdering(new fflib_QueryFactory.Ordering('Bot_Dialog_Instance__c', 'Id', fflib_QueryFactory.SortOrder.DESCENDING));
        return (List<Bot_Dialog_Instance__c>) Database.query(query.toSOQL());
    }

    public List<Bot_Dialog_Instance__c> selectByTranscriptIdAndDialogName(Set<Id> transcriptIds, Set<String> dialogNames) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Chat_Transcript__c IN :transcriptIds AND Dialog_Name__c IN :dialogNames AND Status__c <> \'Completed\'');
        return (List<Bot_Dialog_Instance__c>) Database.query(query.toSOQL());
    }

    public Schema.SObjectType getSObjectType() {
        return Bot_Dialog_Instance__c.SObjectType;
    }
}