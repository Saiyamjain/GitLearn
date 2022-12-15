public with sharing class BotGetAccountDetailsHandler {

    @InvocableMethod(Label='Get Account Details')
    public static List<BotOutput> getAccountDetails(List<String> inputs) {
        return AccountService.newInstance().getAccountDetails(inputs);
    }

    public class BotOutput {
        @InvocableVariable(Description='Primary contact first name.' Required=true)
        public String firstName;
        @InvocableVariable(Description='Primary contact last name.' Required=true)
        public String lastName;
        @InvocableVariable(Description='Id of an account.' Required=true)
        public String Id;
        @InvocableVariable(Description='Status of an account.' Required=true)
        public String accountStatus;
        @InvocableVariable(Description='Notification country code related to account.' Required=true)
        public String notificationCountryCode;
        @InvocableVariable(Description='Notification languge code related to account.' Required=true)
        public String notificationLanguageCode;
        @InvocableVariable(Description='Type of an account.' Required=true)
        public String type;
    }
}