import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCaseRecord from '@salesforce/apex/UpdateNewMessageCheckOnBoxFICaseHelper.getCaseRecord';
import updateCaseRecord from '@salesforce/apex/UpdateNewMessageCheckOnBoxFICaseHelper.updateCaseRecord';

export default class UpdateNewMessageCheckOnBoxFICase extends LightningElement {
    @api recordId;

    connectedCallback() {
        getCaseRecord({ caseId: this.recordId })
            .then(result => {
                console.log('@@result::', result);
                if (result.New_Message__c != undefined && result.New_Message__c == true) {
                    updateCaseRecord({ caseId: this.recordId })
                        .then(result1 => {
                            console.log('@@result1:::',result1);
                            if (result1 != 'SUCCESS') {
                                const event = new ShowToastEvent({
                                    title: 'ERROR!!',
                                    message: error,
                                    variant: 'error',
                                    mode: 'dismissable'
                                });
                                this.dispatchEvent(event);
                            }
                        })
                        .catch(error => {
                            console.log('@@error::', error);
                            const event = new ShowToastEvent({
                                title: 'ERROR!!',
                                message: error,
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(event);
                        });
                }
            })
            .catch(error => {
                console.log('@@error::', error);
                const event = new ShowToastEvent({
                    title: 'ERROR!!',
                    message: error,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            });
    }

}