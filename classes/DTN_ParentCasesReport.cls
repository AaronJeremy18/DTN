/**
* @File Name          : DTN_ParentCasesReport.cls
* @Description        : Controller for parentCaseReport
* @Author             : tyrone.luluquisin@dtn.com
* @Last Modified By   : tyrone.luluquisin@dtn.com
* @Last Modified On   : 01-10-2024
* @Modification Log   :
=====================================================================================================================
        JIRA Issue      Date            Editor                          Modification
=====================================================================================================================
*       SIBA-1455       01-08-2024      tyrone.luluquisin@dtn.com       Created as Controller for parentCaseReport
*       SIBA-1455       01-10-2024      tyrone.luluquisin@dtn.com       Updated to handle pagination
**/
public class DTN_ParentCasesReport {
    
    //It will be use to by the LWC to get the data using a custom wrapper. 
    //Cacheable is set to false so that it always get the lastest data.
    //pageSize and pageData is the range to search for pagination
    @AuraEnabled(cacheable=false)
    public static DTN_ReportWrappers.ParentCaseData getParentCases(String startDate, String endDate, String searchData, Integer pageSize, Integer pageNumber) {

        //Converts that data from format 'yyyy-MM-dd' that lightning-input uses to the standard DateTime that Apex uses
        List<String> starting = startDate.split(DTN_Constants.DTN_DASH);
        List<String> ending = endDate.split(DTN_Constants.DTN_DASH);
        Datetime startingDate = DateTime.newInstance(Integer.valueOf(starting[0]),Integer.valueOf(starting[1]),Integer.valueOf(starting[2]),0,0,0);
        Datetime endingDate = DateTime.newInstance(Integer.valueOf(ending[0]),Integer.valueOf(ending[1]),Integer.valueOf(ending[2]),23,59,59);

        List<Id> caseIDs = new List<Id>();
        List<Id> accountIds = new List<Id>();
        List<DTN_ReportWrappers.ChildCaseWrapper> ccwList =  new List<DTN_ReportWrappers.ChildCaseWrapper>();
        List<DTN_ReportWrappers.ParentCaseWrapper> data = new List<DTN_ReportWrappers.ParentCaseWrapper>();
        DTN_ReportWrappers.ParentCaseData result = new DTN_ReportWrappers.ParentCaseData();
        result.timeZone = UserInfo.getTimeZone().getID();
        result.isLast = false;
        Integer offset = pageSize * (pageNumber-1);
        
        String searchDataFormat = DTN_Constants.DTN_PERCENT+ (String.isBlank(searchData)?DTN_Constants.DTN_BLANK:searchData) +DTN_Constants.DTN_PERCENT;
        //Gets all that Ids for all the Parent Cases to be used for Query using the Parent Cases, starting, ending, and searchData. 
        for(AggregateResult c:[SELECT ParentId from Case WHERE ParentId!=null AND (Parent.CreatedDate >= :startingDate AND Parent.CreatedDate <= :endingDate ) AND Parent.CaseNumber  LIKE :searchDataFormat  GROUP BY ParentId LIMIT :pageSize OFFSET :offset]){
            caseIDs.add((String)c.get(DTN_Constants.DTN_AGGREGATEPARENTID));
        }

        //Gets all the needed Cases to be used by the LWC 
        for(Case c: [SELECT Id,CaseNumber, CreatedDate,(SELECT CommentBody FROM CaseComments),(SELECT ID,CaseNumber,AccountId, Account.Name, CreatedDate, LastModifiedDate,Subject,DTN_Age__c,IsClosed FROM Cases)FROM Case WHERE Id IN :caseIDs]){
                DTN_ReportWrappers.ParentCaseWrapper wrw = new DTN_ReportWrappers.ParentCaseWrapper();
                wrw.id = c.Id; 
                wrw.url = Url.getOrgDomainUrl().toExternalForm()+DTN_Constants.DTN_LIGHTNINGCASEURL+c.Id+DTN_Constants.DTN_LIGHTNINGVIEWURL;
                wrw.caseNumber = c.CaseNumber;
                wrw.caseComments = c.CaseComments;
                wrw.createdDate = c.CreatedDate;
                List<DTN_ReportWrappers.ChildCaseWrapper> ccws = new List<DTN_ReportWrappers.ChildCaseWrapper>();
                for(Case childCases: c.Cases){
                    DTN_ReportWrappers.ChildCaseWrapper ccw = new DTN_ReportWrappers.ChildCaseWrapper();
                    ccw.id = childCases.Id;
                    ccw.url = Url.getOrgDomainUrl().toExternalForm()+DTN_Constants.DTN_LIGHTNINGCASEURL+childCases.Id+DTN_Constants.DTN_LIGHTNINGVIEWURL;
                    ccw.caseNumber = childCases.CaseNumber;
                    ccw.accountId = childCases.AccountId;
                    ccw.accountUrl = Url.getOrgDomainUrl().toExternalForm()+DTN_Constants.DTN_LIGHTNINGACCOUNTURL+childCases.AccountId+DTN_Constants.DTN_LIGHTNINGVIEWURL;
                    ccw.accountName = childCases.Account.Name;
                    ccw.createdDate = childCases.CreatedDate;
                    ccw.lastModifiedDate = childCases.LastModifiedDate;
                    ccw.subject = childCases.Subject;
                    //Calculates Age the same way as they do in the Reports, it is calculated as the number of hours since the CreatedDate.
                    Long dt1 = childCases.CreatedDate.getTime();
                    Long dt2 = DateTime.now().getTime();
                    Long milliseconds = dt2 - dt1;
                    ccw.age = Math.floor(milliseconds/3600000).intValue();
    
                    ccw.dtnAge = childCases.DTN_Age__c.intValue();
                    ccw.closed = childCases.IsClosed;
                    ccw.open = !childCases.IsClosed;
                    ccws.add(ccw);
                    ccwList.add(ccw);
                    accountIds.add(childCases.AccountId);
                }
                if(!ccws.isEmpty()){
                    wrw.childCases = ccws;
                }
                data.add(wrw);
        }

        //Counts the total count from the query
        List<AggregateResult> distinctCount = [SELECT COUNT_DISTINCT(ParentId) FROM Case WHERE ParentId!=null AND (Parent.CreatedDate >= :startingDate AND Parent.CreatedDate <= :endingDate ) AND Parent.CaseNumber  LIKE :searchDataFormat];
        result.totalCount =(Integer)(distinctCount[0].get(DTN_Constants.DTN_AGGREGATEEXPR0)); 
        if(offset+pageSize >= result.totalCount){
            result.isLast = true;
        }

        //Gets the sum of all the Amount of the Opportunities in each Account
        for(AggregateResult ar: [select AccountId, CurrencyIsoCode, SUM(Amount) from Opportunity where AccountId in :accountIds Group By AccountId,CurrencyIsoCode]){
            for(DTN_ReportWrappers.ChildCaseWrapper c :ccwList)
            {
                if(c.accountId == ar.get(DTN_Constants.DTN_AGGREGATEACCOUNTID)){
                    c.currencyIsoCode = (String)ar.get(DTN_Constants.DTN_AGGREGATECURRENCYISO);
                    c.totalContractValue = (Decimal)ar.get(DTN_Constants.DTN_AGGREGATEEXPR0);
                    continue;
                }
            }
        }
        result.data = data;
        return result;
    }
    
}