@IsTest(isParallel=true)
private class ContactSelectorTest {

    @TestSetup
    static void testSetup() {
        Account acc = TestUtils.createAccount('Some account name', 'someemail@email.com');
        insert acc;
        TestUtils.createAndInsertContact(acc.Id, true, 'somecontactemail@email.com');
    }

    @IsTest
    static void testSelectById() {
        List<Contact> contacts = ContactSelector.newInstance().selectById(new Set<Id> {[SELECT Id FROM Contact].Id});

        System.assertEquals(1, contacts.size());

    }

    @IsTest
    static void testSelectPrimaryContactByEmailAddress() {
        List<Contact> contacts = ContactSelector.newInstance().selectPrimaryContactByEmailAddress(new Set<String> {'somecontactemail@email.com'});

        System.assertEquals(1, contacts.size());

    }

    @IsTest
    static void testSelectPrimaryContactByAccountIds() {
        List<Contact> contacts = ContactSelector.newInstance().selectPrimaryContactByAccountIds(new Set<Id> {[SELECT Id FROM Account].Id});

        System.assertEquals(1, contacts.size());

    }

    @IsTest
    static void testSelectPrimaryContactByCustomerId() {
        List<Contact> contacts = ContactSelector.newInstance().selectPrimaryContactByCustomerId(new Set<String> {[SELECT Id, Customer_Id__c FROM Account].Customer_Id__c});

        System.assertEquals(1, contacts.size());

    }

    @IsTest
    static void itShouldSelectContactsByMobilePhoneNumers() {
        new ContactSelector().selectContactsByMobilePhoneNumbers(new Set<String>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getSelectedFields().contains('AccountId'));
        System.assert(result.getCondition().containsIgnoreCase('MobilePhone IN :mobilePhoneNumbers'));
    }
}