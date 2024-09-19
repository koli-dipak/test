import { LightningElement, api, track } from 'lwc';
export default class DemoEmailErrorMessage extends LightningElement {
    @api slaMetadataRecord;
    @api selectedEmails;
    @api matchedEmailAddress = '';
    @api unmatchedEmailAddress = '';

    @track isEmailNotMatched = false;

    /*
    connectedCallback() {
        console.log('OUTPUT slaMetadataRecord : ',this.slaMetadataRecord);
        console.log('OUTPUT selectedEmails : ',this.selectedEmails);

        // Convert comma-separated emails from slaMetadataRecord to an array
        const allSlaEmails = this.slaMetadataRecord.reduce((emails, record) => {
            const recipientEmails = record.Recipient_Email__c.split(',');
            return emails.concat(recipientEmails.map(email => email.trim().toLowerCase()));
        }, []);
        console.log('allSlaEmails', allSlaEmails);

        // this.selectedEmails = this.selectedEmails.map(email => email.toLowerCase());
        // console.log('@@this.selectedEmails', this.selectedEmails);

        // Check if any selected email is not in the list of SLA emails
        const notMatchedEmail = this.selectedEmails.find(selectedEmail => {
            return !allSlaEmails.includes(selectedEmail);
        });

        console.log('notMatchedEmail : ',notMatchedEmail);

        this.isEmailNotMatched = !!notMatchedEmail;
        console.log('isEmailNotMatched : ',this.isEmailNotMatched);

        // add logic for matched and unmatched email
        let matchedEmail = '';
        let noMatchedEmail = '';
        this.selectedEmails.forEach(selectedEmail => {
            if (allSlaEmails.includes(selectedEmail)) {
                // matchedEmail += matchedEmail ? `, ${selectedEmail}` : selectedEmail;
                 matchedEmail = matchedEmail ? matchedEmail + ',' + selectedEmail : selectedEmail;
            } else {
                // noMatchedEmail += noMatchedEmail ? `, ${selectedEmail}` : selectedEmail;
                noMatchedEmail = noMatchedEmail ? noMatchedEmail + ',' + selectedEmail : selectedEmail;
            }
        });

        this.matchedEmailAddress = matchedEmail == undefined || matchedEmail == ""?"null":matchedEmail;
        this.unmatchedEmailAddress = noMatchedEmail == undefined || noMatchedEmail == ""?"null":noMatchedEmail;

        console.log('OUTPUT matchedEmailAddress: ',this.matchedEmailAddress);
        console.log('OUTPUT unmatchedEmailAddress: ',this.unmatchedEmailAddress);
    } */
    

    connectedCallback() {
        // Convert comma-separated emails from slaMetadataRecord to an array
        const allSlaEmails = this.slaMetadataRecord.reduce((emails, record) => {
            const recipientEmails = record.Recipient_Email__c.split(',');
            return emails.concat(recipientEmails.map(email => email.trim().toLowerCase()));
        }, []);

        // Check if any selected email is in the list of SLA emails
        const foundInSLA = this.selectedEmails.some(selectedEmail => allSlaEmails.includes(selectedEmail));

        if (foundInSLA) {
            this.matchedEmailAddress = this.selectedEmails.join(',');
            this.unmatchedEmailAddress = 'null';
        } else {
            this.matchedEmailAddress = 'null';
            this.unmatchedEmailAddress = this.selectedEmails.join(',');
            this.isEmailNotMatched = true;
        }
    }
    
}