import { LightningElement, api, wire } from 'lwc';
import fetchLookupData from '@salesforce/apex/OpportunityController.fetchLookupData';
import fetchDefaultRecord from '@salesforce/apex/OpportunityController.fetchDefaultRecord';

const DELAY = 700; 

export default class AllOpportunity extends LightningElement {

    // public properties with initial default values 
    @api label = 'Opportunity Name';
    @api placeholder = 'search...';
    @api iconName = 'standard:opportunity';
    @api sObjectApiName = 'Opportunity';
    @api defaultRecordId = '';
    @api oEvent;

    // private properties 
    lstResult = []; 
    hasRecords = true;
    searchKey = '';   
    isSearchLoading = false;  
    delayTimeout;
    selectedRecord = {}; 

    connectedCallback() {
        if (this.defaultRecordId != '') {
            fetchDefaultRecord({ recordId: this.defaultRecordId, 'sObjectApiName': this.sObjectApiName })
                .then((result) => {
                    if (result != null) {
                        this.selectedRecord = result;
                        this.handelSelectRecordHelper(); 
                    }
                })
                .catch((error) => {
                    this.error = error;
                    this.selectedRecord = {};
                });
        }
    }

    // wire function property to fetch search record based on user input
    @wire(fetchLookupData, { searchKey: '$searchKey', sObjectApiName: '$sObjectApiName' })
    searchResult(value) {
        const { data, error } = value; 
        this.isSearchLoading = false;
        if (data) {
            this.hasRecords = data.length == 0 ? false : true;
            this.lstResult = JSON.parse(JSON.stringify(data));
        }
        else if (error) {
            console.log('(error---> ' + JSON.stringify(error));
        }
    };

    //update searchKey property on input field change  
    handleKeyChange(event) {
        this.isSearchLoading = true;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey;
        }, DELAY);
    }
    
    // method to toggle lookup result section on UI 
    toggleResult(event) {
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        switch (whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');
                break;
            case 'lookupContainer':
                clsList.remove('slds-is-open');
                break;
        }
    }

    // method to clear selected lookup record  
    handleRemove() {
        this.searchKey = '';
        this.selectedRecord = {};
        this.lookupUpdatehandler(undefined); 
        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        searchBoxWrapper.classList.remove('slds-hide');
        searchBoxWrapper.classList.add('slds-show');

        const pillDiv = this.template.querySelector('.pillDiv');
        pillDiv.classList.remove('slds-show');
        pillDiv.classList.add('slds-hide');
    }

    // method to update selected record from search result 
    handelSelectedRecord(event) {
        console.log('event',this.selectedRecord);
        var objId = event.target.getAttribute('data-recid'); 
        this.selectedRecord = this.lstResult.find(data => data.Id ===objId); 
        this.lookupUpdatehandler(this.selectedRecord.Id); 
        this.handelSelectRecordHelper(); 
    }

    handelSelectRecordHelper() {
        this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');

        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        searchBoxWrapper.classList.remove('slds-show');
        searchBoxWrapper.classList.add('slds-hide');

        const pillDiv = this.template.querySelector('.pillDiv');
        pillDiv.classList.remove('slds-hide');
        pillDiv.classList.add('slds-show');
    }

    // send selected lookup record to parent component using custom event
    lookupUpdatehandler(value) {
        this.oEvent = value;
        console.log('this.oEvent',this.oEvent);
        const oEvent = new CustomEvent('lookupupdate',
            {
                'detail': { selectedRecord: value }
            }
        );
        this.dispatchEvent(oEvent);
    }
}