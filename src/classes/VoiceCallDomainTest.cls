@IsTest /** DML operations aren't permitted on this type of object: CallCenter, so parallel testing is disabled   */
private class VoiceCallDomainTest {

    @IsTest
	private static void testOnInsertWithoutDML() {	
        // Load the test call center from the static resource, regular DML is not permitted, hence we use Test.loadData method
        List<SObject> callCenters = Test.loadData(CallCenter.sObjectType, 'testCallCenter');
        // Verify that a call center is created
        System.assert(callCenters.size() == 1);

        // Disable trigger events, because we are not interested in testing behaviour.
        fflib_SObjectDomain.getTriggerEvent(VoiceCallDomain.class).disableAll(); 
        insertFutureVoiceCall();
	}

    @future
    private static void insertFutureVoiceCall() {
        Test.loadData(VoiceCall.sObjectType, 'testVoiceCall');
    }

    @IsTest
    private static void itShouldAutoCreateCaseForInboundCall() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ContactSelector contactSelectorMock = (ContactSelector) mocks.mock(ContactSelector.class);
        fflib_ISObjectUnitOfWork unitOfWorkMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

        // Given
        String phoneNumber = '689-843-3107';
        String emailAddress =  'your.email+fakedata63770@gmail.com';
        
        Account accountRecord = TestUtils.createAccount('Daphnee Doyle',emailAddress);
        accountRecord.Id = fflib_IDGenerator.generate(Account.SObjectType);

        Contact contactRecord = TestUtils.createContact(accountRecord.Id, true, emailAddress);
        contactRecord.MobilePhone = phoneNumber;

        List<Account> accountsWithContacts =((List<Account>)fflib_ApexMocksUtils.makeRelationship(
			List<Account>.class,
			new List<Account> { accountRecord },
			Contact.AccountId,
			new List<List<Contact>> { new List<Contact> { contactRecord }}
		));

        // Given
        VoiceCall voiceCallRecord = new VoiceCall();
        voiceCallRecord.FromPhoneNumber = phoneNumber;
        voiceCallRecord.CallType = VoiceCallDomain.CALL_TYPE_INBOUND;
        voiceCallRecord.ToPhoneNumber = VoiceCallDomain.TO_PHONE_NUMBER_AUSTRIA;
        voiceCallRecord.OwnerId = UserInfo.getUserId();

        // Given
        mocks.startStubbing();
        mocks.when(contactSelectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactSelectorMock.selectContactsByMobilePhoneNumbers(new Set<String>{voiceCallRecord.FromPhoneNumber})).thenReturn(accountsWithContacts[0].Contacts);
        mocks.stopStubbing();
        Application.Selector.setMock(contactSelectorMock);
        Application.UnitOfWork.setMock(unitOfWorkMock);

        // When
        VoiceCallDomain.newInstance(new List<VoiceCall> {voiceCallRecord}).autoCreateCaseForInboundCalls();

        // Then
        List<Contact> contacts = accountsWithContacts[0].Contacts;
		System.assertNotEquals(null, contacts);
		System.assertEquals(1, contacts.size());
        ((ContactSelector) mocks.verify(contactSelectorMock, 1)).selectContactsByMobilePhoneNumbers(new Set<String>{voiceCallRecord.FromPhoneNumber});
        ((fflib_ISObjectUnitOfWork)mocks.verify(unitOfWorkMock, 1)).registerNew(
            fflib_Match.sObjectWith(
                new Map<SObjectField, Object>{
                    Case.OwnerId => UserInfo.getUserId(),
                    Case.ContactId => contacts[0].Id,
                    Case.AccountId => accountsWithContacts[0].Id
                }
        ));
    }

}