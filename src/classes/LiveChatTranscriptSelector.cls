public inherited sharing class LiveChatTranscriptSelector extends fflib_SObjectSelector {
    public static LiveChatTranscriptSelector newInstance() {
        return (LiveChatTranscriptSelector) Application.Selector.newInstance(LiveChatTranscript.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            LiveChatTranscript.Id,
            LiveChatTranscript.AccountId,
            LiveChatTranscript.CaseId,
            LiveChatTranscript.Bot_First_Owner_Id__c,
            LiveChatTranscript.Bot_Name__c,
            LiveChatTranscript.Latest_Dialog_For_Categorisation__c,
            LiveChatTranscript.OwnerId,
            LiveChatTranscript.Skills__c,
            LiveChatTranscript.Agent_Transfer_Time__c,
            LiveChatTranscript.Agent_End_Time__c,
            LiveChatTranscript.External_Id__c
        };
    }

    public List<LiveChatTranscript> selectById(Set<Id> idSet) {
        return Database.query(
            newQueryFactory(false, false, true)
                .setCondition('Id In :idSet')
                .toSOQL()
        );
    }

    public List<LiveChatTranscript> selectByIdWithLiveChatButton(Set<Id> transcriptIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('LiveChatButton.RoutingConfiguration.CapacityWeight');
        query.selectField('LiveChatButton.HasQueue');
        query.setCondition('Id In :transcriptIds');
        return (List<LiveChatTranscript>) Database.query(query.toSOQL());
    }

    public List<LiveChatTranscript> selectBySkillsAndStatusFromLast24Hours(List<String> skillName, String status) {
        fflib_QueryFactory query = newQueryFactory();
        String[] filters = new String[]{};
        for(String skill : skillName) {
            filters.add('%' + skill + '%');
        }
        query.setCondition('Status = :status AND (Skills__c IN : skillName OR Skills__c LIKE: filters) AND CreatedDate > YESTERDAY');
        return (List<LiveChatTranscript>) Database.query(query.toSOQL());
    }

    public Schema.SObjectType getSObjectType() {
        return LiveChatTranscript.SObjectType;
    }
}