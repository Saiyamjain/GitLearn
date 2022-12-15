@IsTest(IsParallel=true)
private class CaseServiceTest {
    @IsTest
    static void callingServiceShouldCallSelectorPerformResponseActionsInDomainAndCommit() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        CaseDomain domainMock = (CaseDomain) mocks.mock(CaseDomain.class);
        CaseSelector caseSelectorMock = (CaseSelector) mocks.mock(CaseSelector.class);
        CaseQueueAssignmentSelector caseQueueAssignmentSelectorMock = (CaseQueueAssignmentSelector) mocks.mock(CaseQueueAssignmentSelector.class);


        // Given
        mocks.startStubbing();
        String queueName = 'Test Queue';
        String queueId = fflib_IDGenerator.generate(Group.SObjectType);
        String qountryCode = 'Test Code';
        Integer integerValue = 1;
        String stringValue = 'Test';
        String caseAction = 'Billing Escalation';
        //TODO DELETE after groupselector FROM HERE
        Group g = new Group(Type = 'Queue', Name = queueName);
        //insert g;

        User u = new User(Id = UserInfo.getUserId());
        QueueSObject q;
        System.runAs(u) {
            q = new QueueSObject(SobjectType = 'Case', QueueId = g.Id);
            //insert q;
        }
        //TODO TO HERE

        CaseService.CaseActionWrapper caw = new CaseService.CaseActionWrapper();
        caw.caseId = fflib_IDGenerator.generate(Case.SObjectType);
        caw.caseAction = caseAction;
        caw.caseActionReason = stringValue;
        caw.response = stringValue;

        List<Case> testCases = new List<Case> {
            new Case(
                Id = caw.caseId
            )
        };

        Map<String, Case_Queue_Assignment__mdt> testCaseQueueAssignmentsByCountryCode = new Map<String, Case_Queue_Assignment__mdt> {
            qountryCode => new Case_Queue_Assignment__mdt(
                Billing_Cases__c = queueName
            )
        };

        mocks.when(domainMock.sObjectType()).thenReturn(Case.SObjectType);
        mocks.when(domainMock.setStatusField('Open')).thenReturn(domainMock);
        mocks.when(domainMock.setQueueKeyField(caw.queueKey)).thenReturn(domainMock);
        mocks.when(domainMock.getOwnerIdForCaseAction(testCases.get(0), caw)).thenReturn(queueId);
        mocks.when(caseSelectorMock.sObjectType()).thenReturn(Case.SObjectType);
        mocks.when(caseSelectorMock.selectByIdWithFieldsForCloningRecord(new Set<Id> { caw.caseId })).thenReturn(testCases);
        mocks.when(caseQueueAssignmentSelectorMock.sObjectType()).thenReturn(Case_Queue_Assignment__mdt.SObjectType);
        mocks.when(caseQueueAssignmentSelectorMock.selectAll()).thenReturn(testCaseQueueAssignmentsByCountryCode);
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(uowMock);
        Application.Domain.setMock((fflib_ISObjectDomain)domainMock);
        Application.Selector.setMock(caseSelectorMock);
        Application.Selector.setMock(caseQueueAssignmentSelectorMock);

        // When
        CaseService.newInstance().performCaseActions(caw);

        // Then
        ((CaseSelector) mocks.verify(caseSelectorMock, 1)).selectByIdWithFieldsForCloningRecord(new Set<Id> { caw.caseId });
        ((CaseQueueAssignmentSelector) mocks.verify(caseQueueAssignmentSelectorMock, 1)).selectAll();
        ((CaseDomain) mocks.verify(domainMock)).setCaseActionFields(caseAction, stringValue);
        ((CaseDomain) mocks.verify(domainMock)).setStatusField('Open');
        ((CaseDomain) mocks.verify(domainMock)).setQueueKeyField(caw.queueKey);
        ((CaseDomain) mocks.verify(domainMock)).setOwnerIdForCaseAction(caw);
        ((CaseDomain) mocks.verify(domainMock)).setLastCaseCommentField(caw.response);
        ((CaseDomain) mocks.verify(domainMock)).createCaseComment(uowMock, caw.response);
        ((CaseDomain) mocks.verify(domainMock)).sendEmailWithCaseActionsResponse(uowMock, testCases.get(0), caw.response);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    @IsTest
    static void callingServiceShouldCallSelectorPerformNonResponseActionsInDomainAndCommit() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        CaseDomain domainMock = (CaseDomain) mocks.mock(CaseDomain.class);
        CaseSelector caseSelectorMock = (CaseSelector) mocks.mock(CaseSelector.class);
        CaseQueueAssignmentSelector caseQueueAssignmentSelectorMock = (CaseQueueAssignmentSelector) mocks.mock(CaseQueueAssignmentSelector.class);


        // Given
        mocks.startStubbing();
        String queueName = 'Test Queue';
        String queueId = fflib_IDGenerator.generate(Group.SObjectType);
        String qountryCode = 'Test Code';
        String stringValue = 'Test';
        String caseAction = CaseService.CaseActionType.SPLIT_CASE.name();
        //TODO DELETE after groupselector FROM HERE
        Group g = new Group(Type = 'Queue', Name = queueName);
        //insert g;

        User u = new User(Id = UserInfo.getUserId());
        QueueSObject q;
        System.runAs(u) {
            q = new QueueSObject(SobjectType = 'Case', QueueId = g.Id);
            //insert q;
        }
        //TODO TO HERE

        CaseService.CaseActionWrapper caw = new CaseService.CaseActionWrapper();
        caw.caseId = fflib_IDGenerator.generate(Case.SObjectType);
        caw.caseAction = caseAction;
        caw.caseActionReason = stringValue;
        caw.response = stringValue;

        List<Case> testCases = new List<Case> {
            new Case(
                Id = caw.caseId
            )
        };

        Map<String, Case_Queue_Assignment__mdt> testCaseQueueAssignmentsByCountryCode = new Map<String, Case_Queue_Assignment__mdt> {
            qountryCode => new Case_Queue_Assignment__mdt(
                Billing_Cases__c = queueName
            )
        };

        mocks.when(domainMock.sObjectType()).thenReturn(Case.SObjectType);
        mocks.when(domainMock.setStatusField('Closed')).thenReturn(domainMock);
        mocks.when(domainMock.getOwnerIdForCaseAction(testCases.get(0), caw)).thenReturn(queueId);
        mocks.when(caseSelectorMock.sObjectType()).thenReturn(Case.SObjectType);
        mocks.when(caseSelectorMock.selectByIdWithFieldsForCloningRecord(new Set<Id> { caw.caseId })).thenReturn(testCases);
        mocks.when(caseQueueAssignmentSelectorMock.sObjectType()).thenReturn(Case_Queue_Assignment__mdt.SObjectType);
        mocks.when(caseQueueAssignmentSelectorMock.selectAll()).thenReturn(testCaseQueueAssignmentsByCountryCode);
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(uowMock);
        Application.Domain.setMock((fflib_ISObjectDomain)domainMock);
        Application.Selector.setMock(caseSelectorMock);
        Application.Selector.setMock(caseQueueAssignmentSelectorMock);

        // When
        CaseService.newInstance().performCaseActions(caw);

        // Then
        ((CaseSelector) mocks.verify(caseSelectorMock, 1)).selectByIdWithFieldsForCloningRecord(new Set<Id> { caw.caseId });
        ((CaseQueueAssignmentSelector) mocks.verify(caseQueueAssignmentSelectorMock, 1)).selectAll();
        ((CaseDomain) mocks.verify(domainMock)).setCaseActionFields(caseAction, stringValue);
        ((CaseDomain) mocks.verify(domainMock)).setStatusField('Closed');
        ((CaseDomain) mocks.verify(domainMock)).setOwnerToCurrentUser(); //
        ((CaseDomain) mocks.verify(domainMock)).cloneCase(uowMock, new Map<String, Object> {
            'Status' => 'Open',
            'Queue_Key__c' => caw.queueKey,
            'OwnerId' => queueId
        });
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }
}