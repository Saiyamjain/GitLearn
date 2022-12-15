public inherited sharing class OrderItemSelector extends fflib_SObjectSelector {
    public static OrderItemSelector newInstance() {
        return (OrderItemSelector) Application.Selector.newInstance(Order_Item__c.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                Order_Item__c.Unique_Id__c,
                Order_Item__c.Serial_Number__c,
                Order_Item__c.Quantity__c,
                Order_Item__c.Name
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Order_Item__c.SObjectType;
    }

    public List<Order_Item__c> selectByUniqueId(Set<String> orderItemUniqueIds) {
        return Database.query(
                newQueryFactory()
                .setCondition('Unique_Id__c IN :orderItemUniqueIds')
                .toSOQL()
        );
    }
}