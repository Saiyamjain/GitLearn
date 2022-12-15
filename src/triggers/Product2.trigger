trigger Product2 on Product2 (after insert) {
    fflib_SObjectDomain.triggerHandler(Product2Domain.class);

}