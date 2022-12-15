public with sharing class Product2Domain extends ApplicationDomain {

    private Map<String, Product_Family_SKU_Mapping__mdt> productFamilySKUMappingsByName {
        get {
            if(productFamilySKUMappingsByName == null) {
                productFamilySKUMappingsByName = Product_Family_SKU_Mapping__mdt.getAll();
            }
            return productFamilySKUMappingsByName;
        }
        private set;
    }

    public static Product2Domain newInstance(List<Subscription__c> recordList) {
        return (Product2Domain) Application.Domain.newInstance(recordList);
    }

    public Product2Domain(List<Product2> products) {
        super(products);
    }

    public override void onAfterInsert() {
        populateSKUAndExternalId();
        createStandardPriceBook();
    }

    public void populateSKUAndExternalId() {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Product2 productRecord : (List<Product2>) Records) {
            String skuPrefix =  productFamilySKUMappingsByName?.get(productRecord.Family)?.SKU_Prefix__c != null ? productFamilySKUMappingsByName?.get(productRecord.Family)?.SKU_Prefix__c : 'SKU';
            Product2 productRecord2 = new Product2(Id = productRecord.Id);
            productRecord2.StockKeepingUnit = skuPrefix +'-' +productRecord.AutoNumber__c;
            productRecord2.ExternalId = productFamilySKUMappingsByName?.get(productRecord.Family)?.Populate_External_Id_By_Record_Id__c != false ? String.valueOf(productRecord.Id) : productRecord2.ExternalId;
            uow.registerDirty(productRecord2);
        }
        fflib_SObjectDomain.getTriggerEvent(Product2Domain.class).disableAll();
        uow.commitWork();
    }

    public void createStandardPriceBook() {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Pricebook2> priceBookList = PriceBookSelector.newInstance().selectStandardPricebook();
        for (Product2 productRecord : (List<Product2>) Records) {
            PricebookEntry pricebookEntryRecord = new PricebookEntry();
            pricebookEntryRecord.Pricebook2Id = priceBookList[0].Id;
            pricebookEntryRecord.Product2Id = productRecord.Id;
            pricebookEntryRecord.CurrencyIsoCode = 'EUR';
            pricebookEntryRecord.UnitPrice = 0.0;
            pricebookEntryRecord.IsActive = true;

            uow.registerNew(pricebookEntryRecord);
        }
        uow.commitWork();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Product2Domain(sObjectList);
        }
    }

}