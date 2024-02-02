@IsTest
public with sharing class DTN_CreateRenewalQuotesForRCTest {
    @TestSetup
    static void createData() {
        Test.startTest();
        Account acc = new Account(
            Name = 'Test Account',
            BillingType__c = 'Advance',
            BillingCity = 'Demo1',
            BillingCountry = 'United States',
            BillingCountryCode = 'US',
            BillingPostalCode = '11111',
            BillingState = 'Alabama',
            BillingStateCode = 'AL',
            BillingStreet = 'Demo1',
            SBQQ__RenewalModel__c = 'Contract Based',
            SBQQ__RenewalPricingMethod__c = 'List'
        );
        insert acc;
        
        Contact contact = new Contact(
            AccountId = acc.Id,
            LastName = 'Smith Doe',
            Primary_Bill_To_Contact__c = true,
            Primary_Ship_To_Contact__c = true,
            Primary_Contact__c = true,
            Email = 'smtih.doe'+Integer.valueOf((Math.random() * 10))+'@testdtn.com'
        );
        insert contact;
        
        LegalEntity entity = new LegalEntity(
            Name = 'DTN, LLC',
            CompanyName = 'DTN, LLC',
            Status = 'Active',
            //Applicable_Law__c = 'United States',
            Registration_Country__c = 'United States',
            LegalEntityStreet = '11400 Rupp Drive',
            LegalEntityCity = 'Burnsville',
            LegalEntityState = 'Minnesota',
            LegalEntityPostalCode = '55337',
            LegalEntityCountry = 'United States'
        );
        insert entity;
        blng__BillingRule__c billingRule = new blng__BillingRule__c(
            Name = 'Test Billing Rule',
            blng__Active__c = true,
            blng__GenerateInvoices__c = 'Yes',
            blng__InitialBillingTrigger__c = 'Order Product Activation Date',
            blng__PartialPeriodTreatment__c = 'Separate',
            blng__PeriodTreatmentForBTDO__c = 'Separate'
        );
        insert billingRule;
        
        blng__RevenueRecognitionRule__c revenueRule = new blng__RevenueRecognitionRule__c(
            blng__Active__c = true,
            Name = 'Test Revenue Rule',
            blng__CreateRevenueSchedule__c = 'Yes'
        );
        insert revenueRule;
        
        blng__TaxRule__c taxRule = new blng__TaxRule__c(
            Name = 'Test Tax Rule',
            blng__Active__c = true,
            blng__TaxableYesNo__c = 'Yes'
        );
        insert taxRule;
        
        Product2 prod = new Product2(
            Name = 'Test Product',
            Business_Unit__c = 'Agriculture',
            CPQ_Product_Family__c = 'Agriculture',
            CPQ_Product_Sub_Family__c = 'Ag Biz',
            Product_Line__c = 'AGHost/Web Hosting Tools',
            Product_Lifecycle__c = 'Active',
            Description = 'Test Product 1',
            productCode = '1ABCD',
            isActive = true,
            Hide_from_Catalog__c = true,
            SBQQ__ChargeType__c = 'Recurring',
            SBQQ__BillingType__c = 'Advance',
            CurrencyIsoCode = 'USD',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__BlockPricingField__c = 'Quantity',
            SBQQ__DefaultQuantity__c = 1,
            SBQQ__PricingMethod__c = 'List',
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__AssetAmendmentBehavior__c = 'Default',
            SBQQ__AssetConversion__c = 'One per quote line',
            blng__BillingRule__c = billingRule.Id,
            blng__RevenueRecognitionRule__c = revenueRule.Id,
            blng__TaxRule__c = taxRule.Id
        );
        insert prod;

        Product2 prod2 = new Product2(
            Name = 'Test Product 2',
            Business_Unit__c = 'Agriculture',
            CPQ_Product_Family__c = 'Agriculture',
            CPQ_Product_Sub_Family__c = 'Ag Biz',
            Product_Line__c = 'AGHost/Web Hosting Tools',
            Product_Lifecycle__c = 'Active',
            Description = 'Test Product 2',
            productCode = '1ABCD',
            isActive = true,
            Hide_from_Catalog__c = true,
            SBQQ__ChargeType__c = 'Recurring',
            SBQQ__BillingType__c = 'Advance',
            CurrencyIsoCode = 'USD',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__BlockPricingField__c = 'Quantity',
            SBQQ__DefaultQuantity__c = 1,
            SBQQ__PricingMethod__c = 'List',
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__AssetAmendmentBehavior__c = 'Default',
            SBQQ__AssetConversion__c = 'One per quote line',
            blng__BillingRule__c = billingRule.Id,
            blng__RevenueRecognitionRule__c = revenueRule.Id,
            blng__TaxRule__c = taxRule.Id
        );
        insert prod2;
        
        Id standardPBId = Test.getStandardPricebookId();
        
        PriceBook2 pb = new PriceBook2(
            Name = 'USD CPQ Price Book',
            IsActive = true,
            CurrencyIsoCode = 'USD'
        );
        insert pb;
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        PricebookEntry standardPBE = new PricebookEntry(
            Pricebook2Id = standardPBId,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert standardPBE;
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;
        
        Date startDate = Date.today().addYears(-2).addDays(61);
        Opportunity opp = new Opportunity(
            Name = 'Rolling Contract Test Opp',
            StageName = 'Diagnose',
            CloseDate = System.Today(),
            AccountId = acc.Id,
            Legal_Entity__c = entity.Id,
            Contract_Type__c = 'Rolling',
            Auto_Renewal_Days__c = '30 Days',
            Notice_Period_months__c = 1,
            Initial_Term_months__c = 1,
            Rolling_Term_months__c = 12,
            Pricebook2Id = pb.Id,
            Notice_Period_Months_pick__c = '1 Month'
        );
        insert opp;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__SalesRep__c = UserInfo.getUserId(),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Primary__c = true,
            CurrencyIsoCode = 'USD',
            Billing_Type_Pick__c = 'Advance',
            SBQQ__Opportunity2__c = opp.Id,
            SBQQ__PrimaryContact__c = contact.Id,
            SBQQ__BillingFrequency__c = 'Monthly',
            Billing_Frequency_pick__c = 'Monthly',
            SBQQ__PriceBook__c = pb.Id,
            SBQQ__PricebookId__c = pb.Id,
            SBQQ__StartDate__c = startDate,
            //SBQQ__EndDate__c = startDate.addMonths(1),
            SBQQ__Type__c = 'Quote',
            Ready_for_Execution__c = true,
            Needs_Finance_Approval__c = FALSE,
        	Needs_Approval__c = FALSE,
            Needs_Product_Manager_Approval__c = FALSE,
            SBQQ__ContractingMethod__c = 'By Subscription End Date'
        );
        insert quote;
        
        SBQQ__QuoteLineGroup__c quoteGroup = new SBQQ__QuoteLineGroup__c(
            CurrencyIsoCode = 'USD',
            Name = 'Group1',
            SBQQ__Account__c = acc.Id,
            SBQQ__Number__c = 1,
            SBQQ__Quote__c = quote.Id,
            SBQQ__StartDate__c = startDate,
            //SBQQ__EndDate__c = startDate.addMonths(1),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__BillingFrequency__c = 'Monthly'
        );
        insert quoteGroup;
        
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = quote.Id,
            CurrencyIsoCode  = 'USD',
            SBQQ__Product__c = prod.Id,
            SBQQ__PricebookEntryId__c = pbe.Id,
            SBQQ__ListPrice__c = 100,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__DefaultSubscriptionTerm__c = 12,
            SBQQ__ProductSubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__ChargeType__c = 'Recurring',
            SBQQ__StartDate__c = startDate,
            //SBQQ__EndDate__c = startDate.addMonths(1),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Group__c = quoteGroup.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ProrateMultiplier__c = 1,
            SBQQ__OriginalPrice__c = 100,
            Unit_Type__c = 'New / Additional Unit',
            Weeks_Notice__c = '1-4 Weeks',
            SBQQ__SubscriptionBase__c = 'List'
        );
        insert quoteLine;
        
        
        quote.SBQQ__Status__c = 'Approved';
        quote.ApprovalStatus__c = 'Approved';
        quote.SBQQ__Ordered__c = TRUE;
        quote.SBQQ__LineItemsGrouped__c = TRUE;
        quote.SBQQ__PriceBook__c = pb.Id;
        quote.SBQQ__PricebookId__c = pb.Id;
        SBQQ.TriggerControl.disable();
        update quote;
        
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c(
            SBQQ__Account__c = acc.Id,
            Apply_Uplift__c = true,
            CurrencyIsoCode = 'USD',
            SBQQ__OriginalQuoteLine__c = quoteline.Id,
            SBQQ__Product__c = prod.Id,
            SBQQ__ProductSubscriptionType__c = 'Renewable',
            SBQQ__QuoteLine__c = quoteline.Id,
            SBQQ__SubscriptionStartDate__c = startDate,
            //SBQQ__SubscriptionEndDate__c = startDate.addMonths(1),
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__Number__c = 1,
            SBQQ__Quantity__c = 1
        );
        insert sub;
        
        Integer dayOfMonth = startDate.Day();
        Order o = new Order(
            AccountId = acc.Id,
            OpportunityId = opp.Id,
            Type = 'New',
            SBQQ__Quote__c = quote.Id,
            SBQQ__RenewalTerm__c = 12,
            EffectiveDate = startDate,
            //EndDate = startDate.addMonths(1),
            blng__BillingDayOfMonth__c = String.valueOf(dayOfMonth),
            Status = 'Draft',
            Pricebook2Id = standardPBId,
            blng__InvoiceBatch__c = 'DTN, LLC', //'DTN, LLC',
            SBQQ__ContractingMethod__c = 'By Subscription End Date'
        );
        insert o;
                
        OrderItem oi = new OrderItem(
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__ChargeType__c = 'Recurring',
            OrderId = o.Id,
            SBQQ__OrderedQuantity__c = 1,
            Product2Id = prod.Id,
            SBQQ__QuoteLine__c = quoteLine.Id,
            SBQQ__Status__c = 'Draft',
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__DefaultSubscriptionTerm__c = 12,
            ServiceDate = startDate,
            //EndDate = startDate.addMonths(1),
            PricebookEntryId = standardPBE.Id,
            SBQQ__Subscription__c = sub.Id,
            UnitPrice = 100,
            Quantity = 1,
            blng__BillingRule__c = billingRule.Id,
            blng__RevenueRecognitionRule__c = revenueRule.Id,
            blng__TaxRule__c = taxRule.Id
        );
        insert oi;
        
        SBQQ.TriggerControl.enable();
        o.Status = 'Activated';
        update o;
        Test.stopTest();
    }
    
    @IsTest
    static void processRollingContractsTest() {
        Test.startTest();
        
        Contract originalContract = [SELECT Id, Trigger_Rolling__c, StartDate, EndDate, Do_Not_Renew__c, Contract_Type__c, SBQQ__RenewalTerm__c, ContractTerm, Rolling_Term_months__c FROM Contract LIMIT 1];
        originalContract.Contract_Type__c = 'Rolling';
        originalContract.Notice_Period_Months_pick__c = '1 Month';
        originalContract.Rolling_Term_months__c = 12;
        originalContract.Run_Rolling_Process__c = TRUE;
        update originalContract;
        system.debug('---'+originalContract);

        //SIBA-603 -- change trigger rolling to the new calculated end date of 60 days -- joshua.torregoza@dtn.com
        Boolean triggerRollingFlag = (originalContract.Do_Not_Renew__c == false && originalContract.EndDate == Date.today().addYears(-1).addDays(60));

        System.debug('triggerRollingFlag ---' +triggerRollingFlag);
        
        System.assertNotEquals(null, originalContract.Id);
        System.assertEquals(TRUE, triggerRollingFlag);
        DTN_CreateRenewalQuotesForRC batchObject = new DTN_CreateRenewalQuotesForRC();
        Id batchId = Database.executeBatch(batchObject, 1);
        
        Test.stopTest();
        system.debug('--here--');
        DTN_ManageQuotePricingForRC manageQuotePricingBatchObject = new DTN_ManageQuotePricingForRC();
        Id manageQuotePricingBatchId = Database.executeBatch(manageQuotePricingBatchObject, 1);
    }
    
    @IsTest
    static void processRollingContractsTest2() {
        Test.startTest();
        Contract originalContract = [SELECT Id, Trigger_Rolling__c, StartDate, EndDate, Do_Not_Renew__c, Contract_Type__c, AccountId, SBQQ__RenewalTerm__c, ContractTerm, Rolling_Term_months__c, Legal_Entity__c, Pricebook2Id FROM Contract LIMIT 1];
        originalContract.Contract_Type__c = 'Rolling';
        originalContract.Notice_Period_Months_pick__c = '1 Month';
        originalContract.Rolling_Term_months__c = 12;
        originalContract.ProcessAutoRolling__c = TRUE;
        originalContract.Run_Rolling_Process__c = TRUE;
        //update originalContract;
        
        //originalContract.SBQQ__RenewalQuoted__c = true;
        
        //added for testing -- joshua.torregoza
        //SBQQ.TriggerControl.disable();
        //Test.startTest();
        DTN_Utilities.setDoNotRunTrigger();
        update originalContract;
        system.debug('---'+originalContract);

        //SIBA-603 -- change trigger rolling to the new calculated end date of 60 days -- joshua.torregoza@dtn.com
        Date calculatedEndDate = Date.today().addYears(-1).addDays(60);

        Boolean triggerRollingFlag = (originalContract.Do_Not_Renew__c == false && originalContract.EndDate == calculatedEndDate);
        
        System.assertNotEquals(null, originalContract.Id);
        System.assertEquals(TRUE, triggerRollingFlag);
        
        /*Opportunity Opp = [SELECT Id, AccountId, Account.OwnerId, Legal_Entity__c, Pricebook2Id, SBQQ__RenewedContract__c FROM Opportunity LIMIT 1];
        Opp.SBQQ__RenewedContract__c = originalContract.Id;
        update Opp;*/
        Contact primaryContact = [SELECT Id FROM Contact LIMIT 1];
        Product2 prod = [SELECT Id, blng__BillingRule__c, blng__RevenueRecognitionRule__c, blng__TaxRule__c FROM Product2 WHERE Name = 'Test Product'];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE product2Id =: prod.Id and Pricebook2.Name = 'USD CPQ Price Book'];
        //Opportunity Opp = [SELECT Id, AccountId, Legal_Entity__c, Pricebook2Id FROM Opportunity WHERE Name = 'Rolling Contract Test Opp'];
        Opportunity renewalOpp = new Opportunity(
            Name = 'Renewal Opp',
            StageName = 'Diagnose',
            CloseDate = System.Today(),
            AccountId = originalContract.AccountId,
            Legal_Entity__c = originalContract.Legal_Entity__c,
            Contract_Type__c = 'Rolling',
            Auto_Renewal_Days__c = '30 Days',
            Notice_Period_months__c = 1,
            Initial_Term_months__c = 12,
            Rolling_Term_months__c = 12,
            Pricebook2Id = originalContract.Pricebook2Id,
            Notice_Period_Months_pick__c = '1 Month',
            SBQQ__RenewedContract__c = originalContract.Id
        );
        insert renewalOpp;
        
        SBQQ__Quote__c renewalQuote = new SBQQ__Quote__c(
            SBQQ__SalesRep__c = UserInfo.getUserId(),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Primary__c = true,
            CurrencyIsoCode = 'USD',
            Billing_Type_Pick__c = 'Advance',
            SBQQ__Opportunity2__c = renewalOpp.Id,
            SBQQ__PrimaryContact__c = primaryContact.Id,
            SBQQ__BillingFrequency__c = 'Monthly',
            Billing_Frequency_pick__c = 'Monthly',
            SBQQ__PriceBook__c = originalContract.Pricebook2Id,
            SBQQ__PricebookId__c = originalContract.Pricebook2Id,
            SBQQ__StartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__Type__c = 'Quote',
            Needs_Approval__c = false,
            Ready_for_Execution__c = true,
            SBQQ__ContractingMethod__c = 'Single Contract'
        );
        insert renewalQuote;
        
        SBQQ__QuoteLineGroup__c renewalQuoteGroup = new SBQQ__QuoteLineGroup__c(
            CurrencyIsoCode = 'USD',
            Name = 'Group1',
            SBQQ__Account__c = originalContract.AccountId,
            SBQQ__Number__c = 1,
            SBQQ__Quote__c = renewalQuote.Id
        );
        insert renewalQuoteGroup;
        
        SBQQ__QuoteLine__c renewalQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = renewalQuote.Id,
            CurrencyIsoCode  = 'USD',
            SBQQ__Product__c = prod.Id,
            SBQQ__PricebookEntryId__c = pbe.Id,
            SBQQ__ListPrice__c = 100,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__DefaultSubscriptionTerm__c = 12,
            SBQQ__ProductSubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__ChargeType__c = 'Recurring',
            SBQQ__StartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Group__c = renewalQuoteGroup.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ProrateMultiplier__c = 1,
            SBQQ__OriginalPrice__c = 100,
            Unit_Type__c = 'New / Additional Unit',
            Weeks_Notice__c = '1-4 Weeks',
            SBQQ__SubscriptionBase__c = 'List'
        );
        insert renewalQuoteLine;
        
        //added for testing -- joshua.torregoza
        /*SBQQ.TriggerControl.disable();        
        DTN_Utilities.setDoNotRunTrigger();        
        System.debug('Opp--- joshua.torregoza--- ' +renewalOpp.SBQQ__RenewedContract__c);
        
        //SBQQ__Quote__c q = [SELECT Id, SBQQ__Status__c, ApprovalStatus__c, SBQQ__Ordered__c, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.Rolling_Term_months__c FROM SBQQ__Quote__c WHERE (SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Do_Not_Renew__c = FALSE AND SBQQ__Opportunity2__r.SBQQ__RenewedContract__c = :originalContract.Id)];
        
        //System.debug('Quote -- joshua.torregoza --- ' +q);
        
        //added for testing -- joshua.torregoza
        SBQQ.TriggerControl.disable();
        
        //SBQQ__QuoteLine__c quoteline = [SELECT Id, SBQQ__Product__c, SBQQ__PricebookEntryId__c, SBQQ__Product__r.blng__BillingRule__c, SBQQ__Product__r.blng__RevenueRecognitionRule__c, SBQQ__Product__r.blng__TaxRule__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: q.Id];
        
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c(
            SBQQ__Account__c = originalContract.AccountId,
            Apply_Uplift__c = true,
            CurrencyIsoCode = 'USD',
            SBQQ__OriginalQuoteLine__c = renewalQuoteLine.Id,
            SBQQ__Product__c = prod.Id,
            SBQQ__ProductSubscriptionType__c = 'Renewable',
            SBQQ__QuoteLine__c = renewalQuoteLine.Id,
            SBQQ__SubscriptionStartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__Number__c = 1,
            SBQQ__Quantity__c = 1
        );
        insert sub;
        
        Integer dayOfMonth = Date.today().Day();
        Order o = new Order(
            AccountId = originalContract.AccountId,
            OpportunityId = renewalOpp.Id,
            Type = 'New',
            SBQQ__Quote__c = renewalQuote.Id,
            SBQQ__RenewalTerm__c = 12,
            EffectiveDate = originalContract.EndDate.addDays(1),
            blng__BillingDayOfMonth__c = String.valueOf(dayOfMonth),
            Status = 'Draft',
            Pricebook2Id = originalContract.Pricebook2Id,
            SBQQ__ContractingMethod__c = 'Single Contract'
        );
        insert o;
        //SBQQ.TriggerControl.disable();
        OrderItem oi = new OrderItem(
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__ChargeType__c = 'Recurring',
            OrderId = o.Id,
            SBQQ__OrderedQuantity__c = 1,
            Product2Id = prod.Id,
            SBQQ__QuoteLine__c = renewalQuoteLine.Id,
            SBQQ__Status__c = 'Draft',
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__DefaultSubscriptionTerm__c = 12,
            ServiceDate = originalContract.EndDate.addDays(1),
            PricebookEntryId = renewalQuoteLine.SBQQ__PricebookEntryId__c,
            SBQQ__Subscription__c = sub.Id,
            UnitPrice = 100,
            Quantity = 1,
            blng__BillingRule__c = prod.blng__BillingRule__c,
            blng__RevenueRecognitionRule__c = prod.blng__RevenueRecognitionRule__c,
            blng__TaxRule__c = prod.blng__TaxRule__c
        );
        insert oi;
        SBQQ.TriggerControl.enable();
        o.Status = 'Activated';
        update o;*/
        
        DTN_CreateOrdersForRC createOrdersBatchObject = new DTN_CreateOrdersForRC();
        Id createOrdersBatchId = Database.executeBatch(createOrdersBatchObject, 1);
        Test.stopTest();
    }
    
    @IsTest
    static void processRollingContractsNegativeTest() {
        /*Contract c = [SELECT Id, Trigger_Rolling__c, StartDate, EndDate, SBQQ__RenewalForecast__c, Do_Not_Renew__c, Contract_Type__c, SBQQ__RenewalTerm__c, ContractTerm, Rolling_Term_months__c FROM Contract LIMIT 1];
        system.debug('---c.SBQQ__RenewalForecast__c-- '+c.SBQQ__RenewalForecast__c);
        c.SBQQ__RenewalForecast__c = TRUE;
        update c;*/
        
        Test.startTest();
        
        Contract originalContract = [SELECT Id, Trigger_Rolling__c, StartDate, EndDate, Do_Not_Renew__c, Contract_Type__c, SBQQ__RenewalTerm__c, ContractTerm, Rolling_Term_months__c, AccountId, Legal_Entity__c, Pricebook2Id FROM Contract LIMIT 1];
        originalContract.Contract_Type__c = 'Rolling';
        originalContract.Notice_Period_Months_pick__c = '1 Month';
        originalContract.Rolling_Term_months__c = 12;
        originalContract.Run_Rolling_Process__c = TRUE;
        //originalContract.SBQQ__RenewalForecast__c = TRUE;
        update originalContract;
        system.debug('---'+originalContract);
        
        Contact primaryContact = [SELECT Id FROM Contact LIMIT 1];
        Product2 prod = [SELECT Id, blng__BillingRule__c, blng__RevenueRecognitionRule__c, blng__TaxRule__c FROM Product2 WHERE Name = 'Test Product'];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE product2Id =: prod.Id and Pricebook2.Name = 'USD CPQ Price Book'];
        Opportunity Opp = [SELECT Id, AccountId, Legal_Entity__c, Pricebook2Id FROM Opportunity WHERE Name = 'Rolling Contract Test Opp'];
        Opportunity renewalOpp = new Opportunity(
            Name = 'Renewal Opp',
            StageName = 'Diagnose',
            CloseDate = System.Today(),
            AccountId = opp.AccountId,
            Legal_Entity__c = opp.Legal_Entity__c,
            Contract_Type__c = 'Rolling',
            Auto_Renewal_Days__c = '30 Days',
            Notice_Period_months__c = 1,
            Initial_Term_months__c = 12,
            Rolling_Term_months__c = 12,
            Pricebook2Id = opp.Pricebook2Id,
            Notice_Period_Months_pick__c = '1 Month',
            SBQQ__RenewedContract__c = originalContract.Id
        );
        insert renewalOpp;
        
        SBQQ__Quote__c renewalQuote = new SBQQ__Quote__c(
            SBQQ__SalesRep__c = UserInfo.getUserId(),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Primary__c = true,
            CurrencyIsoCode = 'USD',
            Billing_Type_Pick__c = 'Advance',
            SBQQ__Opportunity2__c = renewalOpp.Id,
            SBQQ__PrimaryContact__c = primaryContact.Id,
            SBQQ__BillingFrequency__c = 'Monthly',
            Billing_Frequency_pick__c = 'Monthly',
            SBQQ__PriceBook__c = opp.Pricebook2Id,
            SBQQ__PricebookId__c = opp.Pricebook2Id,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__Type__c = 'Quote'
        );
        insert renewalQuote;
        
        //SIBA-603 -- change trigger rolling to the new calculated end date of 60 days -- joshua.torregoza@dtn.com
        Date calculatedEndDate = Date.today().addYears(-1).addDays(60);
        Boolean triggerRollingFlag = (originalContract.Do_Not_Renew__c == false && originalContract.EndDate == calculatedEndDate);
        
        
        System.assertNotEquals(null, originalContract.Id);
        System.assertEquals(TRUE, triggerRollingFlag);
        
        DTN_CreateRenewalQuotesForRC batchObject = new DTN_CreateRenewalQuotesForRC();
        Id batchId = Database.executeBatch(batchObject, 1);
        
        Test.stopTest();
        
    }
    @IsTest
    static void processRollingContractsNegativeTest2() {
        Product2 prodUpdate = [SELECT Id FROM Product2 WHERE Name = 'Test Product'];
        prodUpdate.Product_Lifecycle__c = 'End Of Life';
        update prodUpdate;
        
        Test.startTest();
        
        Contract originalContract = [SELECT Id, Trigger_Rolling__c, StartDate, EndDate, Do_Not_Renew__c, Contract_Type__c, SBQQ__RenewalTerm__c, ContractTerm, Rolling_Term_months__c, AccountId, Legal_Entity__c, Pricebook2Id FROM Contract LIMIT 1];
        originalContract.Contract_Type__c = 'Rolling';
        originalContract.Notice_Period_Months_pick__c = '1 Month';
        originalContract.Rolling_Term_months__c = 12;
        originalContract.Run_Rolling_Process__c = TRUE;
        //originalContract.SBQQ__RenewalForecast__c = TRUE;
        update originalContract;
        system.debug('---'+originalContract);
        
        Contact primaryContact = [SELECT Id FROM Contact LIMIT 1];
        Product2 prod = [SELECT Id, blng__BillingRule__c, blng__RevenueRecognitionRule__c, blng__TaxRule__c FROM Product2 WHERE Name = 'Test Product'];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE product2Id =: prod.Id and Pricebook2.Name = 'USD CPQ Price Book'];
        Opportunity Opp = [SELECT Id, AccountId, Legal_Entity__c, Pricebook2Id FROM Opportunity WHERE Name = 'Rolling Contract Test Opp'];
        Opportunity renewalOpp = new Opportunity(
            Name = 'Renewal Opp',
            StageName = 'Diagnose',
            CloseDate = System.Today(),
            AccountId = opp.AccountId,
            Legal_Entity__c = opp.Legal_Entity__c,
            Contract_Type__c = 'Rolling',
            Auto_Renewal_Days__c = '30 Days',
            Notice_Period_months__c = 1,
            Initial_Term_months__c = 12,
            Rolling_Term_months__c = 12,
            Pricebook2Id = opp.Pricebook2Id,
            Notice_Period_Months_pick__c = '1 Month',
            SBQQ__RenewedContract__c = originalContract.Id
        );
        insert renewalOpp;
        
        SBQQ__Quote__c renewalQuote = new SBQQ__Quote__c(
            SBQQ__SalesRep__c = UserInfo.getUserId(),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Primary__c = true,
            CurrencyIsoCode = 'USD',
            Billing_Type_Pick__c = 'Advance',
            SBQQ__Opportunity2__c = renewalOpp.Id,
            SBQQ__PrimaryContact__c = primaryContact.Id,
            SBQQ__BillingFrequency__c = 'Monthly',
            Billing_Frequency_pick__c = 'Monthly',
            SBQQ__PriceBook__c = opp.Pricebook2Id,
            SBQQ__PricebookId__c = opp.Pricebook2Id,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__Type__c = 'Quote'
        );
        insert renewalQuote;
        
        //SIBA-603 -- change trigger rolling to the new calculated end date of 60 days -- joshua.torregoza@dtn.com
        Date calculatedEndDate = Date.today().addYears(-1).addDays(60);
        Boolean triggerRollingFlag = (originalContract.Do_Not_Renew__c == false && originalContract.EndDate == calculatedEndDate);
        
        
        System.assertNotEquals(null, originalContract.Id);
        System.assertEquals(TRUE, triggerRollingFlag);
        
        DTN_CreateRenewalQuotesForRC batchObject = new DTN_CreateRenewalQuotesForRC();
        Id batchId = Database.executeBatch(batchObject, 1);
        
        Test.stopTest();
        
    }
    
    @IsTest
    static void processRollingContractsNegativeTest3() {        
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Test Product'];
        prod.Product_Lifecycle__c = 'End Of Life';
        update prod;
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE product2Id =: prod.Id and Pricebook2.Name = 'USD CPQ Price Book'];
        
        Test.startTest();
        
        Contract originalContract = [SELECT Id, Trigger_Rolling__c, StartDate, EndDate, Do_Not_Renew__c, Contract_Type__c, SBQQ__RenewalTerm__c, ContractTerm, Rolling_Term_months__c, AccountId, Legal_Entity__c, Pricebook2Id FROM Contract LIMIT 1];
        originalContract.Contract_Type__c = 'Rolling';
        originalContract.Notice_Period_Months_pick__c = '1 Month';
        originalContract.Rolling_Term_months__c = 12;
        originalContract.Run_Rolling_Process__c = TRUE;
        originalContract.ProcessAutoRolling__c = TRUE;
        
        update originalContract;
        system.debug('---'+originalContract);
        
        Contact primaryContact = [SELECT Id FROM Contact LIMIT 1];
        Opportunity Opp = [SELECT Id, AccountId, Legal_Entity__c, Pricebook2Id FROM Opportunity WHERE Name = 'Rolling Contract Test Opp'];
        Opportunity renewalOpp = new Opportunity(
            Name = 'Renewal Opp',
            StageName = 'Diagnose',
            CloseDate = System.Today(),
            AccountId = opp.AccountId,
            Legal_Entity__c = opp.Legal_Entity__c,
            Contract_Type__c = 'Rolling',
            Auto_Renewal_Days__c = '30 Days',
            Notice_Period_months__c = 1,
            Initial_Term_months__c = 12,
            Rolling_Term_months__c = 12,
            Pricebook2Id = opp.Pricebook2Id,
            Notice_Period_Months_pick__c = '1 Month',
            SBQQ__RenewedContract__c = originalContract.Id
        );
        insert renewalOpp;
        
        SBQQ__Quote__c renewalQuote = new SBQQ__Quote__c(
            SBQQ__SalesRep__c = UserInfo.getUserId(),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Primary__c = true,
            CurrencyIsoCode = 'USD',
            Billing_Type_Pick__c = 'Advance',
            SBQQ__Opportunity2__c = renewalOpp.Id,
            SBQQ__PrimaryContact__c = primaryContact.Id,
            SBQQ__BillingFrequency__c = 'Monthly',
            Billing_Frequency_pick__c = 'Monthly',
            SBQQ__PriceBook__c = opp.Pricebook2Id,
            SBQQ__PricebookId__c = opp.Pricebook2Id,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__Type__c = 'Quote'
        );
        insert renewalQuote;
        
        SBQQ__QuoteLineGroup__c renewalQuoteGroup = new SBQQ__QuoteLineGroup__c(
            CurrencyIsoCode = 'USD',
            Name = 'Group1',
            SBQQ__Account__c = originalContract.AccountId,
            SBQQ__Number__c = 1,
            SBQQ__Quote__c = renewalQuote.Id
        );
        insert renewalQuoteGroup;
        
        SBQQ__QuoteLine__c renewalQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = renewalQuote.Id,
            CurrencyIsoCode  = 'USD',
            SBQQ__Product__c = prod.Id,
            SBQQ__PricebookEntryId__c = pbe.Id,
            SBQQ__ListPrice__c = 100,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__DefaultSubscriptionTerm__c = 12,
            SBQQ__ProductSubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__ChargeType__c = 'Recurring',
            SBQQ__StartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Group__c = renewalQuoteGroup.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ProrateMultiplier__c = 1,
            SBQQ__OriginalPrice__c = 100,
            Unit_Type__c = 'New / Additional Unit',
            Weeks_Notice__c = '1-4 Weeks',
            SBQQ__SubscriptionBase__c = 'List'
        );
        insert renewalQuoteLine;
        
        //SIBA-603 -- change trigger rolling to the new calculated end date of 60 days -- joshua.torregoza@dtn.com
        Date calculatedEndDate = Date.today().addYears(-1).addDays(60);
        Boolean triggerRollingFlag = (originalContract.Do_Not_Renew__c == false && originalContract.EndDate == calculatedEndDate);
        
        System.assertNotEquals(null, originalContract.Id);
        System.assertEquals(TRUE, triggerRollingFlag);
        //DTN_CreateRenewalQuotesForRC batchObject = new DTN_CreateRenewalQuotesForRC();
        //Id batchId = Database.executeBatch(batchObject, 1);
        DTN_CreateOrdersForRC createOrdersBatchObject = new DTN_CreateOrdersForRC();
        Id createOrdersBatchId = Database.executeBatch(createOrdersBatchObject, 1);
        Test.stopTest();
    }
    
    @IsTest
    static void processRollingContractsNegativePriceIncreaseTest() {
        
        Contract originalContract = [SELECT Id, Trigger_Rolling__c, StartDate, EndDate, Do_Not_Renew__c, Contract_Type__c, SBQQ__RenewalTerm__c, ContractTerm, Rolling_Term_months__c, AccountId, Legal_Entity__c, Pricebook2Id  FROM Contract LIMIT 1];
        originalContract.Contract_Type__c = 'Rolling';
        originalContract.Notice_Period_Months_pick__c = '1 Month';
        originalContract.Rolling_Term_months__c = 12;
        originalContract.ProcessAutoRolling__c = TRUE;
        originalContract.Run_Rolling_Process__c = TRUE;
        //update originalContract;
        //originalContract.SBQQ__RenewalForecast__c = true;
        //originalContract.SBQQ__RenewalQuoted__c = true;
        DTN_Utilities.setDoNotRunTrigger();
        update originalContract;
        system.debug('---'+originalContract);
        
        //SIBA-603 -- change trigger rolling to the new calculated end date of 60 days -- joshua.torregoza@dtn.com
        Date calculatedEndDate = Date.today().addYears(-1).addDays(60);
        Boolean triggerRollingFlag = (originalContract.Do_Not_Renew__c == false && originalContract.EndDate == calculatedEndDate);
        
        System.assertNotEquals(null, originalContract.Id);
        System.assertEquals(TRUE, triggerRollingFlag);
        
        
        
        /*Opportunity Opp = [SELECT Id, AccountId, Account.OwnerId, Legal_Entity__c, Pricebook2Id FROM Opportunity WHERE SBQQ__RenewedContract__c =: originalContract.Id];
        Contact primaryContact = [SELECT Id FROM Contact LIMIT 1];
        SBQQ__Quote__c q = [SELECT Id, SBQQ__Status__c, ApprovalStatus__c, SBQQ__Ordered__c, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.Rolling_Term_months__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Trigger_Rolling__c = TRUE];
        q.Needs_Approval__c = false;
        q.Ready_for_Execution__c = true;
        q.SBQQ__SubscriptionTerm__c = 24;
        q.SBQQ__PriceBook__c = opp.Pricebook2Id;
        q.SBQQ__PricebookId__c = opp.Pricebook2Id;
        q.SBQQ__PrimaryContact__c = primaryContact.Id;
        q.SBQQ__Primary__c = true;
        q.SBQQ__ContractingMethod__c = 'By Subscription End Date';*/
        Test.startTest();
        //update q;
        //SBQQ.TriggerControl.disable();
        
        Product2 prod = [SELECT Id, blng__BillingRule__c, blng__RevenueRecognitionRule__c, blng__TaxRule__c FROM Product2 WHERE Name = 'Test Product'];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE product2Id =: prod.Id and Pricebook2.Name = 'USD CPQ Price Book'];
        Contact primaryContact = [SELECT Id FROM Contact LIMIT 1];
        Opportunity renewalOpp = new Opportunity(
            Name = 'Renewal Opp',
            StageName = 'Diagnose',
            CloseDate = System.Today(),
            AccountId = originalContract.AccountId,
            Legal_Entity__c = originalContract.Legal_Entity__c,
            Contract_Type__c = 'Rolling',
            Auto_Renewal_Days__c = '30 Days',
            Notice_Period_months__c = 1,
            Initial_Term_months__c = 12,
            Rolling_Term_months__c = 12,
            Pricebook2Id = originalContract.Pricebook2Id,
            Notice_Period_Months_pick__c = '1 Month',
            SBQQ__RenewedContract__c = originalContract.Id
        );
        insert renewalOpp;
        
        SBQQ__Quote__c renewalQuote = new SBQQ__Quote__c(
            SBQQ__SalesRep__c = UserInfo.getUserId(),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Primary__c = true,
            CurrencyIsoCode = 'USD',
            Billing_Type_Pick__c = 'Advance',
            SBQQ__Opportunity2__c = renewalOpp.Id,
            SBQQ__PrimaryContact__c = primaryContact.Id,
            SBQQ__BillingFrequency__c = 'Monthly',
            Billing_Frequency_pick__c = 'Monthly',
            SBQQ__PriceBook__c = originalContract.Pricebook2Id,
            SBQQ__PricebookId__c = originalContract.Pricebook2Id,
            SBQQ__StartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__Type__c = 'Quote',
            Needs_Approval__c = false,
            Ready_for_Execution__c = true,
            SBQQ__ContractingMethod__c = 'Single Contract'
        );
        insert renewalQuote;
        
        SBQQ__QuoteLineGroup__c renewalQuoteGroup = new SBQQ__QuoteLineGroup__c(
            CurrencyIsoCode = 'USD',
            Name = 'Group1',
            SBQQ__Account__c = originalContract.AccountId,
            SBQQ__Number__c = 1,
            SBQQ__Quote__c = renewalQuote.Id
        );
        insert renewalQuoteGroup;
        
        SBQQ__QuoteLine__c renewalQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = renewalQuote.Id,
            CurrencyIsoCode  = 'USD',
            SBQQ__Product__c = prod.Id,
            SBQQ__PricebookEntryId__c = pbe.Id,
            SBQQ__ListPrice__c = 100,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__DefaultSubscriptionTerm__c = 12,
            SBQQ__ProductSubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__ChargeType__c = 'Recurring',
            SBQQ__StartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Group__c = renewalQuoteGroup.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ProrateMultiplier__c = 1,
            SBQQ__OriginalPrice__c = 100,
            Unit_Type__c = 'New / Additional Unit',
            Weeks_Notice__c = '1-4 Weeks',
            SBQQ__SubscriptionBase__c = 'List'
        );
        insert renewalQuoteLine;
        
        //SBQQ__QuoteLine__c quoteline = [SELECT Id, SBQQ__Product__c, SBQQ__PricebookEntryId__c, SBQQ__Product__r.blng__BillingRule__c, SBQQ__Product__r.blng__RevenueRecognitionRule__c, SBQQ__Product__r.blng__TaxRule__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: q.Id];
        
        /*SBQQ__Subscription__c sub = new SBQQ__Subscription__c(
            SBQQ__Account__c = originalContract.AccountId,
            Apply_Uplift__c = true,
            CurrencyIsoCode = 'USD',
            SBQQ__OriginalQuoteLine__c = renewalQuoteLine.Id,
            SBQQ__Product__c = prod.Id,
            SBQQ__ProductSubscriptionType__c = 'Renewable',
            SBQQ__QuoteLine__c = renewalQuoteLine.Id,
            SBQQ__SubscriptionStartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__Number__c = 1,
            SBQQ__Quantity__c = 1
        );
        insert sub;
        
        Integer dayOfMonth = Date.today().Day();
        Order o = new Order(
            AccountId = originalContract.AccountId,
            OpportunityId = renewalOpp.Id,
            Type = 'New',
            SBQQ__Quote__c = renewalQuote.Id,
            SBQQ__RenewalTerm__c = 12,
            EffectiveDate = originalContract.EndDate.addDays(1),
            blng__BillingDayOfMonth__c = String.valueOf(dayOfMonth),
            Status = 'Draft',
            Pricebook2Id = originalContract.Pricebook2Id,
            SBQQ__ContractingMethod__c = 'Single Contract'
        );
        insert o;
        SBQQ.TriggerControl.disable();
        OrderItem oi = new OrderItem(
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__ChargeType__c = 'Recurring',
            OrderId = o.Id,
            SBQQ__OrderedQuantity__c = 1,
            Product2Id = quoteLine.SBQQ__Product__c,
            SBQQ__QuoteLine__c = quoteLine.Id,
            SBQQ__Status__c = 'Draft',
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__DefaultSubscriptionTerm__c = 12,
            ServiceDate = Date.today(),
            //EndDate = startDate.addMonths(1),
            PricebookEntryId = quoteLine.SBQQ__PricebookEntryId__c,
            SBQQ__Subscription__c = sub.Id,
            UnitPrice = 100,
            Quantity = 1,
            blng__BillingRule__c = quoteLine.SBQQ__Product__r.blng__BillingRule__c,
            blng__RevenueRecognitionRule__c = quoteLine.SBQQ__Product__r.blng__RevenueRecognitionRule__c,
            blng__TaxRule__c = quoteLine.SBQQ__Product__r.blng__TaxRule__c
        );
        insert oi;
        SBQQ.TriggerControl.enable();
        o.Status = 'Activated';
        update o;*/
        
        DTN_CreateOrdersForRC createOrdersBatchObject = new DTN_CreateOrdersForRC();
        Id createOrdersBatchId = Database.executeBatch(createOrdersBatchObject, 1);
        Test.stopTest();
    }
    
    @IsTest
    static void processRollingContractsTest3() {
        Test.startTest();
        Contract originalContract = [SELECT Id, Trigger_Rolling__c, StartDate, EndDate, Do_Not_Renew__c, Contract_Type__c, AccountId, SBQQ__RenewalTerm__c, ContractTerm, Rolling_Term_months__c, Legal_Entity__c, Pricebook2Id FROM Contract LIMIT 1];
        originalContract.Contract_Type__c = 'Rolling';
        originalContract.Notice_Period_Months_pick__c = '1 Month';
        originalContract.Rolling_Term_months__c = 12;
        originalContract.ProcessAutoRolling__c = TRUE;
        originalContract.Run_Rolling_Process__c = TRUE;
        DTN_Utilities.setDoNotRunTrigger();
        update originalContract;
        system.debug('---'+originalContract);
        
        Date calculatedEndDate = Date.today().addYears(-1).addDays(60);
        Boolean triggerRollingFlag = (originalContract.Do_Not_Renew__c == false && originalContract.EndDate == calculatedEndDate);
        
        System.assertNotEquals(null, originalContract.Id);
        System.assertEquals(TRUE, triggerRollingFlag);
        
        Contact primaryContact = [SELECT Id FROM Contact LIMIT 1];
        Product2 prod = [SELECT Id, blng__BillingRule__c, blng__RevenueRecognitionRule__c, blng__TaxRule__c FROM Product2 WHERE Name = 'Test Product'];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE product2Id =: prod.Id and Pricebook2.Name = 'USD CPQ Price Book'];
        
        Opportunity renewalOpp = new Opportunity(
            Name = 'Renewal Opp',
            StageName = 'Diagnose',
            CloseDate = System.Today(),
            AccountId = originalContract.AccountId,
            Legal_Entity__c = originalContract.Legal_Entity__c,
            Contract_Type__c = 'Rolling',
            Auto_Renewal_Days__c = '30 Days',
            Notice_Period_months__c = 1,
            Initial_Term_months__c = 12,
            Rolling_Term_months__c = 12,
            Pricebook2Id = originalContract.Pricebook2Id,
            Notice_Period_Months_pick__c = '1 Month',
            SBQQ__RenewedContract__c = originalContract.Id
        );
        insert renewalOpp;
        
        SBQQ__Quote__c renewalQuote = new SBQQ__Quote__c(
            SBQQ__SalesRep__c = UserInfo.getUserId(),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Primary__c = true,
            CurrencyIsoCode = 'USD',
            Billing_Type_Pick__c = 'Advance',
            SBQQ__Opportunity2__c = renewalOpp.Id,
            SBQQ__PrimaryContact__c = primaryContact.Id,
            SBQQ__BillingFrequency__c = 'Monthly',
            Billing_Frequency_pick__c = 'Monthly',
            SBQQ__PriceBook__c = originalContract.Pricebook2Id,
            SBQQ__PricebookId__c = originalContract.Pricebook2Id,
            SBQQ__StartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__Type__c = 'Quote',
            Needs_Approval__c = false,
            Ready_for_Execution__c = true,
            SBQQ__ContractingMethod__c = 'Single Contract'
        );
        insert renewalQuote;
        
        SBQQ__QuoteLineGroup__c renewalQuoteGroup = new SBQQ__QuoteLineGroup__c(
            CurrencyIsoCode = 'USD',
            Name = 'Group1',
            SBQQ__Account__c = originalContract.AccountId,
            SBQQ__Number__c = 1,
            SBQQ__Quote__c = renewalQuote.Id
        );
        insert renewalQuoteGroup;
        
        SBQQ__QuoteLine__c renewalQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = renewalQuote.Id,
            CurrencyIsoCode  = 'USD',
            SBQQ__Product__c = prod.Id,
            SBQQ__PricebookEntryId__c = pbe.Id,
            SBQQ__ListPrice__c = 100,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__DefaultSubscriptionTerm__c = 12,
            SBQQ__ProductSubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__ChargeType__c = 'Recurring',
            SBQQ__StartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Group__c = renewalQuoteGroup.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ProrateMultiplier__c = 1,
            SBQQ__OriginalPrice__c = 100,
            Unit_Type__c = 'New / Additional Unit',
            Weeks_Notice__c = '1-4 Weeks',
            SBQQ__SubscriptionBase__c = 'List'
        );
        insert renewalQuoteLine;
        
        SBQQ.TriggerControl.disable();        
        DTN_Utilities.setDoNotRunTrigger();
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c(
            SBQQ__Account__c = originalContract.AccountId,
            Apply_Uplift__c = true,
            CurrencyIsoCode = 'USD',
            SBQQ__OriginalQuoteLine__c = renewalQuoteLine.Id,
            SBQQ__Product__c = prod.Id,
            SBQQ__ProductSubscriptionType__c = 'Renewable',
            SBQQ__QuoteLine__c = renewalQuoteLine.Id,
            SBQQ__SubscriptionStartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__Number__c = 1,
            SBQQ__Quantity__c = 1
        );
        insert sub;
        
        Integer dayOfMonth = Date.today().Day();
        Order o = new Order(
            AccountId = originalContract.AccountId,
            OpportunityId = renewalOpp.Id,
            Type = 'New',
            SBQQ__Quote__c = renewalQuote.Id,
            SBQQ__RenewalTerm__c = 12,
            EffectiveDate = originalContract.EndDate.addDays(1),
            blng__BillingDayOfMonth__c = String.valueOf(dayOfMonth),
            Status = 'Draft',
            Pricebook2Id = originalContract.Pricebook2Id,
            SBQQ__ContractingMethod__c = 'Single Contract'
        );
        insert o;
        
        OrderItem oi = new OrderItem(
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__ChargeType__c = 'Recurring',
            OrderId = o.Id,
            SBQQ__OrderedQuantity__c = 1,
            Product2Id = prod.Id,
            SBQQ__QuoteLine__c = renewalQuoteLine.Id,
            SBQQ__Status__c = 'Draft',
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__DefaultSubscriptionTerm__c = 12,
            ServiceDate = originalContract.EndDate.addDays(1),
            PricebookEntryId = renewalQuoteLine.SBQQ__PricebookEntryId__c,
            SBQQ__Subscription__c = sub.Id,
            UnitPrice = 100,
            Quantity = 1,
            blng__BillingRule__c = prod.blng__BillingRule__c,
            blng__RevenueRecognitionRule__c = prod.blng__RevenueRecognitionRule__c,
            blng__TaxRule__c = prod.blng__TaxRule__c
        );
        insert oi;
        SBQQ.TriggerControl.enable();
        //o.Status = 'Activated';
        //update o;
        
        DTN_CreateOrdersForRC createOrdersBatchObject = new DTN_CreateOrdersForRC();
        Id createOrdersBatchId = Database.executeBatch(createOrdersBatchObject, 1);
        Test.stopTest();
    }
    
    //Joshua test method
    @IsTest
    static void processRollingContractsNegativeTest4(){
        Test.startTest();
        Contract originalContract = [SELECT Id, Trigger_Rolling__c, StartDate, EndDate, Do_Not_Renew__c, Contract_Type__c, AccountId, SBQQ__RenewalTerm__c, ContractTerm, Rolling_Term_months__c, Legal_Entity__c, Pricebook2Id FROM Contract LIMIT 1];
        originalContract.Contract_Type__c = 'Rolling';
        originalContract.Notice_Period_Months_pick__c = '1 Month';
        originalContract.Rolling_Term_months__c = 12;
        originalContract.ProcessAutoRolling__c = TRUE;
        originalContract.Run_Rolling_Process__c = TRUE;
        originalContract.StartDate = null;
        DTN_Utilities.setDoNotRunTrigger();
        update originalContract;
        system.debug('---'+originalContract);
        
        Date calculatedEndDate = Date.today().addYears(-1).addDays(60);
        Boolean triggerRollingFlag = (originalContract.Do_Not_Renew__c == false && originalContract.EndDate == calculatedEndDate || originalContract.Run_Rolling_Process__c == TRUE);
        
        System.assertNotEquals(null, originalContract.Id);
        System.assertEquals(TRUE, triggerRollingFlag);
        
        Contact primaryContact = [SELECT Id FROM Contact LIMIT 1];        
        Product2 prod = [SELECT Id, blng__BillingRule__c, blng__RevenueRecognitionRule__c, blng__TaxRule__c FROM Product2 WHERE Name = 'Test Product'];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE product2Id =: prod.Id and Pricebook2.Name = 'USD CPQ Price Book'];
        
        Opportunity amendOpp = new Opportunity(
            Name = 'Amend Opp',
            StageName = 'Diagnose',
            CloseDate = System.Today(),
            AccountId = originalContract.AccountId,
            Legal_Entity__c = originalContract.Legal_Entity__c,
            Contract_Type__c = 'Rolling',
            Auto_Renewal_Days__c = '30 Days',
            Notice_Period_months__c = 1,
            Initial_Term_months__c = 12,
            Rolling_Term_months__c = 12,
            Pricebook2Id = null,
            Notice_Period_Months_pick__c = '1 Month',
            SBQQ__AmendedContract__c = originalContract.Id
        );
        insert amendOpp;
        
        Opportunity renewalOpp = new Opportunity(
            Name = 'Renewal Opp',
            StageName = 'Diagnose',
            CloseDate = System.Today(),
            AccountId = originalContract.AccountId,
            Legal_Entity__c = null,
            Contract_Type__c = 'Rolling',
            Auto_Renewal_Days__c = '30 Days',
            Notice_Period_months__c = 1,
            Initial_Term_months__c = 12,
            Rolling_Term_months__c = 12,
            Pricebook2Id = null,
            Notice_Period_Months_pick__c = '1 Month',
            SBQQ__RenewedContract__c = originalContract.Id
        );
        insert renewalOpp;
        
        SBQQ__Quote__c renewalQuote = new SBQQ__Quote__c(
            SBQQ__SalesRep__c = UserInfo.getUserId(),
            SBQQ__SubscriptionTerm__c = null,
            SBQQ__Primary__c = true,
            CurrencyIsoCode = null,
            Billing_Type_Pick__c = null,
            SBQQ__Opportunity2__c = renewalOpp.Id,
            SBQQ__PrimaryContact__c = null,
            SBQQ__BillingFrequency__c = null,
            Billing_Frequency_pick__c = null,
            SBQQ__PriceBook__c = originalContract.Pricebook2Id,
            SBQQ__PricebookId__c = originalContract.Pricebook2Id,
            SBQQ__StartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__Type__c = null,
            Needs_Approval__c = false,
            Ready_for_Execution__c = true,
            SBQQ__ContractingMethod__c = 'Single Contract'
        );
        insert renewalQuote;
        
        SBQQ__QuoteLineGroup__c renewalQuoteGroup = new SBQQ__QuoteLineGroup__c(
            CurrencyIsoCode = 'USD',
            Name = 'Group1',
            SBQQ__Account__c = originalContract.AccountId,
            SBQQ__Number__c = 1,
            SBQQ__Quote__c = renewalQuote.Id
        );
        insert renewalQuoteGroup;
        
        SBQQ__QuoteLine__c renewalQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = renewalQuote.Id,
            CurrencyIsoCode  = 'USD',
            SBQQ__Product__c = prod.Id,
            SBQQ__PricebookEntryId__c = pbe.Id,
            SBQQ__ListPrice__c = 100,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__DefaultSubscriptionTerm__c = 12,
            SBQQ__ProductSubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__ChargeType__c = 'Recurring',
            SBQQ__StartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Group__c = renewalQuoteGroup.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ProrateMultiplier__c = 1,
            SBQQ__OriginalPrice__c = 100,
            Unit_Type__c = 'New / Additional Unit',
            Weeks_Notice__c = '1-4 Weeks',
            SBQQ__SubscriptionBase__c = 'List'
        );
        insert renewalQuoteLine;
        
        SBQQ.TriggerControl.disable();        
        DTN_Utilities.setDoNotRunTrigger();
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c(
            SBQQ__Account__c = originalContract.AccountId,
            Apply_Uplift__c = true,
            CurrencyIsoCode = 'USD',
            SBQQ__OriginalQuoteLine__c = renewalQuoteLine.Id,
            SBQQ__Product__c = prod.Id,
            SBQQ__ProductSubscriptionType__c = 'Renewable',
            SBQQ__QuoteLine__c = renewalQuoteLine.Id,
            SBQQ__SubscriptionStartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__Number__c = 1,
            SBQQ__Quantity__c = 0
        );
        insert sub;
        
        Integer dayOfMonth = Date.today().Day();
        Order o = new Order(
            AccountId = originalContract.AccountId,
            OpportunityId = renewalOpp.Id,
            Type = 'New',
            SBQQ__Quote__c = renewalQuote.Id,
            SBQQ__RenewalTerm__c = 12,
            EffectiveDate = originalContract.EndDate.addDays(1),
            blng__BillingDayOfMonth__c = String.valueOf(dayOfMonth),
            Status = 'Draft',
            Pricebook2Id = originalContract.Pricebook2Id,
            SBQQ__ContractingMethod__c = 'Single Contract'
        );
        insert o;
        
        OrderItem oi = new OrderItem(
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__ChargeType__c = 'Recurring',
            OrderId = o.Id,
            SBQQ__OrderedQuantity__c = 1,
            Product2Id = prod.Id,
            SBQQ__QuoteLine__c = renewalQuoteLine.Id,
            SBQQ__Status__c = 'Draft',
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__DefaultSubscriptionTerm__c = 12,
            ServiceDate = originalContract.EndDate.addDays(1),
            PricebookEntryId = renewalQuoteLine.SBQQ__PricebookEntryId__c,
            SBQQ__Subscription__c = sub.Id,
            UnitPrice = 100,
            Quantity = 1,
            blng__BillingRule__c = prod.blng__BillingRule__c,
            blng__RevenueRecognitionRule__c = prod.blng__RevenueRecognitionRule__c,
            blng__TaxRule__c = prod.blng__TaxRule__c
        );
        insert oi;
        SBQQ.TriggerControl.enable();
        //o.Status = 'Activated';
        //update o;
        
        DTN_CreateRenewalQuotesForRC createRenewalBatchObject = new DTN_CreateRenewalQuotesForRC();
        Id createRenewalBatchObjectId = Database.executeBatch(createRenewalBatchObject, 1);
        Test.stopTest();
    }
        
    //Catch test -- joshua
   	
    @IsTest
    static void processRollingContractsCatchTest1() {
        Product2 prodUpdate = [SELECT Id FROM Product2 WHERE Name = 'Test Product'];
        prodUpdate.Product_Lifecycle__c = 'End Of Life';
        update prodUpdate;
        
        Test.startTest();
        
        Contract originalContract = [SELECT Id, Trigger_Rolling__c, StartDate, EndDate, Do_Not_Renew__c, Contract_Type__c, SBQQ__RenewalTerm__c, ContractTerm, Rolling_Term_months__c, AccountId, Legal_Entity__c, Pricebook2Id FROM Contract LIMIT 1];
        originalContract.Contract_Type__c = 'Rolling';
        originalContract.Notice_Period_Months_pick__c = '1 Month';
        originalContract.Rolling_Term_months__c = null;
        originalContract.Run_Rolling_Process__c = TRUE;
        originalContract.StartDate = null;
        //originalContract.SBQQ__RenewalForecast__c = TRUE;
        update originalContract;
        system.debug('---'+originalContract);
        
        Contact primaryContact = [SELECT Id FROM Contact LIMIT 1];
        Product2 prod = [SELECT Id, blng__BillingRule__c, blng__RevenueRecognitionRule__c, blng__TaxRule__c FROM Product2 WHERE Name = 'Test Product'];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE product2Id =: prod.Id and Pricebook2.Name = 'USD CPQ Price Book'];
        Opportunity Opp = [SELECT Id, AccountId, Legal_Entity__c, Pricebook2Id FROM Opportunity WHERE Name = 'Rolling Contract Test Opp'];
        Opportunity renewalOpp = new Opportunity(
            Name = null,
            StageName = 'Diagnose',
            CloseDate = System.Today(),
            AccountId = opp.AccountId,
            Legal_Entity__c = opp.Legal_Entity__c,
            Contract_Type__c = 'Rolling',
            Auto_Renewal_Days__c = '30 Days',
            Notice_Period_months__c = 1,
            Initial_Term_months__c = 12,
            Rolling_Term_months__c = 12,
            Pricebook2Id = opp.Pricebook2Id,
            Notice_Period_Months_pick__c = '1 Month',
            SBQQ__RenewedContract__c = originalContract.Id
        );
        insert renewalOpp;
               
        //SIBA-603 -- change trigger rolling to the new calculated end date of 60 days -- joshua.torregoza@dtn.com
        Date calculatedEndDate = Date.today().addYears(-1).addDays(60);
        Boolean triggerRollingFlag = (originalContract.Do_Not_Renew__c == false && originalContract.EndDate == calculatedEndDate || originalContract.Run_Rolling_Process__c == false);
        
        
        System.assertNotEquals(null, originalContract.Id);
        System.assertEquals(TRUE, triggerRollingFlag);
        
        DTN_CreateRenewalQuotesForRC batchObject = new DTN_CreateRenewalQuotesForRC();
        Id batchId = Database.executeBatch(batchObject, 1);
        
        Test.stopTest();
        
    }
    
    @IsTest
    static void processRollingContractsCatchTest2() {
        Test.startTest();
        Contract originalContract = [SELECT Id, Trigger_Rolling__c, StartDate, EndDate, Do_Not_Renew__c, Contract_Type__c, AccountId, SBQQ__RenewalTerm__c, ContractTerm, Rolling_Term_months__c, Legal_Entity__c, Pricebook2Id FROM Contract LIMIT 1];
        originalContract.Contract_Type__c = 'Rolling';
        originalContract.Notice_Period_Months_pick__c = '1 Month';
        originalContract.Rolling_Term_months__c = 12;
        originalContract.ProcessAutoRolling__c = TRUE;
        originalContract.Run_Rolling_Process__c = TRUE;
        originalContract.StartDate = null;
        DTN_Utilities.setDoNotRunTrigger();
        update originalContract;
        system.debug('---'+originalContract);

        //SIBA-603 -- change trigger rolling to the new calculated end date of 60 days -- joshua.torregoza@dtn.com
        Date calculatedEndDate = Date.today().addYears(-1).addDays(60);

        Boolean triggerRollingFlag = (originalContract.Do_Not_Renew__c == false && originalContract.EndDate == calculatedEndDate || originalContract.Run_Rolling_Process__c == true);
        
        System.assertNotEquals(null, originalContract.Id);
        System.assertEquals(TRUE, triggerRollingFlag);
        
        Contact primaryContact = [SELECT Id FROM Contact LIMIT 1];
        Product2 prod = [SELECT Id, blng__BillingRule__c, blng__RevenueRecognitionRule__c, blng__TaxRule__c FROM Product2 WHERE Name = 'Test Product'];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE product2Id =: prod.Id and Pricebook2.Name = 'USD CPQ Price Book'];
        List<SBQQ__Subscription__c> subList = [SELECT Id FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c =: originalContract.Id];
        //Opportunity Opp = [SELECT Id, AccountId, Legal_Entity__c, Pricebook2Id FROM Opportunity WHERE Name = 'Rolling Contract Test Opp'];
        Opportunity renewalOpp = new Opportunity(
            Name = 'Renewal Opp',
            StageName = 'Diagnose',
            CloseDate = System.Today(),
            AccountId = originalContract.AccountId,
            Legal_Entity__c = originalContract.Legal_Entity__c,
            Contract_Type__c = 'Rolling',
            Auto_Renewal_Days__c = '30 Days',
            Notice_Period_months__c = 1,
            Initial_Term_months__c = 12,
            Rolling_Term_months__c = 12,
            Pricebook2Id = originalContract.Pricebook2Id,
            Notice_Period_Months_pick__c = '1 Month',
            SBQQ__RenewedContract__c = originalContract.Id
        );
        insert renewalOpp;
        
        SBQQ__Quote__c renewalQuote = new SBQQ__Quote__c(
            SBQQ__SalesRep__c = UserInfo.getUserId(),
            SBQQ__SubscriptionTerm__c = null,
            SBQQ__Primary__c = true,
            CurrencyIsoCode = 'USD',
            Billing_Type_Pick__c = 'Advance',
            SBQQ__Opportunity2__c = renewalOpp.Id,
            SBQQ__PrimaryContact__c = primaryContact.Id,
            SBQQ__BillingFrequency__c = 'Monthly',
            Billing_Frequency_pick__c = 'Monthly',
            SBQQ__PriceBook__c = originalContract.Pricebook2Id,
            SBQQ__PricebookId__c = originalContract.Pricebook2Id,
            SBQQ__StartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__Type__c = 'Quote',
            Needs_Approval__c = false,
            Ready_for_Execution__c = true,
            SBQQ__ContractingMethod__c = 'Single Contract'
        );
        insert renewalQuote;
        
        SBQQ__QuoteLineGroup__c renewalQuoteGroup = new SBQQ__QuoteLineGroup__c(
            CurrencyIsoCode = 'USD',
            Name = 'Group1',
            SBQQ__Account__c = originalContract.AccountId,
            SBQQ__Number__c = 1,
            SBQQ__Quote__c = renewalQuote.Id
        );
        insert renewalQuoteGroup;
        
        SBQQ__QuoteLine__c renewalQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = renewalQuote.Id,
            CurrencyIsoCode  = 'USD',
            SBQQ__Product__c = prod.Id,
            SBQQ__PricebookEntryId__c = pbe.Id,
            SBQQ__ListPrice__c = 100,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__DefaultSubscriptionTerm__c = 12,
            SBQQ__ProductSubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__ChargeType__c = 'Recurring',
            SBQQ__StartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__RenewedSubscription__c = subList[0].Id,
            SBQQ__Group__c = renewalQuoteGroup.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ProrateMultiplier__c = 1,
            SBQQ__OriginalPrice__c = 100,
            Unit_Type__c = 'New / Additional Unit',
            Weeks_Notice__c = '1-4 Weeks',
            SBQQ__SubscriptionBase__c = 'List'
        );
        insert renewalQuoteLine;
        
        DTN_QuoteLinePricingUpdate pricingActionBatchObject = new DTN_QuoteLinePricingUpdate();
        Id pricingActionBatchId = Database.executeBatch(pricingActionBatchObject, 1);
        Test.stopTest();
    }
    
    @IsTest
    static void processRollingContractsCatchTest3() {
        Test.startTest();
        
        Contract originalContract = [SELECT Id, Trigger_Rolling__c, StartDate, EndDate, Do_Not_Renew__c, Contract_Type__c, SBQQ__RenewalTerm__c, ContractTerm, Rolling_Term_months__c FROM Contract LIMIT 1];
        originalContract.Contract_Type__c = 'Rolling';
        originalContract.Notice_Period_Months_pick__c = '1 Month';
        originalContract.Rolling_Term_months__c = 12;
        originalContract.Run_Rolling_Process__c = TRUE;
        originalContract.StartDate = null;
        update originalContract;
        system.debug('---'+originalContract);

        //SIBA-603 -- change trigger rolling to the new calculated end date of 60 days -- joshua.torregoza@dtn.com
        Boolean triggerRollingFlag = (originalContract.Do_Not_Renew__c == false && originalContract.EndDate == Date.today().addYears(-1).addDays(60) || originalContract.Run_Rolling_Process__c == TRUE);

        System.debug('triggerRollingFlag ---' +triggerRollingFlag);
        
        System.assertNotEquals(null, originalContract.Id);
        System.assertEquals(TRUE, triggerRollingFlag);
        DTN_CreateRenewalQuotesForRC batchObject = new DTN_CreateRenewalQuotesForRC();
        Id batchId = Database.executeBatch(batchObject, 1);
        
        Test.stopTest();
    }
    
    //catch test -- joshua
    

    //siba-603 test
    @IsTest
    static void processRollingContractsRenewalProduct() {        
        Product2 renewalProd = [SELECT Id FROM Product2 WHERE Name = 'Test Product 2'];
        Product2 prod1 = [SELECT Id, SBQQ__RenewalProduct__c, Product_Lifecycle__c FROM Product2 WHERE Name = 'Test Product'];
        prod1.Product_Lifecycle__c = 'End Of Life';
        prod1.SBQQ__RenewalProduct__c = renewalProd.Id;
        update prod1;
       
        Contract originalContract = [SELECT Id, Trigger_Rolling__c, StartDate, EndDate, Do_Not_Renew__c, Contract_Type__c, AccountId, SBQQ__RenewalTerm__c, ContractTerm, Rolling_Term_months__c, Legal_Entity__c, Pricebook2Id FROM Contract LIMIT 1];
        originalContract.Contract_Type__c = 'Rolling';
        originalContract.Notice_Period_Months_pick__c = '1 Month';
        originalContract.Rolling_Term_months__c = 12;
        originalContract.ProcessAutoRolling__c = TRUE;
        originalContract.Run_Rolling_Process__c = TRUE;
        DTN_Utilities.setDoNotRunTrigger();
        update originalContract;
        system.debug('---'+originalContract);
       
        Test.startTest();

        Contact primaryContact = [SELECT Id FROM Contact LIMIT 1];
        Product2 prod = [SELECT Id, blng__BillingRule__c, blng__RevenueRecognitionRule__c, blng__TaxRule__c FROM Product2 WHERE Name = 'Test Product'];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE product2Id =: prod.Id and Pricebook2.Name = 'USD CPQ Price Book'];
        
        Opportunity renewalOpp = new Opportunity(
            Name = 'Renewal Opp',
            StageName = 'Diagnose',
            CloseDate = System.Today(),
            AccountId = originalContract.AccountId,
            Legal_Entity__c = originalContract.Legal_Entity__c,
            Contract_Type__c = 'Rolling',
            Auto_Renewal_Days__c = '30 Days',
            Notice_Period_months__c = 1,
            Initial_Term_months__c = 12,
            Rolling_Term_months__c = 12,
            Pricebook2Id = originalContract.Pricebook2Id,
            Notice_Period_Months_pick__c = '1 Month',
            SBQQ__RenewedContract__c = originalContract.Id
        );
        insert renewalOpp;
        
        SBQQ__Quote__c renewalQuote = new SBQQ__Quote__c(
            SBQQ__SalesRep__c = UserInfo.getUserId(),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Primary__c = true,
            CurrencyIsoCode = 'USD',
            Billing_Type_Pick__c = 'Advance',
            SBQQ__Opportunity2__c = renewalOpp.Id,
            SBQQ__PrimaryContact__c = primaryContact.Id,
            SBQQ__BillingFrequency__c = 'Monthly',
            Billing_Frequency_pick__c = 'Monthly',
            SBQQ__PriceBook__c = originalContract.Pricebook2Id,
            SBQQ__PricebookId__c = originalContract.Pricebook2Id,
            SBQQ__StartDate__c = Date.today(),
            SBQQ__Type__c = 'Quote'
        );
        insert renewalQuote;
        
        SBQQ__QuoteLineGroup__c renewalQuoteGroup = new SBQQ__QuoteLineGroup__c(
            CurrencyIsoCode = 'USD',
            Name = 'Group1',
            SBQQ__Account__c = originalContract.AccountId,
            SBQQ__Number__c = 1,
            SBQQ__Quote__c = renewalQuote.Id
        );
        insert renewalQuoteGroup;
        
        SBQQ__QuoteLine__c renewalQuoteLine = new SBQQ__QuoteLine__c( 
            SBQQ__Quote__c = renewalQuote.Id,
            CurrencyIsoCode  = 'USD',
            SBQQ__Product__c = renewalProd.Id,
            SBQQ__PricebookEntryId__c = pbe.Id,
            SBQQ__ListPrice__c = 100,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__DefaultSubscriptionTerm__c = 12,
            SBQQ__ProductSubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__ChargeType__c = 'Recurring',
            SBQQ__StartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Group__c = renewalQuoteGroup.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ProrateMultiplier__c = 1,
            SBQQ__OriginalPrice__c = 100,
            Unit_Type__c = 'New / Additional Unit',
            Weeks_Notice__c = '1-4 Weeks',
            SBQQ__SubscriptionBase__c = 'List'
        );
        insert renewalQuoteLine;
        
        //SIBA-603 -- change trigger rolling to the new calculated end date of 60 days -- joshua.torregoza@dtn.com
        Date calculatedEndDate = Date.today().addYears(-1).addDays(60);
        Boolean triggerRollingFlag = (originalContract.Do_Not_Renew__c == false && originalContract.EndDate == calculatedEndDate);
        
        System.assertNotEquals(null, originalContract.Id);
        System.assertEquals(TRUE, triggerRollingFlag);

        DTN_CreateRenewalQuotesForRC batchObject = new DTN_CreateRenewalQuotesForRC();
        Id batchId = Database.executeBatch(batchObject, 1);
        
        Test.stopTest();
    }

	@IsTest
    static void processRollingContractsPricingUpdateTest() {
        Test.startTest();
        Contract originalContract = [SELECT Id, Trigger_Rolling__c, StartDate, EndDate, Do_Not_Renew__c, Contract_Type__c, AccountId, SBQQ__RenewalTerm__c, ContractTerm, Rolling_Term_months__c, Legal_Entity__c, Pricebook2Id FROM Contract LIMIT 1];
        originalContract.Contract_Type__c = 'Rolling';
        originalContract.Notice_Period_Months_pick__c = '1 Month';
        originalContract.Rolling_Term_months__c = 12;
        originalContract.ProcessAutoRolling__c = TRUE;
        originalContract.Run_Rolling_Process__c = TRUE;
        DTN_Utilities.setDoNotRunTrigger();
        update originalContract;
        system.debug('---'+originalContract);

        //SIBA-603 -- change trigger rolling to the new calculated end date of 60 days -- joshua.torregoza@dtn.com
        Date calculatedEndDate = Date.today().addYears(-1).addDays(60);

        Boolean triggerRollingFlag = (originalContract.Do_Not_Renew__c == false && originalContract.EndDate == calculatedEndDate);
        
        System.assertNotEquals(null, originalContract.Id);
        System.assertEquals(TRUE, triggerRollingFlag);
        
        Contact primaryContact = [SELECT Id FROM Contact LIMIT 1];
        Product2 prod = [SELECT Id, blng__BillingRule__c, blng__RevenueRecognitionRule__c, blng__TaxRule__c FROM Product2 WHERE Name = 'Test Product'];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE product2Id =: prod.Id and Pricebook2.Name = 'USD CPQ Price Book'];
        List<SBQQ__Subscription__c> subList = [SELECT Id FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c =: originalContract.Id];
        //Opportunity Opp = [SELECT Id, AccountId, Legal_Entity__c, Pricebook2Id FROM Opportunity WHERE Name = 'Rolling Contract Test Opp'];
        Opportunity renewalOpp = new Opportunity(
            Name = 'Renewal Opp',
            StageName = 'Diagnose',
            CloseDate = System.Today(),
            AccountId = originalContract.AccountId,
            Legal_Entity__c = originalContract.Legal_Entity__c,
            Contract_Type__c = 'Rolling',
            Auto_Renewal_Days__c = '30 Days',
            Notice_Period_months__c = 1,
            Initial_Term_months__c = 12,
            Rolling_Term_months__c = 12,
            Pricebook2Id = originalContract.Pricebook2Id,
            Notice_Period_Months_pick__c = '1 Month',
            SBQQ__RenewedContract__c = originalContract.Id
        );
        insert renewalOpp;
        
        SBQQ__Quote__c renewalQuote = new SBQQ__Quote__c(
            SBQQ__SalesRep__c = UserInfo.getUserId(),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Primary__c = true,
            CurrencyIsoCode = 'USD',
            Billing_Type_Pick__c = 'Advance',
            SBQQ__Opportunity2__c = renewalOpp.Id,
            SBQQ__PrimaryContact__c = primaryContact.Id,
            SBQQ__BillingFrequency__c = 'Monthly',
            Billing_Frequency_pick__c = 'Monthly',
            SBQQ__PriceBook__c = originalContract.Pricebook2Id,
            SBQQ__PricebookId__c = originalContract.Pricebook2Id,
            SBQQ__StartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__Type__c = 'Quote',
            Needs_Approval__c = false,
            Ready_for_Execution__c = true,
            SBQQ__ContractingMethod__c = 'Single Contract'
        );
        insert renewalQuote;
        
        SBQQ__QuoteLineGroup__c renewalQuoteGroup = new SBQQ__QuoteLineGroup__c(
            CurrencyIsoCode = 'USD',
            Name = 'Group1',
            SBQQ__Account__c = originalContract.AccountId,
            SBQQ__Number__c = 1,
            SBQQ__Quote__c = renewalQuote.Id
        );
        insert renewalQuoteGroup;
        
        SBQQ__QuoteLine__c renewalQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = renewalQuote.Id,
            CurrencyIsoCode  = 'USD',
            SBQQ__Product__c = prod.Id,
            SBQQ__PricebookEntryId__c = pbe.Id,
            SBQQ__ListPrice__c = 100,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__DefaultSubscriptionTerm__c = 12,
            SBQQ__ProductSubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__ChargeType__c = 'Recurring',
            SBQQ__StartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__RenewedSubscription__c = subList[0].Id,
            SBQQ__Group__c = renewalQuoteGroup.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ProrateMultiplier__c = 1,
            SBQQ__OriginalPrice__c = 100,
            Unit_Type__c = 'New / Additional Unit',
            Weeks_Notice__c = '1-4 Weeks',
            SBQQ__SubscriptionBase__c = 'List'
        );
        insert renewalQuoteLine;
        
        DTN_QuoteLinePricingUpdate pricingActionBatchObject = new DTN_QuoteLinePricingUpdate();
        Id pricingActionBatchId = Database.executeBatch(pricingActionBatchObject, 1);
        Test.stopTest();
    }
    
    @IsTest
    static void processRollingContractsPricingUpdateTest2() {
        Test.startTest();
        Contract originalContract = [SELECT Id, Trigger_Rolling__c, StartDate, EndDate, Do_Not_Renew__c, Contract_Type__c, AccountId, SBQQ__RenewalTerm__c, ContractTerm, Rolling_Term_months__c, Legal_Entity__c, Pricebook2Id FROM Contract LIMIT 1];
        originalContract.Contract_Type__c = 'Rolling';
        originalContract.Notice_Period_Months_pick__c = '1 Month';
        originalContract.Rolling_Term_months__c = 12;
        originalContract.ProcessAutoRolling__c = TRUE;
        originalContract.Run_Rolling_Process__c = TRUE;
        DTN_Utilities.setDoNotRunTrigger();
        update originalContract;
        system.debug('---'+originalContract);

        //SIBA-603 -- change trigger rolling to the new calculated end date of 60 days -- joshua.torregoza@dtn.com
        Date calculatedEndDate = Date.today().addYears(-1).addDays(60);

        Boolean triggerRollingFlag = (originalContract.Do_Not_Renew__c == false && originalContract.EndDate == calculatedEndDate);
        
        System.assertNotEquals(null, originalContract.Id);
        System.assertEquals(TRUE, triggerRollingFlag);
        
        Contact primaryContact = [SELECT Id FROM Contact LIMIT 1];
        Product2 prod = [SELECT Id, blng__BillingRule__c, blng__RevenueRecognitionRule__c, blng__TaxRule__c FROM Product2 WHERE Name = 'Test Product'];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE product2Id =: prod.Id and Pricebook2.Name = 'USD CPQ Price Book'];
        List<SBQQ__Subscription__c> subList = [SELECT Id FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c =: originalContract.Id];
        
        DataForPricingUpdate__c dpu = new DataForPricingUpdate__c(
        	Contract_Id__c = originalContract.Id,
            Effective_Date__c = originalContract.EndDate.addDays(1),
            Group_Name__c = 'Group1', 
            New_Price__c = 20,
            Product_Id__c = prod.Id
        );
        insert dpu;
        
        //Opportunity Opp = [SELECT Id, AccountId, Legal_Entity__c, Pricebook2Id FROM Opportunity WHERE Name = 'Rolling Contract Test Opp'];
        Opportunity renewalOpp = new Opportunity(
            Name = 'Renewal Opp',
            StageName = 'Diagnose',
            CloseDate = System.Today(),
            AccountId = originalContract.AccountId,
            Legal_Entity__c = originalContract.Legal_Entity__c,
            Contract_Type__c = 'Rolling',
            Auto_Renewal_Days__c = '30 Days',
            Notice_Period_months__c = 1,
            Initial_Term_months__c = 12,
            Rolling_Term_months__c = 12,
            Pricebook2Id = originalContract.Pricebook2Id,
            Notice_Period_Months_pick__c = '1 Month',
            SBQQ__RenewedContract__c = originalContract.Id
        );
        insert renewalOpp;
        
        SBQQ__Quote__c renewalQuote = new SBQQ__Quote__c(
            SBQQ__SalesRep__c = UserInfo.getUserId(),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Primary__c = true,
            CurrencyIsoCode = 'USD',
            Billing_Type_Pick__c = 'Advance',
            SBQQ__Opportunity2__c = renewalOpp.Id,
            SBQQ__PrimaryContact__c = primaryContact.Id,
            SBQQ__BillingFrequency__c = 'Monthly',
            Billing_Frequency_pick__c = 'Monthly',
            SBQQ__PriceBook__c = originalContract.Pricebook2Id,
            SBQQ__PricebookId__c = originalContract.Pricebook2Id,
            SBQQ__StartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__Type__c = 'Quote',
            Needs_Approval__c = false,
            Ready_for_Execution__c = true,
            SBQQ__ContractingMethod__c = 'Single Contract'
        );
        insert renewalQuote;
        
        SBQQ__QuoteLineGroup__c renewalQuoteGroup = new SBQQ__QuoteLineGroup__c(
            CurrencyIsoCode = 'USD',
            Name = 'Group1',
            SBQQ__Account__c = originalContract.AccountId,
            SBQQ__Number__c = 1,
            SBQQ__Quote__c = renewalQuote.Id
        );
        insert renewalQuoteGroup;
        
        SBQQ__QuoteLine__c renewalQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = renewalQuote.Id,
            CurrencyIsoCode  = 'USD',
            SBQQ__Product__c = prod.Id,
            SBQQ__PricebookEntryId__c = pbe.Id,
            SBQQ__ListPrice__c = 100,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__DefaultSubscriptionTerm__c = 12,
            SBQQ__ProductSubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__ChargeType__c = 'Recurring',
            SBQQ__StartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__RenewedSubscription__c = subList[0].Id,
            SBQQ__Group__c = renewalQuoteGroup.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ProrateMultiplier__c = 1,
            SBQQ__OriginalPrice__c = 100,
            Unit_Type__c = 'New / Additional Unit',
            Weeks_Notice__c = '1-4 Weeks',
            SBQQ__SubscriptionBase__c = 'List',
            SBQQ__NonDiscountable__c = true
        );
        insert renewalQuoteLine;
        
        DTN_QuoteLinePricingUpdate pricingActionBatchObject = new DTN_QuoteLinePricingUpdate();
        Id pricingActionBatchId = Database.executeBatch(pricingActionBatchObject, 1);
        Test.stopTest();
    }
    
    @IsTest
    static void processRollingContractsPricingUpdateTest3() {
        Test.startTest();
        Contract originalContract = [SELECT Id, Trigger_Rolling__c, StartDate, EndDate, Do_Not_Renew__c, Contract_Type__c, AccountId, SBQQ__RenewalTerm__c, ContractTerm, Rolling_Term_months__c, Legal_Entity__c, Pricebook2Id FROM Contract LIMIT 1];
        originalContract.Contract_Type__c = 'Rolling';
        originalContract.Notice_Period_Months_pick__c = '1 Month';
        originalContract.Rolling_Term_months__c = 12;
        originalContract.ProcessAutoRolling__c = TRUE;
        originalContract.Run_Rolling_Process__c = TRUE;
        DTN_Utilities.setDoNotRunTrigger();
        update originalContract;
        system.debug('---'+originalContract);

        //SIBA-603 -- change trigger rolling to the new calculated end date of 60 days -- joshua.torregoza@dtn.com
        Date calculatedEndDate = Date.today().addYears(-1).addDays(60);

        Boolean triggerRollingFlag = (originalContract.Do_Not_Renew__c == false && originalContract.EndDate == calculatedEndDate);
        
        System.assertNotEquals(null, originalContract.Id);
        System.assertEquals(TRUE, triggerRollingFlag);
        
        Contact primaryContact = [SELECT Id FROM Contact LIMIT 1];
        Product2 prod = [SELECT Id, blng__BillingRule__c, blng__RevenueRecognitionRule__c, blng__TaxRule__c FROM Product2 WHERE Name = 'Test Product'];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE product2Id =: prod.Id and Pricebook2.Name = 'USD CPQ Price Book'];
        List<SBQQ__Subscription__c> subList = [SELECT Id FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c =: originalContract.Id];
        
        DataForPricingUpdate__c dpu = new DataForPricingUpdate__c(
        	Contract_Id__c = originalContract.Id,
            Effective_Date__c = originalContract.EndDate.addDays(1),
            Group_Name__c = 'Group2', 
            New_Price__c = 20,
            Product_Id__c = prod.Id
        );
        insert dpu;
        
        //Opportunity Opp = [SELECT Id, AccountId, Legal_Entity__c, Pricebook2Id FROM Opportunity WHERE Name = 'Rolling Contract Test Opp'];
        Opportunity renewalOpp = new Opportunity(
            Name = 'Renewal Opp',
            StageName = 'Diagnose',
            CloseDate = System.Today(),
            AccountId = originalContract.AccountId,
            Legal_Entity__c = originalContract.Legal_Entity__c,
            Contract_Type__c = 'Rolling',
            Auto_Renewal_Days__c = '30 Days',
            Notice_Period_months__c = 1,
            Initial_Term_months__c = 12,
            Rolling_Term_months__c = 12,
            Pricebook2Id = originalContract.Pricebook2Id,
            Notice_Period_Months_pick__c = '1 Month',
            SBQQ__RenewedContract__c = originalContract.Id
        );
        insert renewalOpp;
        
        SBQQ__Quote__c renewalQuote = new SBQQ__Quote__c(
            SBQQ__SalesRep__c = UserInfo.getUserId(),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Primary__c = true,
            CurrencyIsoCode = 'USD',
            Billing_Type_Pick__c = 'Advance',
            SBQQ__Opportunity2__c = renewalOpp.Id,
            SBQQ__PrimaryContact__c = primaryContact.Id,
            SBQQ__BillingFrequency__c = 'Monthly',
            Billing_Frequency_pick__c = 'Monthly',
            SBQQ__PriceBook__c = originalContract.Pricebook2Id,
            SBQQ__PricebookId__c = originalContract.Pricebook2Id,
            SBQQ__StartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__Type__c = 'Quote',
            Needs_Approval__c = false,
            Ready_for_Execution__c = true,
            SBQQ__ContractingMethod__c = 'Single Contract'
        );
        insert renewalQuote;
        
        SBQQ__QuoteLineGroup__c renewalQuoteGroup = new SBQQ__QuoteLineGroup__c(
            CurrencyIsoCode = 'USD',
            Name = 'Group1',
            SBQQ__Account__c = originalContract.AccountId,
            SBQQ__Number__c = 1,
            SBQQ__Quote__c = renewalQuote.Id
        );
        insert renewalQuoteGroup;
        
        SBQQ__QuoteLine__c renewalQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = renewalQuote.Id,
            CurrencyIsoCode  = 'USD',
            SBQQ__Product__c = prod.Id,
            SBQQ__PricebookEntryId__c = pbe.Id,
            SBQQ__ListPrice__c = 100,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__DefaultSubscriptionTerm__c = 12,
            SBQQ__ProductSubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__ChargeType__c = 'Recurring',
            SBQQ__StartDate__c = originalContract.EndDate.addDays(1),
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__RenewedSubscription__c = subList[0].Id,
            SBQQ__Group__c = renewalQuoteGroup.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ProrateMultiplier__c = 1,
            SBQQ__OriginalPrice__c = 100,
            Unit_Type__c = 'New / Additional Unit',
            Weeks_Notice__c = '1-4 Weeks',
            SBQQ__SubscriptionBase__c = 'List'
        );
        insert renewalQuoteLine;
        
        DTN_QuoteLinePricingUpdate pricingActionBatchObject = new DTN_QuoteLinePricingUpdate();
        Id pricingActionBatchId = Database.executeBatch(pricingActionBatchObject, 1);
        Test.stopTest();
    }    
}