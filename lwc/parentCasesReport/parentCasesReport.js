/**
* FileName          : parentCasesReport.js
* Description        : LWC component for ParentCasesReport
* Author             : tyrone.luluquisin@dtn.com
* Last Modified By   : tyrone.luluquisin@dtn.com
* Last Modified On   : 01-08-2024
* Modification Log   :
=====================================================================================================================
        JIRA Issue      Date            Editor                          Modification
=====================================================================================================================
*       SIBA-1455       01-08-2024      tyrone.luluquisin@dtn.com       Created parentCasesReport
*       SIBA-1455       01-10-2024      tyrone.luluquisin@dtn.com       Updated Pagination
**/
import { LightningElement, api, wire, track } from 'lwc';
import getParentCases from '@salesforce/apex/DTN_ParentCasesReport.getParentCases';
const menuVariant = { 'Filter': 'neutral', 'Search': 'neutral' };
var columns = [
    { 'label': 'Parent Case', 'isParent': 'true', 'value': 'caseNumber', 'iconName': 'utility:arrowup', 'iconClass': 'slds-hidden' },
    { 'label': 'Parent Case Comments', 'isParent': 'true' },
    { 'label': 'Parent Date/Time Opened', 'isParent': 'true', 'value': 'createdDate', 'iconName': 'utility:arrowup', 'iconClass': 'slds-hidden' },
    { 'label': 'Child Cases', 'isParent': 'false', 'value': 'caseNumber', 'iconName': 'utility:arrowup', 'iconClass': 'slds-hidden' },
    { 'label': 'Date/Time Opened', 'isParent': 'false', 'value': 'createdDate', 'iconName': 'utility:arrowup', 'iconClass': 'slds-hidden' },
    { 'label': 'Case Date/Time Last Modified Date', 'isParent': 'false', 'value': 'lastModifiedDate', 'iconName': 'utility:arrowup', 'iconClass': 'slds-hidden' },
    { 'label': 'Subject', 'isParent': 'false', 'value': 'subject', 'iconName': 'utility:arrowup', 'iconClass': 'slds-hidden' },
    { 'label': 'Age', 'isParent': 'false', 'value': 'age', 'iconName': 'utility:arrowup', 'iconClass': 'slds-hidden' },
    { 'label': 'DTN Age', 'isParent': 'false', 'value': 'dtnAge', 'iconName': 'utility:arrowup', 'iconClass': 'slds-hidden' },
    { 'label': 'Open', 'isParent': 'false', 'value': 'open', 'iconName': 'utility:arrowup', 'iconClass': 'slds-hidden' },
    { 'label': 'Close', 'isParent': 'false', 'value': 'closed', 'iconName': 'utility:arrowup', 'iconClass': 'slds-hidden' },
    { 'label': 'Account Name', 'isParent': 'false', 'value': 'accountName', 'iconName': 'utility:arrowup', 'iconClass': 'slds-hidden' },
    { 'label': 'Total Contract Value', 'isParent': 'false', 'value': 'totalContractValue', 'iconName': 'utility:arrowup', 'iconClass': 'slds-hidden' },
];

//The main component for the Parent Report Cases
export default class ParentCasesReport extends LightningElement {

    @api caseResult;
    @track from = '';
    @track to = '';
    @track searchData = '';
    @track isLoading;
    @track caseData;
    @track timeZone = 'UTC';
    @track pageSize;
    @track pageNumber;
    @track isLast = true;
    @track isFirst = true;
    @track totalCount;
    @track lastPageNumber;
    @track menuVariant = menuVariant;
    @track columns = columns;
    @track adjustHeight = 'height: 335px;';

    //As soon as the page loads it calculates the from and to dates and retrieving the Parent Cases
    connectedCallback() {
        var date = new Date();
        this.to = date.getFullYear() + "-" + String(date.getMonth() + 1).padStart(2, '0') + "-" + String(date.getDate()).padStart(2, '0');
        this.from = date.getFullYear() + "-" + String(date.getMonth() + 1).padStart(2, '0') + "-01";
        this.pageSize = 10;
        this.pageNumber = 1;
        this.searchData = '';
        this.getParentCaseReport();

        //Calculates the size of the table every time the window is resized
        this.calculateHeight();
        window.addEventListener('resize', this.onResize);
    }
    onResize = () => {
        this.calculateHeight();
    }

    //Gets the Parent cases to be displayed in the table.
    getParentCaseReport() {
        this.isLoading = true;
        getParentCases({ startDate: this.from, endDate: this.to, searchData: this.searchData, pageSize: this.pageSize,pageNumber: this.pageNumber }).then((caseResult) => {
            console.log("CasesReport: " + JSON.stringify(caseResult));
            this.caseResult = caseResult.data;
            this.caseData = caseResult.data;
            this.timeZone = caseResult.timeZone;
            this.totalCount = caseResult.totalCount;
            this.lastPageNumber = this.totalCount%this.pageSize<=0?this.totalCount/this.pageSize:Math.floor(this.totalCount/this.pageSize)+1;
            if(this.pageNumber<=1){
                this.isFirst = true;
            }else{
                this.isFirst = false;
            }
            this.isLast=caseResult.isLast;
            this.isLoading = false;
        });
    }
    
    //Updates from and to values whenever their values changes
    handleFrom(event) {
        this.from = event.target.value;
    }
    handleTo(event) {
        this.to = event.target.value;
    }

    //Used for refrshing or applying the filters for the data. Resets some page values to default
    handleFind() {
        console.log('From: ' + this.searchData);
        this.pageNumber = 1;
        this.resetIndicators();
        this.getParentCaseReport();
    }

    //Manages the dropdown menus and how they behave
    handleDropdown(event) {
        const eventValue = event.target.value;
        let currentDropdown = event.target.closest('div');
        //Finds the other dropdown menus except the currently one and closes them
        this.template.querySelectorAll(".slds-dropdown-trigger").forEach(result => {
            if (result != currentDropdown) {
                result.classList.remove("slds-is-open");
            }
        });
        for (let key in this.menuVariant) {
            if (key != event.target.value) {
                this.menuVariant[key] = 'neutral';
            }
        }

        //Open the current dropdown menu
        currentDropdown.classList.toggle("slds-is-open");

        //Highlights and unhighlights the buttons to show they are selected
        if (currentDropdown.classList.contains("slds-is-open")) {
            this.menuVariant[eventValue] = 'brand';
        } else {
            this.menuVariant[eventValue] = 'neutral';
        }

        //Makes searchButton Highlighted whenever the search field still have a value
        if (this.searchData != '') {
            this.menuVariant['Search'] = 'brand';
        }
    }

    //Initiates the search whenever the enter key is press in the search field
    handleKeyUp(event) {
        if (event.keyCode === 13) {
            this.getParentCaseReport();
        }
    }

    //Updates the searchData with the value in the search field reset the data when the field is blank
    handleInputChange(event) {
        this.searchData = event.target.value
        if (this.searchData == '') {
            this.getParentCaseReport();
        }
    }

    //Sorts each column by either ascending or descending order
    handleSort(event) {
        this.caseData = JSON.parse(JSON.stringify(this.caseData));
        this.resetIndicatorsP(event.detail.isparent);

        //Determines the indicators that will show up in the header
        this.columns.forEach(result => {
            if (result.value == event.detail.value && result.isParent == event.detail.isparent) {
                if (event.detail.isdesc == 'true') {
                    result.iconName = 'utility:arrowdown';
                    result.iconClass = 'slds-visible';
                } else {
                    result.iconName = 'utility:arrowup';
                    result.iconClass = 'slds-visible';
                }
            }
        });

        //Sorts the selected columns. They are sorted diiferently depending if the data is from the parent or the child case.
        if (event.detail.isparent == 'true') {
            if (event.detail.isdesc == 'true') {
                this.caseData.sort(function (a, b) {
                        let x = a[event.detail.value]==null?'':( a[event.detail.value].toLowerCase());
                        let y = b[event.detail.value]==null?'':( b[event.detail.value].toLowerCase());
                        if (x < y) { return 1; }
                        if (x > y) { return -1; }
                        return 0;
                });
            }
            else {
                this.caseData.sort(function (a, b) {
                        let x = a[event.detail.value]==null?'':( a[event.detail.value].toLowerCase());
                        let y = b[event.detail.value]==null?'':( b[event.detail.value].toLowerCase());
                        if (x < y) { return -1; }
                        if (x > y) { return 1; }
                        return 0;
                });
            }
        } else {
            //Child Cases is sorted different as they are group by their parent cases. If their Data Matched they are instead sorted by their created date as a fallback
            this.caseData.forEach(result => {
                if (event.detail.isdesc == 'true') {
                    result.childCases.sort(function (a, b) {
                        console.log('Typeof: ' + typeof a[event.detail.value]);
                        console.log('Result Boool: ' + a<b);
                        if (typeof a[event.detail.value] == 'string') {
                            let x = a[event.detail.value]==null?'':( a[event.detail.value].toLowerCase());
                            let y = b[event.detail.value]==null?'':( b[event.detail.value].toLowerCase());
                            if (x < y) { return 1; }
                            if (x > y) { return -1; }
                            if (x == y) {
                                let x = a['createdDate']==null?'':( a['createdDate'].toLowerCase());
                                let y = b['createdDate']==null?'':( b['createdDate'].toLowerCase());
                                if (x < y) { return 1; }
                                if (x > y) { return -1; }
                            }
                            return 0;
                        } else {
                            let x = a[event.detail.value]==null?'':a[event.detail.value];
                            let y = b[event.detail.value]==null?'':b[event.detail.value];
                            if (x < y) { return 1; }
                            if (x > y) { return -1; }
                            if (x == y) {
                                let x = a['createdDate']==null?'':( a['createdDate'].toLowerCase());
                                let y = b['createdDate']==null?'':( b['createdDate'].toLowerCase());
                                if (x < y) { return 1; }
                                if (x > y) { return -1; }
                            }
                            return 0;
                        }
                    });
                }
                else {
                    result.childCases.sort(function (a, b) {
                        if (typeof a[event.detail.value] == 'string') {
                            let x = a[event.detail.value]==null?'':( a[event.detail.value].toLowerCase());
                            let y = b[event.detail.value]==null?'':( b[event.detail.value].toLowerCase());
                            if (x < y) { return -1; }
                            if (x > y) { return 1; }
                            if (x == y) {
                                let x = a['createdDate']==null?'':( a['createdDate'].toLowerCase());
                                let y = b['createdDate']==null?'':( b['createdDate'].toLowerCase());
                                if (x < y) { return -1; }
                                if (x > y) { return 1; }
                            }
                            return 0;
                        }
                        else {
                            let x = a[event.detail.value]==null?'':a[event.detail.value];
                            let y = b[event.detail.value]==null?'':b[event.detail.value];
                            if (x < y) { return -1; }
                            if (x > y) { return 1; }
                            if (x == y) {
                                let x = a['createdDate']==null?'':( a['createdDate'].toLowerCase());
                                let y = b['createdDate']==null?'':( b['createdDate'].toLowerCase());
                                if (x < y) { return -1; }
                                if (x > y) { return 1; }
                            }
                            return 0;
                        }
                    });
                }
            })
        }
    }


    //Handles the pagination buttons
    handlePrevious(){
        this.pageNumber--;
        this.getParentCaseReport();
    }
    handleNext(){
        this.pageNumber++;
        this.getParentCaseReport();
    }
    handleFirst(){
        this.pageNumber=1;
        this.getParentCaseReport();
    }
    handleLastPage(){
        this.pageNumber=this.lastPageNumber;
        this.getParentCaseReport();
    }
    handlePageSize(event){
        this.pageNumber=1;
        this.pageSize = event.target.value;
        this.getParentCaseReport();
    }
    handleKeyUpPageNumber(event){
        if (event.keyCode === 13) {
            let goTo = event.target.value;
        ////If it goes over the total page number it goes to the last page instead. 
        //If it goes under the minimum it will go to the first page.
        if(goTo<1){
            this.pageNumber = 1;
            event.target.value = 1
        }else if(this.totalCount>=goTo*this.pageSize){
            this.pageNumber = event.target.value;
        }
        else{
            this.pageNumber = this.lastPageNumber;
            event.target.value = this.lastPageNumber;
        }
        this.getParentCaseReport();
        }
    }

    //Hides the sorting indicators for all the ascending and descending in the headers
    resetIndicators() {
        this.columns.forEach(result => {
            result.iconClass = 'slds-hidden';
        });
    }

    //Used when sorting to either only hide the parents' or child cases' columns sorting indicator depending on the parameter
    resetIndicatorsP(isParent) {
        this.columns.forEach(result => {
            if (result.isParent == isParent) {
                result.iconClass = 'slds-hidden';
            }
        });
    }

    //Calculates the height to be used by the table
    calculateHeight() {
        this.adjustHeight = 'height: ' + (window.innerHeight - 425) + 'px;';
    }
}