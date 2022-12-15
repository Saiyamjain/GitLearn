@IsTest(IsParallel=true)
private class DAZNProductRatePlanSelectorTest {
    @IsTest
    private static void selectProductRatePlanById() {
        DAZNProductRatePlanSelector.newInstance().selectById(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id IN :productRatePlanIds'));
    }

    @IsTest
    private static void selectProductRatePlanByExternalId() {
        DAZNProductRatePlanSelector.newInstance().selectProductRatePlanByExternalId(new Set<String>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('ExternalId__c IN :externalIds'));
    }
}