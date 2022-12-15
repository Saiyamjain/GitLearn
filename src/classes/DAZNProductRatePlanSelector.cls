public inherited sharing class DAZNProductRatePlanSelector extends fflib_SObjectSelector {

    public static DAZNProductRatePlanSelector newInstance() {
        return (DAZNProductRatePlanSelector) Application.Selector.newInstance(ProductRatePlan__c.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                ProductRatePlan__c.Id,
                ProductRatePlan__c.ExternalId__c,
                ProductRatePlan__c.Product__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return ProductRatePlan__c.SObjectType;
    }

    public List<ProductRatePlan__c> selectById(Set<Id> productRatePlanIds) {
        Set<String> fields = new Set<String> {
                'Id',
                'Name',
                'ExternalId__c',
                'Product__c',
                'Product__r.Price_List__c'
        };
        return Database.query(
                newQueryFactory()
                        .selectFields(fields)
                        .setCondition('Id IN :productRatePlanIds')
                        .toSOQL()
        );
    }
    public List<ProductRatePlan__c> selectProductRatePlanByExternalId(Set<String> externalIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('ExternalId__c IN :externalIds');

        return (List<ProductRatePlan__c>) Database.query(query.toSOQL());
    }
}