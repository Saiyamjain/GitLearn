@IsTest
private class ApiLogSelectorTest {
    @IsTest
    static void selectByProcessIdTest() {
        List<API_Log__c> apiLogs = new List<API_Log__c>();
        API_Log__c apiLog1 = new API_Log__c(Request__c = 'request1', Process_ID__c = fflib_IDGenerator.generate(Case.SObjectType));
        apiLogs.add(apiLog1);
        API_Log__c apiLog2 = new API_Log__c(Request__c = 'request2', Process_ID__c = fflib_IDGenerator.generate(Case.SObjectType));
        apiLogs.add(apiLog2);
        insert apiLogs;

        Test.startTest();
        List<API_Log__c> selectedApiLogs = ApiLogSelector.newInstance().selectByProcessId(new Set<Id>{apiLog1.Process_ID__c});
        Test.stopTest();

        System.assertEquals(1, selectedApiLogs.size());
        API_Log__c apiLog = selectedApiLogs.get(0);
        System.assertEquals(apiLog1.Id, apiLog.Id);
        System.assertEquals(apiLog1.Request__c, apiLog.Request__c);
        System.assertEquals(apiLog1.Process_ID__c, apiLog.Process_ID__c);
    }

    @IsTest
    static void selectByIdTest() {
        List<API_Log__c> apiLogs = new List<API_Log__c>();
        API_Log__c apiLog1 = new API_Log__c(Request__c = 'request1', Process_ID__c = fflib_IDGenerator.generate(Case.SObjectType));
        apiLogs.add(apiLog1);
        API_Log__c apiLog2 = new API_Log__c(Request__c = 'request2', Process_ID__c = fflib_IDGenerator.generate(Case.SObjectType));
        apiLogs.add(apiLog2);
        insert apiLogs;

        Test.startTest();
        List<API_Log__c> selectedApiLogs = ApiLogSelector.newInstance().selectById(new Set<Id>{apiLog1.Id});
        Test.stopTest();

        System.assertEquals(1, selectedApiLogs.size());
        API_Log__c apiLog = selectedApiLogs.get(0);
        System.assertEquals(apiLog1.Id, apiLog.Id);
        System.assertEquals(apiLog1.Request__c, apiLog.Request__c);
        System.assertEquals(apiLog1.Process_ID__c, apiLog.Process_ID__c);
    }

    @IsTest
    static void selectSuccessfulOutboundLogByProcessIdTest() {
        List<API_Log__c> apiLogs = new List<API_Log__c>();
        String knowledgeId = fflib_IDGenerator.generate(Knowledge__kav.SObjectType);
        API_Log__c apiLog1 = new API_Log__c(Request__c = 'request1', Process_ID__c = knowledgeId, Callout_type__c = 'Outbound', Status__c = 'Success');
        apiLogs.add(apiLog1);
        API_Log__c apiLog2 = new API_Log__c(Request__c = 'request2', Process_ID__c = knowledgeId, Callout_type__c = 'Inbound');
        apiLogs.add(apiLog2);
        API_Log__c apiLog3 = new API_Log__c(Request__c = 'request3', Process_ID__c = fflib_IDGenerator.generate(Case.SObjectType));
        apiLogs.add(apiLog3);
        insert apiLogs;

        Test.startTest();
        List<API_Log__c> selectedApiLogs = ApiLogSelector.newInstance().selectSuccessfulOutboundLogByProcessId(new Set<String>{knowledgeId});
        Test.stopTest();

        System.assertEquals(1, selectedApiLogs.size());
        API_Log__c apiLog = selectedApiLogs.get(0);
        System.assertEquals(apiLog1.Id, apiLog.Id);
        System.assertEquals(apiLog1.Request__c, apiLog.Request__c);
        System.assertEquals(apiLog1.Process_ID__c, apiLog.Process_ID__c);
    }
}