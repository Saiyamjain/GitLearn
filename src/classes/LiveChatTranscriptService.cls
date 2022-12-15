public with sharing class LiveChatTranscriptService {

    public static final String TYPE_ESCALATE = 'Escalate';
    public static final String NO_AGENT_AVAILABLE_DIALOG_NAME = 'No Agent Available';

    public void updateLiveChatTranscriptBotAction(List<BotUpdateLiveChatTranscriptHandler.updateLiveChatTranscriptInput> botInputs) {
        Set<Id> associatedLiveChatTranscriptIds = new Set<Id>();
        for(BotUpdateLiveChatTranscriptHandler.updateLiveChatTranscriptInput botInput : botInputs) {
            associatedLiveChatTranscriptIds.add(botInput.liveChatId);
        }
        Map<String,LiveChatTranscript> associatedLiveChatTranscripts = new Map<String,LiveChatTranscript>(LiveChatTranscriptSelector.newInstance().selectById(associatedLiveChatTranscriptIds));
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        for(BotUpdateLiveChatTranscriptHandler.updateLiveChatTranscriptInput botInput : botInputs) {
            if(associatedLiveChatTranscripts.containsKey(botInput.liveChatId)) {
                LiveChatTranscript transcriptToUpdate = associatedLiveChatTranscripts.get(botInput.liveChatId);
                if(String.isNotBlank(botInput.accountId)) {
                    transcriptToUpdate.Account_Id__c = botInput.accountId;
                }
                if(String.isNotBlank(botInput.description)) {
                    transcriptToUpdate.Case_Description__c = botInput.description;
                }
                transcriptToUpdate.Case_Origin__c = botInput.caseOrigin;
                transcriptToUpdate.First_Name__c = botInput.firstName;
                transcriptToUpdate.Notification_Country_Code__c = botInput.notificationCountryCode;
                transcriptToUpdate.Notification_Language_Code__c = botInput.notificationLanguageCode;
                transcriptToUpdate.Type__c = botInput.type;
                transcriptToUpdate.Sub_Type__c = botInput.subType;
                transcriptToUpdate.Sub_Type2__c = botInput.subType2;
                transcriptToUpdate.Subject__c = botInput.subject;
                transcriptToUpdate.Supplied_Email__c = botInput.email;
                transcriptToUpdate.Case_SLA__c = botInput.sla;
                transcriptToUpdate.Case_Priority__c = botInput.priority;
                uow.registerDirty(transcriptToUpdate);
            }
        }
        uow.commitWork();
    }

    public void updateLiveChatTranscriptOnInitialization(List<BotDialogInitializationHandler.DialogInitializationInput> dialogInputs, Set<String> dialogNames, Set<Id> transcriptIds) {
        List<Bot_Dialog__c> dialogs = BotDialogSelector.newInstance().selectByDialogName(dialogNames);
        Map<String, Bot_Dialog__c> dialogsByName = new Map<String, Bot_Dialog__c>();
        for (Bot_Dialog__c botDialog : dialogs) {
            dialogsByName.put(botDialog.Dialog_Name__c, botDialog);
        }

        List<String> dialoguesForClassification = new List<String>();
        for (Bot_Intent_Case_Mapping__mdt botIntentCaseMapping : BotIntentCaseMappingSelector.newInstance().selectAll().values()) {
            dialoguesForClassification.add(botIntentCaseMapping.Bot_Intent__c);
        }

        List<LiveChatTranscript> updatedChatTranscripts = new List<LiveChatTranscript>();
        for (BotDialogInitializationHandler.DialogInitializationInput dialogInput : dialogInputs) {
            Bot_Dialog__c dialogData = dialogsByName.get(dialogInput.currentDialogName);
            for (LiveChatTranscript liveChatTranscript : LiveChatTranscriptSelector.newInstance().selectById(transcriptIds)) {
                if (String.isBlank(liveChatTranscript.Bot_First_Owner_Id__c)) {
                    liveChatTranscript.Bot_First_Owner_Id__c = liveChatTranscript.OwnerId;
                    liveChatTranscript.Bot_Name__c = dialogData.Bot_Name__c;
                }
                if (dialoguesForClassification.contains(dialogInput.currentDialogName)) {
                    liveChatTranscript.Latest_Dialog_For_Categorisation__c = dialogInput.currentDialogName;
                }
                updatedChatTranscripts.add(liveChatTranscript);
            }
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(updatedChatTranscripts);
        uow.commitWork();
    }

    public void updateLiveChatTranscriptOnCompletion(List<Bot_Dialog_Instance__c> dialogInstancesToUpsert, Map<Id, LiveChatTranscript> chatTranscriptsByIds) {
        List<LiveChatTranscript> chatTranscriptsToUpdate = new List<LiveChatTranscript>();
        for (Bot_Dialog_Instance__c dialogInstanceToUpsert : dialogInstancesToUpsert) {
            String dialogName = dialogInstanceToUpsert.Dialog_Name__c;
            if (chatTranscriptsByIds.containsKey(dialogInstanceToUpsert.Chat_Transcript__c)) {
                LiveChatTranscript chatTranscriptToUpdate = chatTranscriptsByIds.get(dialogInstanceToUpsert.Chat_Transcript__c);
                if (dialogInstanceToUpsert.Type__c?.equalsIgnoreCase(LiveChatTranscriptService.TYPE_ESCALATE) == true) {
                    chatTranscriptToUpdate.Agent_Transfer_Time__c = Datetime.now();
                }
                if (dialogName.equalsIgnoreCase(LiveChatTranscriptService.NO_AGENT_AVAILABLE_DIALOG_NAME)) {
                    chatTranscriptToUpdate.Agent_End_Time__c = Datetime.now();
                }
                chatTranscriptsToUpdate.add(chatTranscriptToUpdate);
            }
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(chatTranscriptsToUpdate);
        uow.commitWork();
    }

    public Map<Id, Case> getConnectedCases(Set<Id> ids) {
        Map<Id, LiveChatTranscript> liveChatTranscriptsByIds = new Map<Id, LiveChatTranscript>(LiveChatTranscriptSelector.newInstance().selectById(ids));
        Set<Id> caseIds = new Set<Id>();
        for (LiveChatTranscript transcript : liveChatTranscriptsByIds.values()) {
            if (String.isNotBlank(transcript.CaseId)) {
                caseIds.add(transcript.CaseId);
            }
        }
        Map<Id, Case> result = new Map<Id, Case>();
        if (!caseIds.isEmpty()) {
            Map<Id, Case> casesByIds = new Map<Id, Case>(CaseSelector.newInstance().selectById(caseIds));
            for (Id id : ids) {
                LiveChatTranscript transcript = liveChatTranscriptsByIds.get(id);
                if (transcript != null) {
                    result.put(id, casesByIds.get(transcript.CaseId));
                }
            }
        }
        return result;
    }

    public static LiveChatTranscriptService newInstance() {
        return (LiveChatTranscriptService) Application.Service.newInstance(LiveChatTranscriptService.class);
    }
}