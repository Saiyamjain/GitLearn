public with sharing class RejoinCustomerController {

    @AuraEnabled(cacheable=true)
    public static Pricebook2 getPriceManagementData(String businessType, String country, String accountRecordTypeId, String partnerId) {
        return SubscriptionService.newInstance().getPriceManagementData(businessType, country, accountRecordTypeId, partnerId);
    }
 
    @AuraEnabled
    public static void handleRejoinCustomer(SubscriptionService.RejoinData data)  {
        try {
            SubscriptionService.newInstance().handleRejoinCustomer(data);
        } catch (Exception error) {
            Application.throwAuraHandledException(error);
	    }
    }
}