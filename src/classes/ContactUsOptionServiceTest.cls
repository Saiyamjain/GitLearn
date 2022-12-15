@IsTest
private class ContactUsOptionServiceTest {
    @IsTest
    static void callingServiceShouldCallSelectors() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        CaseSelector caseSelectorMock = (CaseSelector) mocks.mock(CaseSelector.class);
        ContactUsTypeOptionSelector contactUsTypeOptionSelectorMock = (ContactUsTypeOptionSelector) mocks.mock(ContactUsTypeOptionSelector.class);
        ContactUsSubTypeOptionSelector contactUsSubTypeOptionSelectorMock = (ContactUsSubTypeOptionSelector) mocks.mock(ContactUsSubTypeOptionSelector.class);
        ContactUsSubType2OptionSelector contactUsSubType2OptionSelectorMock = (ContactUsSubType2OptionSelector) mocks.mock(ContactUsSubType2OptionSelector.class);

        // Given
        mocks.startStubbing();
        String userLanguage = UserInfo.getLanguage().substringBefore('_');
        String optionName = 'Test';
        List<Case> testCases = new List<Case> {
            new Case(
                Id = fflib_IDGenerator.generate(Case.SObjectType),
                Type = optionName,
                Sub_Type__c = optionName,
                Sub_Type2__c = optionName
            )
        };
        Set<Id> testCaseIds = new Map<Id, Case> (testCases).keySet();

        List<Contact_Us_Type_Option__c> testContactUsTypeOptions = new List<Contact_Us_Type_Option__c> {
            new Contact_Us_Type_Option__c(
                Name = optionName,
                View__c = optionName
            )
        };

        List<Contact_Us_SubType_Option__c> testContactUsSubTypeOptions = new List<Contact_Us_SubType_Option__c> {
            new Contact_Us_SubType_Option__c(
                Name = optionName,
                View__c = optionName
            )
        };

        List<Contact_Us_SubType2_Option__c> testContactUsSubType2Options = new List<Contact_Us_SubType2_Option__c> {
            new Contact_Us_SubType2_Option__c(
                Name = optionName,
                View__c = optionName
            )
        };
        ContactUsOptionService.TypeOptionWrapper tow = new ContactUsOptionService.TypeOptionWrapper();
        tow.type = testCases.get(0).Type;
        tow.subType = testCases.get(0).Sub_Type__c;
        tow.subType2 = testCases.get(0).Sub_Type2__c;
        mocks.when(caseSelectorMock.sObjectType()).thenReturn(Case.SObjectType);
        mocks.when(caseSelectorMock.selectById(new Set<Id> { testCases.get(0).Id })).thenReturn(testCases);
        mocks.when(contactUsTypeOptionSelectorMock.sObjectType()).thenReturn(Contact_Us_Type_Option__c.SObjectType);
        mocks.when(contactUsTypeOptionSelectorMock.selectByLanguage(userLanguage)).thenReturn(testContactUsTypeOptions);
        mocks.when(contactUsSubTypeOptionSelectorMock.sObjectType()).thenReturn(Contact_Us_SubType_Option__c.SObjectType);
        mocks.when(contactUsSubTypeOptionSelectorMock.selectByLanguageAndMasterOption(userLanguage, optionName)).thenReturn(testContactUsSubTypeOptions);
        mocks.when(contactUsSubType2OptionSelectorMock.sObjectType()).thenReturn(Contact_Us_SubType2_Option__c.SObjectType);
        mocks.when(contactUsSubType2OptionSelectorMock.selectByLanguageAndMasterOption(userLanguage, optionName)).thenReturn(testContactUsSubType2Options);
        mocks.stopStubbing();
        Application.Selector.setMock(caseSelectorMock);
        Application.Selector.setMock(contactUsTypeOptionSelectorMock);
        Application.Selector.setMock(contactUsSubTypeOptionSelectorMock);
        Application.Selector.setMock(contactUsSubType2OptionSelectorMock);

        // When
        ContactUsOptionService.newInstance().getContactUsOptions(testCases.get(0).Id);

        // Then
        ((CaseSelector) mocks.verify(caseSelectorMock, 1)).selectById(testCaseIds);
        ((ContactUsTypeOptionSelector) mocks.verify(contactUsTypeOptionSelectorMock)).selectByLanguage(userLanguage);
        ((ContactUsSubTypeOptionSelector) mocks.verify(contactUsSubTypeOptionSelectorMock)).selectByLanguageAndMasterOption(userLanguage, optionName);
        ((ContactUsSubType2OptionSelector) mocks.verify(contactUsSubType2OptionSelectorMock)).selectByLanguageAndMasterOption(userLanguage, optionName);
    }

    @IsTest
    static void callingServiceForBotShouldCallSelectorsAndReturnRecords() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ContactUsTypeOptionSelector contactUsTypeOptionSelectorMock = (ContactUsTypeOptionSelector) mocks.mock(ContactUsTypeOptionSelector.class);
        ContactUsSubTypeOptionSelector contactUsSubTypeOptionSelectorMock = (ContactUsSubTypeOptionSelector) mocks.mock(ContactUsSubTypeOptionSelector.class);
        ContactUsSubType2OptionSelector contactUsSubType2OptionSelectorMock = (ContactUsSubType2OptionSelector) mocks.mock(ContactUsSubType2OptionSelector.class);

        // Given
        mocks.startStubbing();
        String language = 'en';
        String country = 'US';
        String optionTypeName = 'Test';
        String optionSubTypeName = 'SubTest';
        String optionSubType2Name = 'SubTest2';

        List<String> languages = new List<String>{language};
        Set<String> languagesSet = new Set<String>(languages);
        Set<String> countries = new Set<String>{country};

        String contactUsTypeOptionId = fflib_IDGenerator.generate(Contact_Us_Type_Option__c.SObjectType);
        String contactUsSubTypeOptionId = fflib_IDGenerator.generate(Contact_Us_SubType_Option__c.SObjectType);
        String contactUsSubType2OptionId = fflib_IDGenerator.generate(Contact_Us_SubType2_Option__c.SObjectType);

        List<String> typeNames = new List<String>{optionTypeName};
        List<String> subTypeNames = new List<String>{optionSubTypeName};

        List<Contact_Us_Type_Option__c> testContactUsTypeOptions = new List<Contact_Us_Type_Option__c> {
            new Contact_Us_Type_Option__c(
                Id = contactUsTypeOptionId,
                Language__c = language,
                Country__c = country,
                Name = optionTypeName,
                View__c = optionTypeName
            )
        };

        List<Contact_Us_SubType_Option__c> testContactUsSubTypeOptions = new List<Contact_Us_SubType_Option__c> {
            new Contact_Us_SubType_Option__c(
                Id = contactUsSubTypeOptionId,
                Type_Key__c = contactUsTypeOptionId,
                Type_Key__r = testContactUsTypeOptions.get(0),
                Name = optionSubTypeName,
                View__c = optionSubTypeName
            )
        };

        List<Contact_Us_SubType2_Option__c> testContactUsSubType2Options = new List<Contact_Us_SubType2_Option__c> {
            new Contact_Us_SubType2_Option__c(
                Id = contactUsSubType2OptionId,
                SubType_Key__c = contactUsSubTypeOptionId,
                SubType_Key__r = testContactUsSubTypeOptions.get(0),
                Name = optionSubType2Name,
                View__c = optionSubType2Name
            )
        };

        BotGetContactUsOptionsHandler.BotInput typeBotInput = new BotGetContactUsOptionsHandler.BotInput();
        typeBotInput.language = language;
        typeBotInput.country = country;
        BotGetContactUsOptionsHandler.BotInput subTypeBotInput = new BotGetContactUsOptionsHandler.BotInput();
        subTypeBotInput.masterTypeOptionName = testContactUsTypeOptions.get(0).Name;
        subTypeBotInput.language = language;
        BotGetContactUsOptionsHandler.BotInput subType2BotInput = new BotGetContactUsOptionsHandler.BotInput();
        subType2BotInput.masterSubTypeOptionName = testContactUsSubTypeOptions.get(0).Name;
        subType2BotInput.language = language;

        List<BotGetContactUsOptionsHandler.BotInput> botInputs = new List<BotGetContactUsOptionsHandler.BotInput> {
            typeBotInput, subTypeBotInput, subType2BotInput
        };

        mocks.when(contactUsTypeOptionSelectorMock.sObjectType()).thenReturn(Contact_Us_Type_Option__c.SObjectType);
        mocks.when(contactUsTypeOptionSelectorMock.selectByLanguageAndCountry(languagesSet, countries)).thenReturn(testContactUsTypeOptions);
        mocks.when(contactUsSubTypeOptionSelectorMock.sObjectType()).thenReturn(Contact_Us_SubType_Option__c.SObjectType);
        mocks.when(contactUsSubTypeOptionSelectorMock.selectByMasterOptionNameAndLanguage(languages, typeNames)).thenReturn(testContactUsSubTypeOptions);
        mocks.when(contactUsSubType2OptionSelectorMock.sObjectType()).thenReturn(Contact_Us_SubType2_Option__c.SObjectType);
        mocks.when(contactUsSubType2OptionSelectorMock.selectByMasterOptionNameAndLanguage(languages, subTypeNames)).thenReturn(testContactUsSubType2Options);
        mocks.stopStubbing();
        Application.Selector.setMock(contactUsTypeOptionSelectorMock);
        Application.Selector.setMock(contactUsSubTypeOptionSelectorMock);
        Application.Selector.setMock(contactUsSubType2OptionSelectorMock);

        // When
        List<List<SObject>> botResults = ContactUsOptionService.newInstance().getContactUsOptionsForBot(botInputs);

        // Then
        ((ContactUsTypeOptionSelector) mocks.verify(contactUsTypeOptionSelectorMock, 1)).selectByLanguageAndCountry(languagesSet, countries);
        ((ContactUsSubTypeOptionSelector) mocks.verify(contactUsSubTypeOptionSelectorMock, 1)).selectByMasterOptionNameAndLanguage(languages, typeNames);
        ((ContactUsSubType2OptionSelector) mocks.verify(contactUsSubType2OptionSelectorMock, 1)).selectByMasterOptionNameAndLanguage(languages, subTypeNames);
        System.assertEquals(contactUsTypeOptionId, botResults.get(0).get(0).Id);
        System.assertEquals(contactUsSubTypeOptionId, botResults.get(1).get(0).Id);
        System.assertEquals(contactUsSubType2OptionId, botResults.get(2).get(0).Id);
    }
}