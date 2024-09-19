import { LightningElement, api, wire } from 'lwc';
// import getPoliciesAndInstecDetilsFromLob from '@salesforce/apex/RenewalInstecCls.getPoliciesAndInstecDetilsFromLob';
import getRenewalLob from '@salesforce/apex/RenewalInstecCls.getRenewalLob';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class StartRenewalInInstec extends LightningElement {
    @api recordId;
    isLoaded = true;
    // @wire(getPoliciesAndInstecDetilsFromLob, { LobRecordId: '$recordId'})
    // searchResult({ data, error }) { 
    //   if (data) {
    //     console.log('@@data::', data);
    //   } else if (error) {
    //     console.error(error);
    //   }
    // }

    //connectedCallback(){
        // getPoliciesAndInstecDetilsFromLob ({LobRecordId: this.recordId})
        // .then(result => {
        //     console.log('outputresult : ', result );     
        // })
        // .catch(error => {
        //     console.error('@@Error',error);
        // });
        /*
        console.log('recordId0', this.recordId);
        getRenewalLob({LobRecordId: this.recordId})
        .then(result => {
            console.log('outputresult : ', result );     
        })
        .catch(error => {
            console.error('@@Error',error);
        });*/  
    //}

    connectedCallback() {
      // Use setTimeout to wait for recordId to be set
      setTimeout(() => {
          if (this.recordId) {
              console.log('recordId:', this.recordId);
              getRenewalLob({ LobRecordId: this.recordId })
                  .then(result => {
                      console.log('outputresult : ', result);
                      this.isLoaded = !this.isLoaded;
                      this.dispatchEvent(new CloseActionScreenEvent());
                      const evt = new ShowToastEvent({
                        title : 'Success!',
                        message : 'The Instec LOB has been sent for renewal with the new Opportunity ID. You can now proceed with other tasks.',
                        variant : 'success',
                      });
                      this.dispatchEvent(evt);
                  })
                  .catch(error => {
                      console.error('@@Error', error);
                      const evt = new ShowToastEvent({
                        title : 'Error',
                        message : 'This Instec LOB could not be sent to Instec for renewal. Please reach out to {0} to get the error resolved or alternatively, it will need to be processed manually.',
                        variant : 'error',
                        messageData : [{
                            url : 'mailto:helpdesk@n2g.com',
                            label : 'helpdesk@n2g.com'
                        }]
                      });
                      this.dispatchEvent(evt);
                  });
          }
      },0);
  }
}