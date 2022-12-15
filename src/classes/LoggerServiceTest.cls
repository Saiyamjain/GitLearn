@IsTest
private class LoggerServiceTest {

    @IsTest
    static void logApiOutboundSuccessTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        Application.UnitOfWork.setMock(uowMock);

        Id account = fflib_IDGenerator.generate(Account.SObjectType);
        String endpoint = 'testEndpoint';
        String requestBody = 'requestBody';
        String responseBody = 'responseBody';
        Integer responseCode = 200;
        Integer responseTime = 50;
        Integer retryCount = 1;

        Test.startTest();
        LoggerService.newInstance().logApiOutbound()
                .setAccountId(account)
                .setCalloutEndpoint(endpoint)
                .setRequest(requestBody)
                .setResponse(responseBody)
                .setResponseCode(responseCode)
                .setResponseTime(responseTime)
                .setRetryCount(retryCount)
                .doInsertAPILog();
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork)
                mocks.verify(uowMock, 1)).registerNew(
                new API_Log__c(
                        Account__c = account,
                        Callout_type__c = String.valueOf(CalloutType.Outbound),
                        Callout_endpoint__c = endpoint,
                        Request__c = requestBody,
                        Response__c = responseBody,
                        Response_Code__c = String.valueOf(responseCode),
                        Response_Time__c = responseTime,
                        Retry_Count__c = retryCount,
                        Status__c = 'Success'
                )
        );
    }

    @IsTest
    static void logApiInboundTimeoutTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        Application.UnitOfWork.setMock(uowMock);

        Integer responseCode = 408;

        Test.startTest();
        LoggerService.newInstance().logApiInbound()
                .setResponseCode(responseCode)
                .doInsertFutureAPILog();
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork)
                mocks.verify(uowMock, 1)).registerNew(
                new API_Log__c(
                        Callout_type__c = String.valueOf(CalloutType.Inbound),
                        Response_Code__c = String.valueOf(responseCode),
                        Status__c = 'Failed with time out'
                )
        );
    }

    @IsTest
    static void logApiInboundErrorsTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        Application.UnitOfWork.setMock(uowMock);

        Integer responseCode = 404;

        Test.startTest();
        LoggerService.newInstance().logApiInbound()
                .setResponseCode(responseCode)
                .doInsertFutureAPILog();
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork)
                mocks.verify(uowMock, 1)).registerNew(
                new API_Log__c(
                        Callout_type__c = String.valueOf(CalloutType.Inbound),
                        Response_Code__c = String.valueOf(responseCode),
                        Status__c = 'Failed with errors'
                )
        );
    }

    @IsTest
    static void logExceptionDirectlyTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        Application.UnitOfWork.setMock(uowMock);

        String runningUserId = fflib_IDGenerator.generate(User.SObjectType);
        String className = 'className';
        String methodName = 'methodName';
        String exceptionMessage = 'exceptionMessage';
        String typeName = 'typeName';
        String stackTrace = 'stackTrace';

        Test.startTest();
        LoggerService.newInstance().logException()
                .setRunningUser(runningUserId)
                .setClassName(className)
                .setMethodName(methodName)
                .setExceptionMessage(exceptionMessage)
                .setTypeName(typeName)
                .setStackTrace(stackTrace)
                .doInsertExceptionLog();
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork)
                mocks.verify(uowMock, 1)).registerNew(
                new Exception_Log__c(
                        Running_User__c = runningUserId,
                        Class_Name__c = className,
                        Method_Name__c = methodName,
                        Exception_Message__c = exceptionMessage,
                        Exception_Type__c = typeName,
                        Stack_Trace_Message__c = stackTrace
                )
        );
    }

    @IsTest
    static void getExceptionLogTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        Application.UnitOfWork.setMock(uowMock);

        Exception thrownException = null;
        Exception_Log__c exceptionLog = null;

        Test.startTest();
        try {
            throw new NullPointerException();
        }
        catch (Exception ex) {
            thrownException = ex;
            exceptionLog = LoggerService.logException(ex).getExceptionLog();
        }
        Test.stopTest();

        System.assertEquals(UserInfo.getUserId(), exceptionLog.Running_User__c);
        System.assertEquals(thrownException.getMessage(), exceptionLog.Exception_Message__c);
        System.assertEquals(thrownException.getTypeName(), exceptionLog.Exception_Type__c);
        System.assertEquals(thrownException.getStackTraceString(), exceptionLog.Stack_Trace_Message__c);
    }
}