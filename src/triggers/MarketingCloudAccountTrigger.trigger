trigger MarketingCloudAccountTrigger on Account (after insert, after update) {
    if (Marketing_Cloud_Triggered_Send__mdt.getInstance('TriggeredSendActive').Triggered_Send__c){
        et4ae5.triggerUtility.automate('Account');
    }
}