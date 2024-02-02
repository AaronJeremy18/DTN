import { api, LightningElement, track } from 'lwc';
import getPriceBookEntriesWrapperList from '@salesforce/apex/DTN_ManagePriceBookEntries.populateAllPricebookEntries';
import savePricebookEntriesList from '@salesforce/apex/DTN_ManagePriceBookEntries.savePricebookEntriesList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class managePricebookEntries extends LightningElement {
    @api recordId;
    @track pbEntries;
    @track allPriceBooks;
    @track error;
    loaded = false;
    //@track pbeTemp = []/*= new Map()*/;
    @track pbePriceContainer = 0;
    connectedCallback() {
        this.retrieveAllPricebookEntries();
    }

    retrieveAllPricebookEntries() {
        if (this.recordId) {
            getPriceBookEntriesWrapperList({ productId: this.recordId })
                .then((result) => {
                    this.pbEntries = result;
                    console.log(JSON.stringify('this.pbEntries:'+this.pbEntries[0]));
                    this.error = undefined;
                    let count = 1;
                    this.pbEntries.forEach(pbe => {
                        //pbe.isSelected = false;
                        pbe.isUSD = pbe.currencyIsoCode =='USD';
                        pbe.key = count;
                        count++;
                    });
                    this.loaded = true;
                })
                .catch((error) => {
                    this.error = error;
                    this.pbEntries = undefined;
                    this.loaded = true;
                });
        }
    }


    calculateConversionRates(event) {
        console.log(event.target.getAttribute('data-iso'));
        let currentId = event.target.name;
        
        
        //if (isoCode === 'USD') {
        if(event.target.getAttribute('data-iso') == 'USD'){
            this.pbePriceContainer = event.target.value;
            //pbe.unitPrice = this.pbePriceContainer;
            this.pbEntries.forEach(pbe => {

                //this.pbeTemp.set(pbe.pricebookId,event.target.value);
                //console.log('>>pbeTemp values<<'+this.pbeTemp.get(pbe.pricebookId));
                //if(pbe.pricebookId === currentId){
                    if (pbe.currencyIsoCode=='USD') {
                        //this.pbePriceContainer = event.target.value;
                        pbe.unitPrice = this.pbePriceContainer;
                        console.log('>>>check price container USD<<< ' + this.pbePriceContainer);
                    } /*else if (pbe.currencyIsoCode == 'PLN') {
                        this.pbeTemp = pbeTemp.set(pbe.pricebookId,pbe);
                    } else*/ if (pbe.currencyIsoCode=='AUD') {
                        pbe.unitPrice = this.pbePriceContainer*1.4;
                        console.log('>>>check price container AUD<<< ' + this.pbePriceContainer);
                    } else if (pbe.currencyIsoCode=='CAD') {
                        pbe.unitPrice = this.pbePriceContainer*1.25;
                        console.log('>>>check price container CAD<<< ' + this.pbePriceContainer);
                    } else if (pbe.currencyIsoCode=='CHF') {
                        pbe.unitPrice = this.pbePriceContainer;
                        console.log('>>>check price container CHF<<< ' + this.pbePriceContainer);
                    } else if (pbe.currencyIsoCode=='EUR') {
                        pbe.unitPrice = this.pbePriceContainer;
                        console.log('>>>check price container EUR<<< ' + this.pbePriceContainer);
                    } else if (pbe.currencyIsoCode=='GBP') {
                        pbe.unitPrice = this.pbePriceContainer;
                        console.log('>>>check price container GBP<<< ' + this.pbePriceContainer);
                    } else if (pbe.currencyIsoCode=='NZD') {
                        pbe.unitPrice = this.pbePriceContainer*1.7;
                        console.log('>>>check price container NZD<<< ' + this.pbePriceContainer);
                    }

                //}
                console.log('>>>price container value<<< ' + this.pbePriceContainer);
            });

        }
        this.pbEntries.forEach(pbe => {
            pbe.isSelected = true;
        });
        console.log('pbe: ' + JSON.stringify(this.pbEntries));
        //}
        /* } else if (pbe.currencyIsoCode == 'PLN') {
                        this.pbeTemp = pbeTemp.set(pbe.pricebookId,(pbe.unitPrice * 1.7));
                    } else if (pbe.currencyIsoCode == 'AUD') {
                        this.pbeTemp = pbeTemp.set(pbe.pricebookId,(pbe.unitPrice * 1.4));
                    } else if (pbe.currencyIsoCode == 'CAD') {
                        this.pbeTemp = pbeTemp.set(pbe.pricebookId,(pbe.unitPrice * 1.25));
                    } else if (pbe.currencyIsoCode == 'CHF') {
                        this.pbeTemp = pbeTemp.set(pbe.pricebookId,(pbe.unitPrice * 1));
                    } else if (pbe.currencyIsoCode == 'EUR') {
                        this.pbeTemp = pbeTemp.set(pbe.pricebookId,(pbe.unitPrice * 1));
                    } else if (pbe.currencyIsoCode == 'GBP') {
                        this.pbeTemp = pbeTemp.set(pbe.pricebookId,(pbe.unitPrice * 1));
                    } else if (pbe.currencyIsoCode == 'NZD') {
                        this.pbeTemp = pbeTemp.set(pbe.pricebookId,(pbe.unitPrice * 1.7));
                    }*/
    }

    changeActiveChkbox(event) {
        this.pbEntries.forEach(pbe => {
            if(pbe.key == event.target.dataset.key) {
                pbe.isActive = event.target.checked;
            }
        });
    }

    changeSelectionChkbox(event) {
        this.pbEntries.forEach(pbe => {
            if(pbe.key == event.target.dataset.key) {
                pbe.isSelected = event.target.checked;
            }
        });
    }

    saveEntries() {
        this.loaded = false;
        console.log('----save---' + JSON.stringify(this.pbEntries));
        let pbeListToUpdate = [];
        this.pbEntries.forEach(pbe => {
            if(pbe.isSelected) {
                console.log('data selected: ' + pbe);
                pbeListToUpdate.push(pbe);
            }
        });
        console.log('----pbeListToUpdate---' + JSON.stringify(pbeListToUpdate));
        savePricebookEntriesList({ pbeWrapperList: pbeListToUpdate, productId: this.recordId })
                .then((result) => {
                    //do something
                    console.log('--save--'+result);
                    this.error = undefined;
                    this.loaded = true;
                    this.showToast();
                    console.log('--post save result--');
                })
                .catch((error) => {
                    console.log('--catch section error--'+error);
                    this.error = error;
                    this.loaded = true;
                });
                console.log('----after save button---');

    }

    showToast() {
        const event = new ShowToastEvent({
            title: 'Pricebook Entries Saved',
            message: 'Pricebook Entries are Saved',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
        //this.refreshPage();
    }

    refreshPage() {
        console.log('---in refresh--');
        window.location.reload();
    }
}