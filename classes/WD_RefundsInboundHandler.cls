public class WD_RefundsInboundHandler {
    Public Static void getRefundsFromWorkdayandCreateInSF(String workdayId, DateTime startDateTime , DateTime endDateTime){
       List<blng__Refund__c> refundstoInsert = new List<blng__Refund__c>();
       List<blng__RefundLinePayment__c> refundLineItemsToInsert = new List<blng__RefundLinePayment__c>();
       WD_CustomerRefundsDTO.Customer_Refunds_Outbound wd_refunds = workday_getRefundsforLegalEntity(workdayId,startDateTime,endDateTime);
       for(WD_CustomerRefundsDTO.CustomerRefundEntry entry:wd_refunds.Report_Entries){
           if(entry.Customer_group!= null && entry.Customer_group.hasValidId()){
               
               blng__Refund__c refundreference = new blng__Refund__c(Refund_Reference__c=entry.Customer_Refund_Reference_ID);
               refundstoInsert.add(entry.toRefund());
               for(WD_CustomerRefundsDTO.TransactionsRefunded_Group lineEntry:entry.transactionsRefunded_group){
                   if(lineEntry.Refunded_Customer_Payment != null && null != lineEntry.toPaymentLine()){
                       blng__RefundLinePayment__c refundLine = lineEntry.toPaymentLine();
                       refundLine.blng__Refund__r  = refundreference;
                       refundLine.blng__Type__c = 'Allocation';
                       refundLine.blng__RefundLineDate__c = entry.Refund_Date;
                       System.debug('Customer refund:'+ refundLine);
                       refundLineItemsToInsert.add(refundLine);
                  }
               }                

           }
       }
       //SObject[] allrecords = new List<SObject>{};
       //allrecords.addAll(refundstoInsert);
       //allrecords.addAll(refundLineItemsToInsert);
       List<Database.UpsertResult> results = DataBase.upsert(refundstoInsert,blng__Refund__c.Fields.Refund_Reference__c,false);
       results.addAll(DataBase.upsert(refundLineItemsToInsert,false));
       List<Error_Log__c> errorLogs = new List<Error_Log__c>();
       // Check results.// TODO:store them in error logs
       for (Integer i = 0; i < results.size(); i++) {
           if (results[i].isSuccess()) {
           System.debug('Successfully created ID: '
                 + results[i].getId());
           } else {
               errorLogs.add(new Error_Log__c(Class_Name__c='WD_RefundsInboundHandler',
                                              Method_Name__c='getRefundsFromWorkdayandCreateInSF',
                                             Exception_Message__c=results[i].getErrors()[0].getMessage()));
           System.debug('Error: could not create sobject '
                 + 'for array element ' + i + '.');
           System.debug('   The error reported was: '
                 + results[i].getErrors()[0].getMessage() + '\n');
           }
       }
       if(errorLogs.size() > 0){
           DataBase.insert(errorLogs, false);
       }
       
   }
   
   Public Static WD_CustomerRefundsDTO.Customer_Refunds_Outbound workday_getRefundsforLegalEntity(String workdayId, DateTime startDateTime , DateTime endDateTime){

       String URL=DTN_Utilities.getWDIntegrationMetadataRecord('WD_Refunds_Report').WD_Key_Value__c+
                                   workdayId+'&Last_Updated_From='+WD_Utilities.toGregorianFormatGMT(startDateTime)+
                                   '&Last_Updated_To='+WD_Utilities.toGregorianFormatGMT(endDateTime);
       HTTPRequest request = new HTTPRequest();
       request.setHeader('Authorization', WD_Utilities.getWDBasicAuthHeader());
       request.setMethod('GET');
       request.setEndpoint(URL);
       Http http = new Http();
       HttpResponse response= http.send(request);
       System.debug('StatusCode : '+response.getStatusCode());
       if(response.getStatusCode() == 200){
           Dom.Document responseDoc = New Dom.Document();
           responseDoc.load(response.getBody());
           Dom.XmlNode rootNode = responseDoc.getRootElement();
           WD_CustomerRefundsDTO.Customer_Refunds_Outbound reader = new WD_CustomerRefundsDTO.Customer_Refunds_Outbound(rootNode);
           System.debug(JSON.serialize(reader));
           return reader;
       }
       return null;
       
   }
}