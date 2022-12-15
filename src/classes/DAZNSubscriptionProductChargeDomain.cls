public with sharing class DAZNSubscriptionProductChargeDomain extends ApplicationDomain {
    public static DAZNSubscriptionProductChargeDomain newInstance(List<SubscriptionProductCharge__c> subscriptionProductCharges) {
        return (DAZNSubscriptionProductChargeDomain) Application.Domain.newInstance(subscriptionProductCharges);
    }

    public DAZNSubscriptionProductChargeDomain(List<SubscriptionProductCharge__c> subscriptionProductCharges) {
        super(subscriptionProductCharges);
    }

    public override void onBeforeInsert() {
        populateFromProductRatePlanAndChargeData();
        populateQuantityField();
    }

    public override void onAfterInsert() {
        populateEffectiveEndDate();
    }

    public void populateFromProductRatePlanAndChargeData() {
        for(SubscriptionProductCharge__c subscriptionProductCharge : (List<SubscriptionProductCharge__c>)getRecordsWithNotBlankFieldValues(new Set<Schema.SObjectField> {Schema.SubscriptionProductCharge__c.ProductRatePlan__c, Schema.SubscriptionProductCharge__c.ProductRatePlanCharge__c})) {
            populateFromProductRatePlan(productRatePlansByIds, subscriptionProductCharge);
            populateFromProductRatePlanCharge(productRatePlanChargesByIds, subscriptionProductCharge);
        }
    }

    private void populateFromProductRatePlan(Map<Id, ProductRatePlan__c> productRatePlansByIds, SubscriptionProductCharge__c subscriptionProductCharge) {
        if (productRatePlansByIds.get(subscriptionProductCharge.ProductRatePlan__c) != null) {
            subscriptionProductCharge.RatePlanName__c = subscriptionProductCharge.RatePlanName__c == null ? productRatePlansByIds.get(subscriptionProductCharge.ProductRatePlan__c).Name : subscriptionProductCharge.RatePlanName__c;
            subscriptionProductCharge.Product__c = subscriptionProductCharge.Product__c == null ? productRatePlansByIds.get(subscriptionProductCharge.ProductRatePlan__c).Product__c : subscriptionProductCharge.Product__c;
            subscriptionProductCharge.ListPriceBase__c = subscriptionProductCharge.ListPriceBase__c == null ? productRatePlansByIds.get(subscriptionProductCharge.ProductRatePlan__c).Product__r.Price_List__c : subscriptionProductCharge.ListPriceBase__c;
        }
    }

    private void populateFromProductRatePlanCharge(Map<Id, ProductRatePlanCharge__c> productRatePlanChargesByIds, SubscriptionProductCharge__c subscriptionProductCharge) {
        if (productRatePlanChargesByIds.get(subscriptionProductCharge.ProductRatePlanCharge__c) != null) {
            subscriptionProductCharge.Name = subscriptionProductCharge.Name == null ? productRatePlanChargesByIds.get(subscriptionProductCharge.ProductRatePlanCharge__c).Name : subscriptionProductCharge.Name;
            subscriptionProductCharge.Model__c = subscriptionProductCharge.Model__c == null ? productRatePlanChargesByIds.get(subscriptionProductCharge.ProductRatePlanCharge__c).Model__c : subscriptionProductCharge.Model__c;
        }
    }

    private Map<Id, ProductRatePlanCharge__c> productRatePlanChargesByIds {
        get {
            if (productRatePlanChargesByIds == null) {
                productRatePlanChargesByIds = new Map<Id, ProductRatePlanCharge__c>(
                        DAZNProductRatePlanChargeSelector.newInstance().selectById(productRatePlanChargeIds));
            }
            return productRatePlanChargesByIds;
        }
        set;
    }

    private Map<Id, ProductRatePlan__c> productRatePlansByIds {
        get {
            if (productRatePlansByIds == null) {
                productRatePlansByIds = new Map<Id, ProductRatePlan__c>(
                        DAZNProductRatePlanSelector.newInstance().selectById(productRatePlanIds));
            }
            return productRatePlansByIds;
        }
        set;
    }

    private Set<Id> productRatePlanChargeIds {
        get {
            if (productRatePlanChargeIds == null) {
                productRatePlanChargeIds = new Set<Id>();
                for (SubscriptionProductCharge__c subscriptionProductCharge : (List<SubscriptionProductCharge__c>) getRecordsWithNotBlankFieldValues(Schema.SubscriptionProductCharge__c.ProductRatePlanCharge__c)) {
                    productRatePlanChargeIds.add(subscriptionProductCharge.ProductRatePlanCharge__c);
                }
            }
            return productRatePlanChargeIds;
        }
        set;
    }

    private Set<Id> productRatePlanIds {
        get {
            if (productRatePlanIds == null) {
                productRatePlanIds = new Set<Id>();
                for (SubscriptionProductCharge__c subscriptionProductCharge : (List<SubscriptionProductCharge__c>)getRecordsWithNotBlankFieldValues(Schema.SubscriptionProductCharge__c.ProductRatePlan__c)) {
                    productRatePlanIds.add(subscriptionProductCharge.ProductRatePlan__c);
                }
            }
            return productRatePlanIds;
        }
        set;
    }

    public void populateQuantityField() {
        for (SubscriptionProductCharge__c subscriptionProductCharge : (List<SubscriptionProductCharge__c>) records) {
            subscriptionProductCharge.Quantity__c = subscriptionProductCharge.Quantity__c == 0 || subscriptionProductCharge.Quantity__c == null ? 1 : subscriptionProductCharge.Quantity__c;
        }
    }

    private Map<Id, Subscription__c> subscriptionById {
        get {
            if (subscriptionById == null) {
                subscriptionById = new Map<Id, Subscription__c>(
                    SubscriptionSelector.newInstance().selectById((Set<Id>)JSON.deserialize(JSON.serialize(getFieldValues(SubscriptionProductCharge__c.Subscription__c)), Set<Id>.class)));
            }
            return subscriptionById;
        }
        set;
    }

    public void populateEffectiveEndDate() {
        fflib_ISObjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance(new List<SObjectType>{
                SubscriptionProductCharge__c.SObjectType
        });
        for(SubscriptionProductCharge__c subscriptionProductCharge : (List<SubscriptionProductCharge__c>)getRecordsWithNotBlankFieldValues(new Set<Schema.SObjectField> {Schema.SubscriptionProductCharge__c.Subscription__c})) {
            if(subscriptionProductCharge.EffectiveEndDate__c == null) {
                unitOfWork.registerDirty(new SubscriptionProductCharge__c(
                        Id = subscriptionProductCharge.Id,
                        EffectiveEndDate__c = subscriptionById?.get(subscriptionProductCharge.Subscription__c)?.SubscriptionEndDate__c
                ));
            }
        }
        unitOfWork.commitWork();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> records) {
            return new DAZNSubscriptionProductChargeDomain(records);
        }
    }
}