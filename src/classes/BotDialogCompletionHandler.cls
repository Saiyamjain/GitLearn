public with sharing class BotDialogCompletionHandler {
/*
    @InvocableMethod(Label='Bot Dialog Completion' Description='Updates given dialog instance')
    public static List<DialogCompletionOutput> updateDialogInstance(List<DialogCompletionInput> dialogInputs) {
        Set<String> dialogNames = new Set<String>();
        Set<Id> routableIds = new Set<Id>();

        Map<String, DialogCompletionWrapper> dialogCompletionWrapperByDialogName = new Map<String, DialogCompletionWrapper>();
        for (BotDialogCompletionHandler.DialogCompletionInput dialogInput : dialogInputs) {
            DialogCompletionWrapper completionWrapper = new DialogCompletionWrapper();
            completionWrapper.rating = dialogInput.bRating;
            completionWrapper.routableID = dialogInput.routableID;
            completionWrapper.systemLastCustomerInput = dialogInput.systemLastCustomerInput;
            completionWrapper.sLastCustomerInput = dialogInput.sLastCustomerInput;
            dialogCompletionWrapperByDialogName.put(dialogInput.currentDialogName, completionWrapper);
            dialogNames.add(dialogInput.currentDialogName);
            routableIds.add(dialogInput.routableId);
        }

        Map<Id, LiveChatTranscript> chatTranscriptsByIds = new Map<Id, LiveChatTranscript>(LiveChatTranscriptSelector.newInstance().selectById(routableIds));
        List<Bot_Dialog_Instance__c> dialogInstancesToUpsert = BotDialogInstanceSelector.newInstance().selectByTranscriptIdAndDialogName(routableIds, dialogNames);

        Set<String> existingDialogs = new Set<String>();
        for (Bot_Dialog_Instance__c botDialogInstance : dialogInstancesToUpsert) {
            if (botDialogInstance.Dialog_Name__c != null) {
                existingDialogs.add(botDialogInstance.Dialog_Name__c);
            }
        }

        for (String dialogName : dialogNames) {
            if (existingDialogs.isEmpty() || !existingDialogs.contains(dialogName)) {
                Bot_Dialog_Instance__c dialogToInsert = new Bot_Dialog_Instance__c();
                dialogToInsert.Dialog_Name__c = ChatBotService.formatAPIName(dialogName);
                if (dialogCompletionWrapperByDialogName.containsKey(dialogName)) {
                    dialogToInsert.Chat_Transcript__c = dialogCompletionWrapperByDialogName.get(dialogName).routableID;
                }
                dialogInstancesToUpsert.add(dialogToInsert);
            }
        }

        LiveChatTranscriptService.newInstance().updateLiveChatTranscriptOnCompletion(dialogInstancesToUpsert, chatTranscriptsByIds);
        return ChatBotService.newInstance().updateDialogInstancesOnDialogCompletion(dialogInstancesToUpsert, dialogCompletionWrapperByDialogName);
    }
*/
    public class DialogCompletionInput {
        @InvocableVariable(Description='This input will only be set by the RateYourGoal dialog')
        public Boolean bRating;
        @InvocableVariable(Description='Current Dialog Name system variable, automatically populated' Required=true)
        public String currentDialogName;
        @InvocableVariable(Description='Routable ID context variable, contains the LiveChatTranscript ID' Required=true)
        public String routableId;
        @InvocableVariable(Description='Last Customer Input custom variable')
        public String sLastCustomerInput;
        @InvocableVariable(Description='The System Last Customer input variable')
        public String systemLastCustomerInput;
    }

    public class DialogCompletionOutput {
        @InvocableVariable(Required=true)
        public Boolean bRating;
        @InvocableVariable(Description='Error message (if operation not successful)')
        public String errorMessage;
        @InvocableVariable(Description='Updated Current Dialog value' Required=true)
        public String sCurrentDialog;
        @InvocableVariable(Description='Updated Current Dialog Type value' Required=true)
        public String sCurrentDialogType;
        @InvocableVariable(Description='Updated Current Step custom variable')
        public String sCurrentStep;
        @InvocableVariable(Description='Last Customer Input custom variable')
        public String sLastCustomerInput;
    }

    public class DialogCompletionWrapper {
        public Boolean rating { get; set; }
        public String routableId { get; set; }
        public String sLastCustomerInput { get; set; }
        public String systemLastCustomerInput { get; set; }

    }
}