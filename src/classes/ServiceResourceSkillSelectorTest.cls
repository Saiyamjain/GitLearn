@IsTest(IsParallel=true)
private class ServiceResourceSkillSelectorTest {
    @IsTest
    private static void selectOnlineAgents() {
        new ServiceResourceSkillSelector().selectByAgentsIds(new Set<Id>{});
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('ServiceResource.RelatedRecordId IN :agentsIds AND ServiceResource.IsActive = true'));
    }

    @IsTest
    private static void selectOnlineAgentsByServicePresenceStatusAndUsers() {
        new ServiceResourceSkillSelector().selectBySkillIds(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('SkillId IN :skillIds AND ServiceResource.IsActive = true'));
    }
}