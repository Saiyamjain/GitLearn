global abstract class Api {
    public static String SERVICE_NAME_TEMPLATE = '{0}Service';

    global class Response {    
        public Integer status {get; private set;} // 500
        public String code {get; private set;} // 500-001
        public String message {get; private set;} // Oops! It looks like the URL is not recognized in our API
        public String developerMessage {get; private set;} // Unable to locate path, should be /event/:type
        public String moreInfo {get; private set;} // https://livesport.atlassian.net/wiki/spaces/SDT/pages/2934507215/Internal+Error+Codes?code=500-001 
        public String data {get; private set;}

        public Response setStatus(Integer status) {this.status = status; return this;}
        public Response setCode(String code) {this.code = code;return this;}
        public Response setMessage(String message) {this.message = message;return this;}
        public Response setDeveloperMessage(String developerMessage) {this.developerMessage = developerMessage;return this;}
        public Response setMoreInfo(String moreInfo) {this.moreInfo = moreInfo;return this;}
        public Response setData(Object data) {this.data = data.toString();return this;}
    }

    public class StatusCode {
        // 2xx success
        public Integer OK = 200;
        public Integer CREATED = 201;
        // 4xx failure client error 
        public Integer BAD_REQUEST = 400;
        public Integer NOT_FOUND = 404;
        public Integer UNPROCESSABLE_ENTITY = 422;
        // 5xx failure server error 
        public Integer INTERNAL_SERVER_ERROR = 500;
    }

    public static Facade Facade {
        get {
            if(Facade == null) {
                Facade = new Facade();
            }
            return Facade;
        }
        private set;
    }

    public class Facade {
        private Facade() { }

        public Response doDelete(ApiRequestResolver resolver) {
            return this.getService(resolver).doDelete(resolver);
        }

        public Response doGet(ApiRequestResolver resolver) {
            return this.getService(resolver).doGet(resolver);
        }

        public Response doPatch(ApiRequestResolver resolver) {
            return this.getService(resolver).doPatch(resolver);
        }

        public Response doPost(ApiRequestResolver resolver) {
            return this.getService(resolver).doPost(resolver);
        }

        public Response doPut(ApiRequestResolver resolver) {
            return this.getService(resolver).doPut(resolver);
        }

        public Service getService(ApiRequestResolver resolver) {
            String serviceName = String.format(SERVICE_NAME_TEMPLATE, new List<String>{resolver.apiName});
            Type serviceType = Type.forName(serviceName);
            Object service = serviceType != null ? serviceType.newInstance() : null;
            if (service instanceOf Api.Service) { 
                return (Api.Service)service;
            }
            return new Api.Service();
        }
    }

    public virtual class Service {
        public Service() {}
        @TestVisible
        protected Response response {
            get {
                if (response == null) {
                    response = defaultConfig;
                }
                return response;
            }
            set;
        }
        private Response defaultConfig {
            get {
                return new Response()
                    .setStatus(404)
                    .setDeveloperMessage(System.Label.InvalidResourcePath);
            }
        }
        public virtual Response doDelete(ApiRequestResolver resolver){return response;}
        public virtual Response doGet(ApiRequestResolver resolver){return response;}
        public virtual Response doPatch(ApiRequestResolver resolver){return response;}
        public virtual Response doPost(ApiRequestResolver resolver){return response;}
        public virtual Response doPut(ApiRequestResolver resolver){return response;}
    }

    public class ApiException extends Exception{}
    
}