import { LightningElement, wire, api, track } from 'lwc'
import getLOBRecords from '@salesforce/apex/MultiselectLOBPremiumHelper.getLOBRecords'
import updateLOBRecords from '@salesforce/apex/MultiselectLOBPremiumHelper.updateLOBRecords'
import updateLOBEffectiveDateRecords from '@salesforce/apex/MultiselectLOBPremiumHelper.updateLOBEffectiveDateRecords'
import updateLOBUnderWriterRecords from '@salesforce/apex/MultiselectLOBPremiumHelper.updateLOBUnderWriterRecords'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation'
import { CloseActionScreenEvent } from 'lightning/actions';

/*const COLS = [
  { label: 'Name', fieldName: 'Name', type: 'text' },
  {
    label: 'Target Premium',
    fieldName: 'Estimated_LOB_Premium__c',
    type: 'text'
  }
]*/

export default class MultiselectLOBPremium extends NavigationMixin(
  LightningElement
) {
  // cols = COLS
  @api OpportunityId
  @api ActionName
  LOBList
  isLoading = false
  responseMap = {}
  instructionNoteMap = {}
  probabilityMap = {}
  get isUpdatePremium () {
    if (this.ActionName == 'UpdatePremium') {
      return true
    }
    return false
  }

  get isUpdateEffectiveDate () {
    if (this.ActionName == 'UpdateEffectiveDate') {
      return true
    }
    return false
  }

  get isUpdateUnderWriter () {
    if (this.ActionName == 'UpdateUnderWriter') {
      return true
    }
    return false
  }

  connectedCallback () {
    console.log('this.ActionName::',this.ActionName);
    getLOBRecords({ OpportunityId: this.OpportunityId })
      .then(result => {
        this.LOBList = result
        this.error = undefined
      })
      .catch(error => {
        this.error = error
        console.log(error)
        this.LOBList = undefined
      })
  }

  handleChange (event) {
    this.responseMap[event.currentTarget.dataset.id] = event.detail.value
  }
  handleProbabilityChange(event){
    this.probabilityMap[event.currentTarget.dataset.id] = event.detail.value
  }

  handleUnderwriterNoteChange(event){
    this.instructionNoteMap[event.currentTarget.dataset.id] = event.detail.value
  }

  handleClick (event) {
    this.isLoading = true

    if (this.ActionName == 'UpdatePremium') {
      updateLOBRecords({ responseMap: this.responseMap, probabilityMap: this.probabilityMap})
        .then(result => {
          console.log('result::: ', result)
          this.error = undefined
        })
        .catch(error => {
          this.error = error
          console.log(error)
        })
      setTimeout(() => {
        this.isLoading = false
        this.showToast('Success!!','success','Record Updated SuccessFully!!')
        setTimeout(() => {
        this.reloadPage()
      }, 1000)
      }, 1000)
    }

    if (this.ActionName == 'UpdateEffectiveDate') {
      updateLOBEffectiveDateRecords({ responseMap: this.responseMap })
        .then(result => {
          console.log('result::: ', result)
          this.error = undefined
        })
        .catch(error => {
          this.error = error
          console.log(error)
        })
      setTimeout(() => {
        this.isLoading = false
        this.showToast('Success!!','success','Effective Dates Updated SuccessFully!!')
        setTimeout(() => {
        this.reloadPage()
      }, 1000)
      }, 1000)
    }

    if (this.ActionName == 'UpdateUnderWriter') {
      console.log('@@this.responseMap::',this.responseMap);
      for(var key in this.responseMap){
        console.log('key::::',key); 
        console.log('temp1[key]::',this.responseMap[key])
        if(this.responseMap[key] == null){
          console.log('Null value found:::::');
          this.showToast('Error!!','error','Referred User cannot be updated to blank,changes cannot be save!!')
          console.log('before return::::');
          this.isLoading = false;
          return;
          console.log('after return:::');
        }
      }
      console.log('Outside for loop');
      updateLOBUnderWriterRecords({ responseMap: this.responseMap, OpportunityId : this.OpportunityId, instructionNoteMap: this.instructionNoteMap })
        .then(result => {
          console.log('result::: ', result)
          this.error = undefined
        })
        .catch(error => {
          this.error = error
          console.log(error)
        })
      setTimeout(() => {
        this.isLoading = false
        this.showToast('Success!!','success','UnderWriters Updated SuccessFully!!')
        setTimeout(() => {
        this.reloadPage()
      }, 1000)
      }, 1000)
    }
  }

  showToast (title, variant, message) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    })
    this.dispatchEvent(event)
  }

  reloadPage () {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: this.OpportunityId,
        objectApiName: 'Opportunity',
        actionName: 'view'
      }
    })
    eval("$A.get('e.force:refreshView').fire();")
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  lookupRecord(event){
    console.log('event.detail.selectedRecord:::',event.detail.selectedRecord);
    if(event.detail.selectedRecord != undefined && event.detail.selectedRecord != null && event.detail.selectedRecord != ""){
      console.log('event.detail.selectedRecord.Id:::',event.detail.selectedRecord.Id);
      console.log('event.currentTarget.dataset.id:::',event.currentTarget.dataset.id);
      this.responseMap[event.currentTarget.dataset.id] = event.detail.selectedRecord.Id;
    }
    else{
      this.responseMap[event.currentTarget.dataset.id] = null;
    }
    console.log('this.responseMap:::',this.responseMap);
  }

}