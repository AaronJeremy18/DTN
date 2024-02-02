/**
* @File Name          : DTN_ActivateRenewalQuotesForRC.cls
* @Description        : 
* @Author             : unknown
* @Last Modified By   : aaronjeremy.santos@dtn.com
* @Last Modified On   : 26-09-2023
* @Modification Log   :
=====================================================================================================================
           JIRA Issue        		Date       	 Editor      					Modification
=====================================================================================================================
*   	   SIBA-529               17-08-2023    aaronjeremy.santos@dtn.com     renewalQuotesQuery, Renewal contract price update
*          SIBA-1566             26-07-2023     joshua.torregoza@dtn.com       set run rolling process to false in catch
**/
global with sharing class DTN_ActivateRenewalQuotesForRC implements Database.Batchable < SObject > , Database.Stateful {
    global List <Id> renewalQuoteIds;
    //global List<Id> renewalOppIds;

    global DTN_ActivateRenewalQuotesForRC() {
        renewalQuoteIds = new List<Id> ();
        //renewalOppIds = new List<Id>();
    }

    public Map<String, SBQQ__QuoteLine__c> quoteLineMap = new Map <String, SBQQ__QuoteLine__c>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Rolling_Contracts_Setting__mdt rollingContractsSetting = LightningUtilities.RollingContractSetting;
        Date calculatedEndDate = Date.today().addDays(Integer.valueof(rollingContractsSetting.Renewal_Quote_Date__c));
        
        // collect the batches of records or objects to be passed to execute
        String renewalQuotesQuery = 'SELECT Id, SBQQ__Status__c, ApprovalStatus__c, SBQQ__Ordered__c, SBQQ__Opportunity2__c, Needs_Approval__c, ' +
            'SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.SBQQ__Opportunity__r.Rolling_Term_months__c, ' +
            'SBQQ__Opportunity2__r.Rolling_Term_months__c, SBQQ__Account__r.OwnerId , SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Rolling_Term_months__c, SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Run_Rolling_Process__c, SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.ProcessAutoRolling__c ' +
            'FROM SBQQ__Quote__c ' +
            'WHERE (SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate =: calculatedEndDate AND SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.ProcessAutoRolling__c = TRUE ) ' +
            'OR (SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Run_Rolling_Process__c = TRUE) ';
        System.debug('debug: '+renewalQuotesQuery);
        return Database.getQueryLocator(renewalQuotesQuery);
    }
    global void execute(Database.BatchableContext bc, List<SBQQ__Quote__c> renewalQuotes) {
        try {
            // process each batch of records
            // set rolling term on opp
            List <sObject> sObjectUpdateList = new List<sObject>();
            //List <sObject> eachOfTheSobjectUpdateList = new List<sObject>();
            List <Opportunity> renewalOpps = new List <Opportunity> ();
            for (SBQQ__Quote__c q: renewalQuotes) {
                Opportunity opp = new Opportunity(Id = q.SBQQ__Opportunity2__c);
                opp.Rolling_Term_months__c = q.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.SBQQ__Opportunity__r.Rolling_Term_months__c;
                system.debug('---term 1--' + q.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.SBQQ__Opportunity__r.Rolling_Term_months__c);
                renewalOpps.add(opp);
                System.debug('--opp--' + opp);
                sObjectUpdateList.addAll(renewalOpps);
            }
            update renewalOpps;
            System.debug('--renewalOpps--' + renewalOpps);

            // activate renewal quote
            for (SBQQ__Quote__c q: renewalQuotes) {
                q.Needs_Approval__c = false;
                q.Ready_for_Execution__c = true;
                q.SBQQ__SubscriptionTerm__c = q.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.SBQQ__Opportunity__r.Rolling_Term_months__c;
                //q.OwnerId = q.SBQQ__Account__r.OwnerId;
                System.debug('--term 2--' + q.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.SBQQ__Opportunity__r.Rolling_Term_months__c);
                renewalQuoteIds.add(q.Id);
                sObjectUpdateList.addAll(renewalQuotes);
            }            
                        
            //create orders
            update renewalQuotes;
            //update sObjectUpdateList;
            System.debug('--renewalQuotes--' + renewalQuotes);
        } catch (Exception ex) {
            DTN_Utilities.LogException(ex, renewalQuotes[0].Id);

            //siba-1566 - do not process if there is issue -- joshua.torregoza            
			CatchUtils.renewErrorAction(renewalQuotes[0].SBQQ__Opportunity2__r.SBQQ__RenewedContract__c);
            //siba-1566 - end
        }
    }
    global void finish(Database.BatchableContext bc) {
        // update the trigger rolling field on quote
        System.debug('---finish actvating quotes --- renewalQuoteIds ---' + renewalQuoteIds);
        List < Rolling_Contracts_Setting__mdt > metadataSetting = [SELECT Id, MasterLabel, Schedule_Wait_Time__c FROM Rolling_Contracts_Setting__mdt
            WHERE MasterLabel = 'Rolling Contract Batch'
            LIMIT 1
        ];


        if (metadataSetting.size() > 0) {
            System.scheduleBatch(new DTN_QuoteLinePricingUpdate(), 'update prices for quotelines for Rolling Contracts', Integer.valueOf(metadataSetting[0].Schedule_Wait_Time__c), 1);
        }
    }
}