public without sharing class ChatBotService {

    public static final String RECORD_TYPE_NAME_DIALOG = 'Dialog';
    public static final String RECORD_TYPE_NAME_GOAL = 'Goal';
    public static final String STATUS_NAME_ABANDONED = 'Abandoned';
    public static final String STATUS_NAME_REDIRECTED = 'Redirected';
    public static final String STATUS_NAME_COMPLETED = 'Completed';
    public static final String ORIGIN_NAME_NLP = 'NLP';
    public static final String ORIGIN_NAME_NAVIGATION = 'Navigation';
    public static final String ORIGIN_NAME_REDIRECT = 'Redirect';
    public static final String TYPE_RATING = 'Rating';
    public static final String RATING_SUCCESS = 'Success';
    public static final String RATING_FAILURE = 'Failure';
/*
    public Static List<BotDialogInitializationHandler.DialogInitializationOutput> initializeBotDialogInstance(List<BotDialogInitializationHandler.DialogInitializationInput> dialogInputs, Set<String> dialogNames, Set<Id> transcriptIds) {
        List<BotDialogInitializationHandler.DialogInitializationOutput> dialogOutputs = new List<BotDialogInitializationHandler.DialogInitializationOutput>();

        List<Bot_Dialog__c> dialogs = BotDialogSelector.newInstance().selectByDialogName(dialogNames);
        Map<String, Bot_Dialog__c> dialogsByName = new Map<String, Bot_Dialog__c>();
        for (Bot_Dialog__c botDialog : dialogs) {
            dialogsByName.put(botDialog.Dialog_Name__c, botDialog);
        }

        for (BotDialogInitializationHandler.DialogInitializationInput dialogInput : dialogInputs) {
            BotDialogInitializationHandler.DialogInitializationOutput dialogOutput = new BotDialogInitializationHandler.DialogInitializationOutput();
            Bot_Dialog__c dialogData = dialogsByName.get(dialogInput.currentDialogName);

            Bot_Dialog_Instance__c newDialogInstance = new Bot_Dialog_Instance__c();
            newDialogInstance.Chat_Transcript__c = dialogInput.routableId;
            newDialogInstance.Dialog_Name__c = dialogInput.currentDialogName;
            //newDialogInstance.Label__c = formatAPIName(dialogInput.currentDialogName);
            newDialogInstance.RecordTypeId = Schema.SObjectType.Bot_Dialog_Instance__c.getRecordTypeInfosByName()
                    .get(ChatBotService.RECORD_TYPE_NAME_DIALOG).getRecordTypeId();
            newDialogInstance.Type__c = dialogData.Type__c;
            //newDialogInstance.Goal_Name__c = ChatBotService.getNewDialogGoalName(dialogData.Goal_Name__c, dialogInput.sCurrentGoal, dialogData.Type__c);

            List<Bot_Dialog_Instance__c> existingDialogInstances = BotDialogInstanceSelector.newInstance().selectByTranscriptId(transcriptIds);
            List<Bot_Dialog_Instance__c> newDialogInstances = new List<Bot_Dialog_Instance__c>();
            Bot_Dialog_Instance__c latestDialogInstance;
            if (!existingDialogInstances.isEmpty()) {
                for (Bot_Dialog_Instance__c existingDialogInstance : existingDialogInstances) {
                    if (existingDialogInstance.Chat_Transcript__c == newDialogInstance.Chat_Transcript__c && (latestDialogInstance == null || existingDialogInstance.Name > latestDialogInstance.Name)) {
                        latestDialogInstance = existingDialogInstance;
                    }
                }
            }

            if (latestDialogInstance != null && (latestDialogInstance.Status__c?.equalsIgnoreCase(STATUS_NAME_REDIRECTED) == true  || latestDialogInstance.Status__c?.equalsIgnoreCase(STATUS_NAME_ABANDONED) == true)) {
                if (newDialogInstance.Goal_Name__c != latestDialogInstance.Goal_Name__c) {
                    latestDialogInstance.Status__c = STATUS_NAME_ABANDONED;
                } else if (newDialogInstance.Goal_Name__c == latestDialogInstance.Goal_Name__c && dialogInput.currentDialogName != dialogInput.sCurrentDialog) {
                    latestDialogInstance.Status__c = STATUS_NAME_REDIRECTED;
                }

                if (dialogInput.sLastCustomerInput != dialogInput.systemLastCustomerInput && (latestDialogInstance.Status__c?.equalsIgnoreCase(STATUS_NAME_REDIRECTED) == true || latestDialogInstance.Status__c?.equalsIgnoreCase(STATUS_NAME_ABANDONED) == true)) {
                    latestDialogInstance.Last_Customer_Input__c = dialogInput.systemLastCustomerInput;
                }

                latestDialogInstance.Last_Step__c = dialogInput.sCurrentStep;
                newDialogInstances.add(latestDialogInstance);
            }

            if (dialogInput.systemLastCustomerInput != dialogInput.sLastCustomerInput && (latestDialogInstance == null || latestDialogInstance.Last_Customer_Input__c != dialogInput.systemLastCustomerInput)) {
                newDialogInstance.Last_Customer_Input__c = dialogInput.systemLastCustomerInput;
            }

            if (dialogInput.sLastCustomerInput != dialogInput.systemLastCustomerInput && dialogInput.systemLastCustomerInput != null && latestDialogInstance?.Goal_Name__c != newDialogInstance.Goal_Name__c && newDialogInstance.Goal_Name__c != null) {
                newDialogInstance.Origin__c = ORIGIN_NAME_NLP;
                newDialogInstance.Triggering_Customer_Input__c = dialogInput.systemLastCustomerInput;
            } else if (latestDialogInstance != null && latestDialogInstance.Type__c?.equalsIgnoreCase(ORIGIN_NAME_NAVIGATION) == true) {
                newDialogInstance.Origin__c = ORIGIN_NAME_NAVIGATION;
            } else {
                newDialogInstance.Origin__c = ORIGIN_NAME_REDIRECT;
            }
            newDialogInstances.add(newDialogInstance);

            dialogOutput.sCurrentDialog = newDialogInstance.Dialog_Name__c;
            dialogOutput.sCurrentDialogType = dialogData.Type__c;
            dialogOutput.sCurrentGoal = newDialogInstance.Goal_Name__c;
            dialogOutput.sCurrentStep = null;
            dialogOutput.sLastCustomerInput = dialogInput.systemLastCustomerInput;
            dialogOutputs.add(dialogOutput);

            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            uow.registerUpsert(newDialogInstances);
            uow.commitWork();
        }

        return dialogOutputs;
    }

    public Static List<BotDialogCompletionHandler.DialogCompletionOutput> updateDialogInstancesOnDialogCompletion(List<Bot_Dialog_Instance__c> dialogInstancesToUpsert, Map<String, BotDialogCompletionHandler.DialogCompletionWrapper> dialogCompletionWrapperByDialogName) {
        List<BotDialogCompletionHandler.DialogCompletionOutput> dialogCompletionOutputs = new List<BotDialogCompletionHandler.DialogCompletionOutput>();

        for (Bot_Dialog_Instance__c dialogInstanceToUpsert : dialogInstancesToUpsert) {
            if (isLastOfChat(dialogInstancesToUpsert, dialogInstanceToUpsert)) {
                String dialogName = dialogInstanceToUpsert?.Dialog_Name__c;
                if (dialogInstanceToUpsert.Type__c?.equalsIgnoreCase(TYPE_RATING) == true) {
                    Boolean incomingBRating = dialogCompletionWrapperByDialogName.get(dialogName).rating;
                    if (incomingBRating != null && dialogInstanceToUpsert.Type__c?.equalsIgnoreCase(TYPE_RATING) == true && dialogInstanceToUpsert.Rating__c == null && !dialogInstanceToUpsert.Status__c?.equalsIgnoreCase(STATUS_NAME_COMPLETED)) {
                        dialogInstanceToUpsert.Rating__c = incomingBRating ? RATING_SUCCESS : RATING_FAILURE;
                    }
                }

                String incomingLastCustomerInput = dialogCompletionWrapperByDialogName.get(dialogName)?.systemLastCustomerInput;
                String incomingSLastCustomerInput = dialogCompletionWrapperByDialogName.get(dialogName)?.sLastCustomerInput;
                if (incomingLastCustomerInput != null && incomingLastCustomerInput != incomingSLastCustomerInput && String.isNotBlank(incomingLastCustomerInput)) {
                    dialogInstanceToUpsert.Last_Customer_Input__c = incomingLastCustomerInput;
                }

                if (dialogInstanceToUpsert.Status__c?.equalsIgnoreCase(STATUS_NAME_COMPLETED) != true) {
                    dialogInstanceToUpsert.Status__c = STATUS_NAME_COMPLETED;
                    dialogInstanceToUpsert.Last_Step__c = null;
                }
            }

            BotDialogCompletionHandler.DialogCompletionOutput dialogCompletionOutput = new BotDialogCompletionHandler.DialogCompletionOutput();
            dialogCompletionOutput.sCurrentDialog = dialogInstanceToUpsert.Dialog_Name__c;
            dialogCompletionOutput.sCurrentDialogType = dialogInstanceToUpsert.Type__c;
            dialogCompletionOutput.sLastCustomerInput = dialogCompletionWrapperByDialogName.get(dialogInstanceToUpsert.Dialog_Name__c)?.systemLastCustomerInput;
            dialogCompletionOutput.sCurrentStep = null;
            dialogCompletionOutputs.add(dialogCompletionOutput);
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerUpsert(dialogInstancesToUpsert);
        uow.commitWork();

        return dialogCompletionOutputs;
    }

    public Static List<BotCheckIfAgentOnlineHandler.BotOutput> checkIfAgentOnline(List<BotCheckIfAgentOnlineHandler.BotInput> botInputs) {
        List<Skill_Requirements_Setting__mdt> skillRequirementSettings = SkillRequirementsSettingSelector.newInstance().selectAll();

        Map<String, Id> skillNameToIdMap = new Map<String, Id>();
        for (Skill skill : SkillSelector.newInstance().selectAll()) {
            skillNameToIdMap.put(skill.DeveloperName, skill.Id);
        }

        Map<String, Skill_Requirements_Setting__mdt> skillRequirementSettingsMap = new Map<String, Skill_Requirements_Setting__mdt>();
        Map<Id, LiveChatTranscript> liveChatTranscriptsByIds = new Map<Id, LiveChatTranscript>();
        for (BotCheckIfAgentOnlineHandler.BotInput input : botInputs) {
            liveChatTranscriptsByIds.put(input.liveChatTranscriptId, null);
            Skill_Requirements_Setting__mdt skillReqSetting = CaseDomain.getSkillReqSettingByLangAndCtryCode(skillRequirementSettings, input.langCode, input.countryCode, Boolean.valueOf(input.churn));
            skillRequirementSettingsMap.put(input.langCode + input.countryCode, skillReqSetting);
        }
        liveChatTranscriptsByIds = new Map<Id, LiveChatTranscript>(LiveChatTranscriptSelector.newInstance().selectByIdWithLiveChatButton(liveChatTranscriptsByIds.keySet()));
        List<String> skillIds = new List<String>();
        Map<String,List<Id>> liveChatTranscriptIdsBySkill = new Map<String,List<Id>>();
        Set<Id> liveChatTranscriptIds = new Set<Id>();
        for(Skill_Requirements_Setting__mdt skillReqSetting : skillRequirementSettingsMap.values()) {
            skillIds.add(skillReqSetting.Skill__c);
        }
        for(LiveChatTranscript liveChatTranscript : LiveChatTranscriptSelector.newInstance().selectBySkillsAndStatusFromLast24Hours(skillIds, 'Waiting')) {
            if(!liveChatTranscriptIdsBySkill.containsKey(liveChatTranscript.Skills__c)) {
                liveChatTranscriptIdsBySkill.put(liveChatTranscript.Skills__c, new List<Id>());
            }
            liveChatTranscriptIdsBySkill.get(liveChatTranscript.Skills__c).add(liveChatTranscript.Id);
            liveChatTranscriptIds.add(liveChatTranscript.Id);
        }

        Map<String,Integer> psrSizeBySkillIds = new Map<String,Integer>();
        for(String SkillId : liveChatTranscriptIdsBySkill.keySet()) {
            psrSizeBySkillIds.put(skillNameToIdMap.get(SkillId), 0);
        }

        for(PendingServiceRouting psr : PendingServiceRoutingSelector.newInstance().selectByWorkItemIdTransferredAndNotPushed(liveChatTranscriptIds)) {
            for(String SkillId : liveChatTranscriptIdsBySkill.keySet()) {
                List<Id> liveChatTranscriptIdsForSkill = liveChatTranscriptIdsBySkill.get(SkillId);
                if(!liveChatTranscriptIdsForSkill.isEmpty()) {
                    for(Id liveChatTranscriptId : liveChatTranscriptIdsForSkill) {
                        if(liveChatTranscriptId == psr.WorkItemId) {
                            psrSizeBySkillIds.put(skillNameToIdMap.get(SkillId), psrSizeBySkillIds.get(skillNameToIdMap.get(SkillId)) + 1);
                            break;
                        }
                    }
                }
            }
        }

        List<BotCheckIfAgentOnlineHandler.BotOutput> botOutputs = new List<BotCheckIfAgentOnlineHandler.BotOutput>();

        for (BotCheckIfAgentOnlineHandler.BotInput input : botInputs) {
            botOutputs.add(createCheckIfAgentOnlineOutput(input, skillRequirementSettingsMap, skillNameToIdMap, liveChatTranscriptsByIds.get(input.liveChatTranscriptId), psrSizeBySkillIds));
        }
        return botOutputs;
    }

    public Static List<BotMapIntentToContactUsOptionHandler.BotOutput> mapIntentToContactUsOption(List<BotMapIntentToContactUsOptionHandler.BotInput> botInputs) {
        List<BotMapIntentToContactUsOptionHandler.BotOutput> outputs = new List<BotMapIntentToContactUsOptionHandler.BotOutput>();
        Map<String,Bot_Intent_Case_Mapping__mdt> botCaseMappingToIntentName = new Map<String,Bot_Intent_Case_Mapping__mdt>();
        for (Bot_Intent_Case_Mapping__mdt botIntentCaseMapping : BotIntentCaseMappingSelector.newInstance().selectAll().values()) {
            botCaseMappingToIntentName.put(botIntentCaseMapping.Bot_Intent__c, botIntentCaseMapping);
        }

        for(BotMapIntentToContactUsOptionHandler.BotInput botInput : botInputs) {
            if(botCaseMappingToIntentName.containsKey(botInput.dialogName)) {
                BotMapIntentToContactUsOptionHandler.BotOutput output = new BotMapIntentToContactUsOptionHandler.BotOutput();
                output.typeKey = botCaseMappingToIntentName.get(botInput.dialogName).Type_Key__c;
                output.subtypeKey = botCaseMappingToIntentName.get(botInput.dialogName).SubType_Key__c;
                output.subtype2Key = botCaseMappingToIntentName.get(botInput.dialogName).SubType2_Key__c;
                outputs.add(output);
            }
        }
        return outputs;
    }

    public Static String formatAPIName(String apiName) {
        return apiName.replace('_', ' ');
    }

    public Static BotCheckIfAgentOnlineHandler.BotOutput createCheckIfAgentOnlineOutput(BotCheckIfAgentOnlineHandler.BotInput botInput, Map<String, Skill_Requirements_Setting__mdt> skillRequirementSettingsMap, Map<String, Id> skillNameToIdMap, LiveChatTranscript transcriptWork, Map<String,Integer> psrSizeBySkillIds) {
        BotCheckIfAgentOnlineHandler.BotOutput botOutput = new BotCheckIfAgentOnlineHandler.BotOutput();
        botOutput.agentsAvailable = 'false';
        botOutput.transferToAgent = 'false';
        botOutput.transferToAgentBool = false;
        botOutput.skillIds = new List<Id>();

        Map<Id, Decimal> remainingCapacity = new Map<Id, Decimal>();
        Decimal capacityWeightForNewTranscript = 0;
        Boolean isChurnCustomer = false;
        Boolean isFirstCheck = true;
        Boolean isAgentAvailable = false;
        Boolean hasQueue = false;

        if(Test.isRunningTest()){
            capacityWeightForNewTranscript = 2;
            hasQueue = true;
        }

        if(botInput.churn != null){
            isChurnCustomer = Boolean.valueOf(botInput.churn);
        }
        if(botInput.isFirstCheck != null){
            isFirstCheck = Boolean.valueOf(botInput.isFirstCheck);
        }

        Skill_Requirements_Setting__mdt skillReqSetting = skillRequirementSettingsMap.get(botInput.langCode + botInput.countryCode);
        String skillId = skillNameToIdMap.get(skillReqSetting.Skill__c);
        Decimal maxQueueSizePerAgent = skillReqSetting.Chat_Queue_Size_Per_Agent__c;

        botOutput.skillIds.add(skillId);

        if(transcriptWork != null && transcriptWork.LiveChatButton != null && transcriptWork.LiveChatButton.RoutingConfiguration != null){
            capacityWeightForNewTranscript = transcriptWork.LiveChatButton.RoutingConfiguration.CapacityWeight;
            hasQueue = transcriptWork.LiveChatButton.HasQueue;
        }

        remainingCapacity = calculateRemainingCapacity(skillId);

        for(Id userId : remainingCapacity.keySet()){
            if(capacityWeightForNewTranscript != null && remainingCapacity.get(userId) >= capacityWeightForNewTranscript){
                botOutput.agentsAvailable = 'true';
                isAgentAvailable = true;
                if(isChurnCustomer || isFirstCheck){
                    botOutput.transferToAgent = null;
                    botOutput.transferToAgentBool = null;
                } else {
                    botOutput.transferToAgent = 'true';
                    botOutput.transferToAgentBool = true;
                }
                break;
            }
        }
        if(!isAgentAvailable && remainingCapacity.keySet() != null && remainingCapacity.keySet().size() > 0 && hasQueue && maxQueueSizePerAgent != null && maxQueueSizePerAgent > 0 && psrSizeBySkillIds.containsKey(skillId)){
            Integer queuePosition = psrSizeBySkillIds.get(skillId) + 1;
            Decimal maxQueueSize = maxQueueSizePerAgent * remainingCapacity.keySet().size();
            if((queuePosition <= maxQueueSize && isFirstCheck) || !isFirstCheck){
                botOutput.agentsAvailable = 'true';
                botOutput.transferToAgent = null;
                botOutput.transferToAgentBool = null;
                botOutput.customersInQueue = String.valueOf(queuePosition);
            }
        }
        return botOutput;
    }

    public Static Map<Id, Decimal> calculateRemainingCapacity(String skillId){

        Map<Id, Decimal> remainingCapacity = new Map<Id, Decimal>();
        Set<Id> userIdsRelatedRecord = new Set<Id>();
        for(ServiceResourceSkill srs: ServiceResourceSkillSelector.newInstance().selectBySkillIds(new Set<Id>{skillId})){
            userIdsRelatedRecord.add(srs.ServiceResource.RelatedRecordId);
        }

        Set<Id> servicePresenceStatusIds = new Set<Id>();
        for(ServiceChannelStatus serviceChannelStatuses : ServiceChannelStatusSelector.newInstance().selectByRelatedServiceChannelEntity(LiveChatTranscript.SObjectType.getDescribe().name)) {
            servicePresenceStatusIds.add(serviceChannelStatuses.ServicePresenceStatusId);
        }
        for(UserServicePresence usp : UserServicePresenceSelector.newInstance().selectOnlineAgentsByServicePresenceStatusAndUsers(servicePresenceStatusIds, userIdsRelatedRecord)){ //put this in custom label
            remainingCapacity.put(usp.UserId, (Test.isRunningTest() ? 5.00 : usp.ConfiguredCapacity));
        }
        for(AgentWork aw : AgentWorkSelector.newInstance().selectOpenedAssignedWork(remainingCapacity.keySet())){
            remainingCapacity.put(aw.UserId, remainingCapacity.get(aw.UserId) - aw.CapacityWeight);
        }

        return remainingCapacity;
    }

    public static Boolean isLastOfChat(List<Bot_Dialog_Instance__c> dialogInstancesToUpsert, Bot_Dialog_Instance__c dialogInstanceToUpsert) {
        Map<Id, List<Bot_Dialog_Instance__c>> bodyDialogInstancesByChat = new Map<Id, List<Bot_Dialog_Instance__c>>();
        Set<Id> bodyDialogInstancesChats = new Set<Id>();
        Datetime lastCreatedDate;

        for (Bot_Dialog_Instance__c bdi : dialogInstancesToUpsert) {
            Id chatTranscriptId = bdi.Chat_Transcript__c;
            bodyDialogInstancesChats.add(chatTranscriptId);
            if (bodyDialogInstancesByChat.containsKey(chatTranscriptId)) {
                List<Bot_Dialog_Instance__c> alreadyOnMap = bodyDialogInstancesByChat.get(chatTranscriptId);
                alreadyOnMap.add(bdi);
                bodyDialogInstancesByChat.put(chatTranscriptId, alreadyOnMap);
            } else {
                List<Bot_Dialog_Instance__c> bodyDialogInstancesByThisChat = new List<Bot_Dialog_Instance__c>();
                bodyDialogInstancesByThisChat.add(bdi);
                bodyDialogInstancesByChat.put(chatTranscriptId, bodyDialogInstancesByThisChat);
            }
        }

        for (Id chatTranscriptId : bodyDialogInstancesChats) {
            if (bodyDialogInstancesByChat.containsKey(chatTranscriptId)) {
                List<Bot_Dialog_Instance__c> bdisOfChat = bodyDialogInstancesByChat.get(chatTranscriptId);
                for (Bot_Dialog_Instance__c bdi : bdisOfChat) {
                    if (lastCreatedDate == null || lastCreatedDate < bdi.CreatedDate) {
                        lastCreatedDate = bdi.CreatedDate;
                    }
                }
                for (Bot_Dialog_Instance__c bdi : bdisOfChat) {
                    if (bdi == dialogInstanceToUpsert && bdi.CreatedDate == lastCreatedDate) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    public Static String getNewDialogGoalName(String dialogGoalName, String sCurrentGoal, String dialogType) {
        if (dialogType == 'Navigation') {
            return null;
        }

        if (dialogGoalName != null && !String.isBlank(dialogGoalName)) {
            return dialogGoalName;
        } else {
            return sCurrentGoal;
        }
    }

    public static ChatBotService newInstance() {
        return (ChatBotService) Application.Service.newInstance(ChatBotService.class);
    }

 */
}