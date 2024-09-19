import { LightningElement, wire, api, track } from 'lwc';
import getStatusPicklistValues from '@salesforce/apex/DocumentChecklistSelectionTableControlle.getStatusPicklistValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuotedChecklistItems from '@salesforce/apex/DocumentChecklistSelectionTableControlle.getQuotedChecklistItems';
import getBinderChecklistItems from '@salesforce/apex/DocumentChecklistSelectionTableControlle.getBinderChecklistItems';
import updateRecords from '@salesforce/apex/DocumentChecklistSelectionTableControlle.updateRecords';
import { NavigationMixin } from 'lightning/navigation';

export default class GenerateQuoteAndBinderRelatedList extends NavigationMixin(LightningElement) {
    @api recordId;
    @track data = [];
    @track statusOptions = [];
    @track quotedData = [];
    @track binderData = [];
    @track error;
    @track isbinderRecords = false;
    @track isQuotedRecords = false;
    @track hasRecords = false;


    
   

    @wire(getBinderChecklistItems, { parentId: '$recordId' })
    wiredBindingChecklistItems({ error, data }) {
        if (data) {
            this.error = undefined;
            this.binderData = data.map((item, index) => ({ ...item, rowNumber: index + 1 }));
            this.binderData = this.findDuplicates(this.binderData);
            this.isbinderRecords = this.binderData.length > 0;
            this.hasRecords = this.binderData.length > 0;

        } else if (error) {
            this.error = error;
            this.binderData = [];
            this.isbinderRecords = false;
            console.error('Error loading checklist items:', error);
        }
    }

    @wire(getQuotedChecklistItems, { parentId: '$recordId' })
    wiredQuotedChecklistItems({ error, data }) {
        if (data) {
            this.error = undefined;
            //this.data = data;
            this.quotedData = data.map((item, index) => ({ ...item, rowNumber: index + 1 }));
            console.log('@@@this.data',this.data);
            this.quotedData = this.findDuplicates(this.quotedData);
            this.isQuotedRecords = this.quotedData.length > 0;           
            this.hasRecords = this.quotedData.length > 0;           
                   
        } else if (error) {
            this.error = error;
            this.quotedData = [];
            this.isQuotedRecords = false;
            console.error('Error loading checklist items:', error);
        }
    }



    @wire(getStatusPicklistValues)
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.error = undefined;
            this.statusOptions = data.map(picklistValue => ({ label: picklistValue, value: picklistValue }));
        } else if (error) {
            this.error = error;
            this.statusOptions = [];
            console.error('Error loading picklist values:', error);
        }
    }

    handleChange(event) {
        const { value } = event.detail;
        const recordId = event.target.name;
        const updatedBindingData  = this.binderData.map(item => {
            if (item.Id === recordId) {
                return { ...item, Status: value };
            }
            return item;
        });
        this.binderData = updatedBindingData ;
        
        const updatedQuotedData = this.quotedData.map(item=>{
            if(item.Id === recordId){
                return{ ...item, Status: value };
            }
            return item;
        });

        this.quotedData = updatedQuotedData;

    }

    handleSave() {
        // Prepare data to save
        const recordsToUpdate = [...this.binderData]
            .filter(item => item.Status !== item.StatusOriginal) // Filter records where status has changed
            .map(item => ({ Id: item.Id, Status: item.Status }));

        // Call Apex to update records
        if (recordsToUpdate.length > 0) {
            updateRecords({ recordsToUpdate })
                .then(() => {
                    // Handle success
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Records updated successfully.',
                            variant: 'success'
                        })
                    );
                })
                .catch(error => {
                    // Handle error
                    console.error('Error updating records:', error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'An error occurred while updating records.',
                            variant: 'error'
                        })
                    );
                });
        }
    }

    findDuplicates(data) {
        const instructionLineCombinations = {};
        data.forEach(item => {
            const key = item.Instruction + item.Line_of_Business__c + item.Country_States__c + item.Type__c;
            if (!instructionLineCombinations[key]) {
                instructionLineCombinations[key] = [];
            }
            instructionLineCombinations[key].push(item);
        });
    
        for (const key in instructionLineCombinations) {
            const items = instructionLineCombinations[key];
            const isDuplicate = items.length > 1;
            items.forEach((item, index) => {
                // Create a new object and extend it with the original item properties
                const newItem = { ...item };
                newItem.isDuplicate = isDuplicate && index > 0;
                items[index] = newItem; // Replace the original item with the new one
            });
        }
    
        // Flatten the array of arrays back to a single array
        return Object.values(instructionLineCombinations).flat();
    }

    navigateToRecord(event) {
        // Get the record id from the event
        const recordId = event.target.dataset.recordId;
        // Navigate to the record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }
    

    getRowNumber(index) {
        return index + 1;
    }
}