@IsTest(IsParallel=true)
private class ChatBotServiceTest {
/*
    @IsTest
    static void callingServiceWithValidInputShouldResultInSuccess() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        LiveChatTranscriptSelector liveChatSelectorMock = (LiveChatTranscriptSelector) mocks.mock(LiveChatTranscriptSelector.class);
        BotDialogSelector botDialogSelectorMock = (BotDialogSelector) mocks.mock(BotDialogSelector.class);
        BotDialogInstanceSelector botDialogInstanceSelectorMock = (BotDialogInstanceSelector) mocks.mock(BotDialogInstanceSelector.class);

        mocks.startStubbing();
        LiveChatTranscript testTranscript = new LiveChatTranscript(
                Id = fflib_IDGenerator.generate(LiveChatTranscript.SObjectType)
        );
        Bot_Dialog__c testDialog = new Bot_Dialog__c(
                Id = fflib_IDGenerator.generate(Bot_Dialog__c.SObjectType),
                RecordTypeId = Schema.SObjectType.Bot_Dialog_Instance__c.getRecordTypeInfosByName()
                        .get(ChatBotService.RECORD_TYPE_NAME_GOAL).getRecordTypeId(),
                Goal_Name__c = 'testGoal',
                Bot_Name__c = 'testBot',
                Label__c = 'testLabel'
        );
        Bot_Dialog__c testDialog2 = new Bot_Dialog__c(
                Id = fflib_IDGenerator.generate(Bot_Dialog__c.SObjectType),
                RecordTypeId = Schema.SObjectType.Bot_Dialog_Instance__c.getRecordTypeInfosByName()
                        .get(ChatBotService.RECORD_TYPE_NAME_DIALOG).getRecordTypeId(),
                Dialog_Name__c = 'testSolution',
                Goal_Name__c = 'testGoal',
                Bot_Name__c = 'testBot',
                Type__c = 'Solution',
                Label__c = 'testLabel'
        );
        Bot_Dialog_Instance__c botInstance = new Bot_Dialog_Instance__c(
                Id = fflib_IDGenerator.generate(Bot_Dialog_Instance__c.SObjectType),
                RecordTypeId = Schema.SObjectType.Bot_Dialog_Instance__c.getRecordTypeInfosByName()
                        .get(ChatBotService.RECORD_TYPE_NAME_DIALOG).getRecordTypeId(),
                Chat_Transcript__c = testTranscript.Id,
                Dialog_Name__c = 'testSolution',
                Goal_Name__c = 'testGoal',
                Type__c = 'Solution'
        );

        BotDialogInitializationHandler.DialogInitializationInput botInput = new BotDialogInitializationHandler.DialogInitializationInput();
        botInput.currentDialogName = 'testSolution';
        botInput.sCurrentDialog = 'testDialog';
        botInput.sCurrentGoal = 'testGoal';
        botInput.routableId = testTranscript.Id;


        mocks.when(botDialogSelectorMock.sObjectType()).thenReturn(Bot_Dialog__c.SObjectType);
        mocks.when(botDialogSelectorMock.selectByDialogName(new Set<String>{'testSolution'})).thenReturn(new List<Bot_Dialog__c>{testDialog2});
        mocks.when(botDialogInstanceSelectorMock.sObjectType()).thenReturn(Bot_Dialog_Instance__c.SObjectType);
        mocks.when(botDialogInstanceSelectorMock.selectByTranscriptId(new Set<Id>{testTranscript.Id})).thenReturn(new List<Bot_Dialog_Instance__c>{botInstance});
        mocks.stopStubbing();

        Application.Selector.setMock(botDialogSelectorMock);
        Application.Selector.setMock(botDialogInstanceSelectorMock);
        Application.UnitOfWork.setMock(uowMock);

        ChatBotService.newInstance().initializeBotDialogInstance(new List<BotDialogInitializationHandler.DialogInitializationInput>{botInput}, new Set<String>{'testSolution'}, new Set<Id>{testTranscript.Id});

        ((BotDialogSelector) mocks.verify(botDialogSelectorMock, 1)).selectByDialogName(new Set<String>{'testSolution'});
        ((BotDialogInstanceSelector) mocks.verify(botDialogInstanceSelectorMock, 1)).selectByTranscriptId(new Set<Id>{testTranscript.Id});
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    @isTest
    static void whenCheckOnlineAgentsForBotActionWithNoAgentsTest() {

        Map<String, Id> skillNameToIdMap = new Map<String, Id>();
        for (Skill skill : SkillSelector.newInstance().selectAll()) {
            skillNameToIdMap.put(skill.DeveloperName, skill.Id);
        }

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        LiveChatTranscriptSelector lctSelectorMock = (LiveChatTranscriptSelector) mocks.mock(LiveChatTranscriptSelector.class);
        PendingServiceRoutingSelector psrSelectorMock = (PendingServiceRoutingSelector) mocks.mock(PendingServiceRoutingSelector.class);
        ServiceResourceSkillSelector srsSelectorMock = (ServiceResourceSkillSelector) mocks.mock(ServiceResourceSkillSelector.class);
        ServiceChannelStatusSelector scsSelectorMock = (ServiceChannelStatusSelector) mocks.mock(ServiceChannelStatusSelector.class);
        UserServicePresenceSelector uspSelectorMock = (UserServicePresenceSelector) mocks.mock(UserServicePresenceSelector.class);
        AgentWorkSelector awSelectorMock = (AgentWorkSelector) mocks.mock(AgentWorkSelector.class);

        mocks.startStubbing();

        LiveChatTranscript testTranscript = new LiveChatTranscript(
            Id = fflib_IDGenerator.generate(LiveChatTranscript.SObjectType),
            Skills__c = 'DACH_English'
        );

        List<LiveChatTranscript> liveChatTrascripts = new List<LiveChatTranscript>();
        liveChatTrascripts.add(testTranscript);

        mocks.when(lctSelectorMock.sObjectType()).thenReturn(LiveChatTranscript.SObjectType);
        mocks.when(lctSelectorMock.selectByIdWithLiveChatButton(new Set<Id>{testTranscript.Id})).thenReturn(liveChatTrascripts);
        mocks.when(lctSelectorMock.selectBySkillsAndStatusFromLast24Hours(new List<String>{'DACH_English'}, 'Waiting')).thenReturn(liveChatTrascripts);

        mocks.when(psrSelectorMock.sObjectType()).thenReturn(PendingServiceRouting.SObjectType);
        mocks.when(psrSelectorMock.selectByWorkItemIdTransferredAndNotPushed(new Set<Id>{testTranscript.Id})).thenReturn(new List<PendingServiceRouting>());
        
        mocks.when(srsSelectorMock.sObjectType()).thenReturn(ServiceResourceSkill.SObjectType);
        mocks.when(srsSelectorMock.selectBySkillIds(new Set<Id>{skillNameToIdMap.get('DACH_English')})).thenReturn(new List<ServiceResourceSkill>());

        mocks.when(scsSelectorMock.sObjectType()).thenReturn(ServiceChannelStatus.SObjectType);
        mocks.when(scsSelectorMock.selectByRelatedServiceChannelEntity('LiveChatTranscript')).thenReturn(new List<ServiceChannelStatus>());

        mocks.when(uspSelectorMock.sObjectType()).thenReturn(UserServicePresence.SObjectType);
        mocks.when(uspSelectorMock.selectOnlineAgentsByServicePresenceStatusAndUsers(new Set<Id>(), new Set<Id>())).thenReturn(new List<UserServicePresence>());

        mocks.when(awSelectorMock.sObjectType()).thenReturn(AgentWork.SObjectType);
        mocks.when(awSelectorMock.selectOpenedAssignedWork(new Set<Id>())).thenReturn(new List<AgentWork>());

        mocks.stopStubbing();

        Application.Selector.setMock(lctSelectorMock);
        Application.Selector.setMock(psrSelectorMock);
        Application.Selector.setMock(srsSelectorMock);
        Application.Selector.setMock(scsSelectorMock);
        Application.Selector.setMock(uspSelectorMock);
        Application.Selector.setMock(awSelectorMock);

        BotCheckIfAgentOnlineHandler.BotInput botInput = new BotCheckIfAgentOnlineHandler.BotInput();
        botInput.langCode = 'en-GB';
        botInput.countryCode = 'de';
        botInput.churn = 'false';
        botInput.isFirstCheck = 'false';
        botInput.liveChatTranscriptId = testTranscript.Id;

        List<BotCheckIfAgentOnlineHandler.BotOutput> botOutput = ChatBotService.newInstance().checkIfAgentOnline(new List<BotCheckIfAgentOnlineHandler.BotInput>{botInput});
        system.assertEquals('false', botOutput[0].agentsAvailable);
        system.assertEquals('false', botOutput[0].transferToAgent);
    }

    @isTest
    static void whenCheckOnlineAgentsForBotActionWithAgentOnlineTest() {

        Map<String, Id> skillNameToIdMap = new Map<String, Id>();
        for (Skill skill : SkillSelector.newInstance().selectAll()) {
            skillNameToIdMap.put(skill.DeveloperName, skill.Id);
        }

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        LiveChatTranscriptSelector lctSelectorMock = (LiveChatTranscriptSelector) mocks.mock(LiveChatTranscriptSelector.class);
        PendingServiceRoutingSelector psrSelectorMock = (PendingServiceRoutingSelector) mocks.mock(PendingServiceRoutingSelector.class);
        ServiceResourceSkillSelector srsSelectorMock = (ServiceResourceSkillSelector) mocks.mock(ServiceResourceSkillSelector.class);
        ServiceChannelStatusSelector scsSelectorMock = (ServiceChannelStatusSelector) mocks.mock(ServiceChannelStatusSelector.class);
        UserServicePresenceSelector uspSelectorMock = (UserServicePresenceSelector) mocks.mock(UserServicePresenceSelector.class);
        AgentWorkSelector awSelectorMock = (AgentWorkSelector) mocks.mock(AgentWorkSelector.class);

        mocks.startStubbing();

        LiveChatTranscript testTranscript = new LiveChatTranscript(
            Id = fflib_IDGenerator.generate(LiveChatTranscript.SObjectType),
            Skills__c = 'DACH_English'
        );

        List<LiveChatTranscript> liveChatTrascripts = new List<LiveChatTranscript>();
        liveChatTrascripts.add(testTranscript);

        mocks.when(lctSelectorMock.sObjectType()).thenReturn(LiveChatTranscript.SObjectType);
        mocks.when(lctSelectorMock.selectByIdWithLiveChatButton(new Set<Id>{testTranscript.Id})).thenReturn(new List<LiveChatTranscript>{testTranscript});
        mocks.when(lctSelectorMock.selectBySkillsAndStatusFromLast24Hours(new List<String>{'DACH_English'}, 'Waiting')).thenReturn(liveChatTrascripts);

        mocks.when(psrSelectorMock.sObjectType()).thenReturn(PendingServiceRouting.SObjectType);
        mocks.when(psrSelectorMock.selectByWorkItemIdTransferredAndNotPushed(new Set<Id>{testTranscript.Id})).thenReturn(new List<PendingServiceRouting>());
        
        User testUser = new User(
            Id = fflib_IDGenerator.generate(User.SObjectType)
        );

        ServiceResource sr = new ServiceResource(
            Id = fflib_IDGenerator.generate(ServiceResource.SObjectType),
            RelatedRecordId = testUser.Id
        );

        ServiceResourceSkill srs = new ServiceResourceSkill(
            Id = fflib_IDGenerator.generate(ServiceResourceSkill.SObjectType),
            SkillId = skillNameToIdMap.get('DACH_English'),
            ServiceResourceId = sr.Id,
            ServiceResource = sr
        );
        
        mocks.when(srsSelectorMock.sObjectType()).thenReturn(ServiceResourceSkill.SObjectType);
        mocks.when(srsSelectorMock.selectBySkillIds(new Set<Id>{skillNameToIdMap.get('DACH_English')})).thenReturn(new List<ServiceResourceSkill>{srs});

        ServiceChannel testServiceChannel = new ServiceChannel(
            Id = fflib_IDGenerator.generate(ServiceChannel.SObjectType),
            RelatedEntity = 'LiveChatTranscript'
        );

        ServiceChannelStatus testServiceChannelStatus = new ServiceChannelStatus(
            ServicePresenceStatusId = fflib_IDGenerator.generate(ServiceChannelStatus.SObjectType),
            ServiceChannelId = testServiceChannel.Id,
            ServiceChannel = testServiceChannel
        );

        mocks.when(scsSelectorMock.sObjectType()).thenReturn(ServiceChannelStatus.SObjectType);
        mocks.when(scsSelectorMock.selectByRelatedServiceChannelEntity('LiveChatTranscript')).thenReturn(new List<ServiceChannelStatus>{testServiceChannelStatus});

        UserServicePresence usp = new UserServicePresence(
            Id = fflib_IDGenerator.generate(UserServicePresence.SObjectType),
            ServicePresenceStatusId = testServiceChannelStatus.ServicePresenceStatusId,
            UserId = testUser.Id
        );
        
        mocks.when(uspSelectorMock.sObjectType()).thenReturn(UserServicePresence.SObjectType);
        mocks.when(uspSelectorMock.selectOnlineAgentsByServicePresenceStatusAndUsers(new Set<Id>{testServiceChannelStatus.ServicePresenceStatusId}, new Set<Id>{testUser.Id})).thenReturn(new List<UserServicePresence>{usp});

        AgentWork testAgentWork = new AgentWork(
            Id = fflib_IDGenerator.generate(AgentWork.SObjectType),
            CapacityWeight = 0,
            UserId = testUser.Id
        );

        mocks.when(awSelectorMock.sObjectType()).thenReturn(AgentWork.SObjectType);
        mocks.when(awSelectorMock.selectOpenedAssignedWork(new Set<Id>{usp.UserId})).thenReturn(new List<AgentWork>{testAgentWork});

        mocks.stopStubbing();

        Application.Selector.setMock(lctSelectorMock);
        Application.Selector.setMock(psrSelectorMock);
        Application.Selector.setMock(srsSelectorMock);
        Application.Selector.setMock(scsSelectorMock);
        Application.Selector.setMock(uspSelectorMock);
        Application.Selector.setMock(awSelectorMock);

        BotCheckIfAgentOnlineHandler.BotInput botInput = new BotCheckIfAgentOnlineHandler.BotInput();
        botInput.langCode = 'en-GB';
        botInput.countryCode = 'de';
        botInput.churn = 'false';
        botInput.isFirstCheck = 'false';
        botInput.liveChatTranscriptId = testTranscript.Id;

        List<BotCheckIfAgentOnlineHandler.BotOutput> botOutput = ChatBotService.newInstance().checkIfAgentOnline(new List<BotCheckIfAgentOnlineHandler.BotInput>{botInput});
        system.assertEquals('true', botOutput[0].agentsAvailable);
        system.assertEquals('true', botOutput[0].transferToAgent);
    }

    @isTest
    static void whenCheckOnlineAgentsForBotActionWithAgentOnlineWithWorkTest() {

        Map<String, Id> skillNameToIdMap = new Map<String, Id>();
        for (Skill skill : SkillSelector.newInstance().selectAll()) {
            skillNameToIdMap.put(skill.DeveloperName, skill.Id);
        }

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        LiveChatTranscriptSelector lctSelectorMock = (LiveChatTranscriptSelector) mocks.mock(LiveChatTranscriptSelector.class);
        PendingServiceRoutingSelector psrSelectorMock = (PendingServiceRoutingSelector) mocks.mock(PendingServiceRoutingSelector.class);
        ServiceResourceSkillSelector srsSelectorMock = (ServiceResourceSkillSelector) mocks.mock(ServiceResourceSkillSelector.class);
        ServiceChannelStatusSelector scsSelectorMock = (ServiceChannelStatusSelector) mocks.mock(ServiceChannelStatusSelector.class);
        UserServicePresenceSelector uspSelectorMock = (UserServicePresenceSelector) mocks.mock(UserServicePresenceSelector.class);
        AgentWorkSelector awSelectorMock = (AgentWorkSelector) mocks.mock(AgentWorkSelector.class);

        mocks.startStubbing();

        LiveChatTranscript testTranscript = new LiveChatTranscript(
            Id = fflib_IDGenerator.generate(LiveChatTranscript.SObjectType),
            Skills__c = 'DACH_English'
        );

        List<LiveChatTranscript> liveChatTrascripts = new List<LiveChatTranscript>();
        liveChatTrascripts.add(testTranscript);

        ServiceChannel testServiceChannel = new ServiceChannel(
            Id = fflib_IDGenerator.generate(ServiceChannel.SObjectType),
            RelatedEntity = 'LiveChatTranscript'
        );

        mocks.when(lctSelectorMock.sObjectType()).thenReturn(LiveChatTranscript.SObjectType);
        mocks.when(lctSelectorMock.selectByIdWithLiveChatButton(new Set<Id>{testTranscript.Id})).thenReturn(new List<LiveChatTranscript>{testTranscript});
        mocks.when(lctSelectorMock.selectBySkillsAndStatusFromLast24Hours(new List<String>{'DACH_English'}, 'Waiting')).thenReturn(liveChatTrascripts);

        PendingServiceRouting psr = new PendingServiceRouting(
            WorkItemId = testTranscript.Id,
            CapacityWeight = 3,
            IsReadyForRouting = true,
            ServiceChannelId = testServiceChannel.Id
        );

        mocks.when(psrSelectorMock.sObjectType()).thenReturn(PendingServiceRouting.SObjectType);
        mocks.when(psrSelectorMock.selectByWorkItemIdTransferredAndNotPushed(new Set<Id>{testTranscript.Id})).thenReturn(new List<PendingServiceRouting>{psr});
        
        User testUser = new User(
            Id = fflib_IDGenerator.generate(User.SObjectType)
        );

        ServiceResource sr = new ServiceResource(
            Id = fflib_IDGenerator.generate(ServiceResource.SObjectType),
            RelatedRecordId = testUser.Id
        );

        ServiceResourceSkill srs = new ServiceResourceSkill(
            Id = fflib_IDGenerator.generate(ServiceResourceSkill.SObjectType),
            SkillId = skillNameToIdMap.get('DACH_English'),
            ServiceResourceId = sr.Id,
            ServiceResource = sr
        );
        
        mocks.when(srsSelectorMock.sObjectType()).thenReturn(ServiceResourceSkill.SObjectType);
        mocks.when(srsSelectorMock.selectBySkillIds(new Set<Id>{skillNameToIdMap.get('DACH_English')})).thenReturn(new List<ServiceResourceSkill>{srs});

        ServiceChannelStatus testServiceChannelStatus = new ServiceChannelStatus(
            ServicePresenceStatusId = fflib_IDGenerator.generate(ServiceChannelStatus.SObjectType),
            ServiceChannelId = testServiceChannel.Id,
            ServiceChannel = testServiceChannel
        );

        mocks.when(scsSelectorMock.sObjectType()).thenReturn(ServiceChannelStatus.SObjectType);
        mocks.when(scsSelectorMock.selectByRelatedServiceChannelEntity('LiveChatTranscript')).thenReturn(new List<ServiceChannelStatus>{testServiceChannelStatus});

        UserServicePresence usp = new UserServicePresence(
            Id = fflib_IDGenerator.generate(UserServicePresence.SObjectType),
            ServicePresenceStatusId = testServiceChannelStatus.ServicePresenceStatusId,
            UserId = testUser.Id
        );
        
        mocks.when(uspSelectorMock.sObjectType()).thenReturn(UserServicePresence.SObjectType);
        mocks.when(uspSelectorMock.selectOnlineAgentsByServicePresenceStatusAndUsers(new Set<Id>{testServiceChannelStatus.ServicePresenceStatusId}, new Set<Id>{testUser.Id})).thenReturn(new List<UserServicePresence>{usp});

        AgentWork testAgentWork = new AgentWork(
            Id = fflib_IDGenerator.generate(AgentWork.SObjectType),
            CapacityWeight = 0,
            UserId = testUser.Id
        );

        mocks.when(awSelectorMock.sObjectType()).thenReturn(AgentWork.SObjectType);
        mocks.when(awSelectorMock.selectOpenedAssignedWork(new Set<Id>{usp.UserId})).thenReturn(new List<AgentWork>{testAgentWork});

        mocks.stopStubbing();

        Application.Selector.setMock(lctSelectorMock);
        Application.Selector.setMock(psrSelectorMock);
        Application.Selector.setMock(srsSelectorMock);
        Application.Selector.setMock(scsSelectorMock);
        Application.Selector.setMock(uspSelectorMock);
        Application.Selector.setMock(awSelectorMock);

        BotCheckIfAgentOnlineHandler.BotInput botInput = new BotCheckIfAgentOnlineHandler.BotInput();
        botInput.langCode = 'en-GB';
        botInput.countryCode = 'de';
        botInput.churn = 'false';
        botInput.isFirstCheck = 'false';
        botInput.liveChatTranscriptId = testTranscript.Id;

        List<BotCheckIfAgentOnlineHandler.BotOutput> botOutput = ChatBotService.newInstance().checkIfAgentOnline(new List<BotCheckIfAgentOnlineHandler.BotInput>{botInput});
        system.assertEquals('true', botOutput[0].agentsAvailable);
        system.assertEquals('true', botOutput[0].transferToAgent);
    }

    @isTest
    static void whenCheckOnlineAgentsForBotActionWithAgentOnlineWhenOverloadedTest() {

        Map<String, Id> skillNameToIdMap = new Map<String, Id>();
        for (Skill skill : SkillSelector.newInstance().selectAll()) {
            skillNameToIdMap.put(skill.DeveloperName, skill.Id);
        }

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        LiveChatTranscriptSelector lctSelectorMock = (LiveChatTranscriptSelector) mocks.mock(LiveChatTranscriptSelector.class);
        PendingServiceRoutingSelector psrSelectorMock = (PendingServiceRoutingSelector) mocks.mock(PendingServiceRoutingSelector.class);
        ServiceResourceSkillSelector srsSelectorMock = (ServiceResourceSkillSelector) mocks.mock(ServiceResourceSkillSelector.class);
        ServiceChannelStatusSelector scsSelectorMock = (ServiceChannelStatusSelector) mocks.mock(ServiceChannelStatusSelector.class);
        UserServicePresenceSelector uspSelectorMock = (UserServicePresenceSelector) mocks.mock(UserServicePresenceSelector.class);
        AgentWorkSelector awSelectorMock = (AgentWorkSelector) mocks.mock(AgentWorkSelector.class);

        mocks.startStubbing();

        LiveChatTranscript testTranscript = new LiveChatTranscript(
            Id = fflib_IDGenerator.generate(LiveChatTranscript.SObjectType),
            Skills__c = 'DACH_English'
        );

        LiveChatTranscript testTranscript2 = new LiveChatTranscript(
            Id = fflib_IDGenerator.generate(LiveChatTranscript.SObjectType),
            Skills__c = 'DACH_English'
        );

        List<LiveChatTranscript> liveChatTrascripts = new List<LiveChatTranscript>();
        liveChatTrascripts.add(testTranscript);
        liveChatTrascripts.add(testTranscript2);

        ServiceChannel testServiceChannel = new ServiceChannel(
            Id = fflib_IDGenerator.generate(ServiceChannel.SObjectType),
            RelatedEntity = 'LiveChatTranscript'
        );

        mocks.when(lctSelectorMock.sObjectType()).thenReturn(LiveChatTranscript.SObjectType);
        mocks.when(lctSelectorMock.selectByIdWithLiveChatButton(new Set<Id>{testTranscript.Id})).thenReturn(new List<LiveChatTranscript>{testTranscript});
        mocks.when(lctSelectorMock.selectBySkillsAndStatusFromLast24Hours(new List<String>{'DACH_English'}, 'Waiting')).thenReturn(liveChatTrascripts);

        PendingServiceRouting psr = new PendingServiceRouting(
            WorkItemId = testTranscript.Id,
            CapacityWeight = 3,
            IsReadyForRouting = true,
            ServiceChannelId = testServiceChannel.Id
        );

        PendingServiceRouting psr2 = new PendingServiceRouting(
            WorkItemId = testTranscript2.Id,
            CapacityWeight = 3,
            IsReadyForRouting = true,
            ServiceChannelId = testServiceChannel.Id
        );

        mocks.when(psrSelectorMock.sObjectType()).thenReturn(PendingServiceRouting.SObjectType);
        mocks.when(psrSelectorMock.selectByWorkItemIdTransferredAndNotPushed(new Set<Id>{testTranscript.Id, testTranscript2.Id})).thenReturn(new List<PendingServiceRouting>{psr,psr2});
        
        User testUser = new User(
            Id = fflib_IDGenerator.generate(User.SObjectType)
        );

        ServiceResource sr = new ServiceResource(
            Id = fflib_IDGenerator.generate(ServiceResource.SObjectType),
            RelatedRecordId = testUser.Id
        );

        ServiceResourceSkill srs = new ServiceResourceSkill(
            Id = fflib_IDGenerator.generate(ServiceResourceSkill.SObjectType),
            SkillId = skillNameToIdMap.get('DACH_English'),
            ServiceResourceId = sr.Id,
            ServiceResource = sr
        );
        
        mocks.when(srsSelectorMock.sObjectType()).thenReturn(ServiceResourceSkill.SObjectType);
        mocks.when(srsSelectorMock.selectBySkillIds(new Set<Id>{skillNameToIdMap.get('DACH_English')})).thenReturn(new List<ServiceResourceSkill>{srs});

        ServiceChannelStatus testServiceChannelStatus = new ServiceChannelStatus(
            ServicePresenceStatusId = fflib_IDGenerator.generate(ServiceChannelStatus.SObjectType),
            ServiceChannelId = testServiceChannel.Id,
            ServiceChannel = testServiceChannel
        );

        mocks.when(scsSelectorMock.sObjectType()).thenReturn(ServiceChannelStatus.SObjectType);
        mocks.when(scsSelectorMock.selectByRelatedServiceChannelEntity('LiveChatTranscript')).thenReturn(new List<ServiceChannelStatus>{testServiceChannelStatus});

        UserServicePresence usp = new UserServicePresence(
            Id = fflib_IDGenerator.generate(UserServicePresence.SObjectType),
            ServicePresenceStatusId = testServiceChannelStatus.ServicePresenceStatusId,
            UserId = testUser.Id
        );
        
        mocks.when(uspSelectorMock.sObjectType()).thenReturn(UserServicePresence.SObjectType);
        mocks.when(uspSelectorMock.selectOnlineAgentsByServicePresenceStatusAndUsers(new Set<Id>{testServiceChannelStatus.ServicePresenceStatusId}, new Set<Id>{testUser.Id})).thenReturn(new List<UserServicePresence>{usp});

        AgentWork testAgentWork = new AgentWork(
            Id = fflib_IDGenerator.generate(AgentWork.SObjectType),
            CapacityWeight = 6,
            UserId = testUser.Id
        );

        mocks.when(awSelectorMock.sObjectType()).thenReturn(AgentWork.SObjectType);
        mocks.when(awSelectorMock.selectOpenedAssignedWork(new Set<Id>{usp.UserId})).thenReturn(new List<AgentWork>{testAgentWork});

        mocks.stopStubbing();

        Application.Selector.setMock(lctSelectorMock);
        Application.Selector.setMock(psrSelectorMock);
        Application.Selector.setMock(srsSelectorMock);
        Application.Selector.setMock(scsSelectorMock);
        Application.Selector.setMock(uspSelectorMock);
        Application.Selector.setMock(awSelectorMock);

        BotCheckIfAgentOnlineHandler.BotInput botInput = new BotCheckIfAgentOnlineHandler.BotInput();
        botInput.langCode = 'en-GB';
        botInput.countryCode = 'de';
        botInput.churn = 'false';
        botInput.isFirstCheck = 'false';
        botInput.liveChatTranscriptId = testTranscript.Id;

        List<BotCheckIfAgentOnlineHandler.BotOutput> botOutput = ChatBotService.newInstance().checkIfAgentOnline(new List<BotCheckIfAgentOnlineHandler.BotInput>{botInput});
    
        system.assertEquals('true', botOutput[0].agentsAvailable);
        system.assertEquals(null, botOutput[0].transferToAgent);
        system.assertEquals('3', botOutput[0].customersInQueue);
    }

	@IsTest
    private static void userIntentMatchesWithContactUsOptions() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BotIntentCaseMappingSelector selectorMock = (BotIntentCaseMappingSelector) mocks.mock(BotIntentCaseMappingSelector.class);

        String intent = 'test intent';
        String type = 'test type';
        String subtype = 'test subtype';
        String subtype2 = 'test subtype2';

        // Given
        BotMapIntentToContactUsOptionHandler.BotInput botInput = new BotMapIntentToContactUsOptionHandler.BotInput();
        botInput.dialogName = intent;
        List<BotMapIntentToContactUsOptionHandler.BotInput> botInputs = new List<BotMapIntentToContactUsOptionHandler.BotInput>{BotInput};

        String mdtId = fflib_IDGenerator.generate(Bot_Intent_Case_Mapping__mdt.SObjectType);
        Map<String,Bot_Intent_Case_Mapping__mdt> testBotIntentCaseMappings = new Map<String,Bot_Intent_Case_Mapping__mdt> {
            mdtId => new Bot_Intent_Case_Mapping__mdt(
                Id = mdtId,
                Bot_Intent__c = intent,
                Type_Key__c = type,
                SubType_Key__c = subtype,
                SubType2_Key__c = subtype2
            )
        };

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Bot_Intent_Case_Mapping__mdt.SObjectType);
        mocks.when(selectorMock.selectAll()).thenReturn(testBotIntentCaseMappings);
        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);

        // When
        List<BotMapIntentToContactUsOptionHandler.BotOutput> result = ChatBotService.newInstance().mapIntentToContactUsOption(BotInputs);

        // Then
        ((BotIntentCaseMappingSelector) mocks.verify(selectorMock, 1)).selectAll();
        System.assertEquals(1, result.size(), 'Case Intent should be mapped with a Contact Us option');
        System.assertEquals(type, result[0].typeKey, 'Type value is not correctly set');
        System.assertEquals(subtype, result[0].subtypeKey, 'Subtype value is not correctly set');
        System.assertEquals(subtype2, result[0].subtype2Key, 'Subtype2 value is not correctly set');
    }

    @IsTest
    private static void userIntentDoesNotMatchWithAnyContactUsOption() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BotIntentCaseMappingSelector selectorMock = (BotIntentCaseMappingSelector) mocks.mock(BotIntentCaseMappingSelector.class);

        String dialog = 'test dialog';
        String intent = 'test intent';
        String type = 'test type';
        String subtype = 'test subtype';
        String subtype2 = 'test subtype2';

        // Given
        BotMapIntentToContactUsOptionHandler.BotInput botInput = new BotMapIntentToContactUsOptionHandler.BotInput();
        botInput.dialogName = dialog;
        List<BotMapIntentToContactUsOptionHandler.BotInput> botInputs = new List<BotMapIntentToContactUsOptionHandler.BotInput>{BotInput};

        String mdtId = fflib_IDGenerator.generate(Bot_Intent_Case_Mapping__mdt.SObjectType);
        Map<String,Bot_Intent_Case_Mapping__mdt> testBotIntentCaseMappings = new Map<String,Bot_Intent_Case_Mapping__mdt> {
            mdtId => new Bot_Intent_Case_Mapping__mdt(
                Id = mdtId,
                Bot_Intent__c = intent,
                Type_Key__c = type,
                SubType_Key__c = subtype,
                SubType2_Key__c = subtype2
            )
        };

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Bot_Intent_Case_Mapping__mdt.SObjectType);
        mocks.when(selectorMock.selectAll()).thenReturn(testBotIntentCaseMappings);
        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);

        // When
        List<BotMapIntentToContactUsOptionHandler.BotOutput> result = ChatBotService.newInstance().mapIntentToContactUsOption(BotInputs);

        // Then
        ((BotIntentCaseMappingSelector) mocks.verify(selectorMock, 1)).selectAll();
        System.assertEquals(0, result.size(), 'Case Intent should not be mapped with any Contact Us option');
    }

    @IsTest
    static void shouldUpdateDialogInstancesOnDialogCompletion() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        LiveChatTranscript testTranscript = new LiveChatTranscript(
                Id = fflib_IDGenerator.generate(LiveChatTranscript.SObjectType)
        );

        Bot_Dialog_Instance__c botInstance = new Bot_Dialog_Instance__c(
                Id = fflib_IDGenerator.generate(Bot_Dialog_Instance__c.SObjectType),
                RecordTypeId = Schema.SObjectType.Bot_Dialog_Instance__c.getRecordTypeInfosByName()
                        .get(ChatBotService.RECORD_TYPE_NAME_DIALOG).getRecordTypeId(),
                Chat_Transcript__c = testTranscript.Id,
                Dialog_Name__c = 'testSolution',
                Goal_Name__c = 'testGoal',
                Type__c = 'Rating',
                Status__c = ChatBotService.STATUS_NAME_REDIRECTED
        );

        BotDialogCompletionHandler.DialogCompletionOutput botOutput = new BotDialogCompletionHandler.DialogCompletionOutput();
        botOutput.sCurrentDialog = 'testDialog';
        botOutput.bRating = true;

        BotDialogCompletionHandler.DialogCompletionWrapper dialogCompletionWrapper = new BotDialogCompletionHandler.DialogCompletionWrapper();
        dialogCompletionWrapper.sLastCustomerInput = 'Test';
        dialogCompletionWrapper.systemLastCustomerInput = 'TESTing';
        dialogCompletionWrapper.rating = true;


        Map<String, BotDialogCompletionHandler.DialogCompletionWrapper> mapCompletionWrappersByStrings = new Map<String, BotDialogCompletionHandler.DialogCompletionWrapper>();
        mapCompletionWrappersByStrings.put(botInstance.Dialog_Name__c, dialogCompletionWrapper);

        Application.UnitOfWork.setMock(uowMock);

        ChatBotService.newInstance().updateDialogInstancesOnDialogCompletion(new List<Bot_Dialog_Instance__c>{botInstance}, mapCompletionWrappersByStrings);

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }
*/
}