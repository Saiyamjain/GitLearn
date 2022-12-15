public inherited sharing class CaseSelector extends fflib_SObjectSelector {
    public static CaseSelector newInstance() {
        return (CaseSelector) Application.Selector.newInstance(Case.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Case.Status,
            Case.Type,
            Case.Sub_Type__c,
            Case.Sub_Type2__c,
            Case.Notification_Country_Code__c,
            Case.Notification_Language_Code__c,
            Case.Status,
            Case.Notification_Country_Code__c,
            Case.Notification_Language_Code__c,
            Case.AccountId,
            Case.CaseNumber,
            Case.RecordTypeId
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Case.SObjectType;
    }

    public List<Case> selectById(Set<Id> idSet) {
        return (List<Case>) selectSObjectsById(idSet);
    }

    public List<Case> selectByIdWithFieldsForCloningRecord(Set<Id> idSet) {
        Set<String> fields = new Set<String> {
            'Id',
            'RecordType.Name',
            'ContactId',
            'Contact.Email',
            'Status',
            'Origin',
            'Case_Actions__c',
            'Case_Action_Reason__c',
            'Reason',
            'Notification_Country_Code__c',
            'Notification_Language_Code__c',
            'Type',
            'Sub_Type__c',
            'Sub_Type2__c',
            'Subject',
            'AccountId',
            'Mass_Response__c',
            'Priority',
            'SuppliedEmail',
            'Thread_Id__c'
        };
        return Database.query(
            newQueryFactory()
                .selectFields(fields)
                .setCondition('Id IN :idSet')
                .toSOQL()
        );
    }
    public List<Case> selectByFromAddressSubjectAndCreatedAfter(String fromAddress, String subject, Datetime createdAfter) {
        return Database.query(
                newQueryFactory()
                        .setCondition('SuppliedEmail = :fromAddress AND Subject = :subject AND CreatedDate > :createdAfter')
                        .toSOQL()
        );
    }
}