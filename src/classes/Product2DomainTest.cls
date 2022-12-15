@IsTest
private class Product2DomainTest {
    @IsTest
    static void insertProductTest() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

        Product2 productRecord = TestUtils.createProduct2('Test', 'Device');

        Pricebook2 priceBookRecord = new Pricebook2(Id = fflib_IDGenerator.generate(Pricebook2.SObjectType),  IsActive = true);
        PriceBookSelector priceBookSelectorMock = (PriceBookSelector) mocks.mock(PriceBookSelector.class);

        mocks.startStubbing();
        mocks.when(priceBookSelectorMock.sObjectType()).thenReturn(Pricebook2.SObjectType);
        mocks.when(priceBookSelectorMock.selectStandardPricebook()).thenReturn(new List<Pricebook2> {priceBookRecord});
        mocks.stopStubbing();

        Application.Selector.setMock(priceBookSelectorMock);
        Application.UnitOfWork.setMock(uowMock);

        Test.startTest();
        Insert productRecord;
        Test.stopTest();

        //Then
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock,1)).registerNew(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork)mocks.verify(uowMock,mocks.times(1)
                .description('Price Book entry record created')))
                .registerNew(fflib_Match.sObjectWith(
                new Map<SObjectField,Object> {
                        PricebookEntry.Product2Id => productRecord.Id,
                        PricebookEntry.Pricebook2Id => priceBookRecord.Id
                }
        ));
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 2)).commitWork();
        ((PriceBookSelector) mocks.verify(priceBookSelectorMock, 1)).selectStandardPricebook();
    }
}