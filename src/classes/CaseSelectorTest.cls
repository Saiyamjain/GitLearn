@IsTest
public with sharing class CaseSelectorTest {

    @TestSetup
    static void testSetup() {
        Account acc = TestUtils.createAndInsertAccount('Some account name', 'someemail@email.com');
        TestUtils.createAndInsertContact(acc.Id, false, 'somecontactemail@email.com');
    }

    @IsTest
    static void testSelectById() {
        Case c = TestUtils.createAndInsertCase([SELECT Id FROM Account].Id, [SELECT Id FROM Contact].Id, 'Open');

        List<Case> cases = CaseSelector.newInstance().selectById(new Set<Id> { c.Id });

        System.assertEquals('Open', cases.get(0).Status);
    }

    @IsTest
    static void testSelectByIdWithFieldsForCloningRecord() {
        Case c = TestUtils.createCase([SELECT Id FROM Account].Id, [SELECT Id FROM Contact].Id, 'Open');
        c.Subject = 'Testing this subject';
        c.SuppliedEmail = 'thissuppliedemail@email.com';
        insert c;

        List<Case> cases = CaseSelector.newInstance().selectByIdWithFieldsForCloningRecord(new Set<Id> { c.Id });

        System.assertEquals('Testing this subject', cases.get(0).Subject);
        System.assertEquals('thissuppliedemail@email.com', cases.get(0).SuppliedEmail);

    }

    @IsTest
    static void testSelectByFromAddressSubjectAndCreatedAfter() {
        Case c = TestUtils.createCase([SELECT Id FROM Account].Id, [SELECT Id FROM Contact].Id, 'Open');
        c.Subject = 'Testing this subject';
        c.SuppliedEmail = 'thissuppliedemail@email.com';
        insert c;

        List<Case> cases = CaseSelector.newInstance().selectByFromAddressSubjectAndCreatedAfter('thissuppliedemail@email.com', 'Testing this subject', Datetime.now().addDays(-1));

        System.assertEquals('Open', cases.get(0).Status);

    }
}