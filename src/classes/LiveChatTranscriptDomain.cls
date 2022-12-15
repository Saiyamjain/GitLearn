public inherited sharing class LiveChatTranscriptDomain extends ApplicationDomain {
    public static final String CASE_ORIGIN_WEB = 'Web';
    public static final String CASE_ORIGIN_CHATBOT = 'Chatbot';
    public static final String CASE_ORIGIN_CHATBOT_AGENT = 'Chatbot - Agent';
    public static final String CASE_ORIGIN_VOICE = 'Voice';
    public static final String STATUS_IN_PROGRESS = 'InProgress';
    public static final String STATUS_OPEN = 'Open';
    public static final String STATUS_WAITING = 'Waiting';
    public static final String STATUS_COMPLETED = 'Completed';
    public static final String STATUS_MISSED = 'Missed';
    
    public static LiveChatTranscriptDomain newInstance(List<LiveChatTranscript> transcripts) {
        return (LiveChatTranscriptDomain) Application.Domain.newInstance(transcripts);
    }

    public LiveChatTranscriptDomain(List<LiveChatTranscript> transcripts) {
        super(transcripts);
    }

    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        setCaseStatusIfChatMissed();
    }

    public void setCaseStatusIfChatMissed(){
        fflib_ISObjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance();
        for ( LiveChatTranscript transcript : (List<LiveChatTranscript>)Records ) {
            if( transcript.status == STATUS_MISSED && transcript.caseId != null ){
                Case caseRecord = new Case( Id=transcript.caseId, Status = STATUS_OPEN );
                unitOfWork.registerDirty( caseRecord );
            }
        }
        unitOfWork.commitWork();
    }


    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> records) {
            return new LiveChatTranscriptDomain(records);
        }
    }

}