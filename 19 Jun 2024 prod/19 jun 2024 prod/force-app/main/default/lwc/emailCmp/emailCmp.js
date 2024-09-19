import { LightningElement, track, api } from "lwc";
import sendEmail from "@salesforce/apex/EmailHelperClass.sendEmail";
import getDefaultEmailTemplateRecord from "@salesforce/apex/EmailHelperClass.getDefaultEmailTemplateRecord";
import getDynamicEmailTemplateRecord from "@salesforce/apex/EmailHelperClass.getDynamicEmailTemplateRecord";
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { CloseActionScreenEvent } from 'lightning/actions';

export default class EmailCmp extends LightningElement {
    toAddress = [];
    ccAddress = [];
    subject = "";
    body = "";
    @track files = [];
    @track _recordId;
    emailTemplateSubject;
    emailTemplateBody;
    emailTemplateName;

    wantToUploadFile = false;
    noEmailError = false;
    invalidEmails = false;
    isLoading = false;
    contactId;

    /*toggleFileUpload() {
        this.wantToUploadFile = !this.wantToUploadFile;
    }*/


    @api set recordId(value) {
        this._recordId = value;
        this.getDefaultEmailValues();
        // do your thing right here with this.recordId / value
    }
    
    get recordId() {
        return this._recordId;
    }


    getDefaultEmailValues(){
        console.log('getDefaultEmailValues::');
        console.log('@@_recordId',this._recordId);
        if(this._recordId == null )
        return;
        getDefaultEmailTemplateRecord()
          .then(result => {
            console.log('result::',result);
            this.emailTemplateSubject = result.Subject;
            this.emailTemplateBody = result.HtmlValue;
            this.emailTemplateName = result.Name;
            this.body = result.HtmlValue;
            this.subject = result.Subject;
            this.error = undefined
          })
          .catch(error => {
            this.error = error
            console.log('@@error::',error)
          })
    }

    /*handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        this.files = [...this.files, ...uploadedFiles];
        this.wantToUploadFile = false;
    }*/

    /*handleRemove(event) {
        const index = event.target.dataset.index;
        this.files.splice(index, 1);
    }*/

    getDynamicEmailTemplateBody(ContactId){
        this.isLoading = true;
        getDynamicEmailTemplateRecord({ContactId: ContactId})
          .then(result => {
            console.log('result::',result);
            this.body = result.HtmlValue;
            this.subject = result.Subject;
            this.error = undefined
            this.isLoading = false;
          })
          .catch(error => {
            this.error = error
            this.isLoading = false;
            console.log('@@error::',error)
          })
    }

    handleToAddressChange(event) {
        console.log('@@event.detail.selectedValues.length::'+event.detail.selectedValues.length);
        /*if(event.detail.selectedValues.length > 1){
            this.showToast('Error!!','error',"You cannot send email to multiple contacts. else put them in Cc.");
            return;
        }*/
        this.toAddress = event.detail.selectedValues;
    }

    handleValueSelect(event){
        console.log('@@this.toAddress.length::'+this.toAddress.length);
       /* if(this.toAddress.length > 1){
            return;
        }*/
        this.contactId = event.detail.selectedId;
        this.getDynamicEmailTemplateBody(event.detail.selectedId);
    }

    handleCcAddressChange(event) {
        this.ccAddress = event.detail.selectedValues;
    }

    handleSubjectChange(event) {
        this.subject = event.target.value;
    }

    handleBodyChange(event) {
        this.body = event.target.value;
    }

    validateEmails(emailAddressList) {
        let areEmailsValid;
        if(emailAddressList.length > 1) {
            areEmailsValid = emailAddressList.reduce((accumulator, next) => {
                const isValid = this.validateEmail(next);
                return accumulator && isValid;
            });
        }
        else if(emailAddressList.length > 0) {
            areEmailsValid = this.validateEmail(emailAddressList[0]);
        }
        return areEmailsValid;
    }

    validateEmail(email) {
        console.log("In VE");
        const res = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()s[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        console.log("res", res);
        return res.test(String(email).toLowerCase());
    }

     handleReset() {
        this.toAddress = [];
        this.ccAddress = [];
        this.subject = this.emailTemplateSubject;
        this.body = this.emailTemplateBody;
        //this.files = [];
        
        this.template.querySelectorAll("c-email-input-cmp").forEach((input) => input.reset());
    }

    handleSendEmail() {
        this.isLoading = true;
        this.noEmailError = false;
        this.invalidEmails = false;
        if (![...this.toAddress, ...this.ccAddress].length > 0) {
            this.noEmailError = true;
            this.isLoading = false;
            this.showToast('Error!!','error',"Please add a recepient");
            return;
        }
        
        if (!this.validateEmails([...this.toAddress, ...this.ccAddress])) {
            this.invalidEmails = true;
            this.isLoading = false;
            this.showToast('Error!!','error',"Some of the emails added are invalid");
            return;
        }

        let emailDetails = {
            toAddress: this.toAddress,
            ccAddress: this.ccAddress,
            subject: this.subject,
            body: this.body
        };

        sendEmail({ emailDetailStr: JSON.stringify(emailDetails) ,contactId: this.contactId})
            .then(() => {
                console.log("Email Sent");
                this.isLoading = false;
                this.showToast('Success!!','success','Email Sent SuccessFully!!')
                eval("$A.get('e.force:refreshView').fire();")
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch((error) => {
                console.error("Error in sendEmailController:", error);
                this.isLoading = false;
                this.showToast('Error!!','error',"Error in sendEmailController:" + error);
                eval("$A.get('e.force:refreshView').fire();")
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }

    /*lookupRecord(event){
        if(event.detail.selectedRecord != undefined && event.detail.selectedRecord != null && event.detail.selectedRecord != ""){
          getEmailTemplateRecord({emailTemplateId: event.detail.selectedRecord.Id})
          .then(result => {
            this.body = result.HtmlValue;
            this.subject = result.Subject;
            this.error = undefined
          })
          .catch(error => {
            this.error = error
            console.log(error)
          })

        }
    }*/

    showToast (title, variant, message) {
        const event = new ShowToastEvent({
          title: title,
          message: message,
          variant: variant
        })
        this.dispatchEvent(event)
      }
}