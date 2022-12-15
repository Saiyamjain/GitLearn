@IsTest
private class ContactUsSubType2OptionSelectorTest {
    @IsTest
    private static void testSelectByLanguageAndMasterOption() {
        String name = 'Test';
        String subType2Name = 'Test Subtype2';
        String language = 'en';
        Contact_Us_Type_Option__c contactUsTypeOption = new Contact_Us_Type_Option__c(
            Name = name,
            View__c = name,
            Language__c = language,
            Case_Resolution_Owner__c = 'DAZN',
            Provider_Type__c = 'DAZN'
        );
        insert contactUsTypeOption;
        Contact_Us_SubType_Option__c contactUsSubTypeOption = new Contact_Us_SubType_Option__c(
            Name = name,
            View__c = name,
            Type_Key__c = contactUsTypeOption.Id
        );
        insert contactUsSubTypeOption;
        Contact_Us_SubType2_Option__c contactUsSubType2Option = new Contact_Us_SubType2_Option__c(
            Name = subType2Name,
            View__c = subType2Name,
            SubType_Key__c = contactUsSubTypeOption.Id
        );
        insert contactUsSubType2Option;

        // Query
        List<Contact_Us_SubType2_Option__c> contactUsSubType2Options =
            ContactUsSubType2OptionSelector.newInstance().selectByLanguageAndMasterOption(language, name);

        // Assert
        System.assertEquals(contactUsSubType2Option.Id, contactUsSubType2Options.get(0).Id);
    }

    @IsTest
    private static void testSelectByMasterOptionNameAndLanguage() {
        String name = 'Test';
        String subType2Name = 'Test Subtype2';
        String language = 'en';
        Contact_Us_Type_Option__c contactUsTypeOption = new Contact_Us_Type_Option__c(
            Name = name,
            View__c = name,
            Language__c = language,
            Case_Resolution_Owner__c = 'DAZN',
            Provider_Type__c = 'DAZN'
        );
        insert contactUsTypeOption;
        Contact_Us_SubType_Option__c contactUsSubTypeOption = new Contact_Us_SubType_Option__c(
            Name = name,
            View__c = name,
            Type_Key__c = contactUsTypeOption.Id
        );
        insert contactUsSubTypeOption;
        Contact_Us_SubType2_Option__c contactUsSubType2Option = new Contact_Us_SubType2_Option__c(
            Name = subType2Name,
            View__c = subType2Name,
            SubType_Key__c = contactUsSubTypeOption.Id
        );
        insert contactUsSubType2Option;

        // Query
        List<Contact_Us_SubType2_Option__c> contactUsSubType2Options =
            ContactUsSubType2OptionSelector.newInstance().selectByMasterOptionNameAndLanguage(new List<String>{language}, new List<String>{contactUsSubTypeOption.Name});

        // Assert
        System.assertEquals(contactUsSubType2Option.Id, contactUsSubType2Options.get(0).Id);
    }
}