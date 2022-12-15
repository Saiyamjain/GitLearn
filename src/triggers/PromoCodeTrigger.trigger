trigger PromoCodeTrigger on PromoCode__c (after insert) {
    fflib_SObjectDomain.triggerHandler(PromoCodeDomain.class);
}