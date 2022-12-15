public with sharing class PriceBookSelector extends fflib_SObjectSelector {

    public static PriceBookSelector newInstance() {
        return (PriceBookSelector) Application.Selector.newInstance(PriceBook2.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            PriceBook2.Account_Type__c,
            PriceBook2.Business_Type__c,
            PriceBook2.Country__c,
            PriceBook2.IsActive,
            PriceBook2.Name,
            PriceBook2.Id,
            PriceBook2.VAT__c,
            PriceBook2.Partner_Id__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return PriceBook2.SObjectType;
    }

    public List<PriceBook2> selectById(Set<Id> PriceBook2Id) {
        return (List<PriceBook2>) selectSObjectsById(PriceBook2Id);
    }

    public Set<String> getPriceBookEntryFieldList() {
        return new Set<String> {
            'Id',
            'IsActive',
            'Name',
            'Pricebook2Id',
            'Product2Id',
            'Renewal_Term__c',
            'Renewal_Term_Period_Type__c',
            'UnitPrice',
            'Product2.Family',
            'Renewal_Price__c'
        };
    }

    public List<PriceBook2> selectStandardPricebook() {

        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('IsActive = true AND IsStandard = true');

        return Database.query(query.toSOQL());
    }

    public List<PriceBook2> getPriceManagementData(List<String> businessTypes, List<String> countries, List<String> accountRecordTypeNames, List<String> productFamilies) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Business_Type__c INCLUDES (\'' + String.join(businessTypes, '\',\'') + '\') AND Country__c IN: countries AND Account_Type__c INCLUDES (\'' + String.join(accountRecordTypeNames, '\',\'') + '\') AND IsActive = true');
        query.emptyOrdering();
        query.subselectQuery('PriceBookEntries').selectFields(getPriceBookEntryFieldList())
                .setCondition('IsActive = true AND Product2.family IN: productFamilies' );
        query.emptyOrdering();
        return Database.query(query.toSOQL());
    }

    public List<PriceBook2> getPriceManagementData(List<String> businessTypes, List<String> countries, List<String> accountRecordTypeNames, List<String> productFamilies, List<String> partnerIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Business_Type__c INCLUDES (\'' + String.join(businessTypes, '\',\'') + '\') AND Country__c IN: countries AND Account_Type__c INCLUDES (\'' + String.join(accountRecordTypeNames, '\',\'') + '\') AND  Partner_Id__c IN :partnerIds AND IsActive = true');

        query.emptyOrdering();
        query.subselectQuery('PriceBookEntries').selectFields(getPriceBookEntryFieldList())
                .setCondition('IsActive = true AND Product2.family IN: productFamilies' );
        query.emptyOrdering();
        return Database.query(query.toSOQL());
    }
}