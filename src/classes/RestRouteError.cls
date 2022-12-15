public class RestRouteError {
    public class Response {
        public String errorCode { get; private set; }
        private String message;
        private Id exceptionLogId;

        public Response(String errorCode, String message) {
            this.errorCode = errorCode;
            this.message = message;
        }

        public void setExceptionLogId(Id exceptionLogId) {
            this.exceptionLogId = exceptionLogId;
        }
    }

    public virtual class RestException extends Exception {
        public Response errorResponse { get; private set; }
        public Integer statusCode { get; private set; }

        public RestException(String message, String errorCode, Integer statusCode) {
            this.setMessage(message);
            this.errorResponse = new Response(errorCode, message);
            this.statusCode = statusCode;
        }
    }
}