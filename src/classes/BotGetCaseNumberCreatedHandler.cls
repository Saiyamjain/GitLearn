public with sharing class BotGetCaseNumberCreatedHandler {
    @InvocableMethod(Label='Get Case Number Created')
    public static List<String> getCaseNumberCreated(List<String> inputs) {
        Set<Id> ids = new Set<Id>();
        for (String str : inputs) {
            if (str instanceof Id) {
                ids.add(str);
            }
        }
        Map<Id, Case> casesByTranscriptIds = LiveChatTranscriptService.newInstance().getConnectedCases(ids);
        List<String> result = new List<String>();
        for (String input : inputs) {
            String caseNumber;
            if (input instanceof Id) {
                Case connectedCase = casesByTranscriptIds.get(input);
                if (connectedCase != null) {
                    caseNumber = connectedCase.CaseNumber;
                }
            }
            result.add(caseNumber);
        }
        return result;
    }
}