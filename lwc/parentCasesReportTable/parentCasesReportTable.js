/**
* FileName          : parentCasesReportTable.js
* Description        : table for parentCasesReport
* Author             : tyrone.luluquisin@dtn.com
* Last Modified By   : tyrone.luluquisin@dtn.com
* Last Modified On   : 01-08-2024
* Modification Log   :
=====================================================================================================================
        JIRA Issue      Date            Editor                          Modification
=====================================================================================================================
*       SIBA-1455       01-08-2024      tyrone.luluquisin@dtn.com       Created parentCasesReportTable
**/
import { LightningElement,api } from 'lwc';

export default class ParentCasesReportTable extends LightningElement {
    @api columns;
    @api tableData;
    @api timeZone;

    //Dispatch an event that the Parent Component will use whenever a column needs to be sorted
    handleSort(event){
        let data = {'isparent': event.target.dataset.parent, 'isdesc': event.target.dataset.order,'value':event.target.value};
        this.dispatchEvent(new CustomEvent('sort', {
            detail: data
          }));
    }
}