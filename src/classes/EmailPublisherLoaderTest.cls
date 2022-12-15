@IsTest
private class EmailPublisherLoaderTest {
    @IsTest
    static void setEmailDefaultsTest() {
        Account acc = TestUtils.createAndInsertAccount('Test account', 'test@test.com');
        Contact con = TestUtils.createAndInsertContact(acc.Id, false, 'test@test.com');
        Case c = TestUtils.createAndInsertCase(acc.Id, con.Id, 'Open');
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = Test.newSendEmailQuickActionDefaults(c.Id, null);
        Test.startTest();
        EmailPublisherLoader emailPublisher = new EmailPublisherLoader();
        emailPublisher.onInitDefaults(new List<QuickAction.QuickActionDefaults>{(QuickAction.QuickActionDefaults)sendEmailDefaults});
        Test.stopTest();
        EmailMessage emailMessage = (EmailMessage) sendEmailDefaults.getTargetSObject();
        System.assertNotEquals(null, emailMessage);
        System.assertEquals(null, emailMessage.BccAddress);
        System.assertEquals(null, emailMessage.CcAddress);
        System.assertEquals(Case.SObjectType, sendEmailDefaults.getContextId().getSObjectType());
    }
}