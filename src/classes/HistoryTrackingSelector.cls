/**
 * Selector class for History_Tracking__c sObject.
 *
 * @author		Nishant Khandelwal (nishant.khandelwal@dazn.com)
 * @created		Sept 2021
 */
public with sharing class HistoryTrackingSelector extends fflib_SObjectSelector {
    /**
     * Creates a new instance of this selector class.
     */
    public static HistoryTrackingSelector newInstance() {
        return (HistoryTrackingSelector) Application.Selector.newInstance(History_Tracking__c.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            History_Tracking__c.Id,
            History_Tracking__c.Field_API_Name__c,
            History_Tracking__c.New_Value__c,
            History_Tracking__c.Old_Value__c,
            History_Tracking__c.CreatedDate,
            History_Tracking__c.Record_Id__c,
            History_Tracking__c.Time_of_Last_Change__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return History_Tracking__c.SObjectType;
    }

    public List<History_Tracking__c> selectHistoryRecordsByRecordId(Set<Id> recordIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Record_Id__c IN :recordIds');
        query.emptyOrdering();
        query.addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);

        return (List<History_Tracking__c>) Database.query(query.toSOQL());
    }
}