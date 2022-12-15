@IsTest(IsParallel=true)
private class OrderItemSelectorTest {
    @IsTest
    private static void selectByUniqueId() {
        new OrderItemSelector().selectByUniqueId(new Set<String>{'12345'});
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Unique_Id__c IN :orderItemUniqueIds'));
    }}