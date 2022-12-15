@IsTest(IsParallel=true)
private class ServiceChannelStatusSelectorTest {
    @IsTest
    private static void selectByRelatedServiceChannelEntity() {
        new ServiceChannelStatusSelector().selectByRelatedServiceChannelEntity('EntityName');
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('ServiceChannel.RelatedEntity = :entityName'));
    }}