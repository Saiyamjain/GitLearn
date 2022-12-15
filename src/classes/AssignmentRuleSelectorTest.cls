@IsTest(IsParallel=true)
private class AssignmentRuleSelectorTest {
    
    @IsTest
    private static void shouldSelectLeadAssignmentRuleByName() {
        new AssignmentRuleSelector().selectLeadAssignmentRulesByName(null);
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase(
            'SobjectType =\'Lead\' AND Name =: name'),result.getCondition());
    }
}