public inherited sharing class ContactSelector extends fflib_SObjectSelector {
    public static ContactSelector newInstance() {
        return (ContactSelector) Application.Selector.newInstance(Contact.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Contact.Email,
            Contact.FirstName,
            Contact.Id,
            Contact.LastName
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Contact.SObjectType;
    }

    public List<Contact> selectById(Set<Id> idSet) {
        return (List<Contact>) selectSObjectsById(idSet);
    }

    public List<Contact> selectPrimaryContactByEmailAddress(Set<String> fromAddresses) {
        Set<String> contactFields = new Set<String> {
            'Account.Account_Status__c',
            'Account.Business_Email__c',
            'Account.Business_Type__c',
            'Account.Notification_Country_Code__c',
            'Account.Notification_Language_Code__c'
        };
        return Database.query(
            newQueryFactory()
                .selectFields(contactFields)
                .setCondition('Primary_Contact__c = TRUE AND Email IN :fromAddresses')
                .toSOQL()
        );
    }

    public List<Contact> selectPrimaryContactByCustomerId(Set<String> customerIds) {
        Set<String> contactFields = new Set<String> {
            'Account.Customer_Id__c',
            'Account.Id',
            'Account.RecordType',
            'Account.RecordType.DeveloperName'
        };
        return Database.query(
            newQueryFactory()
                .selectFields(contactFields)
                .setCondition('Primary_Contact__c = TRUE AND Account.Customer_Id__c IN :customerIds')
                .toSOQL()
        );
    }
  
    public List<Contact> selectPrimaryContactByAccountIds(Set<Id> idSet) {
        Set<String> contactFields = new Set<String> {
            'Account.Account_Status__c',
            'Account.All_Email_Preferences__c',
            'Account.Business_Type__c',
            'Account.Name',
            'Account.Notification_Country_Code__c',
            'Account.Notification_Language_Code__c',
            'Account.Previous_Status__c',
            'Account.RecordTypeId'
        };
        return Database.query(
            newQueryFactory()
                .selectFields(contactFields)
                .setCondition('Primary_Contact__c = TRUE AND AccountId IN :idSet')
                .toSOQL()
        );
    }

    public List<Contact> selectContactsByMobilePhoneNumbers(Set<String> mobilePhoneNumbers) {
        return Database.query(
            newQueryFactory()
                .selectFields(new Set<SObjectField>{Contact.AccountId, Contact.MobilePhone})
                .setCondition('MobilePhone IN :mobilePhoneNumbers')
                .toSOQL()
        );
    }

    public List<Contact> selectContactByIds(Set<Id> idSet) {
        Set<String> contactFields = new Set<String> {
                'Account.Name',
                'Account.Account_Status__c',
                'Account.All_Email_Preferences__c',
                'Account.Business_Type__c',
                'Account.Notification_Country_Code__c',
                'Account.Notification_Language_Code__c',
                'Account.Previous_Status__c',
                'Account.RecordTypeId'
        };
        return Database.query(
                newQueryFactory()
                        .selectFields(contactFields)
                        .setCondition('Id IN :idSet')
                        .toSOQL()
        );
    }
}