/**
* @File Name          : DTN_CreateRenewalQuotesForRC.cls
* @Description        : 
* @Author             : unknown
* @Last Modified By   : joshua.torregoza@dtn.com
* @Last Modified On   : 26-9-2023
* @Modification Log   :
=====================================================================================================================
           JIRA Issue        		Date       	 Editor      					Modification
=====================================================================================================================
*   	   SIBA-527               13-7-2023    	aaronjeremy.santos@dtn.com     rollingContractsQuery
*          SIBA-603              25-07-2023     joshua.torregoza@dtn.com       rollingContractsQuery and the condition for EOL/EOS products
*          SIBA-1566             26-07-2023     joshua.torregoza@dtn.com       set run rolling process to false in catch
**/
global class DTN_CreateRenewalQuotesForRC implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    global List<Id> originalContractIds;
    //global List<Id> endOfSaleOppIds;
    
    global DTN_CreateRenewalQuotesForRC() {
        originalContractIds = new List<Id>();
        //endOfSaleOppIds = new List<Id>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {

        Rolling_Contracts_Setting__mdt rollingContractsSetting = LightningUtilities.RollingContractSetting;
        // collect the batches of records or objects to be passed to execute
        String rollingValue = 'Rolling';
        String cancelledStatus = 'Cancelled';
        Date calculatedEndDate = Date.today().addDays(Integer.valueof(rollingContractsSetting.Renewal_Quote_Date__c));
        String rollingContractsQuery = 'SELECT Id, Name, SBQQ__RenewalQuoted__c, Rolling_Term_months__c, Trigger_Rolling__c, Do_Not_Renew__c, EndDate, SBQQ__Opportunity__c, Run_Rolling_Process__c, ProcessAutoRolling__c, '+
            ' SBQQ__RenewalOpportunity__c, SBQQ__RenewalOpportunity__r.OwnerId, ' +
            ' (SELECT Id, SBQQ__Quantity__c, SBQQ__Product__c, SBQQ__Product__r.Product_Lifecycle__c, SBQQ__Product__r.SBQQ__RenewalProduct__c FROM SBQQ__Subscriptions__r), '+
            ' (SELECT Id, SBQQ__PrimaryQuote__c FROM SBQQ__RenewalOpportunities__r), '+
            ' (SELECT Id, StageName, IsClosed FROM SBQQ__AmendmentOpportunities__r) '+
            ' FROM Contract WHERE (((Do_Not_Renew__c = FALSE AND EndDate =: calculatedEndDate) AND SBQQ__Opportunity__r.Contract_Type__c =: rollingValue AND Current_Status__c !=: cancelledStatus) '+
            ' OR (Run_Rolling_Process__c = TRUE)) ';
        System.debug('debug: '+rollingContractsQuery);
        System.debug('debug: '+calculatedEndDate);
        return Database.getQueryLocator(rollingContractsQuery);
        
   }
    global void execute(Database.BatchableContext bc, List<Contract> contracts) {
        try {
            // process each batch of records
            List<SBQQ__Quote__c> renewalQuotes = new List<SBQQ__Quote__c>();
            List<Opportunity> amendmentOppToCloseLost = new List<Opportunity>();
            for(Contract c: contracts) {
                Boolean hasRenewalQuoted = false;
                Boolean hasOpenAmmendmentOpp = false;
                Boolean hasRetiredProduct = false;
                Double sumOfSubscriptions = 0;
                
                Rolling_Contracts_Setting__mdt metadataSetting = [SELECT Id, MasterLabel, RetiredProductsDateCheck__c FROM Rolling_Contracts_Setting__mdt WHERE MasterLabel = 'Rolling Contract Batch' LIMIT 1];
                Date dateToCheckRetiredProducts = metadataSetting.RetiredProductsDateCheck__c;
                for(Opportunity renewalOpp: c.SBQQ__RenewalOpportunities__r) {
                    if(renewalOpp.SBQQ__PrimaryQuote__c != null) {
                        hasRenewalQuoted = true;
                    }
                }
                for(Opportunity ammendmentOpp: c.SBQQ__AmendmentOpportunities__r) {
                    if(!ammendmentOpp.IsClosed) {
                        //hasOpenAmmendmentOpp = true;
                        ammendmentOpp.StageName = 'Closed Lost';
                        ammendmentOpp.StageName = 'Closed Lost';
                        ammendmentOpp.Loss_Reason__c = 'Pricing Update Action';
                        amendmentOppToCloseLost.add(ammendmentOpp);
                    }
                }
                for(SBQQ__Subscription__c sub: c.SBQQ__Subscriptions__r) {
                    //SIBA-603 => updated the condition for EOS/EOL product -- joshua.torregoza@dtn.com
                    // do not check for retired products for contracts with enddate less than aug 31, 2023
                    if(c.EndDate > dateToCheckRetiredProducts && (sub.SBQQ__Product__r.Product_Lifecycle__c == 'End Of Sale' || sub.SBQQ__Product__r.Product_Lifecycle__c == 'End Of Life')) {
                        if(sub.SBQQ__Product__r.SBQQ__RenewalProduct__c == null){
                            hasRetiredProduct = true;
                            System.debug('has retired product -- ' +hasRetiredProduct);
                        }
                        else if(sub.SBQQ__Product__r.SBQQ__RenewalProduct__c != null){
                            sub.SBQQ__Product__c = sub.SBQQ__Product__r.SBQQ__RenewalProduct__c;
                            System.debug('has renewal product -- ' +sub.SBQQ__Product__c);
                        }                       
                    }
                    //SIBA-603 => end of code changes
                   sumOfSubscriptions = sumOfSubscriptions + sub.SBQQ__Quantity__c;
                }
                if(sumOfSubscriptions == 0) {
                    c.Renewal_Failure_Reason__c = 'All Subscriptions are canceled';
                    c.Run_Rolling_Process__c = FALSE;
                }
                if(hasRetiredProduct == true) {
                    c.Renewal_Failure_Reason__c = 'Has Retired Products';
                    if(c.SBQQ__RenewalOpportunity__c != null) {
                        //endOfSaleOppIds.add(c.SBQQ__RenewalOpportunity__c);
                        DTN_Utilities.createChatterPost(c.SBQQ__RenewalOpportunity__r.OwnerId, c.SBQQ__RenewalOpportunity__c, 'Renewal Quote cannot be created because there are one or more retired products.');
                        c.Run_Rolling_Process__c = FALSE;
                    }
                } else if(hasOpenAmmendmentOpp == true) {
                    c.Renewal_Failure_Reason__c = 'Has Open Amendment';
                    c.Run_Rolling_Process__c = FALSE;
                } else if(hasRenewalQuoted == true) {
                    c.Renewal_Failure_Reason__c = 'Has a Renewal Quote InProgress ';
                    c.Run_Rolling_Process__c = FALSE;
                } else {
                    c.Renewal_Failure_Reason__c = '';
                    c.SBQQ__RenewalQuoted__c = true;
                    c.ProcessAutoRolling__c = true;
                    originalContractIds.add(c.Id);
                }
            }
            if(amendmentOppToCloseLost.size() > 0) {
                DTN_Utilities.setDoNotRunTrigger();
                update amendmentOppToCloseLost;
            }
            
            //update contracts
            update contracts;
            
            /*Set<Id> quoteIds = new Set<Id>();
            for(Contract c: contracts){
                quoteIds.add(c.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.Id);
            }
			System.debug('List of renewal quote Id\'s: '+quoteIds);*/
            
        } catch (Exception ex) {
            DTN_Utilities.LogException(ex, contracts[0].Id);
            
            CatchUtils.renewErrorAction(contracts[0].Id);      
        }
    }
    global void finish(Database.BatchableContext bc) {
        // update the trigger rolling field on quote
        System.debug('---finish---'+originalContractIds);
        //call next batch to activate quotes
        List<Rolling_Contracts_Setting__mdt> metadataSetting = [SELECT Id, MasterLabel, Schedule_Wait_Time__c FROM Rolling_Contracts_Setting__mdt 
                                                                WHERE MasterLabel = 'Rolling Contract Batch' LIMIT 1];
        if(metadataSetting.size() > 0) {
            System.scheduleBatch(new DTN_ActivateRenewalQuotesForRC(), 'Manage Pricing of Renewal Quotes for Rolling Contracts', Integer.valueOf(metadataSetting[0].Schedule_Wait_Time__c), 1);
        }
    }
}