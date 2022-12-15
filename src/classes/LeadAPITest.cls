@IsTest(IsParallel=true)
private class LeadAPITest {
    
    private static final String RESOURCE_URL = '/v1/leads';
    private static final String RESOURCE_PATH = '/services/apexrest' + RESOURCE_URL;
   
    @IsTest
    private static void itShouldSuccessfullyCreateLead() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        LeadService leadServiceMock = (LeadService) mocks.mock(LeadService.class);
        LoggerService loggerServiceMock = (LoggerService) mocks.mock(LoggerService.class);
        LeadService.DAZNLead daznLead = new LeadService.DAZNLead();
        daznLead.Lead = TestUtils.createStandardLead();

        // Given
        RestRouteTestUtil.setRestRequest(
            RESOURCE_PATH, 
            '/leads',
            'POST',
            null,
            Blob.valueOf(JSON.serialize(daznLead))
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
        mocks.when(leadServiceMock.createLead(daznLead)).thenReturn(leadServiceMock);
        mocks.stopStubbing();
        Application.Service.setMock(LeadService.class, leadServiceMock);
        Application.Service.setMock(LoggerService.class, loggerServiceMock);

        // When
        LeadAPI.handlePost();

        // Then
        ((LeadService) mocks.verify(leadServiceMock, 1))
            .createLead((LeadService.DAZNLead)fflib_Match.anyObject());

        fflib_ArgumentCaptor capturedDAZNLeadArg = 
            fflib_ArgumentCaptor.forClass(LeadService.DAZNLead.class);
        
        ((LeadService) mocks.verify(leadServiceMock,1))
            .createLead((LeadService.DAZNLead)capturedDAZNLeadArg.capture());

        Object actualCapturedLeadArgAsObject = capturedDAZNLeadArg.getValue();
        LeadService.DAZNLead actualDAZNLead = (LeadService.DAZNLead)actualCapturedLeadArgAsObject;

        System.assertEquals(daznLead.Lead.Id, actualDAZNLead.Lead.Id,'should have same leadId value.');
        System.assertEquals(daznLead.Lead.Country__c, actualDAZNLead.Lead.Country__c,'should have same country value.');
        System.assertEquals(daznLead.Lead.Business_type__c, actualDAZNLead.Lead.Business_type__c,'should have same business type value.');
        ((LoggerService) mocks.verify(loggerServiceMock,1)).logApiInbound();    
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setRequest(RestContext.Request.requestBody.toString()); 
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponse(RestContext.Response.responseBody.toString());  
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setCalloutEndpoint(RestContext.Request.requestURI);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).setResponseCode(RestContext.Response.statusCode);   
        ((LoggerService) mocks.verify(loggerServiceMock,1)).doInsertAPILog();
    }

}