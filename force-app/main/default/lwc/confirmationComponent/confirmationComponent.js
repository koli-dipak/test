import { LightningElement, wire,track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getRelatedEmailMessages from '@salesforce/apex/PlatformEventController.getRelatedEmailMessagesWithBox';
import createPlatformEvent from '@salesforce/apex/PlatformEventController.createPlatformEvent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions'

export default class ConfirmationComponent extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    showConfirmation = false;
    @track spinnerStatus=false;
  
    connectedCallback() {
        this.spinnerStatus=true;
        if (this.pageRef) {
            this.recordId = this.pageRef.state.recordId;
        }
        getRelatedEmailMessages({caseId: this.recordId}) 
        .then(result => {
            this.spinnerStatus=false;
            
            // Handle the success response
           
           
            console.log('Platform event created successfully:', result);
        })
        .catch(error => {
            this.spinnerStatus=false;
            this.dispatchEvent(new CloseActionScreenEvent());

            // Handle the error response
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                })
            )
            console.error('Error creating platform event:', error);
        });
    }

    handleClick() {
        this.showConfirmation = true;
    }

    handleYes() {
        this.showConfirmation = false;
        this.spinnerStatus=true;
           
        createPlatformEvent({ recordId: this.recordId })
        .then(result => {
            this.spinnerStatus=false;
            
            // Handle the success response
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Email record(s) has been send to Box folder!',
                    variant: 'success'
                })
            ) 
            this.dispatchEvent(new CloseActionScreenEvent());

            console.log('Platform event created successfully:', result);
        })
        .catch(error => {
            this.spinnerStatus=false;
            
            // Handle the error response
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                })
            )
            console.error('Error creating platform event:', error);
        });
    }

    handleNo() {
        this.showConfirmation = false;
        this.dispatchEvent(new CloseActionScreenEvent());

    }

   
}