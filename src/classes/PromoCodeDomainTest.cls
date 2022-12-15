@IsTest
private class PromoCodeDomainTest {
    @IsTest
    static void insertPromoCodeTest() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

        PromoCode__c promoCode = new PromoCode__c(Name = 'Test');

        Application.UnitOfWork.setMock(uowMock);

        Test.startTest();
        Insert promoCode;
        Test.stopTest();

        //Then
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock,1)).registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork)mocks.verify(uowMock,mocks.times(1)
                .description('Promo Code was updated')))
                .registerDirty(fflib_Match.sObjectWith(
                new Map<SObjectField,Object> {
                        PromoCode__c.External_ID__c => promoCode.Id
                }
        ));
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }
}