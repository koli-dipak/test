import { LightningElement,wire,api,track } from 'lwc';
import getRelatedBinderChecklistItems from '@salesforce/apex/DocumentChecklistSelectionTableControlle.getRelatedBinderChecklistItems';

import {
   FlowNavigationNextEvent
  } from "lightning/flowSupport";
export default class DisplayBinderRecordsFromFlow extends LightningElement {
    @api recordId;
    @track data = [];
    @track statusOptions = [];
    @track error;
    @api selectedRows = [];
    @api availableActions = [];

 

    @wire(getRelatedBinderChecklistItems, { parentId: '$recordId' })
    wiredChecklistItems({ error, data }) {
        if (data) {
            this.error = undefined;
            this.data = data;     
            console.log('Flowthis.data',this.data);
            
            //this.data = data.map((item, index) => ({ ...item, rowNumber: index + 1 }));
            
            this.data = this.findDuplicates(this.data);
      

           
            
        } else if (error) {
            this.error = error;
            this.data = [];
            console.error('Error loading checklist items:', error);
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

    get modifiedData() {
        return this.data.map(item => ({ ...item, selected: this.selectedRows.includes(item.Id) }));
    }

    handleRowSelection(event) {
        const selectedId = {
            Id: event.target.value
        };
    
        if (event.target.checked) {
            this.selectedRows = [...this.selectedRows, selectedId];
            console.log('this.selectedRows', this.selectedRows);
        } else {
            this.selectedRows = this.selectedRows.filter(row => row.Id !== selectedId.Id);
            console.log('else this.selectedRows', this.selectedRows);
        }
    }
    
    handleSelectAll(event) {
        const checkboxes = this.template.querySelectorAll('input[type="checkbox"]');
        if (event.target.checked) {
            this.selectedRows = this.data.map(item => ({ Id: item.Id }));
            console.log('handle this.selectedRows',this.selectedRows);
            checkboxes.forEach(checkbox => {
                checkbox.checked = true;
            });
        } else {
            this.selectedRows = [];
            checkboxes.forEach(checkbox => {
                checkbox.checked = false;
                console.log('else handle this.selectedRows',this.selectedRows);
            });
        }
    }
    
    handleNextClick() {
        if (this.availableActions.find((action) => action === "NEXT")) {
          const navigateNextEvent = new FlowNavigationNextEvent();
          this.dispatchEvent(navigateNextEvent);
        }
      }

}