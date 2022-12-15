@IsTest
public class TestUtils {
    public static final String FAKE_ID = 'qwertyuioplkjhg';

    public static Account createAccount(String name, String notificationEmail) {
        return new Account(
            Name = name,
            Customer_Id__c = 'eb32e69e28984400b31d5a2abd075d74',
            Viewer_Id__c = 'b75d21f0eb91',
            Account_Status__c = 'ActivePaid',
            Business_Type__c = 'Other',
            Notification_Language_Code__c = 'de-DE',
            Notification_Country_Code__c = 'DE',
            Notification_Email__c = notificationEmail,
            Venue_Address_Country__c ='de',
            RecordTypeId = Utils.getRecordTypeId(Account.SObjectType, 'Independent (ecommerce)'),
            Venue_Address_City__c = 'Utrecht',
            Venue_Address_Street__c='Street1',
            Venue_Address_Post_Code__c = '1111AA',
            Content_Digest__c = true
        );
    }

    public static Account createAndInsertAccount(String name, String notificationEmail) {
        Account a = TestUtils.createAccount(name, notificationEmail);
        insert a;
        return a;
    }

    public static List<Account> createAccountWithContactsAndOpportunities(String name, String notificationEmail) {
        Account a = TestUtils.createAccount(name, notificationEmail);
        a.Id = fflib_IDGenerator.generate(Account.SObjectType);
        Contact c = TestUtils.createContact(a.Id, true, notificationEmail);
        c.Id = fflib_IDGenerator.generate(Contact.SObjectType);
        Opportunity o = TestUtils.createOpportunity(a.Id, name);

        List<Account> accountsWithContacts = (List<Account>)fflib_ApexMocksUtils.makeRelationship(
            List<Account>.class,
            new List<Account> { a },
            Contact.AccountId,
            new List<List<Contact>> {  new List<Contact>{ c } }
        ); 

        List<Account> accountsWithContactsAndOpportunities = (List<Account>)fflib_ApexMocksUtils.makeRelationship(
            List<Account>.class,
            accountsWithContacts,
            Opportunity.AccountId,
            new List<List<Opportunity>> { new List<Opportunity>{o} }
        ); 
        return accountsWithContactsAndOpportunities;
    }

    public static Contact createContact(Id accId, Boolean isPrimary, String email) {
        return new Contact(
                LastName = 'lastName',
                AccountId = accId,
                Email = email,
                Primary_Contact__c = isPrimary
        );

    }

    public static Contact createAndInsertContact(String accId, Boolean isPrimary, String email) {
        Contact c = TestUtils.createContact(accId, isPrimary, email);
        insert c;
        return c;
    }

    public static Case createCase(Id accId, Id contactId, String status) {
        return new Case(
                Notification_Language_Code__c = 'en-GB',
                Notification_Country_Code__c = 'de',
                AccountId = accId,
                ContactId = contactId,
                Status = status
        );

    }

    public static Case createAndInsertCase(Id accId, Id contactId, String status) {
        Case c = TestUtils.createCase(accId, contactId, status);
        insert c;
        return c;
    }

    public static PendingServiceRouting createPendingServiceRouting(Id caseId, Id serviceChannelIdForCases) {
        return new PendingServiceRouting(
                CustomRequestedDateTime = System.now(),
                CapacityWeight = 1,
                IsReadyForRouting = false,
                RoutingModel = 'MostAvailable',
                RoutingPriority = 1,
                RoutingType = 'SkillsBased',
                ServiceChannelId = serviceChannelIdForCases,
                WorkItemId = caseId,
                PushTimeout = 0
        );
    }

    public static PendingServiceRouting createAndInsertPendingServiceRouting(Id caseId, Id serviceChannelIdForCases) {
        PendingServiceRouting pendingServiceRouting = TestUtils.createPendingServiceRouting(caseId, serviceChannelIdForCases);
        insert pendingServiceRouting;
        return pendingServiceRouting;
    }

    public static void createAndInsertNewGroup(String name, String type) {
        insert new Group(
                Name = name,
                Type = type
        );
    }

    public static Knowledge__kav createKnowledgeArticle(String title, String url) {
        return new Knowledge__kav(
            IsVisibleInCsp = false,
            IsVisibleInPkb = false,
            IsVisibleInPrm = false,
            Title = title,
            UrlName = url,
            Content__c = 'Some content',
            Language = 'de'
        );
    }

    public static Knowledge__kav createAndInsertKnowledgeArticle(String title, String url) {
        Knowledge__kav knowledgeArticle = createKnowledgeArticle(title, url);
        insert knowledgeArticle;
        return knowledgeArticle;
    }

    public static Event__c createEvent(String status, String customerType, String type) {
        return new Event__c(Status__c = status, Name = 'EventName', Record_Type__c = customerType, Type__c = type);
    }

    public static Event__c createAndInsertEvent(String status, String customerType, String type) {
        Event__c customEvent = createEvent(status, customerType, type);
        insert customEvent;
        return customEvent;
    }

    public static EmailMessage createEmail(String fromAddress, String fromName, String subject) {
        return new EmailMessage(FromAddress = fromAddress, FromName = fromName, Subject = subject);
    }

    public static EmailMessage createAndInsertEmail(String fromAddress, String fromName, String subject) {
        EmailMessage emailMessage = createEmail(fromAddress, fromName, subject);
        insert emailMessage;
        return emailMessage;
    }

    public static Zuora__CustomerAccount__c createZuoraBillingAccount(Id accountId) {
        return new Zuora__CustomerAccount__c(Zuora__Account__c = accountId);
    }

    public static Zuora__CustomerAccount__c createAndInsertZuoraBillingAccount(Id accountId) {
        Zuora__CustomerAccount__c zuoraCustomerAccount = createZuoraBillingAccount(accountId);
        insert zuoraCustomerAccount;
        return zuoraCustomerAccount;
    }

    public static Zuora__ZInvoice__c createZuoraInvoice(Id accountId) {
        return new Zuora__ZInvoice__c(Zuora__Account__c = accountId);
    }

    public static Zuora__ZInvoice__c createAndInsertZuoraInvoice(Id accountId) {
        Zuora__ZInvoice__c zuoraZInvoice = createZuoraInvoice(accountId);
        insert zuoraZInvoice;
        return zuoraZInvoice;
    }

    public static Zuora__DebitMemo__c createZuoraDebitMemo(Id zuoraBillingAccId) {
        return new Zuora__DebitMemo__c(
            Zuora__BillingAccount__c = zuoraBillingAccId,
            Zuora__Balance__c = 100.0,
            Zuora__DiscountAmount__c = 1.00,
            Zuora__External_Id__c = 'asd',
            Zuora__TaxAmount__c = 1.00,
            Zuora__TotalAmount__c = 1.00,
            Zuora__TotalTaxExemptAmount__c = 1.00,
            Zuora__TotalAmountWithoutTax__c = 11.00);
    }

    public static Zuora__Subscription__c createAndInsertZuoraSubscription(String zuoraAccountId, String zuoraBillingAccountId) {
        Zuora__Subscription__c zuoraSubscription = createZuoraSubscription(zuoraAccountId,zuoraBillingAccountId);
        insert zuoraSubscription;
        return zuoraSubscription;
    }

    public static Zuora__Subscription__c createZuoraSubscription(String zuoraAccountId, String zuoraBillingAccountId) {
        Date todaysDate = System.today();
        Zuora__Subscription__c zuoraSubscription = new Zuora__Subscription__c(
            Name = 'TestSubscription',
            Zuora__Status__c = 'Active',
            Zuora__NextRenewalDate__c =  todaysDate.addDays(2),
            Zuora__SubscriptionNumber__c = 'A-S00000000',
            Zuora__SubscriptionEndDate__c = todaysDate.addDays(14),
            Zuora__CustomerAccount__c = zuoraBillingAccountId,
            Zuora__Account__c = zuoraAccountId
        );
        return zuoraSubscription;
    }

    public static Zuora__DebitMemo__c createAndInsertZuoraDebitMemo(Id zuoraBillingAccId) {
        Zuora__DebitMemo__c zuoraDebitMemo = createZuoraDebitMemo(zuoraBillingAccId);
        insert zuoraDebitMemo;
        return zuoraDebitMemo;
    }

    public static Order__c createOrder(Id accId, String status) {
        return new Order__c(
                Invoice_Sent__c = false,
                RecordTypeId = Utils.getRecordTypeId(Order__c.SObjectType, 'Standard'),
                Status__c = status,
                Account__c = accId
        );
    }

    public static Order__c createAndInsertOrder(Id accId, String status) {
        Order__c order = TestUtils.createOrder(accId, status);
        insert order;
        return order;
    }

    public static String getDefaultRecordType(SObjectType sObjType) {
        Schema.DescribeSObjectResult dsr = sObjType.getDescribe();
        for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
            if(rti.isDefaultRecordTypeMapping()) {
                return rti.recordTypeId;
            }
        }

        return null;
    }

    public static History_Tracking__c createHistoryTrackingRecord(Id recordId) {
        return new History_Tracking__c(
            Field_API_Name__c = 'Vat_Id__c', 
            Record_Id__c = recordId
        );
    }

    public static Subscription__c createSubscriptionRecord(Id recordId) {
        return new Subscription__c(
            Id = recordId,
            AutoRenew__c = true,
            CancelledDate__c = System.today(),
            ContractAcceptanceDate__c = System.today(),
            ContractEffectiveDate__c = System.today(),
            CurrentTermPeriodType__c = 'Month',
            CurrentTerm__c = '12',
            InitialTermPeriodType__c = 'Month',
            InitialTerm__c = '12',
            MRR__c = 250,
            NextChargeDate__c = System.today(),
            RenewalTermPeriodType__c = 'Month',
            RenewalTerm__c = '12',
            ServiceActivationDate__c = System.today(),
            Status__c = 'Active',
            SubscriptionEndDate__c = System.today(),
            SubscriptionStartDate__c = System.today(),
            TCV__c = 3000,
            TermEndDate__c = System.today(),
            TermSettingType__c = 'TERMED',
            TermStartDate__c = System.today(),
            SubPromoCode__c = '199OKTSPEZIAL'
        );
    }
    public static Subscription__c createSubscriptionRecord() {
        return createSubscriptionRecord(null);
    }

    public static SubscriptionProductCharge__c createSubscriptionProductChargeRecord(Id recordId) {
        return new SubscriptionProductCharge__c(
            Id = recordId,
            DiscountAmount__c = 74.95,
            DiscountPercentage__c = 24.95,
            ProductRatePlanChargeId__c = '8a28f1aa7a8a57da017a8a66edaf2316',
            RatePlanId__c = '8a288b297a8a448a017a8a66e798503f',
            BillCycleType__c = 'SubscriptionStartDay',
            BillingPeriod__c = 'Month',
            BillingTiming__c = 'In Advance',
            DMRC__c = 250,
            DTCV__c = 3000,
            EffectiveEndDate__c = System.today(),
            EffectiveStartDate__c = System.today(),
            EndDateCondition__c = 'Subscription End Date',
            ExtendedAmount__c = 250,
            IncludedUnits__c = 1,
            ListPriceBase__c = 'Per Billing Period',
            Model__c = 'Per Unit Pricing',
            MonthlyRecurringRevenue__c = 250,
            NumberOfPeriods__c = 1,
            OverageCalculationOption__c = 'EndOfSmoothingPeriod',
            OverageUnusedUnitsCreditOption__c = 'NoCredit',
            PriceChangeOption__c = 'NoChange',
            PriceIncreasePercentage__c = 5,
            Price__c = 250,
            ProcessedThroughDate__c = System.today(),
            ProductEffectiveEndDate__c = System.today(),
            Quantity__c = 1,
            RatePlanEffectiveEndDate__c = System.today(),
            Segment__c = 1,
            SpecificEndDate__c = System.today(),
            TotalContractValue__c = 3000,
            TriggerDate__c = System.today(),
            TriggerEvent__c = 'Upon Service Activation',
            Type__c = 'Recurring',
            UOM__c = 'Subscription',
            UpToPeriodsType__c = 'Billing Periods',
            UsageRecordRatingOption__c = 'EndOfBillingPeriod'
        );
    }
    public static SubscriptionProductCharge__c createSubscriptionProductChargeRecord() {
        return createSubscriptionProductChargeRecord(null);
    }

    public static priceBookEntry createPriceBookEntryRecord(){
        return new priceBookEntry( 
            IsActive = true,
            CurrencyIsoCode = 'EUR',
            UnitPrice = 200,
            UseStandardPrice = false
        );
    }

    public static Opportunity createOpportunity(Id accountRecordId, String fullName) {
        return new Opportunity(
            AccountId = accountRecordId,
            Name = fullName,
            StageName = 'Qualification',
            CloseDate = System.today().addDays(14)
        );
    }

    public static SubscriptionService.CancellationData createCancellationData(SubscriptionService.CancellationType type) {
        SubscriptionService.CancellationData data = new SubscriptionService.CancellationData();
        data.Type = type;
        data.Reasons = new List<String>{
            'TooExpensive', 
            'NoSportsAnymore'};
        data.Comment = 'The cost of my contract has gone up and now it is too expensive for me.';

        return data;
    }
  
    public static Lead createStandardLead() {
        return new Lead(
            Country__c = 'de',
            Business_type__c = 'Gastronomy',
            FirstName = 'Roman',
            LastName = 'Ledner',
            Phone = '213-986-2254',
            Email = 'your.email+fakedata77415@gmail.de',
            Company = 'Kemmer - Runolfsson',
            Brand_name__c = 'Kemmer - Runolfsson',
            Number_of_screens__c = 2,
            Number_of_venues__c = 1,
            Description = 'Ipsum sequi labore odio praesentium nostrum suscipit. Consequuntur illum doloremque laborum alias. Sit et blanditiis ratione rerum dicta. Laudantium est deleniti quis adipisci atque odit aut maiores aliquam. Cupiditate repellat praesentium in exercitationem dignissimos.',
            Lead_Id__c = 'a9a734647b764a9786b9cdd42f5654c4',
            Internet_speed__c = '70 Mbps'
        );
    }

    public static Lead createJapanLead() {
        return new Lead( 
            Country__c = 'jp',
            Business_Type__c = 'SPA/Nursing house/Hospital (each bed)',
            FirstName = '小説',
            LastName = 'レドナー',
            Phone = '213-986-2254',
            Email = 'your.email+fakedata77415@gmail.jp',
            Company = 'ケメル・ルノルフソン',
            Brand_name__c = 'ケメル・ルノルフソン',
            Number_of_screens__c = 2,
            Number_of_venues__c = 1,
            Description = '現在の憎しみを追いかけるのは大変な努力です。その後、他の困難と苦痛が続きました。物事を言わせて、理由でお世辞を言いましょう。彼は応援を嫌い、彼や彼の先祖をなだめる人を憎みます。現在の最も価値のあるものを運動に戻したいという願望。',
            Lead_Id__c = 'a9a734647b764a9786b9cdd42f5654c4',
            Internet_speed__c = '70 Mbps',
            Total_number_of_rooms__c = 1,
            Total_number_of_devices__c = 1
        );
    }
  
    public static ProductRatePlan__c createProductRatePlan(Id productId) {
        return new ProductRatePlan__c(Name = 'TestProductRatePlan',
            Product__c = productId,
            ExternalId__c = 'TestRatePlanExternalId');
    }

    public static ProductRatePlanCharge__c createProductRatePlanCharge() {
        return new ProductRatePlanCharge__c(Name = 'TestProductRatePlanCharge',
            ExternalId__c = 'TestRatePlanChargeExternalId');
    }

    public static CustomerService.Customer createCustomer(Id accountId) {
        CustomerService.Customer customer = createCustomer();
        customer.Account.Id = accountId;

        return customer;
    }

    public static CustomerService.Customer createCustomer() {
        Account accountRecord = TestUtils.createAccount('test','test@mail.com');
        Contact contactRecord = TestUtils.createContact(accountRecord.Id, true,'test@mail.com');
        
        CustomerService.Customer customer = new CustomerService.Customer();
        customer.Account = accountRecord;
        customer.Contact = contactRecord;
        customer.Type = CustomerService.CustomerType.Independent_Ecommerce;

        return customer;
    }

    public static SubscriptionService.SubscriptionCreateRequest createSubscriptionCreateRequestData() {
        SubscriptionService.SubscriptionCreateRequest data = new SubscriptionService.SubscriptionCreateRequest();
        data.AccountId = fflib_IDGenerator.generate(Schema.Account.SObjectType);
        data.SubscriptionProductCharges = new List<SubscriptionProductCharge__c> {createSubscriptionProductChargeRecord()};
        data.Subscription = createSubscriptionRecord();
        data.BillingAccount = createCustomerBillingAccount();
        data.PaymentMethods = new List<PaymentMethod__c> {createPaymentMethod(true)};

        return data;
    }

    public static SubscriptionService.RejoinData createRejoinData() {
        Account accountRecord = TestUtils.createAndInsertAccount('test','test@mail.com');

        SubscriptionService.RejoinData data = new SubscriptionService.RejoinData();
        data.startDate = System.today();
        data.endDate = System.today().addDays(365);
        data.subscriptionRenewalTerm = '12';
        data.subscriptionRenewalTermPeriod = 'Month';
        data.accountId = accountRecord.Id;
        data.accountType = 'Gastronomy';
        data.device = '2';
        data.price = '250';
        data.priceBookEntryDevice = JSON.serialize( createPriceBookEntryRecord() );

        return data;
    }

    public static CustomerAccount__c createCustomerBillingAccount() {
        CustomerAccount__c customerAccount = new CustomerAccount__c();
        customerAccount.Batch__c = 'TestBatch';
        customerAccount.BillCycleDay__c = '1st of the month';

        return customerAccount;
    }

    public static CustomerAccount__c createBillingRecordWithAccount() {
        Account acc =createAndInsertAccount('test','test@gmail.com');
        CustomerAccount__c customerAccount = new CustomerAccount__c();
        customerAccount.Account__c = acc.Id;
        customerAccount.BillCycleDay__c = '1st of the month';
        insert customerAccount;

        return customerAccount;
    }

    public static PaymentMethod__c createPaymentMethod(Boolean defaultPaymentMethod) {
        PaymentMethod__c paymentMethod = new PaymentMethod__c();
        paymentMethod.DefaultPaymentMethod__c = defaultPaymentMethod;
        paymentMethod.Type__c = 'CreditCardReferenceTransaction';

        return paymentMethod;
    }

    public static Product2 createProduct2(String name, String family) {
        Product2 productRecord = new Product2();
        productRecord.Name = name;
        productRecord.Family = family;

        return productRecord;
    }

    public Static Pricebook2 createPriceBook(String name) {
        Pricebook2 pricebook2Record = new Pricebook2();
        pricebook2Record.Name = name;
        pricebook2Record.Business_Type__c = 'Gastronomy';
        pricebook2Record.Account_Type__c = 'Independent_Bank_Transfer';
        pricebook2Record.Country__c = 'de';

        return pricebook2Record;
    }

    public Static List<Pricebook2> createPriceBookWithPriceBookEntries(String name) {
        Pricebook2 pricebook2Record = createPriceBook(name);
        PricebookEntry priceBookEntryRecord = createPriceBookEntryRecord();
        priceBookEntryRecord.Id =  fflib_IDGenerator.generate(PricebookEntry.SObjectType);

        List<Pricebook2> pricebook2WithPriceBookEntry = (List<Pricebook2>) fflib_ApexMocksUtils.makeRelationship(
                List<Pricebook2>.class,
                new List<Pricebook2>{pricebook2Record},
                PricebookEntry.Pricebook2Id,
                new List<List<PricebookEntry>>{new List<PricebookEntry>{priceBookEntryRecord}}
        );

        return pricebook2WithPriceBookEntry;
    }
}