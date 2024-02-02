/**
* @File Name          : DTN_ParentCasesReportTest.cls
* @Description        : Test Class for DTN_ParentCasesReport
* @Author             : tyrone.luluquisin@dtn.com
* @Last Modified By   : tyrone.luluquisin@dtn.com
* @Last Modified On   : 01-08-2024
* @Modification Log   :
=====================================================================================================================
        JIRA Issue      Date            Editor                          Modification
=====================================================================================================================
*       SIBA-1455       01-08-2024      tyrone.luluquisin@dtn.com       Created as Test Classe for DTN_ParentCasesReport
**/
@isTest
public with sharing class DTN_ParentCasesReportTest {
    @TestSetup
    static void testSetup() {
        Account testAccount = new Account(
            Name = 'Test Account 1',
            BillingCountry = 'United States');
        insert testAccount;
        Opportunity testOpportunity = new Opportunity( Name = 'Test Opportunity',
                                                     StageName = 'Business Analysis/Assessment',
                                                     CloseDate = system.today(),
                                                     AccountId = testAccount.Id
        );
        insert testOpportunity;
        Case parentCase = new Case(Subject = 'Test Parent Case', Status = 'New');
        insert parentCase;
        CaseComment parentCaseComment = new CaseComment(CommentBody = 'Test',ParentId = parentCase.id);
        insert parentCaseComment;
        Case childCase = new Case(Subject = 'Test Parent Case', Status = 'New', ParentId = parentCase.id, AccountId = testAccount.id);
        insert childCase;
    }
    @isTest 
    static void testController() {
        String lwcDate = System.now().format('yyyy-MM-dd');
        DTN_ParentCasesReport.getParentCases(lwcDate, lwcDate,'',10,1);
    }
}