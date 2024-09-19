import { api, track, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getForm from '@salesforce/apex/AddRelatedRecordController.getForm';
import createJunctionObjectRecord from '@salesforce/apex/AddRelatedRecordController.createJunctionObjectRecord';
import fetchLookupData from '@salesforce/apex/AddRelatedRecordController.fetchLookupData';
import getLocationCase from '@salesforce/apex/LocationDetailController.getLocationCase';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { NavigationMixin } from 'lightning/navigation';

export default class AddRelatedRecordLwc extends NavigationMixin(LightningElement) {

    @api title;
    @api iconNameOfTitle;
    @api iconNameOfSearchResult;
    @api sObjectApiNameToSearch;
    @api sObjectApiNameOfJunctionObject;
    @api additionalFielddAPINamesToShow;
    @api apiNameOfFieldSetToSearch;
    @api apiNameOfFieldSetForDataTable;
    @api fieldAPINameOfCurrentObject;
    @api fieldAPINameOfSelectedObject;
    @api successMessage;
    @api recordId;
    @api objectApiName;
    @api allSelectedPicklistValueIds = [];
    @api limitForDropdownOptions;
    @api recordTypeNamesToFilter;
    @api fieldValuesToFilter;
    @api searchKey = '';
    @api comboboxOptions = [];
    @api showDropdown;
    @api FlowComponent;
    @api junctionData;
    @api ButtonComponent;
    @api CaseFromOpportunity;
    @api lookupContact; //m
    @api fieldAPINameOfAdditionalObject; //m
    @api currentAdditionalObjectId; //m

    @track options;
    @track fields;
    @track dataTableFields = [];

    @track createLocationClick = false; // Ahil changes

    // private properties
    isShowModal = false;
    showRecordEditForm = false;
    showRecordTypes = false;
    selectedRecordId;
    allSelectedRecordIds = [];
    isLoading = false;
    allRecords;
    showDataTable = false;
    isDataAvailable = false;
    fetchAllData = false;
    allSelectedPicklistRecordsObj = [];
    firstDataLoad = false;
    searchKeyValid = true;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    additionalFielddAPINamesToShowList=[];

    connectedCallback() {
        console.log('sObjectApiNameOfJunctionObject', this.sObjectApiNameOfJunctionObject);
        console.log('sObjectApiNameToSearch', this.sObjectApiNameToSearch);
        console.log('recordId', this.recordId);
        console.log('lookupContact', this.lookupContact);
        console.log('fieldAPINameOfAdditionalObject', this.fieldAPINameOfAdditionalObject);
        console.log('currentAdditionalObjectId ', this.currentAdditionalObjectId );
        // above added on 17/july/2023

        this.firstDataLoad = true;
        this.fetchDataFromApex();

        if (this.apiNameOfFieldSetForDataTable != undefined && this.apiNameOfFieldSetForDataTable != null) {
            this.apiNameOfFieldSetForDataTable = this.apiNameOfFieldSetForDataTable.trim();
            if (this.apiNameOfFieldSetForDataTable != "") {
                this.getfields(this.apiNameOfFieldSetForDataTable);
            }
            else{
                this.getfields(this.apiNameOfFieldSetToSearch);
            }
        }
        else{
            this.getfields(this.apiNameOfFieldSetToSearch);
        }

        // for additional fields to show in search results
        if(this.additionalFielddAPINamesToShow != undefined && this.additionalFielddAPINamesToShow != null){
            this.additionalFielddAPINamesToShow.trim();
            this.additionalFielddAPINamesToShowList = this.additionalFielddAPINamesToShow.split(";");
        }
        console.log("@@@Buuton",this.ButtonComponent);
        console.log("@@@CaseFromOpportunity",this.CaseFromOpportunity);
    }

    getfields(fieldsetName){
        getForm({ objectName: this.sObjectApiNameToSearch, fieldSetName: fieldsetName })
                .then(result => {
                    if (result) {
                        this.fields = [];
                        this.fields = result.Fields;
                        this.error = undefined;
                        // this.isLoading = false;
                    }
                }).catch(error => {
                    console.log(error);
                    this.error = error;
                    // this.isLoading = false;
                });
    }

    hideModalBox() {
        this.isShowModal = false;
        this.showDataTable = false;
        this.fetchAllData = false;
        // this.allSelectedRecordIds = [];
        // this.allSelectedPicklistValueIds=[];
        // this.allSelectedPicklistRecordsObj = [];
        // this.searchKey = '';
        // this.template.querySelector('c-multi-select-pick-list').clearSelectedRecords();
        this.fetchDataFromApex();
    }

    handleCreateJunctionObjectRecords() {
        this.isLoading = true;
        if (this.showDataTable == true && (this.allSelectedRecordIds == undefined || this.allSelectedRecordIds == null || this.allSelectedRecordIds.length == 0)) {
            this.showToast('Error!!', 'error', 'Please select a record to Add')
            this.isLoading = false;
            return;
        }
        else if (this.showDataTable == false && (this.allSelectedPicklistValueIds == undefined || this.allSelectedPicklistValueIds == null || this.allSelectedPicklistValueIds.length == 0)) {
            this.showToast('Error!!', 'error', 'Please select a record to Add')
            this.isLoading = false;
            return;
        }

        var inputMap = {};
        inputMap["currentRecordId"] = this.recordId;
        if (this.showDataTable == true) {
            inputMap["allSelectedRecordIds"] = JSON.stringify(this.allSelectedRecordIds);
        } else {
            inputMap["allSelectedRecordIds"] = JSON.stringify(this.allSelectedPicklistValueIds);
        }
        inputMap["currentSObjectName"] = this.objectApiName;
        inputMap["sObjectApiNameToSearch"] = this.sObjectApiNameToSearch;
        inputMap["sObjectApiNameOfJunctionObject"] = this.sObjectApiNameOfJunctionObject;
        inputMap["fieldAPINameOfCurrentObject"] = this.fieldAPINameOfCurrentObject;
        inputMap["fieldAPINameOfSelectedObject"] = this.fieldAPINameOfSelectedObject;
        //mahendra changes
        if((this.fieldAPINameOfAdditionalObject != undefined && this.fieldAPINameOfAdditionalObject != null) && (this.currentAdditionalObjectId != undefined && this.currentAdditionalObjectId != null)){ 
            inputMap["fieldAPINameOfAdditionalObject"] = this.fieldAPINameOfAdditionalObject;
            inputMap["currentAdditionalObjectId"] = this.currentAdditionalObjectId;
        }
        console.log('inputMap',inputMap); //Ahil changes
        createJunctionObjectRecord({ inputMap: inputMap })
            .then(result => {
                if (result === 'SUCCESS') {
                    this.allSelectedPicklistRecordsObj = [];
                    this.allSelectedPicklistValueIds = [];
                    this.allRecords = [];
                    this.allSelectedRecordIds = [];
                    this.searchKey = '';
                    this.error = undefined
                    this.isLoading = false;
                    this.template.querySelector('c-multi-select-pick-list').clear(this.comboboxOptions);
                    if(this.ButtonComponent){
                        // this.showToast('Success!!', 'success', 'Your new survey location has been added successfully to your risk engineering request, you may proceed to the next screen.') // This success message is change due to N2G-644
                        this.showToast('Success!!', 'success', 'Success! Your new survey location has been added.');

                    }else{
                        this.showToast('Success!!', 'success', this.successMessage)
                    }
                    this.hideModalBox();
                    eval("$A.get('e.force:refreshView').fire();");
                    if(this.CaseFromOpportunity || this.lookupContact){
                    // this[NavigationMixin.Navigate]({
                    //     type: 'standard__recordPage',
                    //     attributes: {
                    //         recordId: this.recordId,
                    //         objectApiName: this.objectApiName, // objectApiName is optional
                    //         actionName: 'view'
                    //     }
                    // });
                    }else {
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.recordId,
                                objectApiName: this.objectApiName, // objectApiName is optional
                                actionName: 'view'
                            }
                        });
                    }
                    eval("$A.get('e.force:refreshView').fire();");
                    
                } else if (result.startsWith('ERROR')) {
                    this.showToast('Error!!', 'error', this.removeFirstWord(result))
                    this.isLoading = false;
                    eval("$A.get('e.force:refreshView').fire();");
                }

            })
            .catch(error => {
                this.error = error
                console.log(error)
                this.isLoading = false;
                eval("$A.get('e.force:refreshView').fire();");
            })

    }

    handleCreateLocationRecords(event){
        console.log("@@Records");
        this.createLocationClick = true;
    //     this.recordId = value;
    //     //this._recordId = '500Ea000003zLKLIA2';
    
        // console.log('recordId', this.recordId);
        //     const defaultValues = encodeDefaultFieldValues({
        //         Case__c: this.recordId
        //         });
        //         this[NavigationMixin.Navigate]({
        //             type: 'standard__objectPage',
        //             attributes: {
        //                 objectApiName:'Location',
        //                 actionName: 'new'
        //             },
        //             state: {
        //                 navigationLocation: 'RELATED_LIST',
        //                 defaultFieldValues: defaultValues
        //             }
        //          });

    }
    
    // get recordId() {
    // return this.recordId;
    //  }
    modalCloseHandler(){
        this.createLocationClick = false;
    }
    
        
    

    removeFirstWord(str) {
        const indexOfSpace = str.indexOf(' ');

        if (indexOfSpace === -1) {
            return '';
        }

        return str.substring(indexOfSpace + 1);
    }

    showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        })
        this.dispatchEvent(event)
    }

    handleSearchKeyChange(event) {
				window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        if (searchKey.length >= 3) {
            this.searchKeyValid = true;
        }
        else {
            this.searchKeyValid = false;
        }
        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey;
            this.fetchDataFromApex();
        }, 300);
    }

    handleDataTableRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.allSelectedRecordIds = [];
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++) {
            this.allSelectedRecordIds.push(selectedRows[i].Id);
        }
    }

    fetchDataFromApex() {
        if (this.showDataTable == false) {
            fetchLookupData({ searchKey: this.searchKey, currentRecordId: this.recordId, sObjectApiName: this.sObjectApiNameToSearch, apiNameOfFieldSetToSearch: this.apiNameOfFieldSetToSearch, fetchAllData: this.fetchAllData, limitForDropdownOptions: this.limitForDropdownOptions, allSelectedPicklistValueIds: JSON.stringify(this.allSelectedPicklistValueIds), recordTypeNamesToFilter: this.recordTypeNamesToFilter, apiNameOfFieldSetForDataTable: null, additionalFielddAPINamesToShow: this.additionalFielddAPINamesToShow, fieldValuesToFilter: this.fieldValuesToFilter })
                .then(result => {
                    if (result.length != 0) {
                        this.isDataAvailable = true
                    }
                    else {
                        this.isDataAvailable = false;
                        this.comboboxOptions = [];
                        // this.allSelectedPicklistRecordsObj = [];
                        // this.allSelectedPicklistValueIds = [];
                        const multiCombobox = this.template.querySelector('c-multi-select-pick-list');
                        multiCombobox.refreshOptions(this.comboboxOptions);
                        if (this.firstDataLoad == false) {
                            this.showDropdown = true;
                        }
                    }
                    if (!this.fetchAllData) {
                        this.comboboxOptions = [];
                        if (this.searchKey != undefined && this.searchKey != null && this.searchKey != "") {
                            var tempSearchKey = this.searchKey.trim();
                            if (tempSearchKey != null && tempSearchKey != "" && tempSearchKey.length >= 3) {
                                let searchObj = { label: "Search \"" + this.searchKey + "\" in all records", value: "SearchInAll", icon: 'utility:search', selected:false };
                                this.comboboxOptions.push(searchObj);
                            }
                        }
                        for (let i = 0; i < result.length; i++) {
                            let DisplayLabel = result[i].Name;

                            if(this.additionalFielddAPINamesToShowList.length > 0){
                                for (let j = 0; j < this.additionalFielddAPINamesToShowList.length; j++) {
                                    if(result[i][this.additionalFielddAPINamesToShowList[j]] != undefined && result[i][this.additionalFielddAPINamesToShowList[j]] != null){
                                        result[i][this.additionalFielddAPINamesToShowList[j]].toString().trim();
                                        if(result[i][this.additionalFielddAPINamesToShowList[j]] != ""){
                                            DisplayLabel = DisplayLabel + " | " + result[i][this.additionalFielddAPINamesToShowList[j]];
                                        }
                                    }
                                }
                            }
                            let obj = { label: DisplayLabel, value: result[i].Id, icon: this.iconNameOfSearchResult, selected:false };
                            this.comboboxOptions.push(obj);
                        }
                        const multiCombobox = this.template.querySelector('c-multi-select-pick-list');
                        multiCombobox.refreshOptions(this.comboboxOptions);
                        if (this.firstDataLoad == false) {
                            this.showDropdown = true;
                        }
                    }

                    if (this.firstDataLoad == true) {
                        this.firstDataLoad = false;
                    }

                    // this.opps = result;
                    this.error = undefined;
                    this.isLoading = false;
                })
                .catch(error => {
                    this.error = error
                    console.log(error)
                    this.isLoading = false;
                    this.showToast('Error!!', 'error', 'ERROR: ' + error)
                })
        }
        else if (this.showDataTable == true && this.searchKey.length >= 3) {
            this.isLoading = true;
            fetchLookupData({ searchKey: this.searchKey, currentRecordId: this.recordId, sObjectApiName: this.sObjectApiNameToSearch, apiNameOfFieldSetToSearch: this.apiNameOfFieldSetToSearch, fetchAllData: this.fetchAllData, limitForDropdownOptions: this.limitForDropdownOptions, allSelectedPicklistValueIds: JSON.stringify(this.allSelectedPicklistValueIds), recordTypeNamesToFilter: this.recordTypeNamesToFilter, apiNameOfFieldSetForDataTable: this.apiNameOfFieldSetForDataTable, additionalFielddAPINamesToShow: this.additionalFielddAPINamesToShow, fieldValuesToFilter: this.fieldValuesToFilter })
                .then(result => {
                    if (result.length != 0) {
                        this.isDataAvailable = true
                    }
                    else {
                        this.isDataAvailable = false;
                    }
                    this.allRecords = result;
                    this.error = undefined;
                    this.isLoading = false;
                })
                .catch(error => {
                    this.error = error
                    console.log(error)
                    this.isLoading = false;
                    this.showToast('Error!!', 'error', 'ERROR: ' + error)
                })

            if (this.fields != undefined && this.fields != null) {
                this.dataTableFields = [];
                for (let i = 0; i < this.fields.length; i++) {
                    const field = this.fields[i];
                    this.dataTableFields.push({ label: field.Label, fieldName: field.APIName, type: field.Type, sortable: true })
                }
            }
        }

    }

    // Used to sort the column
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.allRecords];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.allRecords = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    handleSelectOptionList(event) {
        console.log('@@event.detail.objectValues:::', event.detail.objectValues);
        this.allSelectedPicklistRecordsObj = event.detail.objectValues;
        this.allSelectedPicklistValueIds = [];
        this.allSelectedPicklistRecordsObj.forEach(element => {
            this.allSelectedPicklistValueIds.push(element.value);
        })
        console.log('@@this.allSelectedPicklistValueIds:::', this.allSelectedPicklistValueIds);
    }

    handlePicklistSearchKeyChange(event) {
        this.searchKey = event.detail;
        this.isLoading = true;
        this.fetchDataFromApex();
        this.template.querySelector('c-multi-select-pick-list').handleMouseInFromParent();
    }

    handlePicklistOpenDataTable(event) {
        this.isLoading = true;
        this.fetchAllData = true;
        this.showDataTable = true;
        this.fetchDataFromApex();
    }
}