import { LightningElement  ,api} from 'lwc';

export default class DemoEmailMessage extends LightningElement {

    // @api defaultemailBody = '<p>Dear User, with regards to {!Get_Case_Record.Account.Name},</p><p><br></p><p>Please assign a {!Get_Case_Record.Visit_Type__c} risk engineering request.</p><p><br></p><p>The reason for the request is: {!Get_Case_Record.Reason_for_Request__c}.</p><p><br></p><p>1. Real property value: </p><p><br></p><p>2. BPP value: </p><p><br></p><p>3. BI value: </p><p><br></p><p>4. Location TIV: </p>'
    @api defaultemailBody 
    @api finalemailBody 
    @api slaMetadataRecord; //m 22/08/2023

    connectedCallback() {
      this.finalemailBody=this.defaultemailBody
      console.log('slaMetadataRecord',this.slaMetadataRecord);
    }

  handleRichTextChange(event) {
    // Update the richTextValue when the content changes
    this.finalemailBody = event.target.value;
  }
}

// import { LightningElement } from 'lwc';

// export default class DemoEmailMessage extends LightningElement {
//     defaultEmailBody = 'Default email body content';

//     handleUseEmailBody() {
//         const demoEmailMessage = this.template.querySelector('c-demo-email-message');
//         const emailBody = demoEmailMessage.getFinalEmailBody();

//         // Use the email body value in your logic (e.g., send an email, save to database, etc.)
//         console.log('Email Body:', emailBody);
//     }
// }