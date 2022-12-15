@IsTest(IsParallel=true)
private class CustomerServiceTest {

    @IsTest
    private static void shouldSuccessfullyCreateAccount() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork unitOfWorkMock = (fflib_SObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
        CustomerService.Customer customer = TestUtils.createCustomer();
        Application.UnitOfWork.setMock(unitOfWorkMock);

        // When
        CustomerService.newInstance().createCustomer(customer);

        // Then
        ((fflib_ISObjectUnitOfWork) mocks.verify(unitOfWorkMock, mocks.times(2)
                .description('Account should be created')))
                .registerNew(fflib_Match.anySObject());

        ((fflib_ISObjectUnitOfWork) mocks.verify(unitOfWorkMock,1)).commitWork();

        fflib_ArgumentCaptor capturedWorkerArg =
                fflib_ArgumentCaptor.forClass(CustomerService.Customer.class);

        ((fflib_ISObjectUnitOfWork) mocks.verify(unitOfWorkMock,2))
                .registerNew((Account)capturedWorkerArg.capture());

        Object actualWorkerAsObject = capturedWorkerArg.getValue();
        Contact actualCustomerData =
                (Contact) actualWorkerAsObject;

        System.assertEquals(customer.Account.Id, actualCustomerData.AccountId,'should have same AccountId.');
        System.assertEquals(customer.Contact.LastName, actualCustomerData.LastName,'should be same last name');
    }

    @IsTest
    private static void shouldSuccessfullyUpdateAccount() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork unitOfWorkMock = (fflib_SObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
        CustomerService.Customer customer = TestUtils.createCustomer();
        customer.Account.Id = fflib_IDGenerator.generate(Account.SObjectType);
        Application.UnitOfWork.setMock(unitOfWorkMock);

        // When
        CustomerService.newInstance().updateCustomer(customer);

        // Then
        ((fflib_ISObjectUnitOfWork) mocks.verify(unitOfWorkMock, mocks.times(2)
                .description('Account should be Updated')))
                .registerDirty(fflib_Match.anySObject());

        ((fflib_ISObjectUnitOfWork) mocks.verify(unitOfWorkMock,1)).commitWork();

        fflib_ArgumentCaptor capturedWorkerArg =
                fflib_ArgumentCaptor.forClass(CustomerService.Customer.class);

        ((fflib_ISObjectUnitOfWork) mocks.verify(unitOfWorkMock,2))
                .registerDirty((Account)capturedWorkerArg.capture());

        Object actualWorkerAsObject = capturedWorkerArg.getValue();
        Contact actualCustomerData =
                (Contact) actualWorkerAsObject;

        System.assertEquals(customer.Contact.Id, actualCustomerData.Id,'should have same AccountId.');
    }

    // TODO: Jens - 16-06-2022 - add more unit tests for better coverage
}