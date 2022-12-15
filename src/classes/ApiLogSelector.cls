public inherited sharing class ApiLogSelector extends fflib_SObjectSelector {
    public static ApiLogSelector newInstance() {
        return (ApiLogSelector) Application.Selector.newInstance(API_Log__c.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
                API_Log__c.Correlation_Id__c,
                API_Log__c.Request__c,
                API_Log__c.Process_ID__c
        };
     }

    public Schema.SObjectType getSObjectType() {
        return API_Log__c.SObjectType;
    }

    public List<API_Log__c> selectById(Set<Id> idSet){
        return (List<API_Log__c>) selectSObjectsById(idSet);
    }

    public List<API_Log__c> selectByProcessId(Set<Id> idSet){
        return Database.query(
            newQueryFactory()
                .setCondition('Process_ID__c IN :idSet')
                .toSOQL()
        );
    }

    public List<API_Log__c> selectSuccessfulOutboundLogByProcessId(Set<String> processIds) {
        return Database.query(
                newQueryFactory()
                    .setCondition('Process_ID__c IN :processIds AND Callout_type__c = \'Outbound\' AND Status__c = \'Success\'')
                    .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
                    .toSOQL());
    }

}