@isTest
private class ApiServiceTests {
    @isTest
    static void itShouldReturnFailForNonExistentRoute() {
        // Given
        RestContext.request = getRequest('nonexistent');
        // When
        Api.Response response = ApiService.doGet();
        // Then
        System.assertEquals(404,response.status);
        System.assertEquals(System.Label.InvalidResourcePath,response.developerMessage);
    }

    @isTest
    static void itShouldReturnSuccessForExistingRoute() {
        // Given
        RestContext.request = new RestRequest();
        Api.SERVICE_NAME_TEMPLATE = ApiServiceTests.class.getName() + '.{0}Service';
        // have to insert the "namespace" for the test class
        // otherwise it will fail to dynamically build correctly
        RestContext.request = getRequest('Event');
        // When
        Api.Response doDeleteResponse = ApiService.doDelete();
        // Then
        System.assertEquals(200,doDeleteResponse.status);
        // When
        Api.Response doGetResponse = ApiService.doGet();
        // Then
        System.assertEquals(200,doGetResponse.status);
        // When
        Api.Response doPatchResponse = ApiService.doPatch();
        // Then
        System.assertEquals(200,doPatchResponse.status);
        // When
        Api.Response doPostResponse = ApiService.doPost();
        // Then
        System.assertEquals(200,doPostResponse.status);
        // When
        Api.Response doPutResponse = ApiService.doPut();
        // Then
        System.assertEquals(200,doPutResponse.status);   
    }

    public class EventService extends Api.Service {
        public override Api.Response doDelete(ApiRequestResolver resolver) {return getSuccessMessage();}
        public override Api.Response doGet(ApiRequestResolver resolver) {return getSuccessMessage();}
        public override Api.Response doPatch(ApiRequestResolver resolver) {return getSuccessMessage();}
        public override Api.Response doPost(ApiRequestResolver resolver) {return getSuccessMessage();}
        public override Api.Response doPut(ApiRequestResolver resolver) {return getSuccessMessage();}
    }

    static Api.Response getSuccessMessage(){
        Api.Response response = new Api.Response();
        return response
                    .setMessage('')
                    .setDeveloperMessage('')
                    .setStatus(200)
                    .setCode('')
                    .setMoreInfo('')
                    .setData('');
    }

    static RestRequest getRequest(String apiName) {
        return getRequest(apiName, '{}');
    }

    static RestRequest getRequest(String apiName, String requestBody) {
        RestRequest req = new RestRequest();
        req.requestURI = '/api/' + apiName;
        req.requestBody = Blob.valueOf(requestBody);
        return req;
    }

}