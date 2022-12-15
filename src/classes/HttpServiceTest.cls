@IsTest
private class HttpServiceTest {

    @IsTest
    static void isSuccessResponseCodeTrueTest() {
        String successStatusCode = '200';
        Boolean result = HttpService.newInstance().isSuccessResponseCode(successStatusCode);
        System.assertEquals(true, result);
    }

    @IsTest
    static void isSuccessResponseCodeFalseTest() {
        String failureStatusCode = '404';
        Boolean result = HttpService.newInstance().isSuccessResponseCode(failureStatusCode);
        System.assertEquals(false, result);
    }

    @IsTest
    static void sendReturnMockedHttpResponseTest() {
        MockHttpResponse mockHttpResponse = new MockHttpResponse();
        Test.setMock(HttpCalloutMock.class, mockHttpResponse);

        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod(mockHttpResponse.METHOD);
        httpRequest.setEndpoint(mockHttpResponse.ENDPOINT);

        HttpResponse httpResponse = HttpService.newInstance().send(httpRequest);

        System.assertEquals(mockHttpResponse.HEADER_VALUE, httpResponse.getHeader(mockHttpResponse.HEADER_KEY));
        System.assertEquals(mockHttpResponse.BODY, httpResponse.getBody());
        System.assertEquals(mockHttpResponse.STATUS_CODE, httpResponse.getStatusCode());
    }

    private class MockHttpResponse implements HttpCalloutMock {
        private final String ENDPOINT = 'http://example.com/example/test';
        private final String METHOD = 'GET';
        private final String HEADER_KEY = 'Content-Type';
        private final String HEADER_VALUE = 'application/json';
        private final String BODY = '{"example":"test"}';
        private final Integer STATUS_CODE = 200;

        public HttpResponse respond(HttpRequest request) {
            System.assertEquals(ENDPOINT, request.getEndpoint());
            System.assertEquals(METHOD, request.getMethod());

            HttpResponse res = new HttpResponse();
            res.setHeader(HEADER_KEY, HEADER_VALUE);
            res.setBody(BODY);
            res.setStatusCode(STATUS_CODE);
            return res;
        }
    }
}