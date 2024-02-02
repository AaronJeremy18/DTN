import { LightningElement , wire, api, track } from 'lwc';
//import{ getListUi } from 'lightning/uiListApi';
import getCaseResolution from '@salesforce/apex/Reports_AverageCaseResolution.getCaseResolution';

/*const headerData = [
    {'label':'Case Number', 'isParent': 'true','value':'CaseNumber'},
    {'label':'Case Issue', 'isParent': 'true','value':'CaseIssue'},
    {'label':'OwnerName', 'value':'OwnerName'},
    {'label':'Status', 'value':'Status'},
    {'label':'LastModifiedBy', 'value':'Last Modified By'},
    {'label':'LastModifiedDate', 'value':'LastModified'},
    {'label':'Created Date', 'value':'CreatedDate'},
    {'label':'Close Date', 'value':'ClosedDate'},
    {'label':'CaseAge', 'value':'CaseAge'},
    //{'label':'Average Resolution', 'value':'AverageResolution'},
    //{'label':'Field/Event', 'value':'Field/Event'},
    //{'label':'New Value', 'value':'New Value'},
];*/

const columns = [
    { label: 'Business Unit', fieldName: 'BusinessUnit', type: 'text', sortable: "true" },
    { label: 'Case Number', fieldName: 'CaseNumber', type: 'text', sortable: "true" },
    { label: 'Case Issue', fieldName: 'CaseIssue', type: 'text', sortable: "true" },
    { label: 'OwnerName', fieldName: 'OwnerName', type: 'text', sortable: "true" },
    { label: 'Status', fieldName: 'Status', type: 'text', sortable: "true" },
    { label: 'Last Modified By', fieldName: 'LastModifiedBy', type: 'text', sortable: "true" },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', sortable: "true" },
    { label: 'Close Date', fieldName: 'ClosedDate', type: 'date', sortable: "true" },
    { label: 'CaseAge', fieldName: 'CaseAge', type: 'number' , cellAttributes: { alignment: 'left' }, sortable: "true"},
];

export default class AverageCaseResolutionTime extends LightningElement {

    //headerData = headerData;
    columns = columns;
    @track Cases = [];
    @track searchResult;
    @track AverageResolution = 0;
    totalPages; //Total no.of pages
    records = [];
    pageSizeOptions = [5, 10, 25, 50, 75, 100];
    pageSize;
    pageNumber = 1;
    @track recordsToDisplay = [];
    totalRecords = 0;
    @track sortBy;
    @track sortDirection;
    /*handleSearch({ }){
        console.log('Debug test before getCaseResolution method');
        getCaseResolution()
        .then(result =>{
            console.log('result is ', result);
            this.searchResult = result;
            }).catch(error => {
                console.log('error occured ', error);

            });
    }*/
    get bDisableFirst() {
        return this.pageNumber == 1;
    }
    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }
    @wire(getCaseResolution)
    caseResolution({error, data}){
        if(data){
            this.records = data.CaseWrappers;
            console.log('records debug: '+JSON.stringify(this.records));
            this.totalRecords = data.CaseWrappers.length;
            console.log('total records: '+JSON.stringify(this.totalRecords));
            this.pageSize = this.pageSizeOptions[0]; //set pageSize with default value as first option
            this.AverageResolution = data.AverageResolution;
            this.paginationHelper();
        }else if(error){
            console.log('error while fetch Cases--> ' + JSON.stringify(error));
        };
        
        
    }
    
    
    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.paginationHelper();
    }
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }
    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }
    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }
    // JS function to handel pagination logic 
    paginationHelper() {
        this.recordsToDisplay = [];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.records[i]);
            //this.recordsToDisplay = this.records[i]
        }
    }
    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }
    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.records));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
            
            
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
            
        });
        this.recordsToDisplay = [];
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(parseData[i]);
            //this.recordsToDisplay = this.records[i]
            
        }

    }    

 
}