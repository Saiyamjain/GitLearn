public with sharing class RestCalloutService {
    public static final String CALLOUT_DETAILS_RESET_PASSWORD_NAME = 'Reset_Password';
    public static final String CALLOUT_DETAILS_ARTICLE_UPSERT_NAME = 'Article_Upsert';
    public static final String CALLOUT_DETAILS_ACCOUNT_SYNC_IND_BANK_TRANSFER_EUC = 'Account_Sync_Ind_Bank_Transfer_EUC';
    public static final String CALLOUT_DETAILS_DOWNLOAD_INVOICE = 'Download_Invoice';

    public HttpRequest request {get; private set;}
    public HttpResponse response {get; private set;}
    public LoggerService logger {get; private set;}
    public String processId {get; private set;}
    public String accountId {get; private set;}

    public static RestCalloutService newInstance() {
        return (RestCalloutService)  Application.Service.newInstance(RestCalloutService.class);
    }

    public RestCalloutService() {
        request = new HttpRequest();
        response = new HttpResponse();
    }

    public RestCalloutService post() {
        return setMethod('POST');
    }

    public RestCalloutService get() {
        return setMethod('GET');
    }

    public RestCalloutService put() {
        return setMethod('PUT');
    }

    public RestCalloutService setJsonHeaderContentType() {
        request.setHeader('Content-Type','application/json');
        return this;
    }

    public RestCalloutService setUrlEncodedHeaderContentType() {
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        return this;
    }

    public RestCalloutService setBearerTokenAuthorizationHeader(String token) {
        request.setHeader('Authorization', 'Bearer ' + token);
        return this;
    }

    public RestCalloutService setHeader(String key, String value) {
        request.setHeader(key,value);
        return this;
    }

    public RestCalloutService setMethod(String method) {
        request.setMethod(method);
        return this;
    }

    public RestCalloutService setBody(String body) {
        request.setBody(body);
        return this;
    }

    public RestCalloutService setEndpoint(String endpoint) {
        request.setEndpoint(endpoint);
        return this;
    }

    public RestCalloutService setTimeout(Integer timeout) {
        request.setTimeout(timeout);
        return this;
    }

    public RestCalloutService setAccountId(String accountId) {
        this.accountId = accountId;
        return this;
    }

    public RestCalloutService setProcessId(String processId) {
        this.processId = processId;
        return this;
    }

    public RestCalloutService send() {
        return send(true);
    }

    public RestCalloutService send(Boolean logApiCall) {
        Long sendingTime = Datetime.now().getTime();
        Rest_Callout_Settings__mdt calloutSettings = RestCalloutSettingsSelector.newInstance().getOrgDefault();
        Integer retryCount = -1;
        for (Integer i = 0; i <= calloutSettings.Max_Retry_Count__c; i++) {
            retryCount++;
            response = HttpService.newInstance().send(request);
            if (HttpService.newInstance().isSuccessResponseCode(String.valueOf(response.getStatusCode()))) {
                break;
            }
        }
        Long responseTime = Datetime.now().getTime() - sendingTime;
        createApiLogCall(responseTime, retryCount);
        if (logApiCall) {
            logger.doInsertAPILog();
        }
        return this;
    }

    public Integer getStatusCode() {
        return response.getStatusCode();
    }

    public String getResponseBody() {
        return response.getBody();
    }

    public HttpResponse getResponse() {
        return response;
    }

    public RestCalloutService setCalloutDetails(String calloutDetailsName) {
        Callout_Details__mdt calloutDetailsAllEnvironments =
            CalloutDetailsSelector.newInstance().selectByDeveloperName(calloutDetailsName);

        CalloutDetails calloutDetails = (CalloutDetails) JSON.deserialize(
            (String)calloutDetailsAllEnvironments.get(
                OrgConfigurationSelector.newInstance().selectMainConfig().Environment_Type__c + '__c')
            ,CalloutDetails.class);
        
        setEndpoint(calloutDetails.endpoint);
        if (calloutDetails.headers != null) {
            for (Header header : calloutDetails.headers) {
                setHeader(header.key, header.value);
            }
        }
        if (calloutDetails.timeout != null) {
            setTimeout(calloutDetails.timeout);
        }
        return this;
    }

    public RestCalloutService setCalloutDetailsForInvoice(String calloutDetailsName, String customerId, String transactionId) {
        Callout_Details__mdt calloutDetailsAllEnvironments =
                CalloutDetailsSelector.newInstance().selectByDeveloperName(calloutDetailsName);

        CalloutDetails calloutDetails = (CalloutDetails) JSON.deserialize(
                (String)calloutDetailsAllEnvironments.get(
                        OrgConfigurationSelector.newInstance().selectMainConfig().Environment_Type__c + '__c')
                ,CalloutDetails.class);

        String endpointForInvoice = calloutDetails.endpoint + '/' + customerId + '/' + transactionId;
        setEndpoint(endpointForInvoice);
        if (calloutDetails.headers != null) {
            for (Header header : calloutDetails.headers) {
                setHeader(header.key, header.value);
            }
        }
        if (calloutDetails.timeout != null) {
            setTimeout(calloutDetails.timeout);
        }
        return this;
    }

    public API_Log__c getApiLog() {
        return logger?.getApiLog();
    }

    private void createApiLogCall(Long responseTime, Integer retryCount) {
        logger = LoggerService.newInstance().logApiOutbound(new API_Log__c(Process_ID__c = processId))
                .setCalloutEndpoint(request.getEndpoint())
                .setRequest(request.getBody())
                .setResponse(response.getBody())
                .setResponseCode(response.getStatusCode())
                .setResponseTime(responseTime.intValue())
                .setRetryCount(retryCount)
                .setAccountId(accountId);
    }

    public class CalloutDetails {
        public String endpoint { get; private set; }
        public List<Header> headers { get; private set; }
        public Integer timeout { get; private set; }
    }

    public class Header {
        String key;
        String value;
    }
    
}