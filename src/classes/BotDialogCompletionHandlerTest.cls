@IsTest(isParallel=true)
private class BotDialogCompletionHandlerTest {
    /*
    @IsTest
    static void testUpdateDialogInstance() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        LiveChatTranscriptSelector lctSelectorMock = (LiveChatTranscriptSelector) mocks.mock(LiveChatTranscriptSelector.class);
        LiveChatTranscriptService liveChatTranscriptService = (LiveChatTranscriptService) mocks.mock(LiveChatTranscriptService.class);
        BotDialogInstanceSelector botDialogInstanceSelectorMock = (BotDialogInstanceSelector) mocks.mock(BotDialogInstanceSelector.class);
        ChatBotService chatBotServiceMock = (ChatBotService) mocks.mock(ChatBotService.class);

        BotDialogCompletionHandler.DialogCompletionInput dialogCompletionInput = new BotDialogCompletionHandler.DialogCompletionInput();
        dialogCompletionInput.bRating = true;
        dialogCompletionInput.routableId = fflib_IDGenerator.generate(LiveChatTranscript.SObjectType);
        dialogCompletionInput.currentDialogName = 'Test_Dialog';

        LiveChatTranscript transcript = new LiveChatTranscript(Id = dialogCompletionInput.routableId);
        List<String> botInputs = new List<String>{transcript.Id, 'not proper id'};

        Bot_Dialog_Instance__c botInstance = new Bot_Dialog_Instance__c(
                Id = fflib_IDGenerator.generate(Bot_Dialog_Instance__c.SObjectType),
                RecordTypeId = Schema.SObjectType.Bot_Dialog_Instance__c.getRecordTypeInfosByName()
                        .get(ChatBotService.RECORD_TYPE_NAME_DIALOG).getRecordTypeId(),
                Chat_Transcript__c = dialogCompletionInput.routableId,
                Dialog_Name__c = 'Test_Dialog',
                Goal_Name__c = 'Test_Dialog',
                Type__c = 'Solution'
        );

        BotDialogCompletionHandler.DialogCompletionOutput dialogCompletionOutput = new BotDialogCompletionHandler.DialogCompletionOutput();
        dialogCompletionOutput.bRating = true;
        dialogCompletionOutput.sCurrentDialog = 'Test_Dialog';
        Map<String, BotDialogCompletionHandler.DialogCompletionWrapper> dialogCompletionWrapperByDialogName = new Map<String, BotDialogCompletionHandler.DialogCompletionWrapper>();

        BotDialogCompletionHandler.DialogCompletionWrapper completionWrapper = new BotDialogCompletionHandler.DialogCompletionWrapper();
        completionWrapper.rating = dialogCompletionInput.bRating;
        completionWrapper.routableID = dialogCompletionInput.routableID;
        completionWrapper.systemLastCustomerInput = dialogCompletionInput.systemLastCustomerInput;
        completionWrapper.sLastCustomerInput = dialogCompletionInput.sLastCustomerInput;
        dialogCompletionWrapperByDialogName.put(dialogCompletionInput.currentDialogName, completionWrapper);


        Map<Id, LiveChatTranscript> transcriptMap = new Map<Id, LiveChatTranscript>();
        transcriptMap.put(dialogCompletionInput.routableId, transcript);
        mocks.startStubbing();
        mocks.when(lctSelectorMock.sObjectType()).thenReturn(LiveChatTranscript.SObjectType);
        mocks.when(lctSelectorMock.selectById(new Set<Id>{dialogCompletionInput.routableId})).thenReturn(new List<LiveChatTranscript>{transcript});
        mocks.when(botDialogInstanceSelectorMock.sObjectType()).thenReturn(Bot_Dialog_Instance__c.SObjectType);
        mocks.when(botDialogInstanceSelectorMock.selectByTranscriptIdAndDialogName(new Set<Id>{dialogCompletionInput.routableId}, new Set<String> {dialogCompletionInput.currentDialogName})).thenReturn(new List<Bot_Dialog_Instance__c>{botInstance});
        ((LiveChatTranscriptService) mocks.doAnswer(new VoidAnswer(), liveChatTranscriptService)).updateLiveChatTranscriptOnCompletion(new List<Bot_Dialog_Instance__c>{botInstance}, transcriptMap);
        mocks.when(chatBotServiceMock.updateDialogInstancesOnDialogCompletion(new List<Bot_Dialog_Instance__c>{botInstance}, dialogCompletionWrapperByDialogName)).thenReturn(new List<BotDialogCompletionHandler.DialogCompletionOutput> {dialogCompletionOutput});
        mocks.stopStubbing();

        Application.Service.setMock(LiveChatTranscriptService.class, liveChatTranscriptService);
        Application.Service.setMock(ChatBotService.class, chatBotServiceMock);
        Application.Selector.setMock(lctSelectorMock);
        Application.Selector.setMock(botDialogInstanceSelectorMock);

        List<BotDialogCompletionHandler.DialogCompletionOutput> dialogCompletionOutputs = BotDialogCompletionHandler.updateDialogInstance(new List<BotDialogCompletionHandler.DialogCompletionInput> {dialogCompletionInput});

        ((LiveChatTranscriptSelector) mocks.verify(lctSelectorMock, 1)).selectById(new Set<Id>{dialogCompletionInput.routableId});
        ((BotDialogInstanceSelector) mocks.verify(botDialogInstanceSelectorMock, 1)).selectByTranscriptIdAndDialogName(new Set<Id>{dialogCompletionInput.routableId}, new Set<String> {dialogCompletionInput.currentDialogName});
        ((LiveChatTranscriptService) mocks.verify(liveChatTranscriptService,1)).updateLiveChatTranscriptOnCompletion(new List<Bot_Dialog_Instance__c>{botInstance}, transcriptMap);
    }


    class VoidAnswer implements fflib_Answer {
        public Object answer(fflib_InvocationOnMock invocation) {
            return null;
        }
    }
    
     */
}