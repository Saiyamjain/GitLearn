@IsTest(IsParallel=true)
private class AccountSelectorTest {
    @IsTest
    private static void testSelectById() {
        String email = 'email@test.com';
        Account acc = TestUtils.createAndInsertAccount('Test', email);

        // Query
        List<Account> accounts =
            AccountSelector.newInstance().selectById(new Set<Id> { acc.Id });

        // Assert
        System.assertEquals(email, accounts.get(0).Notification_Email__c);
    }

    @IsTest
    private static void selectByCustomerId() {
        new AccountSelector().selectByCustomerId(new Set<String>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Customer_Id__c IN :customerIds'));
    }

    @IsTest
    private static void getAccountContactAndOpportunityData() {
        new AccountSelector().getAccountContactAndOpportunityData(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id IN :accountIds'));
    }

    @IsTest
    private static void itShouldGetSignUpFormFieldValues() {
        new AccountSelector().getSignUpFormFieldValuesByFieldSets(new Map<Schema.SObjectType,Schema.FieldSet>{
            Account.SObjectType => SObjectType.Account.FieldSets.Sign_Up_Form_Fields,
            Contact.SObjectType => SObjectType.Contact.FieldSets.Sign_Up_Form_Fields,
            Opportunity.SObjectType => SObjectType.Opportunity.FieldSets.Sign_Up_Form_Fields
        }, new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getSelectedFields().contains('Trading_Brand_name__c'));
        System.assert(result.getSelectedFields().contains('Venue_Address_State_Province__c'));
        System.assert(result.getCondition().containsIgnoreCase('Id IN :accountIds'));
    }

}