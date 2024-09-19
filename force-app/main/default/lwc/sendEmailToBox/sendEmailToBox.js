import { LightningElement, api, track,wire } from 'lwc'
import getRelatedEmailMessages from '@salesforce/apex/SendEmailToBoxController.getRelatedEmailMessagesWithBox';
import sendEmailToBox from '@salesforce/apex/SendEmailToBoxController.sendEmailToBox';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

const DELAY = 3000;
export default class FISendEmailToBox extends LightningElement {
    @api recordId;
    @api caseId;
    @api ActionName
    @track emailMessages;
    @track selectedEmails = [];
    error;
    records;
    @track spinnerStatus=false;
    @track noRecordFound=false;
    @track hasEmailProcessed=false;
    @track showEmailMessageList=false;
    @track folderOptions=[];
    @track selectedFolder='';
		@track showPrev=true;
    renderedCallback() {
       
        this.connectedCallback();
    }
    connectedCallback(){
        if (!this.hasEmailProcessed && this.recordId) {
            this.spinnerStatus=true;
            this.hasEmailProcessed=true;
            getRelatedEmailMessages({caseId: this.recordId})
            .then(result => {
                var recordInfo=JSON.parse(result);
                this.emailMessages = recordInfo.EmailMessage;
                this.folderOptions=[];
                if(recordInfo.defaultBox==undefined){
                    this.folderOptions.push({"label":"--None--", "value":"" ,isSelected:true});
                }else{
                    this.selectedFolder=recordInfo.defaultBox;
								}
								if(recordInfo.isForAccount){
										this.showPrev=false;
										this.showEmailMessageList=true;
								}
                
                for(var key in recordInfo.BoxFolderList){
                    this.folderOptions.push({"label":recordInfo.BoxFolderList[key], "value":key,"isSelected":(recordInfo.defaultBox==key)})
                }
                this.spinnerStatus=false;
                if(this.emailMessages.length == 0){
                    this.noRecordFound=true;
                }

            }).catch(error=>{
                console.log('error',error);
                this.spinnerStatus=false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
                
             });
            // Execute some function or backend controller call that needs the recordId
        }
    }

    handleSelect(event) {
        const emailId = event.target.value;
        console.log("emailId",emailId);
        if(event.target.checked) {
            this.selectedEmails.push(emailId);
        } else {
            this.selectedEmails = this.selectedEmails.filter(email => email !== emailId);
        }

    }

    handleSelectAll(event) {
        var length=this.template.querySelectorAll('.selectCheckbox').length;
        for(let i=0; i<length; i++) {
            this.template.querySelectorAll('.selectCheckbox')[i].checked = event.target.checked;
        }
        if(event.target.checked) {
            this.selectedEmails = this.emailMessages.map(email => email.Id);
        } else {
            this.selectedEmails = [];
        }
    }
    changeHandler(e){
        this.selectedFolder = e.currentTarget.value ;
    }
    handleNext(event) {
        if (this.selectedFolder==undefined || this.selectedFolder=="") {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Warning',
                    message: 'Please Select Folder to procced further!',
                    variant: 'warning'
                })
            );
            return;
        }
        this.showEmailMessageList=true;
        if(this.template.querySelector('.OverrideCSS')!=null && this.template.querySelector('.OverrideCSS').children.length==0){
            const style = document.createElement('style');
            style.innerText = `.uiModal--medium .modal-container{
                width: 85% !important;
                max-width: 85% !important;
            }`;
            this.template.querySelector('.OverrideCSS').appendChild(style);

        }
    }
    handlePrevious(event) {
        this.showEmailMessageList=false;
        if(this.template.querySelector('.OverrideCSS')!=null){
            const style = document.createElement('style');
            style.innerText = ``;
            this.template.querySelector('.OverrideCSS').innerHTML='';

        }
        for(var i in this.folderOptions){
            this.folderOptions[i].isSelected=false;
            if(this.folderOptions[i].value==this.selectedFolder){
                this.folderOptions[i].isSelected=true;
            }
           
        }
      
    }
    handleUpdate(event) {
        if (this.selectedEmails.length ==0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Warning',
                    message: 'No any email is selected. Please select any email(s) to save into box folder !',
                    variant: 'warning'
                })
            );
            return;
        }
        this.spinnerStatus=true;
        sendEmailToBox({emailIds: this.selectedEmails,caseId : this.recordId,boxFolderName : this.selectedFolder})
            // .then(result => {
            //     // Show a success message
            // })
            .then(result => {
                this.spinnerStatus=false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Email record(s) has been send to Box folder!',
                        variant: 'success'
                    })
                ); 
                eval("$A.get('e.force:refreshView').fire();");  
                this.dispatchEvent(new CloseActionScreenEvent());
                
                    
                // make a call to Box API to save the email records in the folder related to the Opportunity record
                // associated with the case record
            })
            .catch(error => {
                this.spinnerStatus=false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    
    }
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}