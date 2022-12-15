@isTest(IsParallel=true)
public class RestRouteTests {
    private static final String RESOURCE_URL = '/api/*';
    private static final String RESOURCE_PATH = '/services/apexrest' + RESOURCE_URL;

    @isTest
    public static void testEntryRoute() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork unitOfWorkMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        LoggerService loggerServiceMock = (LoggerService) mocks.mock(LoggerService.class);

        // Create Exception_Log__c object
        Exception_Log__c exceptionLog = new Exception_Log__c(
            Exception_Message__c = 'stubbed exception.'
        );

        // Create RestRequest and RestResponse objects
        RestRouteTestUtil.setRestRequest(
            RESOURCE_PATH, 
            '/api/v1'
        );
        RestRouteTestUtil.setSuccessRestResponse();

        // Given
        mocks.startStubbing();
        mocks.when(loggerServiceMock.logApiInbound()).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setRequest(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponse(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setCalloutEndpoint(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponseCode(fflib_Match.anyInteger())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.doInsertAPILog()).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.logException()).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setRunningUser(fflib_Match.anyId())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setExceptionMessage(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setTypeName(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setStackTrace(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setClassName(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setMethodName(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.getExceptionLog()).thenReturn(exceptionLog);
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(unitOfWorkMock);
        Application.Service.setMock(LoggerService.class, loggerServiceMock);

        // When
        new RestRouteTestRoutes.APIEntryRoute().execute();

        // Then
        System.assertEquals(405, RestContext.Response.statusCode);

        // Then
        ((fflib_ISObjectUnitOfWork) mocks.verify(unitOfWorkMock, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork)mocks.verify(unitOfWorkMock,mocks.times(1)
            .description('Exception log should be created')))
            .registerNew(fflib_Match.sObjectWith(
            new Map<SObjectField,Object> {
                Exception_Log__c.Exception_Message__c => 'stubbed exception.'
            }
        )); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).logApiInbound();    
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setRequest(RestContext.Request.requestBody.toString()); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponse(RestContext.Response.responseBody.toString());  
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setCalloutEndpoint(RestContext.Request.requestURI);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponseCode(RestContext.Response.statusCode);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).doInsertAPILog();
        ((LoggerService) mocks.verify(loggerServiceMock,1)).logException();    
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setRunningUser(UserInfo.getUserId()); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setExceptionMessage(fflib_Match.anyString());  
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setTypeName(fflib_Match.anyString());   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setStackTrace(fflib_Match.anyString());   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setClassName('RestRoute');   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setMethodName('execute');
        ((LoggerService) mocks.verify(loggerServiceMock,1)).getExceptionLog();   
    }

    @isTest
    public static void testEntryRouteCollections() {
         // Create mocks
         fflib_ApexMocks mocks = new fflib_ApexMocks();
         fflib_ISObjectUnitOfWork unitOfWorkMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
         LoggerService loggerServiceMock = (LoggerService) mocks.mock(LoggerService.class);
 
         // Create Exception_Log__c object
         Exception_Log__c exceptionLog = new Exception_Log__c(
             Exception_Message__c = 'stubbed exception.'
         );
 
         // Create RestRequest and RestResponse objects
         RestRouteTestUtil.setRestRequest(
             RESOURCE_PATH, 
             '/api'
         );
         RestRouteTestUtil.setRestResponse(405);
 
         // Given
         mocks.startStubbing();
         mocks.when(loggerServiceMock.logApiInbound()).thenReturn(loggerServiceMock);
         mocks.when(loggerServiceMock.setRequest(fflib_Match.anyString())).thenReturn(loggerServiceMock);
         mocks.when(loggerServiceMock.setResponse(fflib_Match.anyString())).thenReturn(loggerServiceMock);
         mocks.when(loggerServiceMock.setCalloutEndpoint(fflib_Match.anyString())).thenReturn(loggerServiceMock);
         mocks.when(loggerServiceMock.setResponseCode(fflib_Match.anyInteger())).thenReturn(loggerServiceMock);
         mocks.when(loggerServiceMock.doInsertAPILog()).thenReturn(loggerServiceMock);
         mocks.when(loggerServiceMock.logException()).thenReturn(loggerServiceMock);
         mocks.when(loggerServiceMock.setRunningUser(fflib_Match.anyId())).thenReturn(loggerServiceMock);
         mocks.when(loggerServiceMock.setExceptionMessage(fflib_Match.anyString())).thenReturn(loggerServiceMock);
         mocks.when(loggerServiceMock.setTypeName(fflib_Match.anyString())).thenReturn(loggerServiceMock);
         mocks.when(loggerServiceMock.setStackTrace(fflib_Match.anyString())).thenReturn(loggerServiceMock);
         mocks.when(loggerServiceMock.setClassName(fflib_Match.anyString())).thenReturn(loggerServiceMock);
         mocks.when(loggerServiceMock.setMethodName(fflib_Match.anyString())).thenReturn(loggerServiceMock);
         mocks.when(loggerServiceMock.getExceptionLog()).thenReturn(exceptionLog);
         mocks.stopStubbing();
         Application.UnitOfWork.setMock(unitOfWorkMock);
         Application.Service.setMock(LoggerService.class, loggerServiceMock);
 
         // When
         new RestRouteTestRoutes.APIEntryRoute().execute();
 
         // Then
         System.assertEquals(405, RestContext.Response.statusCode);
 
         // Then
         ((fflib_ISObjectUnitOfWork) mocks.verify(unitOfWorkMock, 1)).commitWork();
         ((fflib_ISObjectUnitOfWork)mocks.verify(unitOfWorkMock,mocks.times(1)
             .description('Exception log should be created')))
             .registerNew(fflib_Match.sObjectWith(
             new Map<SObjectField,Object> {
                 Exception_Log__c.Exception_Message__c => 'stubbed exception.'
             }
         )); 
         ((LoggerService) mocks.verify(loggerServiceMock,1)).logApiInbound();    
         ((LoggerService) mocks.verify(loggerServiceMock,1)).setRequest(RestContext.Request.requestBody.toString()); 
         ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponse(RestContext.Response.responseBody.toString());  
         ((LoggerService) mocks.verify(loggerServiceMock,1)).setCalloutEndpoint(RestContext.Request.requestURI);   
         ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponseCode(RestContext.Response.statusCode);   
         ((LoggerService) mocks.verify(loggerServiceMock,1)).doInsertAPILog();
         ((LoggerService) mocks.verify(loggerServiceMock,1)).logException();    
         ((LoggerService) mocks.verify(loggerServiceMock,1)).setRunningUser(UserInfo.getUserId()); 
         ((LoggerService) mocks.verify(loggerServiceMock,1)).setExceptionMessage(fflib_Match.anyString());  
         ((LoggerService) mocks.verify(loggerServiceMock,1)).setTypeName(fflib_Match.anyString());   
         ((LoggerService) mocks.verify(loggerServiceMock,1)).setStackTrace(fflib_Match.anyString());   
         ((LoggerService) mocks.verify(loggerServiceMock,1)).setClassName('RestRoute');   
         ((LoggerService) mocks.verify(loggerServiceMock,1)).setMethodName('execute');
         ((LoggerService) mocks.verify(loggerServiceMock,1)).getExceptionLog();   
    }

    @isTest
    public static void testBaseRouteCollection() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        LoggerService loggerServiceMock = (LoggerService) mocks.mock(LoggerService.class);

        // Create RestRequest and RestResponse objects
        RestRouteTestUtil.setRestRequest(
            RESOURCE_PATH, 
            '/api/v1/companies/'
        );
        RestRouteTestUtil.setSuccessRestResponse();

        // Given
        mocks.startStubbing();
        mocks.when(loggerServiceMock.logApiInbound()).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setRequest(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponse(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setCalloutEndpoint(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponseCode(fflib_Match.anyInteger())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.doInsertAPILog()).thenReturn(loggerServiceMock);
        mocks.stopStubbing();
        Application.Service.setMock(LoggerService.class, loggerServiceMock);

        // When
        new RestRouteTestRoutes.APIEntryRoute().execute();

        // Then
        System.assertEquals(200, RestContext.Response.statusCode);
        RestRouteTestRoutes.Company[] response = (RestRouteTestRoutes.Company[]) JSON.deserialize(
            RestContext.Response.responseBody.toString(),
            List<RestRouteTestRoutes.Company>.class
        );
        System.assertEquals(2, response.size());

        // Then
        ((LoggerService) mocks.verify(loggerServiceMock,1)).logApiInbound();    
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setRequest(RestContext.Request.requestBody.toString()); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponse(RestContext.Response.responseBody.toString());  
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setCalloutEndpoint(RestContext.Request.requestURI);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponseCode(RestContext.Response.statusCode);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).doInsertAPILog();
    }

    @isTest
    public static void testNoResourceRoute() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        LoggerService loggerServiceMock = (LoggerService) mocks.mock(LoggerService.class);

        // Create RestRequest and RestResponse objects
        RestRouteTestUtil.setRestRequest(
            RESOURCE_PATH, 
            '/api/v1/other/foo'
        );
        RestRouteTestUtil.setSuccessRestResponse();

        // Given
        mocks.startStubbing();
        mocks.when(loggerServiceMock.logApiInbound()).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setRequest(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponse(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setCalloutEndpoint(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponseCode(fflib_Match.anyInteger())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.doInsertAPILog()).thenReturn(loggerServiceMock);
        mocks.stopStubbing();
        Application.Service.setMock(LoggerService.class, loggerServiceMock);

        // When
        new RestRouteTestRoutes.APIEntryRoute().execute();

        // Then
        System.assertEquals(200, RestContext.Response.statusCode);
        System.assertEquals('foo', RestContext.Response.responseBody.toString());

        // Then
        ((LoggerService) mocks.verify(loggerServiceMock,1)).logApiInbound();    
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setRequest(RestContext.Request.requestBody.toString()); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponse(RestContext.Response.responseBody.toString());  
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setCalloutEndpoint(RestContext.Request.requestURI);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponseCode(RestContext.Response.statusCode);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).doInsertAPILog();
    }

    @isTest
    public static void testBaseRouteCollection2() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        LoggerService loggerServiceMock = (LoggerService) mocks.mock(LoggerService.class);

        // Create RestRequest and RestResponse objects
        RestRouteTestUtil.setRestRequest(
            RESOURCE_PATH, 
            '/api/v1/companies'
        );
        RestRouteTestUtil.setSuccessRestResponse();

        // Given
        mocks.startStubbing();
        mocks.when(loggerServiceMock.logApiInbound()).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setRequest(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponse(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setCalloutEndpoint(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponseCode(fflib_Match.anyInteger())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.doInsertAPILog()).thenReturn(loggerServiceMock);
        mocks.stopStubbing();
        Application.Service.setMock(LoggerService.class, loggerServiceMock);

        // When
        new RestRouteTestRoutes.APIEntryRoute().execute();

        // Then
        System.assertEquals(200, RestContext.Response.statusCode);
        RestRouteTestRoutes.Company[] response = (RestRouteTestRoutes.Company[]) JSON.deserialize(
            RestContext.Response.responseBody.toString(),
            List<RestRouteTestRoutes.Company>.class
        );
        System.assertEquals(2, response.size());

        // Then
        ((LoggerService) mocks.verify(loggerServiceMock,1)).logApiInbound();    
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setRequest(RestContext.Request.requestBody.toString()); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponse(RestContext.Response.responseBody.toString());  
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setCalloutEndpoint(RestContext.Request.requestURI);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponseCode(RestContext.Response.statusCode);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).doInsertAPILog();
    }

    @isTest
    public static void testBaseRouteSingle() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        LoggerService loggerServiceMock = (LoggerService) mocks.mock(LoggerService.class);

        // Create RestRequest and RestResponse objects
        RestRouteTestUtil.setRestRequest(
            RESOURCE_PATH, 
            '/api/v1/companies/c-1'
        );
        RestRouteTestUtil.setSuccessRestResponse();

        // Given
        mocks.startStubbing();
        mocks.when(loggerServiceMock.logApiInbound()).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setRequest(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponse(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setCalloutEndpoint(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponseCode(fflib_Match.anyInteger())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.doInsertAPILog()).thenReturn(loggerServiceMock);
        mocks.stopStubbing();
        Application.Service.setMock(LoggerService.class, loggerServiceMock);

        // When
        new RestRouteTestRoutes.APIEntryRoute().execute();

        // Then
        System.assertEquals(200, RestContext.Response.statusCode);
        RestRouteTestRoutes.Company response = (RestRouteTestRoutes.Company) JSON.deserialize(
            RestContext.Response.responseBody.toString(),
            RestRouteTestRoutes.Company.class
        );
        System.assertEquals('c-1', response.id);

        // Then
        ((LoggerService) mocks.verify(loggerServiceMock,1)).logApiInbound();    
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setRequest(RestContext.Request.requestBody.toString()); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponse(RestContext.Response.responseBody.toString());  
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setCalloutEndpoint(RestContext.Request.requestURI);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponseCode(RestContext.Response.statusCode);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).doInsertAPILog();
    }

    @isTest
    public static void testSingleExpanded() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        LoggerService loggerServiceMock = (LoggerService) mocks.mock(LoggerService.class);

        // Create RestRequest and RestResponse objects
        RestRouteTestUtil.setRestRequest(
            RESOURCE_PATH, 
            '/api/v1/companies/c-1',
            new Map<String, String>{ 'expand' => '1' }
        );
        RestRouteTestUtil.setSuccessRestResponse();

        // Given
        mocks.startStubbing();
        mocks.when(loggerServiceMock.logApiInbound()).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setRequest(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponse(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setCalloutEndpoint(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponseCode(fflib_Match.anyInteger())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.doInsertAPILog()).thenReturn(loggerServiceMock);
        mocks.stopStubbing();
        Application.Service.setMock(LoggerService.class, loggerServiceMock);

        // When
        new RestRouteTestRoutes.APIEntryRoute().execute();

        // Then
        System.assertEquals(200, RestContext.Response.statusCode);

        // Then
        ((LoggerService) mocks.verify(loggerServiceMock,1)).logApiInbound();    
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setRequest(RestContext.Request.requestBody.toString()); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponse(RestContext.Response.responseBody.toString());  
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setCalloutEndpoint(RestContext.Request.requestURI);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponseCode(RestContext.Response.statusCode);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).doInsertAPILog();
    }

    @isTest
    public static void testCollectionExpanded() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        LoggerService loggerServiceMock = (LoggerService) mocks.mock(LoggerService.class);

        // Create RestRequest and RestResponse objects
        RestRouteTestUtil.setRestRequest(
            RESOURCE_PATH, 
            '/api/v1/companies',
            new Map<String, String>{ 'expand' => '1' }
        );
        RestRouteTestUtil.setSuccessRestResponse();

        // Given
        mocks.startStubbing();
        mocks.when(loggerServiceMock.logApiInbound()).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setRequest(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponse(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setCalloutEndpoint(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponseCode(fflib_Match.anyInteger())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.doInsertAPILog()).thenReturn(loggerServiceMock);
        mocks.stopStubbing();
        Application.Service.setMock(LoggerService.class, loggerServiceMock);

        // When
        new RestRouteTestRoutes.APIEntryRoute().execute();

        // Then
        System.assertEquals(200, RestContext.Response.statusCode);

        // Then
        ((LoggerService) mocks.verify(loggerServiceMock,1)).logApiInbound();    
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setRequest(RestContext.Request.requestBody.toString()); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponse(RestContext.Response.responseBody.toString());  
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setCalloutEndpoint(RestContext.Request.requestURI);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponseCode(RestContext.Response.statusCode);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).doInsertAPILog();
    }

    @isTest
    public static void testNestedRouteCollection() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        LoggerService loggerServiceMock = (LoggerService) mocks.mock(LoggerService.class);

        // Create RestRequest and RestResponse objects
        RestRouteTestUtil.setRestRequest(
            RESOURCE_PATH, 
            '/api/v1/companies/c-2/locations'
        );
        RestRouteTestUtil.setSuccessRestResponse();

        // Given
        mocks.startStubbing();
        mocks.when(loggerServiceMock.logApiInbound()).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setRequest(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponse(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setCalloutEndpoint(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponseCode(fflib_Match.anyInteger())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.doInsertAPILog()).thenReturn(loggerServiceMock);
        mocks.stopStubbing();
        Application.Service.setMock(LoggerService.class, loggerServiceMock);

        // When
        new RestRouteTestRoutes.APIEntryRoute().execute();

        // Then
        System.assertEquals(200, RestContext.Response.statusCode);
        RestRouteTestRoutes.CompanyLocation[] response = (RestRouteTestRoutes.CompanyLocation[]) JSON.deserialize(
            RestContext.Response.responseBody.toString(),
            List<RestRouteTestRoutes.CompanyLocation>.class
        );
        System.assertEquals(1, response.size());
        System.assertEquals('LA', response[0].name);

        // Then
        ((LoggerService) mocks.verify(loggerServiceMock,1)).logApiInbound();    
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setRequest(RestContext.Request.requestBody.toString()); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponse(RestContext.Response.responseBody.toString());  
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setCalloutEndpoint(RestContext.Request.requestURI);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponseCode(RestContext.Response.statusCode);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).doInsertAPILog();
    }

    @isTest
    public static void testAlternateRoute() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        LoggerService loggerServiceMock = (LoggerService) mocks.mock(LoggerService.class);

        // Create RestRequest and RestResponse objects
        RestRouteTestUtil.setRestRequest(
            RESOURCE_PATH, 
            '/api/v1/employees', 
            new Map<String, String>{ 'companyId' => 'c-2' }
        );
        RestRouteTestUtil.setSuccessRestResponse();

        // Given
        mocks.startStubbing();
        mocks.when(loggerServiceMock.logApiInbound()).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setRequest(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponse(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setCalloutEndpoint(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponseCode(fflib_Match.anyInteger())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.doInsertAPILog()).thenReturn(loggerServiceMock);
        mocks.stopStubbing();
        Application.Service.setMock(LoggerService.class, loggerServiceMock);

        // When
        RestRouteTestRoutes.APIEntryRoute router = new RestRouteTestRoutes.APIEntryRoute();
        router.execute();

        // Then
        System.assertEquals(200, RestContext.Response.statusCode);
        RestRouteTestRoutes.CompanyEmployee[] response = (RestRouteTestRoutes.CompanyEmployee[]) JSON.deserialize(
            RestContext.Response.responseBody.toString(),
            List<RestRouteTestRoutes.CompanyEmployee>.class
        );
        System.assertEquals(3, response.size());
        System.assertEquals('Iron Man', response[0].name);

        // Then
        ((LoggerService) mocks.verify(loggerServiceMock,1)).logApiInbound();    
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setRequest(RestContext.Request.requestBody.toString()); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponse(RestContext.Response.responseBody.toString());  
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setCalloutEndpoint(RestContext.Request.requestURI);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponseCode(RestContext.Response.statusCode);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).doInsertAPILog();
    }

    @isTest
    public static void testRouteCollectionFilter() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        LoggerService loggerServiceMock = (LoggerService) mocks.mock(LoggerService.class);

        // Create RestRequest and RestResponse objects
        RestRouteTestUtil.setRestRequest(
            RESOURCE_PATH, 
            '/api/v1/companies/c-2/employees',
            new Map<String, String>{ 'role' => 'CEO' }
        );
        RestRouteTestUtil.setSuccessRestResponse();

        // Given
        mocks.startStubbing();
        mocks.when(loggerServiceMock.logApiInbound()).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setRequest(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponse(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setCalloutEndpoint(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponseCode(fflib_Match.anyInteger())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.doInsertAPILog()).thenReturn(loggerServiceMock);
        mocks.stopStubbing();
        Application.Service.setMock(LoggerService.class, loggerServiceMock);

        // When
        RestRouteTestRoutes.APIEntryRoute router = new RestRouteTestRoutes.APIEntryRoute();
        router.execute();
 
        // Then
        System.assertEquals(200, RestContext.Response.statusCode);
        RestRouteTestRoutes.CompanyEmployee[] response = (RestRouteTestRoutes.CompanyEmployee[]) JSON.deserialize(
            RestContext.Response.responseBody.toString(),
            List<RestRouteTestRoutes.CompanyEmployee>.class
        );
 
        System.assertEquals(2, response.size());
        System.assertEquals('Iron Man', response[0].name);

        // Then
        ((LoggerService) mocks.verify(loggerServiceMock,1)).logApiInbound();    
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setRequest(RestContext.Request.requestBody.toString()); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponse(RestContext.Response.responseBody.toString());  
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setCalloutEndpoint(RestContext.Request.requestURI);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponseCode(RestContext.Response.statusCode);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).doInsertAPILog();
    }

    @isTest
    public static void testNestedRouteSingle() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        LoggerService loggerServiceMock = (LoggerService) mocks.mock(LoggerService.class);

        // Create RestRequest and RestResponse objects
        RestRouteTestUtil.setRestRequest(
            RESOURCE_PATH, 
            '/api/v1/companies/c-1/employees/e-2'
        );
        RestRouteTestUtil.setSuccessRestResponse();

        // Given
        mocks.startStubbing();
        mocks.when(loggerServiceMock.logApiInbound()).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setRequest(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponse(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setCalloutEndpoint(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponseCode(fflib_Match.anyInteger())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.doInsertAPILog()).thenReturn(loggerServiceMock);
        mocks.stopStubbing();
        Application.Service.setMock(LoggerService.class, loggerServiceMock);

        // When
        RestRouteTestRoutes.APIEntryRoute router = new RestRouteTestRoutes.APIEntryRoute();
        router.execute();
 
        // Then
        System.assertEquals(200, RestContext.Response.statusCode);
        RestRouteTestRoutes.CompanyEmployee response = (RestRouteTestRoutes.CompanyEmployee) JSON.deserialize(
            RestContext.Response.responseBody.toString(),
            RestRouteTestRoutes.CompanyEmployee.class
        );
        System.assertEquals('e-2', response.id);

        // Then
        ((LoggerService) mocks.verify(loggerServiceMock,1)).logApiInbound();    
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setRequest(RestContext.Request.requestBody.toString()); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponse(RestContext.Response.responseBody.toString());  
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setCalloutEndpoint(RestContext.Request.requestURI);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponseCode(RestContext.Response.statusCode);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).doInsertAPILog();
    }

    @isTest
    public static void testNestedRouteSingleNotRelated() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork unitOfWorkMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        LoggerService loggerServiceMock = (LoggerService) mocks.mock(LoggerService.class);

        // Create Exception_Log__c object
        Exception_Log__c exceptionLog = new Exception_Log__c(
            Exception_Message__c = 'stubbed exception.'
        );

        // Create RestRequest and RestResponse objects
        RestRouteTestUtil.setRestRequest(
            RESOURCE_PATH, 
            '/api/v1/companies/c-2/employees/e-2'
        );
        RestRouteTestUtil.setRestResponse(404);

        // Given
        mocks.startStubbing();
        mocks.when(loggerServiceMock.logApiInbound()).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setRequest(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponse(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setCalloutEndpoint(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponseCode(fflib_Match.anyInteger())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.doInsertAPILog()).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.logException()).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setRunningUser(fflib_Match.anyId())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setExceptionMessage(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setTypeName(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setStackTrace(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setClassName(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setMethodName(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.getExceptionLog()).thenReturn(exceptionLog);
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(unitOfWorkMock);
        Application.Service.setMock(LoggerService.class, loggerServiceMock);

        // When
        new RestRouteTestRoutes.APIEntryRoute().execute();

        // Then
        System.assertEquals(404, RestContext.Response.statusCode);
        RestRouteError.Response[] response = RestRouteTestUtil.parseResponseErrors(RestContext.Response);

        System.assertEquals(1, response.size());
        System.assertEquals('NOT_FOUND', response[0].errorCode);

        // Then
        ((fflib_ISObjectUnitOfWork) mocks.verify(unitOfWorkMock, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork)mocks.verify(unitOfWorkMock,mocks.times(1)
            .description('Exception log should be created')))
            .registerNew(fflib_Match.sObjectWith(
            new Map<SObjectField,Object> {
                Exception_Log__c.Exception_Message__c => 'stubbed exception.'
            }
        )); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).logApiInbound();    
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setRequest(RestContext.Request.requestBody.toString()); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponse(RestContext.Response.responseBody.toString());  
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setCalloutEndpoint(RestContext.Request.requestURI);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponseCode(RestContext.Response.statusCode);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).doInsertAPILog();
        ((LoggerService) mocks.verify(loggerServiceMock,1)).logException();    
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setRunningUser(UserInfo.getUserId()); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setExceptionMessage(fflib_Match.anyString());  
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setTypeName(fflib_Match.anyString());   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setStackTrace(fflib_Match.anyString());   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setClassName('RestRoute');   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setMethodName('execute');
        ((LoggerService) mocks.verify(loggerServiceMock,1)).getExceptionLog();   
    }

    @isTest
    public static void testNoRouteFound() {
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork unitOfWorkMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        LoggerService loggerServiceMock = (LoggerService) mocks.mock(LoggerService.class);

        // Create Exception_Log__c object
        Exception_Log__c exceptionLog = new Exception_Log__c(
            Exception_Message__c = 'stubbed exception.'
        );

        // Create RestRequest and RestResponse objects
        RestRouteTestUtil.setRestRequest(
            RESOURCE_PATH, 
            '/api/v1/companies/c-2/asdf'
        );
        RestRouteTestUtil.setRestResponse(404);

        // Given
        mocks.startStubbing();
        mocks.when(loggerServiceMock.logApiInbound()).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setRequest(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponse(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setCalloutEndpoint(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setResponseCode(fflib_Match.anyInteger())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.doInsertAPILog()).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.logException()).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setRunningUser(fflib_Match.anyId())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setExceptionMessage(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setTypeName(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setStackTrace(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setClassName(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.setMethodName(fflib_Match.anyString())).thenReturn(loggerServiceMock);
        mocks.when(loggerServiceMock.getExceptionLog()).thenReturn(exceptionLog);
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(unitOfWorkMock);
        Application.Service.setMock(LoggerService.class, loggerServiceMock);

        // When
        new RestRouteTestRoutes.APIEntryRoute().execute();

        // Then
        System.assertEquals(404, RestContext.Response.statusCode);
        RestRouteError.Response[] response = RestRouteTestUtil.parseResponseErrors(RestContext.Response);

        System.assertEquals(1, response.size());
        System.assertEquals('NOT_FOUND', response[0].errorCode);

        // Then
        ((fflib_ISObjectUnitOfWork) mocks.verify(unitOfWorkMock, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork)mocks.verify(unitOfWorkMock,mocks.times(1)
            .description('Exception log should be created')))
            .registerNew(fflib_Match.sObjectWith(
            new Map<SObjectField,Object> {
                Exception_Log__c.Exception_Message__c => 'stubbed exception.'
            }
        )); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).logApiInbound();    
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setRequest(RestContext.Request.requestBody.toString()); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponse(RestContext.Response.responseBody.toString());  
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setCalloutEndpoint(RestContext.Request.requestURI);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponseCode(RestContext.Response.statusCode);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).doInsertAPILog();
        ((LoggerService) mocks.verify(loggerServiceMock,1)).logException();    
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setRunningUser(UserInfo.getUserId()); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setExceptionMessage(fflib_Match.anyString());  
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setTypeName(fflib_Match.anyString());   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setStackTrace(fflib_Match.anyString());   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setClassName('RestRoute');   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setMethodName('execute');
        ((LoggerService) mocks.verify(loggerServiceMock,1)).getExceptionLog();   
    }

}