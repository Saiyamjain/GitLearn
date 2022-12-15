@isTest
private class AvailableChannelServiceTest {
    
    @isTest
    private static void whenTestedWithIdProvided() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        AvailableChannelSelector selectorMock = (AvailableChannelSelector) mocks.mock(AvailableChannelSelector.class);

        mocks.startStubbing();
        Contact_Us_SubType2_Option__c testSubOption = new Contact_Us_SubType2_Option__c (
            Id = fflib_IDGenerator.generate(Contact_Us_SubType2_Option__c.SObjectType)
        );

        Available_Channel__c voiceChannel = new Available_Channel__c(
            Id = fflib_IDGenerator.generate(Available_Channel__c.SObjectType),
            ContactUs_SubType2__c = testSubOption.Id,
            Is_Active__c = true,
            View__c = 'Voice'
        );

        Available_Channel__c webChannel = new Available_Channel__c(
            Id = fflib_IDGenerator.generate(Available_Channel__c.SObjectType),
            ContactUs_SubType2__c = testSubOption.Id,
            Is_Active__c = true,
            View__c = 'Web'
        );

        List<Available_Channel__c> availableChannelsList = new List<Available_Channel__c>{voiceChannel,webChannel};

        mocks.when(selectorMock.sObjectType()).thenReturn(Available_Channel__c.SObjectType);
        mocks.when(selectorMock.selectActiveBySubTypeIdOrName(new Set<Id>{testSubOption.Id}, new Set<String>())).thenReturn(availableChannelsList);
        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);

        BotGetAvailableChannelsHandler.BotInput input = new BotGetAvailableChannelsHandler.BotInput ();
        input.subType2Id = testSubOption.id;

        List<BotGetAvailableChannelsHandler.BotOutput> output = AvailableChannelService.newInstance().getAvailableChannelsForContactUsSubtype2Options(new List<BotGetAvailableChannelsHandler.BotInput>{input});
        system.assertEquals(2, output[0].avaiableChannelViewList.size());
        system.assertEquals(true, output[0].avaiableChannelViewList.contains(voiceChannel.View__c));
        system.assertEquals(true, output[0].avaiableChannelViewList.contains(webChannel.View__c));
    }

    @isTest
    private static void whenTestedWithNameProvided() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        AvailableChannelSelector selectorMock = (AvailableChannelSelector) mocks.mock(AvailableChannelSelector.class);

        mocks.startStubbing();
        Contact_Us_SubType2_Option__c testSubOption = new Contact_Us_SubType2_Option__c (
            Id = fflib_IDGenerator.generate(Contact_Us_SubType2_Option__c.SObjectType),
            Name = 'TestName'
        );

        Available_Channel__c voiceChannel = new Available_Channel__c(
            Id = fflib_IDGenerator.generate(Available_Channel__c.SObjectType),
            ContactUs_SubType2__c = testSubOption.Id,
            Is_Active__c = true,
            View__c = 'Voice'
        );

        List<Available_Channel__c> availableChannelsList = new List<Available_Channel__c>{voiceChannel};

        mocks.when(selectorMock.sObjectType()).thenReturn(Available_Channel__c.SObjectType);
        mocks.when(selectorMock.selectActiveBySubTypeIdOrName(new Set<Id>(), new Set<String>{testSubOption.Name})).thenReturn(availableChannelsList);
        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);

        BotGetAvailableChannelsHandler.BotInput input = new BotGetAvailableChannelsHandler.BotInput ();
        input.subType2Name = testSubOption.Name;

        List<BotGetAvailableChannelsHandler.BotOutput> output = AvailableChannelService.newInstance().getAvailableChannelsForContactUsSubtype2Options(new List<BotGetAvailableChannelsHandler.BotInput>{input});
        system.assertEquals(1, output[0].avaiableChannelViewList.size());
        system.assertEquals(true, output[0].avaiableChannelViewList.contains(voiceChannel.View__c));
    }
}