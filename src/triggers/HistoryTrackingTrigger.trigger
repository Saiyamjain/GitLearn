/**
* Trigger for History_Tracking__c object
*
* @author   Nishant Khandelwal(nishant.khandelwal@dazn.com)
* @created  Sept 2021
*/
trigger HistoryTrackingTrigger on History_Tracking__c (before insert) {
    fflib_SObjectDomain.triggerHandler(HistoryTrackingDomain.class);
}