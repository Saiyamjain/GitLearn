public with sharing class BotGetContactUsOptionsHandler {
    /*
    @InvocableMethod(Label='Get Contact Us Options')
    public static List<List<SObject>> getContactUsOptions(List<BotInput> inputs) {
        return ContactUsOptionService.newInstance().getContactUsOptionsForBot(inputs);
    }
*/
    public class BotInput {
        @InvocableVariable(Label='Country' Description='Country')
        public String country;
        @InvocableVariable(Label='Language' Description='Language')
        public String language;
        @InvocableVariable(Label='Parent Type Name' Description='Parent Type Name')
        public String masterTypeOptionName;
        @InvocableVariable(Label='Parent SubType Name' Description='Parent SubType Name')
        public String masterSubTypeOptionName;
    }
}