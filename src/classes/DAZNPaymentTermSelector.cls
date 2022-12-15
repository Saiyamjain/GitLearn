public inherited sharing class DAZNPaymentTermSelector extends fflib_SObjectSelector {

    public static DAZNPaymentTermSelector newInstance() {
        return (DAZNPaymentTermSelector) Application.Selector.newInstance(PaymentTerm__c.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                PaymentTerm__c.Id,
                PaymentTerm__c.Name,
                PaymentTerm__c.Business_Type__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return PaymentTerm__c.SObjectType;
    }

    public List<PaymentTerm__c> selectPaymentTermByBusinessType(Set<String> paymentTerm) {
        // Prevent SOQL injection
        List<String> paymentTermList = new List<String>();
        for(String community : paymentTerm) {
            paymentTermList.add(String.escapeSingleQuotes(community));
        }

        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Business_Type__c INCLUDES (\'' + String.join(paymentTermList, '\',\'') + '\') ');
        return (List<PaymentTerm__c>) Database.query(query.toSOQL());
    }
}