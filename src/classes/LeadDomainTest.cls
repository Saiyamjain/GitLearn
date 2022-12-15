// not running test in parallel because APEX_DATA_ACCESS_RESTRICTION, In parallel Apex tests, DML operations aren't permitted on this type of object: Group
@IsTest 
private class LeadDomainTest {

    // TODO: Jens - 20-06-2022 - Need to refactor this test class, get rid of all DML statements and run tests in parallel. Also increase coverage for defaulting methods.
    @TestSetup
    static void setup() {
        Group testGroup = new Group(Name = 'Germany leads', Type = 'Queue');
        insert testGroup;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            QueueSobject testQueue = new QueueSobject(QueueId = testGroup.Id, SobjectType = 'Lead');
            insert testQueue;
        }
    }

    @IsTest
    static void changeLeadStatusOnOwnerChangeFromQueueToUserTest() {
        Id testGroupId = [SELECT QueueId FROM QueueSobject WHERE SobjectType = 'Lead'][0].QueueId;

        Id LeadRecordTypeId = Utils.getRecordTypeId(Lead.SObjectType, 'Standard');
        Lead testLead = new Lead(FirstName = 'John', LastName = 'Smith', Status = 'Open', Country__c = 'DE', Company = 'TestCompany', Business_type__c = 'Bar', Lead_Id__c = '12351', OwnerId = testGroupId, RecordTypeId = LeadRecordTypeId);
        insert testLead;

        User newUser = new User(Id = UserInfo.getUserId());
        testLead.OwnerId = newUser.Id;
        update testLead;

        System.assertEquals('In progress', [SELECT Id, Status FROM Lead].Status, 'Lead status should be changed on changing owner from queue to account manager.');
    }

    @IsTest
    static void assignLeadToUserCreatingIt() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User();
        u.LastName = 'Test Code';
        u.Email = 'test@test.com';
        u.Alias = 'Tcode';
        u.Username = 'yourusualuser@test.com';
        u.ProfileId = profileId.Id;
        u.CommunityNickname = 'test12';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        insert u;

        List<Lead> leads = new List<Lead>();
        Id LeadRecordTypeId = Utils.getRecordTypeId(Lead.SObjectType, 'Standard');
        Lead germanyUnder5Venues = new Lead(FirstName = 'John', LastName = 'Smith', Status = 'Open', Number_of_venues__c = 4, Country__c = 'DE', Company = 'GermanyCompany', Business_type__c = 'Bar', Lead_Id__c = '1234', OwnerId = u.Id, RecordTypeId =LeadRecordTypeId);
        Lead germanyOver5Venues = new Lead(FirstName = 'Johnny', LastName = 'Cash', Status = 'Open', Number_of_venues__c = 7, Country__c = 'DE', Company = 'GermanyCompany', Business_type__c = 'Bar', Lead_Id__c = '1235', OwnerId = u.Id, RecordTypeId =LeadRecordTypeId);
        leads.add(germanyUnder5Venues);
        leads.add(germanyOver5Venues);
        insert leads;

        Set<Id> userIds = new Set<Id>();
        List<Lead> insertedLeads = [SELECT Id, OwnerId FROM Lead];
        for (Lead insertedLead : insertedLeads) {
            userIds.add(insertedLead.OwnerId);
        }

        Map<Id, User> queueById = new Map<Id, User>([SELECT Id, Username FROM User WHERE Id IN : userIds]);
        System.assertEquals('yourusualuser@test.com', queueById.get([SELECT Id, OwnerId FROM Lead WHERE Lead_Id__c = '1234'].OwnerId).Username, 'Lead should be assigned to the user creating it');
        System.assertEquals('yourusualuser@test.com', queueById.get([SELECT Id, OwnerId FROM Lead WHERE Lead_Id__c = '1235'].OwnerId).Username, 'Lead should be assigned to the user creating it');
    }

    /**
     * 
     * TODO - Jens - 18/7/2022 - This test needs to be refactored, 
     * I don't think Limits.getEmailInvocations() is ever invoked 
     * and this email should ideally be send through a record triggered Flow
     * or by sending emails to queue members using standard functionality, 
     * discuss this subject with Remco
     *  
    **/ 
    // @IsTest
    // static void sendEmailNotificationsForApiLeads() {
    //     Group leadsGroup = new Group(Name = 'Germany leads');
    //     leadsGroup.Id = fflib_IDGenerator.generate(leadsGroup.getSObjectType());
    //     Id LeadRecordTypeId = Utils.getRecordTypeId(Lead.SObjectType, 'Standard');
    //     Lead lead = new Lead(OwnerId = leadsGroup.Id, LastName = 'ln', Company = 'cmp', Country__c = 'DE', Business_type__c = 'Bar', RecordTypeId =LeadRecordTypeId);
    //     lead.Id = fflib_IDGenerator.generate(lead.getSObjectType());
    //     New_Integration_Lead_Notification__mdt newIntegrationLeadNotification = new New_Integration_Lead_Notification__mdt(Email__c = 'test@example.com', Language__c = 'DE');
    //     EmailTemplate emailTemplate = new EmailTemplate(Subject = 'New Lead DE');
    //     DAZN_Configuration__mdt daznConfiguration = new DAZN_Configuration__mdt(Email_Address_For_Lead_Actions__c = 'lead@example.com');
    //     OrgWideEmailAddress orgWideEmailAddress = new OrgWideEmailAddress(Address = daznConfiguration.Email_Address_For_Lead_Actions__c);

    //     fflib_ApexMocks mocks = new fflib_ApexMocks();
    //     mocks.startStubbing();
    //     IGroupSelector groupSelector = (IGroupSelector) mocks.mock(IGroupSelector.class);
    //     mocks.when(groupSelector.sObjectType()).thenReturn(Group.SObjectType);
    //     mocks.when(groupSelector.selectById(new Set<Id>{leadsGroup.Id})).thenReturn(new List<Group>{leadsGroup});

    //     INewIntegrationLeadNotificationSelector newIntegrationLeadNotificationSelector = (INewIntegrationLeadNotificationSelector) mocks.mock(INewIntegrationLeadNotificationSelector.class);
    //     mocks.when(newIntegrationLeadNotificationSelector.sObjectType()).thenReturn(New_Integration_Lead_Notification__mdt.SObjectType);
    //     mocks.when(newIntegrationLeadNotificationSelector.getAll()).thenReturn(new List<New_Integration_Lead_Notification__mdt>{newIntegrationLeadNotification});

    //     IEmailTemplateSelector emailTemplateSelector = (IEmailTemplateSelector) mocks.mock(IEmailTemplateSelector.class);
    //     mocks.when(emailTemplateSelector.sObjectType()).thenReturn(emailTemplate.getSObjectType());
    //     mocks.when(emailTemplateSelector.selectWhereNameStartsWith(fflib_Match.anyString())).thenReturn(new List<EmailTemplate>{emailTemplate});

    //     IDAZNConfigurationSelector daznConfigurationSelector = (IDAZNConfigurationSelector) mocks.mock(IDAZNConfigurationSelector.class);
    //     mocks.when(daznConfigurationSelector.sObjectType()).thenReturn(daznConfiguration.getSObjectType());
    //     mocks.when(daznConfigurationSelector.selectByEnvType()).thenReturn(daznConfiguration);

    //     IOrgWideEmailAddressSelector orgWideEmailAddressSelector = (IOrgWideEmailAddressSelector) mocks.mock(IOrgWideEmailAddressSelector.class);
    //     mocks.when(orgWideEmailAddressSelector.sObjectType()).thenReturn(orgWideEmailAddress.getSObjectType());
    //     mocks.when(orgWideEmailAddressSelector.selectByEmailAddress(fflib_Match.anyString())).thenReturn(orgWideEmailAddress);

    //     mocks.stopStubbing();

    //     Application.Selector.setMock(groupSelector);
    //     Application.Selector.setMock(newIntegrationLeadNotificationSelector);
    //     Application.Selector.setMock(daznConfigurationSelector);
    //     Application.Selector.setMock(orgWideEmailAddressSelector);

    //     Test.startTest();
    //     ((LeadDomain)LeadDomain.newInstance(new List<Lead>{lead})).handleAfterInsert();
    //     Integer emailInvocations = Limits.getEmailInvocations();
    //     Test.stopTest();

    //     System.assertEquals(1, emailInvocations);
    // }
}