public with sharing class AvailableChannelService {

    public List<BotGetAvailableChannelsHandler.BotOutput> getAvailableChannelsForContactUsSubtype2Options(List<BotGetAvailableChannelsHandler.BotInput> botInputs) {
        Set<Id> availableChannelsIds = new Set<Id>();
        Set<String> availableChannelsNames = new Set<String>();
        BotGetAvailableChannelsHandler.BotOutput output = new BotGetAvailableChannelsHandler.BotOutput();

        for(BotGetAvailableChannelsHandler.BotInput botInput : botInputs) {
            if(String.isNotBlank(botInput.subType2Id)) {
                availableChannelsIds.add(botInput.subType2Id);
            }
            if(String.isNotBlank(botInput.subType2Name)) {
                availableChannelsNames.add(botInput.subType2Name);
            }
        }

        output.avaiableChannelViewList = new List<String>();

        for(Available_Channel__c availableChannel : AvailableChannelSelector.newInstance().selectActiveBySubTypeIdOrName(availableChannelsIds, availableChannelsNames)) {
            output.avaiableChannelViewList.add(availableChannel.View__c);
        }

        return new List<BotGetAvailableChannelsHandler.BotOutput>{output};
    }

    public static AvailableChannelService newInstance() {
        return (AvailableChannelService) Application.Service.newInstance(AvailableChannelService.class);
    }
}