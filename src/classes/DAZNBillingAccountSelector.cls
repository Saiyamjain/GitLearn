public inherited sharing class DAZNBillingAccountSelector extends fflib_SObjectSelector {

    public static DAZNBillingAccountSelector newInstance() {
        return (DAZNBillingAccountSelector) Application.Selector.newInstance(CustomerAccount__c.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                CustomerAccount__c.Id,
                CustomerAccount__c.External_Id__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return CustomerAccount__c.SObjectType;
    }

    public List<CustomerAccount__c> selectBillingAccountByExternalId(Set<String> externalIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('External_Id__c IN :externalIds');

        return (List<CustomerAccount__c>) Database.query(query.toSOQL());
    }

    public List<CustomerAccount__c> selectBillingAccountByAccountId(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Account__c IN :accountIds');
        query.subselectQuery('Payment_Methods__r').selectFields(new Set<String>{'Type__c'});
        return (List<CustomerAccount__c>) Database.query(query.toSOQL());
    }
}