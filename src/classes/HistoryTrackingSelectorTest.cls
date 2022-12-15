/**
 * Unit test class for HistoryTrackingSelector class.
 *
 * @author      Nishant Khandelwal(nishant.khandelwal@dazn.com)
 * @created     Sept 2021
 */
@IsTest(isParallel=true)
private class HistoryTrackingSelectorTest {

    @IsTest
    static void testselectHistoryRecordsByRecordId() {

        Id recordId = fflib_IDGenerator.generate(History_Tracking__c.SObjectType);
        History_Tracking__c historyTracking = TestUtils.createHistoryTrackingRecord(recordId);
        insert historyTracking;
        List<History_Tracking__c> historyTrackingList = HistoryTrackingSelector.newInstance().selectHistoryRecordsByRecordId(new Set<Id> {recordId});

        System.assertEquals(1, historyTrackingList.size());
        System.assertEquals(recordId, historyTrackingList[0].Record_Id__c);
    }
}