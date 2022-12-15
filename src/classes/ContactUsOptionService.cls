public with sharing class ContactUsOptionService {

    /**
     * It might be useful to change caseActions component (editCaseCmp.js), to stop using this method
     * and start using this List<Map<String, String>> getContactUsOptions(String language, String country, String masterOptionId, ContactUsOptionService.ContactUsOption contactUsOption)
     * which base on the parent Ids not the names of ContactUs records.
     */
    public List<Map<String, String>> getContactUsOptions(String masterOption, ContactUsOptionService.ContactUsOption contactUsOption) {
        Map<String, Map<String, String>> result = new Map<String, Map<String, String>>();
        List<SObject> contactUsOptions = new List<SObject>();
        String userLanguage = UserInfo.getLanguage().substringBefore('_');
        switch on contactUsOption {
            when TYPE {
                contactUsOptions = ContactUsTypeOptionSelector.newInstance().selectByLanguage(userLanguage);
            }
            when SUBTYPE {
                contactUsOptions = ContactUsSubTypeOptionSelector.newInstance().selectByLanguageAndMasterOption(userLanguage, masterOption);
            }
            when SUBTYPE2 {
                contactUsOptions = ContactUsSubType2OptionSelector.newInstance().selectByLanguageAndMasterOption(userLanguage, masterOption);
            }
        }
        for (SObject option : contactUsOptions) {
            result.put((String)option.get('Name'), LightningResult.prepareComboboxOption((String)option.get('Name'), (String)option.get('View__c')));
        }
        return result.values();
    }

    public ContactUsOptionService.TypeOptionWrapper getContactUsOptions(Id caseId) {
        List<Case> caseRecords =
            CaseSelector.newInstance().selectById(new Set<Id> { caseId });
        if (caseRecords.isEmpty()) {
            throw new Application.ApplicationException(Label.No_Records_Found);
        }

        ContactUsOptionService.TypeOptionWrapper tow = new ContactUsOptionService.TypeOptionWrapper(caseRecords.get(0));
        tow.optionsByField.put(ContactUsOptionService.ContactUsOption.TYPE.name().toLowerCase(), getContactUsOptions(null, ContactUsOptionService.ContactUsOption.TYPE));
        if (String.isNotBlank(tow.type)) {
            tow.optionsByField.put(ContactUsOptionService.ContactUsOption.SUBTYPE.name().toLowerCase(), getContactUsOptions(tow.type, ContactUsOptionService.ContactUsOption.SUBTYPE));
        }
        if (String.isNotBlank(tow.subType)) {
            tow.optionsByField.put(ContactUsOptionService.ContactUsOption.SUBTYPE2.name().toLowerCase(), getContactUsOptions(tow.subType, ContactUsOptionService.ContactUsOption.SUBTYPE2));
        }
        return tow;
    }

    public List<List<SObject>> getContactUsOptionsForBot(List<BotGetContactUsOptionsHandler.BotInput> inputs) {
        List<String> languages = new List<String>();
        List<String> masterTypeOptionLanguages = new List<String>();
        List<String> masterSubTypeOptionLanguages = new List<String>();
        Set<String> countries = new Set<String>();
        List<String> masterTypeOptionNames = new List<String>();
        List<String> masterSubTypeOptionNames = new List<String>();
        for (BotGetContactUsOptionsHandler.BotInput input : inputs) {
            if (String.isNotBlank(input.language)) {
                languages.add(input.language);
            }
            if (String.isNotBlank(input.country)) {
                countries.add(input.country);
            }
            if (String.isNotBlank(input.masterTypeOptionName)) {
                masterTypeOptionNames.add(input.masterTypeOptionName);
                masterTypeOptionLanguages.add(input.language);
            }
            if (String.isNotBlank(input.masterSubTypeOptionName)) {
                masterSubTypeOptionNames.add(input.masterSubTypeOptionName);
                masterSubTypeOptionLanguages.add(input.language);
            }
        }
        List<Contact_Us_Type_Option__c> contactUsTypeRecords = new List<Contact_Us_Type_Option__c>();
        if (!languages.isEmpty() || !countries.isEmpty()) {
            contactUsTypeRecords.addAll(ContactUsTypeOptionSelector.newInstance().selectByLanguageAndCountry(new Set<String> (languages), countries));
        }
        List<Contact_Us_SubType_Option__c> contactUsSubTypeRecords = new List<Contact_Us_SubType_Option__c>();
        List<Contact_Us_SubType2_Option__c> contactUsSub2TypeRecords = new List<Contact_Us_SubType2_Option__c>();
        if (!masterTypeOptionNames.isEmpty()) {
            contactUsSubTypeRecords.addAll(ContactUsSubTypeOptionSelector.newInstance().selectByMasterOptionNameAndLanguage(masterTypeOptionLanguages, masterTypeOptionNames));
        }
        if (!masterSubTypeOptionNames.isEmpty()) {
            contactUsSub2TypeRecords.addAll(ContactUsSubType2OptionSelector.newInstance().selectByMasterOptionNameAndLanguage(masterSubTypeOptionLanguages, masterSubTypeOptionNames));
        }

        List<List<SObject>> result = new List<List<SObject>>();
        for (BotGetContactUsOptionsHandler.BotInput input : inputs) {
            List<SObject> inputResults = new List<SObject>();
            if (!contactUsTypeRecords.isEmpty()) {
                for (Integer i = 0;i < contactUsTypeRecords.size(); i++) {
                    if (contactUsTypeRecords.get(i).Language__c == input.language &&
                        contactUsTypeRecords.get(i).Country__c.containsIgnoreCase(input.country)) {
                        inputResults.add(contactUsTypeRecords.get(i));
                        contactUsTypeRecords.remove(0);
                        i--;
                    }
                }
            }
            if (inputResults.isEmpty() && !contactUsSubTypeRecords.isEmpty()) {
                for (Integer i = 0;i < contactUsSubTypeRecords.size(); i++) {
                    if (contactUsSubTypeRecords.get(0).Type_Key__r.Language__c == input.language &&
                        contactUsSubTypeRecords.get(0).Type_Key__r.Name == input.masterTypeOptionName) {
                        inputResults.add(contactUsSubTypeRecords.get(0));
                        contactUsSubTypeRecords.remove(0);
                        i--;
                    }
                }
            }
            if (inputResults.isEmpty() && !contactUsSub2TypeRecords.isEmpty()) {
                for (Integer i = 0;i < contactUsSub2TypeRecords.size(); i++) {
                    if (contactUsSub2TypeRecords.get(0).SubType_Key__r.Type_Key__r.Language__c == input.language &&
                        contactUsSub2TypeRecords.get(0).SubType_Key__r.Name == input.masterSubTypeOptionName) {
                        inputResults.add(contactUsSub2TypeRecords.get(0));
                        contactUsSub2TypeRecords.remove(0);
                        i--;
                    }
                }
            }
            result.add(inputResults);
        }
        return result;
    }

    public static ContactUsOptionService newInstance() {
        return (ContactUsOptionService) Application.Service.newInstance(ContactUsOptionService.class);
    }

    public enum ContactUsOption {TYPE, SUBTYPE, SUBTYPE2}

    public static ContactUsOption toContactUsOption(String s) {
        for (ContactUsOption contactUsOption : ContactUsOption.values()) {
            if (contactUsOption.name().equalsIgnoreCase(s)) {
                return contactUsOption;
            }
        }
        return null;
    }

    public class TypeOptionWrapper {
        @AuraEnabled
        public String fieldName { get; set; }
        @AuraEnabled
        public String masterOptionValue { get; set; }
        @AuraEnabled
        public String caseId { get; set; }
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public String subType { get; set; }
        @AuraEnabled
        public String subType2 { get; set; }
        @AuraEnabled
        public Map<String, List<Map<String, String>>> optionsByField {
            get {
                if (optionsByField == null) {
                    optionsByField = new Map<String, List<Map<String, String>>>();
                }
                return optionsByField;
            }
            set;
        }

        @TestVisible
        public ContactUsOption contactUsOption {
            get {
                if (this.contactUsOption == null) {
                    if (String.isNotBlank(fieldName)) {
                        this.contactUsOption = toContactUsOption(fieldName);
                    }
                }
                return this.contactUsOption;
            }
            private set;
        }

        public TypeOptionWrapper(Case c) {
            this.type = c.Type;
            this.subType = c.Sub_Type__c;
            this.subType2 = c.Sub_Type2__c;
        }

        public TypeOptionWrapper() {}
    }
}