@isTest
public class HttpCalloutMockFactory implements HttpCalloutMock {
    protected Integer code {
        get {
            if (code == null) {
                code = 0;
            }
            return code;
        }
        set;
    }
    protected String status {
        get {
            if (status == null) {
                status = 'exampleStatus';
            }
            return status;
        }
        set;
    }
    protected String body {
        get {
            if (body == null) {
                body = 'exampleBody';
            }
            return body;
        }
        set;
    }
    protected Map<String, String> responseHeaders {
        get {
            if (responseHeaders == null) {
                responseHeaders = new Map<String, String>();
            }
            return responseHeaders;
        }
        set;
    }

    public HttpCalloutMockFactory(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    public HttpCalloutMockFactory(Integer code) {
        this.code = code;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
}