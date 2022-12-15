public without sharing class BotCheckIfAgentOnlineHandler {
    /*@InvocableMethod(label='Check If Agent is Online')
    public static List<BotOutput> checkIfAgentOnline(List<BotInput> botInputs) {
        return ChatBotService.checkIfAgentOnline(botInputs);
    }
*/
    public class BotInput {
        @InvocableVariable
        public String langCode;
        @InvocableVariable
        public String countryCode;
        @InvocableVariable
        public String churn;
        @InvocableVariable
        public String liveChatTranscriptId;
        @InvocableVariable
        public String isFirstCheck;
    }
    
    public class BotOutput {
        @InvocableVariable
        public String agentsAvailable;
        @InvocableVariable
        public String customersInQueue;
        @InvocableVariable
        public List<Id> skillIds;
        @InvocableVariable
        public String transferToAgent;
        @InvocableVariable
        public Boolean transferToAgentBool;
    }

}