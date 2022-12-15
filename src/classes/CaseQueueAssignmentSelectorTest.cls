@IsTest
private class CaseQueueAssignmentSelectorTest {
    @IsTest
    private static void testSelectByDeveloperName() {
        String devName = 'de';
        // Query
        Case_Queue_Assignment__mdt caseQueueAssignment =
            CaseQueueAssignmentSelector.newInstance().selectByDeveloperName(devName);

        // Assert
        System.assert(caseQueueAssignment != null);
    }

    @IsTest
    private static void testSelectAll() {
        // Query
        List<Case_Queue_Assignment__mdt> caseQueueAssignments =
            CaseQueueAssignmentSelector.newInstance().selectAll().values();

        // Assert
        System.assert(!caseQueueAssignments.isEmpty());
    }
}