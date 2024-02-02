/*Schedule apex to get payments hourly fromworkday and insert into salesforce.
 * System.schedule('WD Payments Schedule', '0 0 * * * ?', new WD_RefundsInboundBatchJob() );
*/
public class WD_RefundsInboundBatchJob implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable {
    String Query;
    DateTime startTime;
    DateTime endTime;
    public WD_RefundsInboundBatchJob(){
        this.Query='SELECT id,Name,WorkdayId__c FROM blng__LegalEntity__c WHERE WorkdayId__c != null AND blng__Active__c=true';
        DateTime time_now= System.now();
        this.endTime=Datetime.newInstanceGmt(time_now.yearGmt(), time_now.monthGmt(), time_now.dayGmt(), time_now.hourGmt(), 00, 00) ;
        this.startTime = endTime.addHours(-1);
    }
    public WD_RefundsInboundBatchJob(String query){
        this();
        if(String.isNotBlank(query)){
            this.Query=query;
        }
        
    }
    public WD_RefundsInboundBatchJob(DateTime startTime,DateTime endTime){
        this();
        Assert.isNotNull(startTime, 'start time cannot be null.');
        Assert.isNotNull(endTime, 'end time cannot be null.');
        if(null != startTime && null != endTime){
            this.startTime=startTime;
            this.endTime=endTime;
        }
       
    }
    public WD_RefundsInboundBatchJob(String query, DateTime startTime,DateTime endTime){
        this(query);
        Assert.isNotNull(startTime, 'start time cannot be null.');
        Assert.isNotNull(endTime, 'end time cannot be null.');
        if(null != startTime && null != endTime){
            this.startTime=startTime;
            this.endTime=endTime;
        }
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        for(sobject s : scope){
            WD_RefundsInboundHandler.getRefundsFromWorkdayandCreateInSF((String)s.get('WorkdayId__c'),this.startTime,this.endTime);
        }
    }
    public void finish(Database.BatchableContext BC){
        
    }

    public void execute(SchedulableContext sc) {
		WD_RefundsInboundBatchJob b = new WD_RefundsInboundBatchJob(); 
      	Database.executeBatch(b,1);
	}
}