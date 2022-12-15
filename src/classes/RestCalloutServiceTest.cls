/** add unit test for below methods
  getApiLog
  getResponse
  getResponseBody
  setAccountId
  setProcessId
  setHeader
  setBearerTokenAuthorizationHeader
  setUrlEncodedHeaderContentType
  setCalloutDetails (add calloutDetailHeaders in unit test)
 */
@IsTest(IsParallel=true)
private class RestCalloutServiceTest {

    @IsTest
    static void postTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        CalloutDetailsSelector calloutDetailsSelectorMock = (CalloutDetailsSelector) mocks.mock(CalloutDetailsSelector.class);
        RestCalloutSettingsSelector restCalloutSettingsSelector = (RestCalloutSettingsSelector) mocks.mock(RestCalloutSettingsSelector.class);
        OrgConfigurationSelector orgConfigSelectorMock = (OrgConfigurationSelector) mocks.mock(OrgConfigurationSelector.class);
        Org_Configuration__mdt mainConfigMock = new Org_Configuration__mdt(Environment_Type__c = 'DEV');
        HttpService httpMock = (HttpService) mocks.mock(HttpService.class);

        String requestBody = '{ "Email" : test@example.com }';
        String calloutDetailsName = 'Reset_Password__c';
        Callout_Details__mdt mockedCalloutDetails = new Callout_Details__mdt(
                DEV__c = '{"Endpoint":"http://","Headers":[{"Key":"X-Api-Key","Value":"Ofl6GC9bQkr5ruf"}]}'
        );
        Rest_Callout_Settings__mdt mockedRestCalloutSettings = new Rest_Callout_Settings__mdt(
                Max_Retry_Count__c = 0
        );
        HttpResponse mockedHttpResponse = new HttpResponse();
        Integer expectedResponseStatusCode = 200;
        mockedHttpResponse.setStatusCode(expectedResponseStatusCode);

        mocks.startStubbing();
        mocks.when(orgConfigSelectorMock.sObjectType()).thenReturn(Org_Configuration__mdt.SObjectType);
        mocks.when(orgConfigSelectorMock.selectMainConfig()).thenReturn(mainConfigMock);
        mocks.when(calloutDetailsSelectorMock.sObjectType()).thenReturn(Callout_Details__mdt.SObjectType);
        mocks.when(calloutDetailsSelectorMock.selectByDeveloperName(calloutDetailsName)).thenReturn(mockedCalloutDetails);
        mocks.when(restCalloutSettingsSelector.sObjectType()).thenReturn(Rest_Callout_Settings__mdt.SObjectType);
        mocks.when(restCalloutSettingsSelector.getOrgDefault()).thenReturn(mockedRestCalloutSettings);
        mocks.when(httpMock.send((HttpRequest) fflib_Match.anyObject())).thenReturn(mockedHttpResponse);
        mocks.when(httpMock.isSuccessResponseCode(fflib_Match.anyString())).thenReturn(true);
        mocks.stopStubbing();

        Application.UnitOfWork.setMock(uowMock);
        Application.Selector.setMock(orgConfigSelectorMock);
        Application.Selector.setMock(calloutDetailsSelectorMock);
        Application.Selector.setMock(restCalloutSettingsSelector);
        Application.Service.setMock(HttpService.class, httpMock);

        Integer responseStatusCode = RestCalloutService.newInstance().post()
                .setJsonHeaderContentType()
                .setCalloutDetails(calloutDetailsName)
                .setBody(requestBody)
                .send()
                .getStatusCode();

        ((HttpService) mocks.verify(httpMock, 1)).send((HttpRequest) fflib_Match.anyObject());
        System.assertEquals(expectedResponseStatusCode, responseStatusCode);
    }

    @IsTest
    static void retriesTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        OrgConfigurationSelector orgConfigSelectorMock = (OrgConfigurationSelector) mocks.mock(OrgConfigurationSelector.class);
        Org_Configuration__mdt mainConfigMock = new Org_Configuration__mdt(Environment_Type__c = 'DEV');
        CalloutDetailsSelector calloutDetailsSelectorMock = (CalloutDetailsSelector) mocks.mock(CalloutDetailsSelector.class);
        RestCalloutSettingsSelector restCalloutSettingsSelector = (RestCalloutSettingsSelector) mocks.mock(RestCalloutSettingsSelector.class);
        HttpService httpMock = (HttpService) mocks.mock(HttpService.class);

        String requestBody = '{ "Email" : test@example.com }';
        String calloutDetailsName = 'Reset_Password__c';
        Callout_Details__mdt mockedCalloutDetails = new Callout_Details__mdt(
                DEV__c = '{"Endpoint":"http://","Headers":[{"Key":"X-Api-Key","Value":"Ofl6GC9bQkr5ruf"}]}'
        );
        Integer maxRetryCount = 3;
        Rest_Callout_Settings__mdt mockedRestCalloutSettings = new Rest_Callout_Settings__mdt(
            Max_Retry_Count__c = maxRetryCount
        );
        HttpResponse mockedHttpResponse = new HttpResponse();
        Integer expectedResponseStatusCode = 400;
        mockedHttpResponse.setStatusCode(expectedResponseStatusCode);

        mocks.startStubbing();
        mocks.when(orgConfigSelectorMock.sObjectType()).thenReturn(Org_Configuration__mdt.SObjectType);
        mocks.when(orgConfigSelectorMock.selectMainConfig()).thenReturn(mainConfigMock);
        mocks.when(calloutDetailsSelectorMock.sObjectType()).thenReturn(Callout_Details__mdt.SObjectType);
        mocks.when(calloutDetailsSelectorMock.selectByDeveloperName(calloutDetailsName)).thenReturn(mockedCalloutDetails);
        mocks.when(restCalloutSettingsSelector.sObjectType()).thenReturn(Rest_Callout_Settings__mdt.SObjectType);
        mocks.when(restCalloutSettingsSelector.getOrgDefault()).thenReturn(mockedRestCalloutSettings);
        mocks.when(httpMock.send((HttpRequest) fflib_Match.anyObject())).thenReturn(mockedHttpResponse);
        mocks.when(httpMock.isSuccessResponseCode(fflib_Match.anyString())).thenReturn(false);
        mocks.stopStubbing();

        Application.UnitOfWork.setMock(uowMock);
        Application.Selector.setMock(orgConfigSelectorMock);
        Application.Selector.setMock(calloutDetailsSelectorMock);
        Application.Selector.setMock(restCalloutSettingsSelector);
        Application.Service.setMock(HttpService.class, httpMock);

        RestCalloutService.newInstance().get()
                .setJsonHeaderContentType()
                .setCalloutDetails(calloutDetailsName)
                .setBody(requestBody)
                .send();

        ((HttpService) mocks.verify(httpMock, maxRetryCount + 1)).send((HttpRequest) fflib_Match.anyObject());
    }

    @IsTest
    static void putTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        OrgConfigurationSelector orgConfigSelectorMock = (OrgConfigurationSelector) mocks.mock(OrgConfigurationSelector.class);
        Org_Configuration__mdt mainConfigMock = new Org_Configuration__mdt(Environment_Type__c = 'DEV');
        CalloutDetailsSelector calloutDetailsSelectorMock = (CalloutDetailsSelector) mocks.mock(CalloutDetailsSelector.class);
        RestCalloutSettingsSelector restCalloutSettingsSelector = (RestCalloutSettingsSelector) mocks.mock(RestCalloutSettingsSelector.class);
        HttpService httpMock = (HttpService) mocks.mock(HttpService.class);

        String requestBody = '{ "Email" : test@example.com }';
        String calloutDetailsName = 'Reset_Password__c';
        Callout_Details__mdt mockedCalloutDetails = new Callout_Details__mdt(
                DEV__c = '{"Endpoint":"http://","Headers":[{"Key":"X-Api-Key","Value":"Ofl6GC9bQkr5ruf"}]}'
        );
        Rest_Callout_Settings__mdt mockedRestCalloutSettings = new Rest_Callout_Settings__mdt(
                Max_Retry_Count__c = 0
        );
        HttpResponse mockedHttpResponse = new HttpResponse();
        Integer expectedResponseStatusCode = 200;
        mockedHttpResponse.setStatusCode(expectedResponseStatusCode);

        mocks.startStubbing();
        mocks.when(orgConfigSelectorMock.sObjectType()).thenReturn(Org_Configuration__mdt.SObjectType);
        mocks.when(orgConfigSelectorMock.selectMainConfig()).thenReturn(mainConfigMock);
        mocks.when(calloutDetailsSelectorMock.sObjectType()).thenReturn(Callout_Details__mdt.SObjectType);
        mocks.when(calloutDetailsSelectorMock.selectByDeveloperName(calloutDetailsName)).thenReturn(mockedCalloutDetails);
        mocks.when(restCalloutSettingsSelector.sObjectType()).thenReturn(Rest_Callout_Settings__mdt.SObjectType);
        mocks.when(restCalloutSettingsSelector.getOrgDefault()).thenReturn(mockedRestCalloutSettings);
        mocks.when(httpMock.send((HttpRequest) fflib_Match.anyObject())).thenReturn(mockedHttpResponse);
        mocks.when(httpMock.isSuccessResponseCode(fflib_Match.anyString())).thenReturn(true);
        mocks.stopStubbing();

        Application.UnitOfWork.setMock(uowMock);
        Application.Selector.setMock(orgConfigSelectorMock);
        Application.Selector.setMock(calloutDetailsSelectorMock);
        Application.Selector.setMock(restCalloutSettingsSelector);
        Application.Service.setMock(HttpService.class, httpMock);

        Integer responseStatusCode = RestCalloutService.newInstance().put()
                .setJsonHeaderContentType()
                .setCalloutDetails(calloutDetailsName)
                .setBody(requestBody)
                .send()
                .getStatusCode();

        ((HttpService) mocks.verify(httpMock, 1)).send((HttpRequest) fflib_Match.anyObject());
        System.assertEquals(expectedResponseStatusCode, responseStatusCode);
    }

    @IsTest
    static void getTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        OrgConfigurationSelector orgConfigSelectorMock = (OrgConfigurationSelector) mocks.mock(OrgConfigurationSelector.class);
        Org_Configuration__mdt mainConfigMock = new Org_Configuration__mdt(Environment_Type__c = 'DEV');
        CalloutDetailsSelector calloutDetailsSelectorMock = (CalloutDetailsSelector) mocks.mock(CalloutDetailsSelector.class);
        RestCalloutSettingsSelector restCalloutSettingsSelector = (RestCalloutSettingsSelector) mocks.mock(RestCalloutSettingsSelector.class);
        HttpService httpMock = (HttpService) mocks.mock(HttpService.class);

        String calloutDetailsName = 'Download_Invoice';
        Callout_Details__mdt mockedCalloutDetails = new Callout_Details__mdt(
                DEV__c = '{"Endpoint":"http://","Headers":[{"Key":"X-Api-Key","Value":"Ofl6GC9bQkr5ruf"}]}'
        );
        Rest_Callout_Settings__mdt mockedRestCalloutSettings = new Rest_Callout_Settings__mdt(
                Max_Retry_Count__c = 0
        );
        HttpResponse mockedHttpResponse = new HttpResponse();
        Integer expectedResponseStatusCode = 200;
        mockedHttpResponse.setStatusCode(expectedResponseStatusCode);

        mocks.startStubbing();
        mocks.when(orgConfigSelectorMock.sObjectType()).thenReturn(Org_Configuration__mdt.SObjectType);
        mocks.when(orgConfigSelectorMock.selectMainConfig()).thenReturn(mainConfigMock);
        mocks.when(calloutDetailsSelectorMock.sObjectType()).thenReturn(Callout_Details__mdt.SObjectType);
        mocks.when(calloutDetailsSelectorMock.selectByDeveloperName(calloutDetailsName)).thenReturn(mockedCalloutDetails);
        mocks.when(restCalloutSettingsSelector.sObjectType()).thenReturn(Rest_Callout_Settings__mdt.SObjectType);
        mocks.when(restCalloutSettingsSelector.getOrgDefault()).thenReturn(mockedRestCalloutSettings);
        mocks.when(httpMock.send((HttpRequest) fflib_Match.anyObject())).thenReturn(mockedHttpResponse);
        mocks.when(httpMock.isSuccessResponseCode(fflib_Match.anyString())).thenReturn(true);
        mocks.stopStubbing();

        Application.UnitOfWork.setMock(uowMock);
        Application.Selector.setMock(orgConfigSelectorMock);
        Application.Selector.setMock(calloutDetailsSelectorMock);
        Application.Selector.setMock(restCalloutSettingsSelector);
        Application.Service.setMock(HttpService.class, httpMock);

        Integer responseStatusCode = RestCalloutService.newInstance().put()
                .setJsonHeaderContentType()
                .setCalloutDetailsForInvoice(calloutDetailsName,'', '')
                .send()
                .getStatusCode();

        ((HttpService) mocks.verify(httpMock, 1)).send((HttpRequest) fflib_Match.anyObject());
        System.assertEquals(expectedResponseStatusCode, responseStatusCode);
    }
}