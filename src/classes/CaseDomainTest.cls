@isTest
private class CaseDomainTest {

    @isTest
    private static void testSkillBasedRoutingSuccessOnCaseInsert() {
        Map<String, Id> skillNameToIdMap = new Map<String, Id>();
        for (Skill skill : [SELECT Id, DeveloperName FROM Skill]) {
            skillNameToIdMap.put(skill.DeveloperName, skill.Id);
        }

        Case testCase = new Case(
            Origin = 'Web',
            Notification_Country_Code__c = 'DE',
            Notification_Language_Code__c = 'de-DE',
            Priority = '2',
            Status = 'Open'
        );

        insert testCase;

        List<PendingServiceRouting> createdPSR = [SELECT Id, WorkItemId, IsReadyForRouting FROM PendingServiceRouting WHERE WorkItemId = :testCase.Id];
        system.assertEquals(1, createdPSR.size());
        system.assertEquals(true, createdPSR[0].IsReadyForRouting);

        List<SkillRequirement> skillRequired = [SELECT Id, SkillId, SkillLevel, RelatedRecordId FROM SkillRequirement WHERE RelatedRecordId = :createdPSR[0].Id];
        system.assertEquals(1, skillRequired.size());
        system.assertEquals(1, skillRequired[0].SkillLevel);
        system.assertEquals(skillNameToIdMap.get('DACH'), skillRequired[0].SkillId);
    }

    @isTest
    private static void testSkillBasedRoutingWithStatusChangeOnCase() {
        Case testCase = new Case(
            Origin = 'Web',
            Notification_Country_Code__c = 'DE',
            Notification_Language_Code__c = 'de-DE',
            Priority = '2',
            Status = 'Open'
        );

        insert testCase;

        List<PendingServiceRouting> createdPSR = [SELECT Id, WorkItemId, IsReadyForRouting FROM PendingServiceRouting WHERE WorkItemId = :testCase.Id];
        system.assertEquals(1, createdPSR.size());
        system.assertEquals(true, createdPSR[0].IsReadyForRouting);

        testCase.Status = 'Responded';

        update testCase;

        createdPSR = [SELECT Id, WorkItemId FROM PendingServiceRouting WHERE WorkItemId = :testCase.Id];
        system.assertEquals(0, createdPSR.size());
    }

    @isTest
    private static void testSkillBasedRoutingSuccessOnCaseReopen() {
        Map<String, Id> skillNameToIdMap = new Map<String, Id>();
        for (Skill skill : [SELECT Id, DeveloperName FROM Skill]) {
            skillNameToIdMap.put(skill.DeveloperName, skill.Id);
        }

        Case testCase = new Case(
            Origin = 'Web',
            Notification_Country_Code__c = 'JP',
            Notification_Language_Code__c = 'ja-JP',
            Priority = '2',
            Status = 'Responded'
        );

        insert testCase;

        testCase.Status = 'Open';
        update testCase;

        List<PendingServiceRouting> createdPSR = [SELECT Id, WorkItemId, IsReadyForRouting FROM PendingServiceRouting WHERE WorkItemId = :testCase.Id];
        system.assertEquals(1, createdPSR.size());
        system.assertEquals(true, createdPSR[0].IsReadyForRouting);

        List<SkillRequirement> skillRequired = [SELECT Id, SkillId, SkillLevel, RelatedRecordId FROM SkillRequirement WHERE RelatedRecordId = :createdPSR[0].Id];
        system.assertEquals(1, skillRequired.size());
        system.assertEquals(1, skillRequired[0].SkillLevel);
        system.assertEquals(skillNameToIdMap.get('Japan'), skillRequired[0].SkillId);
    }

    @isTest
    private static void testSkillBasedRoutingOnQueueAssignment() {
        Map<String, Id> skillNameToIdMap = new Map<String, Id>();
        for (Skill skill : [SELECT Id, DeveloperName FROM Skill]) {
            skillNameToIdMap.put(skill.DeveloperName, skill.Id);
        }

        List<Group> queues = [SELECT Id, Name FROM Group WHERE Type = 'Queue'];

        Case testCase = new Case(
            Origin = 'Web',
            Notification_Country_Code__c = 'JP',
            Notification_Language_Code__c = 'ja-JP',
            Priority = '2',
            Status = 'Open',
            OwnerId = queues[0].Id
        );

        insert testCase;

        List<PendingServiceRouting> createdPSR = [SELECT Id, WorkItemId, IsReadyForRouting FROM PendingServiceRouting WHERE WorkItemId = :testCase.Id];
        system.assertEquals(0, createdPSR.size());
    }

    @isTest
    private static void testContactUsEmailAssignmentWithContact() {
        String email = 'your.email+fakedata89952@gmail.com';
        Account testAccount = TestUtils.createAndInsertAccount('Keshawn Pagac', email);
        Contact testContact = TestUtils.createAndInsertContact(testAccount.Id, true, email);
        Case testCase = TestUtils.createAndInsertCase(testAccount.Id, testContact.Id, 'ActivePaid');
        List<Case> createdCases = [SELECT Id, Contact_Us_Email__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(testContact.Email, createdCases[0].Contact_Us_Email__c);
    }

    @isTest
    private static void testContactUsEmailAssignmentWithSuppliedEmail() {
        Case testCase = new Case(
            Origin = 'Web',
            Notification_Country_Code__c = 'jp',
            Notification_Language_Code__c = 'ja-JP',
            Priority = '2',
            Status = 'Open',
            SuppliedEmail = 'test@test.com'
        );
        
        insert testCase;

        List<Case> createdCases = [SELECT Id, Contact_Us_Email__c, SuppliedEmail FROM Case WHERE Id = :testCase.Id];
        system.assertEquals(createdCases[0].Contact_Us_Email__c, createdCases[0].SuppliedEmail);
    }
  
    @IsTest
    private static void callingChangeStatusShouldChangeStatusInDomainRecords() {
        // Given
        String fromStatus = 'Test Status';
        String properStatus = 'Proper Test Status';
        Case c = new Case(
            Id = fflib_IDGenerator.generate(Case.SObjectType),
            Status = fromStatus
        );
        // When
        CaseDomain.newInstance(new List<Case> {c}).changeStatus(fromStatus, properStatus);

        // Then
        System.assertEquals(properStatus, c.Status);
    }

    @IsTest
    private static void callingSetFieldsShouldChangeFieldsInDomainRecords() {
        // Given
        String newStringValue = 'New Test';
        Integer newIntegerValue = 2;
        Case c = new Case(
            Id = fflib_IDGenerator.generate(Case.SObjectType)
        );

        // When
        CaseDomain.newInstance(new List<Case> { c }).setCaseActionFields(newStringValue, newStringValue);
        CaseDomain.newInstance(new List<Case> { c }).setStatusField(newStringValue);
        CaseDomain.newInstance(new List<Case> { c }).setQueueKeyField(newIntegerValue);
        CaseDomain.newInstance(new List<Case> { c }).setLastCaseCommentField(newStringValue);
        CaseDomain.newInstance(new List<Case> { c }).setOwnerToCurrentUser();

        // Then
        System.assertEquals(newStringValue, c.Case_Actions__c);
        System.assertEquals(newStringValue, c.Case_Action_Reason__c);
        System.assertEquals(newStringValue, c.Status);
        System.assertEquals(newIntegerValue, c.Queue_Key__c);
        System.assertEquals(newStringValue, c.Last_Case_Comment__c);
        System.assertEquals(UserInfo.getUserId(), c.OwnerId);
    }

    @IsTest
    private static void callingGetOwnerIdForCaseActionShouldGetProperQueueId() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        GroupSelector groupSelectorMock = (GroupSelector) mocks.mock(GroupSelector.class);
        // Given
        mocks.startStubbing();
        String notificationCountryCode = 'XY';
        String queueName = 'Test Queue';
        String queueId = fflib_IDGenerator.generate(Group.SObjectType);
        CaseService.CaseActionType caseActionType = CaseService.CaseActionType.BILLING_ESCALATION;

        CaseService.CaseActionWrapper caw = new CaseService.CaseActionWrapper();
        caw.caseActionType = caseActionType;
        caw.setCaseQueueAssignmentByCountryCode(new Map<String, Case_Queue_Assignment__mdt> {
            notificationCountryCode => new Case_Queue_Assignment__mdt(
                DeveloperName = notificationCountryCode,
                Billing_Cases__c = queueName
            )
        });

        Case c = new Case(
            Id = fflib_IDGenerator.generate(Case.SObjectType),
            Notification_Country_Code__c = notificationCountryCode
        );
        RecordType rt = new RecordType(
            Name = 'Standard'
        );
        c.RecordType = rt;
        List<Group> queues = new List<Group> {
            new Group(
                Id = queueId,
                Name = queueName
            )
        };
        mocks.when(groupSelectorMock.sObjectType()).thenReturn(Group.SObjectType);
        mocks.when(groupSelectorMock.selectByType('Queue')).thenReturn(queues);
        mocks.stopStubbing();
        Application.Selector.setMock(groupSelectorMock);

        // When

        String ownerId = CaseDomain.newInstance(new List<Case> { c }).getOwnerIdForCaseAction(c, caw);

        // Then
        System.assertEquals(queueId, ownerId);
    }

    @IsTest
    private static void callingSetOwnerIdForCaseActionShouldSetProperQueueId() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        GroupSelector groupSelectorMock = (GroupSelector) mocks.mock(GroupSelector.class);
        // Given
        mocks.startStubbing();
        String notificationCountryCode = 'XY';
        String queueName = 'Test Queue';
        String queueId = fflib_IDGenerator.generate(Group.SObjectType);
        CaseService.CaseActionType caseActionType = CaseService.CaseActionType.BILLING_ESCALATION;

        CaseService.CaseActionWrapper caw = new CaseService.CaseActionWrapper();
        caw.caseActionType = caseActionType;
        caw.setCaseQueueAssignmentByCountryCode(new Map<String, Case_Queue_Assignment__mdt> {
            notificationCountryCode => new Case_Queue_Assignment__mdt(
                DeveloperName = notificationCountryCode,
                Billing_Cases__c = queueName
            )
        });

        Case c = new Case(
            Id = fflib_IDGenerator.generate(Case.SObjectType),
            Notification_Country_Code__c = notificationCountryCode
        );
        RecordType rt = new RecordType(
            Name = 'Standard'
        );
        c.RecordType = rt;
        List<Group> queues = new List<Group> {
            new Group(
                Id = queueId,
                Name = queueName
            )
        };
        mocks.when(groupSelectorMock.sObjectType()).thenReturn(Group.SObjectType);
        mocks.when(groupSelectorMock.selectByType('Queue')).thenReturn(queues);
        mocks.stopStubbing();
        Application.Selector.setMock(groupSelectorMock);

        // When
        String ownerId = CaseDomain.newInstance(new List<Case> { c }).getOwnerIdForCaseAction(c, caw);
        CaseDomain.newInstance(new List<Case> { c }).setOwnerIdForCaseAction(caw);

        // Then
        System.assertEquals(queueId, c.OwnerId);
    }

    @IsTest
    private static void callingCloneCaseShouldCloneCaseWithAllPassedValues() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        // Given
        String parentStatus = 'Parent';
        String childStatus = 'Child';
        Case c = new Case(
            Id = fflib_IDGenerator.generate(Case.SObjectType),
            Status = parentStatus
        );
        List<Case> testCasesList = new List<Case> { c };
        Application.UnitOfWork.setMock(uowMock);

        // When
        CaseDomain.newInstance(testCasesList).cloneCase(uowMock, new Map<String, Object> {
            'Status' => childStatus
        });

        // Then
        ((fflib_ISObjectUnitOfWork)
            mocks.verify(uowMock, 1)).registerNew(
            fflib_Match.sObjectWith(
                new Map<SObjectField, Object>{
                    Case.ParentId => c.Id,
                    Case.Status => childStatus
                }
            ));
    }

    @IsTest
    private static void callingCreateCaseCommentShouldCreateCaseCommentForCases() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        // Given
        String commentBody = 'Comment';
        Case c = new Case(
            Id = fflib_IDGenerator.generate(Case.SObjectType)
        );
        List<Case> testCasesList = new List<Case> { c };
        Application.UnitOfWork.setMock(uowMock);

        // When
        CaseDomain.newInstance(testCasesList).createCaseComment(uowMock, commentBody);

        // Then
        ((fflib_ISObjectUnitOfWork)
            mocks.verify(uowMock, 1)).registerNew(
            fflib_Match.sObjectWith(
                new Map<SObjectField, Object>{
                    CaseComment.ParentId => c.Id,
                    CaseComment.CommentBody => commentBody
                }
            ));
    }

    @IsTest
    private static void callingSendEmailWithCaseActionsResponseShouldSendEmailAndCreateEmailMessage() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        DAZNConfigurationSelector daznConfigurationSelectorMock = (DAZNConfigurationSelector) mocks.mock(DAZNConfigurationSelector.class);
        OrgWideEmailAddressSelector orgWideEmailAddressSelectorMock = (OrgWideEmailAddressSelector) mocks.mock(OrgWideEmailAddressSelector.class);
        // Given
        mocks.startStubbing();
        String response = 'response';
        String email = 'test@email.com';
        Case c = new Case(
            Id = fflib_IDGenerator.generate(Case.SObjectType),
            SuppliedEmail = email
        );
        List<Case> testCasesList = new List<Case> { c };
        DAZN_Configuration__mdt daznConfiguration = new DAZN_Configuration__mdt(
            Email_Address_For_Case_Actions__c = email
        );
        OrgWideEmailAddress owea = new OrgWideEmailAddress(
            Id = fflib_IDGenerator.generate(OrgWideEmailAddress.SObjectType),
            Address = email
        );
        mocks.when(daznConfigurationSelectorMock.sObjectType()).thenReturn(DAZN_Configuration__mdt.SObjectType);
        mocks.when(daznConfigurationSelectorMock.selectByEnvType()).thenReturn(daznConfiguration);
        mocks.when(orgWideEmailAddressSelectorMock.sObjectType()).thenReturn(OrgWideEmailAddress.SObjectType);
        mocks.when(orgWideEmailAddressSelectorMock.selectByEmailAddress(email)).thenReturn(owea);
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(uowMock);
        Application.Selector.setMock(daznConfigurationSelectorMock);
        Application.Selector.setMock(orgWideEmailAddressSelectorMock);

        // When
        CaseDomain.newInstance(testCasesList).sendEmailWithCaseActionsResponse(uowMock, c, response);

        // Then
        ((fflib_ISObjectUnitOfWork)
            mocks.verify(uowMock, 1)).registerEmail((Messaging.SingleEmailMessage) fflib_Match.anyObject());

        fflib_ArgumentCaptor capturedEmailArg = fflib_ArgumentCaptor.forClass(Messaging.SingleEmailMessage.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock,1))
            .registerEmail((Messaging.SingleEmailMessage)capturedEmailArg.capture());

        Object actualEmailAsObject = capturedEmailArg.getValue();
        Messaging.SingleEmailMessage actualEmail =
            (Messaging.SingleEmailMessage) actualEmailAsObject;

        System.assertEquals('UTF-8', actualEmail.getCharset());
        System.assertEquals(new List<String> {email},actualEmail.getToAddresses());

        ((fflib_ISObjectUnitOfWork)
            mocks.verify(uowMock, 1)).registerNew(
            fflib_Match.sObjectWith(
                new Map<SObjectField, Object>{
                    EmailMessage.FromName => actualEmail.getSenderDisplayName(),
                    EmailMessage.ToAddress => email,
                    EmailMessage.Subject => actualEmail.getSubject(),
                    EmailMessage.TextBody => actualEmail.getPlainTextBody(),
                    EmailMessage.HtmlBody => actualEmail.getHtmlBody(),
                    EmailMessage.ParentId => c.Id,
                    EmailMessage.Incoming => true,
                    EmailMessage.Status => '0'
                }
            ));
    }

    @IsTest
    private static void callingSendEmailWithCaseActionsResponseShouldThrowException() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        // Given
        String response = 'response';
        Case c = new Case(
            Id = fflib_IDGenerator.generate(Case.SObjectType)
        );
        List<Case> testCasesList = new List<Case> { c };
        Application.UnitOfWork.setMock(uowMock);

        // When
        String exceptionMessage;
        try {
            CaseDomain.newInstance(testCasesList).sendEmailWithCaseActionsResponse(uowMock, c, response);
        } catch(Exception e) {
            exceptionMessage = e.getMessage();
        }
        // Then
        System.assertEquals(Label.Email_Has_Not_Been_Sent, exceptionMessage);
    }

    @IsTest
    private static void onBeforeUpdateChangeStatusToOpenIfQueueAssignedTest() {
        Group g = new Group(Type = 'Queue', Name = 'Queue name');
        insert g;

        User u = new User(Id = UserInfo.getUserId());
        QueueSObject q;
        System.runAs(u) {
            q = new QueueSObject(SobjectType = 'Case', QueueId = g.Id);
            insert q;
        }

        Case c = new Case ( Status = 'In Progress', Notification_Country_Code__c = 'de' );
        insert c;

        c.OwnerId = g.Id;
        update c;

        System.assertEquals('Open', [SELECT Status FROM Case].Status);
    }

    @IsTest
    private static void onApplyDefaultsShouldSetCorrectRecordTypeWhenCaseCreatedFromAPI() {
        String correlationId = 'test correlation Id';

        API_Log__c apiLog = new API_Log__c(Correlation_Id__c = correlationId);
        insert apiLog;

        Case c = new Case (Status = 'In Progress', Notification_Country_Code__c = 'de', Notification_Language_Code__c = 'de-DE', Correlation_Id__c = correlationId);
        insert c;

        System.assertEquals('General Process', [SELECT RecordType.Name FROM Case][0].RecordType.Name);
    }

    @IsTest
    private static void onApplyDefaultsShouldSetContactAndAccountIds() {
        //Given
        String email = 'test@test.com';
        Account acc = TestUtils.createAndInsertAccount('Test Account', email);
        Contact con = TestUtils.createAndInsertContact(acc.Id, true, email);
        Case c = new Case (
            Status = 'In Progress',
            Notification_Country_Code__c = 'de',
            Notification_Language_Code__c = 'de-DE',
            SuppliedEmail = email
        );

        //When
        insert c;

        //Then
        c = [SELECT Id, AccountId, ContactId FROM Case LIMIT 1];
        System.assertEquals(acc.Id, c.AccountId);
        System.assertEquals(con.Id, c.ContactId);
    }

    @IsTest
    private static void shouldUpdateLangAndCountryCodeTest() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ContactSelector selectorMock = (ContactSelector) mocks.mock(ContactSelector.class);

        Account accountRecord = TestUtils.createAccount('TestAccount', 'test@test.com');
        accountRecord.Id = fflib_IDGenerator.generate(Account.SObjectType);
        Contact contactRecord = TestUtils.createContact(accountRecord.Id, true, 'test@test.com');
        contactRecord.Id = fflib_IDGenerator.generate(Contact.SObjectType);
        contactRecord.Account = accountRecord;
        Case caseRec = TestUtils.createCase(accountRecord.Id, contactRecord.Id, 'In Progress');
        caseRec.Notification_Language_Code__c = null;
        Case caseRec2 = TestUtils.createCase(null, null, 'In Progress');
        caseRec2.Notification_Language_Code__c = null;


        // Given
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(selectorMock.selectContactByIds(new Set<Id>{contactRecord.Id})).thenReturn(new List<Contact>{contactRecord});
        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        CaseDomain.newInstance(new List<Case> {caseRec, caseRec2}).updateLangAndCountryCode();

        // Then
        ((ContactSelector) mocks.verify(selectorMock, 1)).selectContactByIds(new Set<Id> {contactRecord.Id});
    }

}