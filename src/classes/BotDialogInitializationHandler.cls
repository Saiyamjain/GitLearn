public with sharing class BotDialogInitializationHandler {
/*
    @InvocableMethod(Label='Bot Dialog Initialization')
    public static List<DialogInitializationOutput> initializeDialog(List<DialogInitializationInput> dialogInputs) {
        List<DialogInitializationOutput> dialogOutputs = new List<DialogInitializationOutput>();

        Set<String> dialogNames = new Set<String>();
        Set<Id> transcriptIds = new Set<Id>();
        for (BotDialogInitializationHandler.DialogInitializationInput dialogInput : dialogInputs) {
            dialogNames.add(dialogInput.sCurrentDialog);
            dialogNames.add(dialogInput.currentDialogName);
            transcriptIds.add(dialogInput.routableId);
        }

        LiveChatTranscriptService.newInstance().updateLiveChatTranscriptOnInitialization(dialogInputs, dialogNames, transcriptIds);
        dialogOutputs = ChatBotService.newInstance().initializeBotDialogInstance(dialogInputs, dialogNames, transcriptIds);
        return dialogOutputs;
    }
*/
    public class DialogInitializationOutput {
        @InvocableVariable(Description='Error message (if operation not successful)')
        public String errorMessage;
        @InvocableVariable(Description='Updated Current Dialog value' Required=true)
        public String sCurrentDialog;
        @InvocableVariable(Description='Updated Current Dialog Type value' Required=true)
        public String sCurrentDialogType;
        @InvocableVariable(Description='Populated Goal Bot_Dialog__c API name')
        public String sCurrentGoal;
        @InvocableVariable(Description='Updated Current Step custom variable')
        public String sCurrentStep;
        @InvocableVariable(Description='Last Customer Input custom variable')
        public String sLastCustomerInput;
    }

    public class DialogInitializationInput {
        @InvocableVariable(Description='Current Dialog Name system variable, automatically populated' Required=true)
        public String currentDialogName;
        @InvocableVariable(Description='Routable ID context variable, contains the LiveChatTranscript ID' Required=true)
        public String routableId;
        @InvocableVariable(Description='Current Dialog custom variable, should be null on first bot dialog')
        public String sCurrentDialog;
        @InvocableVariable(Description='Current Goal custom variable, should be null on first bot dialog')
        public String sCurrentGoal;
        @InvocableVariable(Description='Current Step custom variable')
        public String sCurrentStep;
        @InvocableVariable(Description='Last Customer Input custom variable')
        public String sLastCustomerInput;
        @InvocableVariable(Description='The System Last Customer input variable')
        public String systemLastCustomerInput;
    }
}