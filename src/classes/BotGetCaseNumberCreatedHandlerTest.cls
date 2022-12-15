@IsTest
private class BotGetCaseNumberCreatedHandlerTest {
    @IsTest
    static void testBehavior() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        Case generatedCase = (Case) JSON.deserialize('{"CaseNumber":"00001073"}', Case.class);
        generatedCase.Id = fflib_IDGenerator.generate(Case.SObjectType);
        LiveChatTranscript transcript = new LiveChatTranscript(Id = fflib_IDGenerator.generate(LiveChatTranscript.SObjectType), CaseId = generatedCase.Id);

        List<String> botInputs = new List<String>{transcript.Id, 'not proper id'};

        LiveChatTranscriptService liveChatTranscriptService = (LiveChatTranscriptService) mocks.mock(LiveChatTranscriptService.class);
        mocks.startStubbing();
        mocks.when(liveChatTranscriptService.getConnectedCases(new Set<Id>{transcript.Id})).thenReturn(new Map<Id, Case>{transcript.Id => generatedCase});
        mocks.stopStubbing();
        Application.Service.setMock(LiveChatTranscriptService.class, liveChatTranscriptService);

        Test.startTest();
        List<String> botResults = BotGetCaseNumberCreatedHandler.getCaseNumberCreated(botInputs);
        Test.stopTest();

        System.assertEquals(2, botResults.size());
        System.assertEquals(generatedCase.CaseNumber, botResults.get(0));
        System.assertEquals(null, botResults.get(1));
    }
}