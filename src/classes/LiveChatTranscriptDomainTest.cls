@IsTest(IsParallel=true)
private class LiveChatTranscriptDomainTest {

    @IsTest
    private static void whenChatIsMissed() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        Application.UnitOfWork.setMock(uowMock);

        // Given
        LiveChatTranscript statusEqualsMissedLiveAgentChat= new LiveChatTranscript(
            Id = fflib_IDGenerator.generate(LiveChatTranscript.SObjectType),
            LiveChatVisitorId = fflib_IdGenerator.generate(LiveChatVisitor.SObjectType),
            Status = LiveChatTranscriptDomain.STATUS_MISSED
        );
        LiveChatTranscriptDomain domainLiveChatTranscript = LiveChatTranscriptDomain.newInstance(new List<LiveChatTranscript> { statusEqualsMissedLiveAgentChat });

        // When
        domainLiveChatTranscript.setCaseStatusIfChatMissed();

        // Then
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    @IsTest
    private static void whenTranscriptIsInsertedTriggerShouldBeInvoked() {
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        LiveChatTranscript transcript = new LiveChatTranscript(
                LiveChatVisitorId = visitor.Id
        );
        insert transcript;
    }
}