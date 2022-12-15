public without sharing class BotGetAvailableChannelsHandler {
/*
    @InvocableMethod(Label='Bot Get Available Channels')
    public static List<BotOutput> getAvailableChannels(List<BotInput> botInput) {
        return AvailableChannelService.newInstance().getAvailableChannelsForContactUsSubtype2Options(botInput);
    }
*/
    public class BotInput {
        @InvocableVariable(Description='Id of Contact Us Subtype2 Option')
        public String subType2Id;
        @InvocableVariable(Description='Name of Contact Us Subtype2 Option')
        public String subType2Name;
    }

    public class BotOutput {
        @InvocableVariable(Description='List of Avaiable Channels view' Required=true)
        public List<String> avaiableChannelViewList;
    }
}