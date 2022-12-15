@isTest
private class ApiRequestResolverTests {
    @isTest
    static void itShouldResolveResourceRoute() {
        // Given
        String apiName = 'orders';
        RestContext.request = getRequest(apiName);
        // When
        ApiRequestResolver resolver = new ApiRequestResolver(RestContext.request);
        // Then
        System.assertEquals(apiName.capitalize(), resolver.apiName);
    }

    @isTest
    static void itShouldHandleNonTrailingSlash() {
        // Given
        String apiName = 'orders';
        RestContext.request = getRequest(apiName + '/');
        // When
        ApiRequestResolver resolver = new ApiRequestResolver(RestContext.request);
        // Then
        System.assertEquals(apiName.capitalize(), resolver.apiName);
    }

    @isTest
    static void itShouldNotResolveRequestBody() {
        // Given
        String apiName = 'orders';
        String invalidBody = ',';
        RestContext.request = getRequest(apiName,invalidBody);
        RestContext.request.headers.put('Content-Type', 'application/json');

        // When
        ApiRequestResolver resolver = new ApiRequestResolver(RestContext.request);
        // Then
        System.assertEquals('', resolver.requestBody);
        System.assert(resolver.requestBody != invalidBody);
    }

    @isTest
    static void itShouldResolvePathParameter() {
        // Given
        String apiName = 'orders';
        String validPathParam = 'customercreated';
        RestContext.request = getRequest(apiName + '/' + validPathParam);
        // When
        ApiRequestResolver resolver = new ApiRequestResolver(RestContext.request);
        // Then
        System.assertEquals(validPathParam, resolver.pathParameter);
    }

    @IsTest
    static void itShouldGetCorrelationId() {
        // Given
        String apiName = 'orders';
        String correlationId = '1111-ffff-1111-ffff';
        RestContext.request = getRequest(apiName + '/', correlationId);
        RestContext.request.headers.put('X-Correlation-Id', correlationId);
        // When
        ApiRequestResolver resolver = new ApiRequestResolver(RestContext.request);
        // Then
        System.assertEquals(correlationId, resolver.correlationId);
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