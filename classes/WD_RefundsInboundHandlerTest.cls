/**
* @File Name          : WD_RefundsInboundHandlerTest.cls
* @Description        : Test class for WD_RefundsInboundHandler
* @Author             : allendale.francisco@dtn.com
* @Last Modified By   : allendale.francisco@dtn.com
* @Last Modified On   : 03-11-2023
* @Modification Log   :
=====================================================================================================================
           JIRA Issue        		Date       	 Editor      					Modification
=====================================================================================================================
*   	   SIBA-2044              03-11-2023    allendale.francisco@dtn.com     Created and updated test class
**/
@isTest
global class WD_RefundsInboundHandlerTest implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        
        String header = '<soap:Report_Data xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
        String body = '<soap:Body><CustomerRefund>CUSTREFUND</CustomerRefund><Customer_group><Customer_Reference_ID>01t3m00000QxkdGAAR</Customer_Reference_ID><Customer_ID>123</Customer_ID></Customer_group><Payment_Date>2023-10-10-</Payment_Date><Refund_Date>2023-10-10-</Refund_Date><Open_Amount>12.2</Open_Amount><customerRefundPayment_group>TESTGROUP</customerRefundPayment_group>';
       	String body2 = '<Payment_Method>PAYMENT METHOD</Payment_Method><Customer_Refund_Reference_ID>123</Customer_Refund_Reference_ID><Transactions_Refunded>YES</Transactions_Refunded>';
        String transactionRefGroup = '<transactionsRefunded_group><Refunded_Customer_Invoice>REFCUSIN</Refunded_Customer_Invoice><Refunded_Customer_Payment><IDList>01t3m00000QxkdGAAR</IDList></Refunded_Customer_Payment><Invoice_Number>123</Invoice_Number>';
        String transcationRefGroup2= '<CF_LRV_-_Amount_Due_on_Customer_Invoice_Adjustment>AMOUNTDUE</CF_LRV_-_Amount_Due_on_Customer_Invoice_Adjustment><CF_LRV_Refunded_Customer_Payment_Transaction_Amount>CUSPAY</CF_LRV_Refunded_Customer_Payment_Transaction_Amount><CF_LRV_Refunded_Customer_Payment_Number>CUSPAY</CF_LRV_Refunded_Customer_Payment_Number><CF_LRV_Customer_Invoice_Reference_ID>ID</CF_LRV_Customer_Invoice_Reference_ID></transactionsRefunded_group></soap:Body>';
        String endTag = '</soap:Report_Data>';
        String soapData = header + body + body2 + transactionRefGroup + transcationRefGroup2 + endTag;
  	
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(soapData);
        response.setStatusCode(200);
        return response; 
    }
    
    static testMethod void runTest(){
       
        Test.setMock(HttpCalloutMock.class, new WD_RefundsInboundHandlerTest()); 
        DateTime time_now = System.now();
    	DateTime endTime = DateTime.newInstanceGmt(time_now.yearGmt(), time_now.monthGmt(), time_now.dayGmt(), time_now.hourGmt(),00,00);
    	DateTime startTime = endTime.addHours(-1);
        Test.startTest();
        WD_RefundsInboundHandler.getRefundsFromWorkdayandCreateInSF('123',startTime,endTime);
        Test.stopTest();
    }
}