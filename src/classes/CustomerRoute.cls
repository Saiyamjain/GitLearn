public class CustomerRoute extends RestRoute {

    protected override Map<String, RestRoute> getNextRouteMap() {
        validateIfResourceIdIsBlank(ResourceType.Customer);
        return new Map<String, RestRoute>{
            'subscriptions' => new SubscriptionRoute(
                new Map<String,String>{'accountId' => this.resourceId, 'customerId' => this.resourceId})
        };
    }

    protected override Object doPost() {
        CustomerService.Customer customer = deserializeJSONintoCustomer();
        CustomerService.newInstance().createCustomer(customer);
        this.response.responseBody = Blob.valueOf(JSON.serialize(String.format(System.Label.CustomerCreatedSuccessfully,
            new List<String>{
                customer.Account.Customer_Id__c})));

        return null;
    }

    protected override Object doPut() {
        validateIfResourceIdIsBlank(ResourceType.Customer);
        CustomerService.Customer customer = deserializeJSONintoCustomer(this.resourceId);
        CustomerService.newInstance().updateCustomer(customer);
        this.response.responseBody = Blob.valueOf(JSON.serialize(String.format(System.Label.CustomerUpdatedSuccessfully,
            new List<String>{
                customer.Account.Customer_Id__c})));

        return null; 
    }

    private CustomerService.Customer deserializeJSONintoCustomer(Id accountId) {
        CustomerService.Customer customer = deserializeJSONintoCustomer();
        customer.Account.Id = accountId;

        return customer;
    }

    private CustomerService.Customer deserializeJSONintoCustomer() {
        CustomerService.Customer customer = (CustomerService.Customer)JSON.deserializeStrict(
            this.request.requestBody.toString(), CustomerService.Customer.class);
        
        return validateCustomerProperties(customer);
    }

    private CustomerService.Customer validateCustomerProperties(CustomerService.Customer customer) {
        validateIfTypeIsMissing(customer);
        validateIfContactIsMissing(customer);
        validateIfAccountIsMissing(customer);

        return customer;
    }

    private void validateIfTypeIsMissing(CustomerService.Customer customer) {
        if (customer?.Type == null) {
            throw new RestRoute.PropertyIsMissingException(null, 'Type');
        }
    }

    private void validateIfContactIsMissing(CustomerService.Customer customer) {
        if (customer?.Contact == null) {
            throw new RestRoute.PropertyIsMissingException(null, 'Contact');
        }
    }

    private void validateIfAccountIsMissing(CustomerService.Customer customer) {
        if (customer?.Account == null) {
            throw new RestRoute.PropertyIsMissingException(null, 'Account');
        }
    }

    // TODO: Jens - 16-06-2022 - add CustomerRouteTest class, currently non existent 

}