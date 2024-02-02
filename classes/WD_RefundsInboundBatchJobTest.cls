/**
* @File Name          : WD_PaymentsInboundBatchJobTest.cls
* @Description        : Test class for WD_RefundsInboundBatchJobTest
* @Author             : aaronjeremy.santos@dtn.com
* @Last Modified By   : aaronjeremy.santos@dtn.com
* @Last Modified On   : Nov/09/2023
* @Modification Log   :
**/
@isTest
public class WD_RefundsInboundBatchJobTest {
    static testMethod void TestMethod1(){
        String Query = 'SELECT id,WorkdayId__c FROM blng__LegalEntity__c WHERE WorkdayId__c != null AND blng__Active__c=true';
            System.debug('>>>>hi query hehe<<<<'+Query);
        Test.startTest();
        WD_RefundsInboundBatchJob obj = new WD_RefundsInboundBatchJob(Query);
        Database.executeBatch(obj);
        Test.stopTest();
    }
    static testMethod void TestMethod2(){
        DateTime time_now = System.now();
    	DateTime endTime = DateTime.newInstanceGmt(time_now.yearGmt(), time_now.monthGmt(), time_now.dayGmt(), time_now.hourGmt(),00,00);
    	DateTime startTime = endTime.addHours(-1);
        Test.startTest();
        WD_RefundsInboundBatchJob obj = new WD_RefundsInboundBatchJob(startTime, endTime);
        Database.executeBatch(obj);
        Test.stopTest();
    }
    static testMethod void TestMethod3(){
        String Query = 'SELECT id,WorkdayId__c FROM blng__LegalEntity__c WHERE WorkdayId__c != null AND blng__Active__c=true';
            System.debug('>>>>hi query hehe<<<<'+Query);
        DateTime time_now = System.now();
    	DateTime endTime = DateTime.newInstanceGmt(time_now.yearGmt(), time_now.monthGmt(), time_now.dayGmt(), time_now.hourGmt(),00,00);
    	DateTime startTime = endTime.addHours(-1);
        Test.startTest();
        WD_RefundsInboundBatchJob obj = new WD_RefundsInboundBatchJob(Query,startTime, endTime);
        Database.executeBatch(obj);
        Test.stopTest();
    }
    static testMethod void testschedule() {
		Test.StartTest();
        WD_RefundsInboundBatchJob sh1 = new WD_RefundsInboundBatchJob();
		String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest(); 
    }
}