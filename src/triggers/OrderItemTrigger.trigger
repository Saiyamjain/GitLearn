trigger OrderItemTrigger on Order_Item__c (after delete, after insert, after update, before delete, before insert, before update) {
    fflib_SObjectDomain.triggerHandler(OrderItemDomain.class);
}