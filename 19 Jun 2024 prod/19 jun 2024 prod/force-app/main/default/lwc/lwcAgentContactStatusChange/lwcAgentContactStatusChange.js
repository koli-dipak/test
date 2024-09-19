import { LightningElement, api,track } from 'lwc';
import Status__c from '@salesforce/schema/Agent_Contact__c.Status__c';
import Approve_Reject_Comment__c from '@salesforce/schema/Agent_Contact__c.Approve_Reject_Comment__c';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import updateReleatedObject from '@salesforce/apex/RequestContactUpdateController.updateReleatedObject'

export default class LwcAgentContactStatusChange extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track spinnerStatus=false;
    nameField = Status__c;
    commentField=Approve_Reject_Comment__c;

    onSave(){
        var hasError=false;
        this.template.querySelectorAll('lightning-input-field').forEach(
            element =>{ if(!element.reportValidity())hasError=true;}
        );
        if(!hasError){
            this.spinnerStatus=true;
        }
    }
    closeQuickAction() {
        this.spinnerStatus=false;
        this.showToast('Success','Record Updated Successfully','Success');
        this.dispatchEvent(new CloseActionScreenEvent());
        console.log('inside button', this.recordId);
        /*const objectid = this.recordId;
        updateReleatedObject({recordId : objectid})
        .then(result => {
            console.log('Success');
        })
        .catch(error => {
            console.log('Faild');
        });*/
    }
    closeQuickActionError(){
        this.spinnerStatus=false;
        this.showToast('Error','Error Occured While Updating Data','Error');
        this.dispatchEvent(new CloseActionScreenEvent());
        console.log('inside button', this.recordId);
    }
    showToast(title,message,variant) {
        const event = new ShowToastEvent({
            title: title,
            message:message,
            variant:variant
        });
        this.dispatchEvent(event);
    }
}