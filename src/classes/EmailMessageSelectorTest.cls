@IsTest
public with sharing class EmailMessageSelectorTest {
    @IsTest
    static void testSelectByFromAddressSubjectAndCreatedAfter() {
        EmailMessage emailMessage = TestUtils.createAndInsertEmail('senderemail@mail.com', 'Jon Gotti', 'SecretStuff');
        List<EmailMessage> emailMessages = EmailMessageSelector.newInstance().selectByFromAddressSubjectAndCreatedAfter('senderemail@mail.com', 'SecretStuff', Datetime.now().addDays(-1));
        System.assert(emailMessages.size() > 0);
    }
}