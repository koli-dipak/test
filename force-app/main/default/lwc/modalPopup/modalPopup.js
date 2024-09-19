import { LightningElement, api, track } from 'lwc';

export default class ModalPopup extends LightningElement{
  @api getCurrentLob;
  @api coverageId;

  showModal = false;
  @api selectedIds;
  @api show(selected) {
    this.showModal = true;
    this.selectedIds=selected;
  }

  @api selectCoverageForm() {
    this.addForms = true;
    this.extForm = false;
    this.HeaderTitle = "Select Required Forms";
    this.FooterBtnTitle = "Add Forms in Coverages";
  }

  @api extAddForms() {
    this.extForm = true;
    this.addForms = false;
    this.HeaderTitle = "Extension";
    this.FooterBtnTitle = "Add In Country";
  }

  handleDialogClose() {
    this.showModal = false;
  }


  //--------------------23-08-2022
  @api selectedFormData = "[]";
  
  hanldeFormDataChange(event) {
    this.selectedFormData = event.detail.FormData;
  }

  // @api formsIds = []; // this is using in add form.js
  addFormInCov() {
      if(this.selectedFormData != undefined && this.selectedFormData != "[]"){
        var selectedEvent = new CustomEvent("selectedformdataadd", {
            detail: {
              "FormData": this.selectedFormData
            }
      
          });
          // Dispatches the event.
          this.dispatchEvent(selectedEvent);
          this.showModal = false;
      }else{
        this.showModal = false;
      }

    //-------------------------------------23-08-2022---------------------
    // var selectedEvent = new CustomEvent("selectedformdataadd", {
    //   detail: {
    //     "FormData": this.selectedFormData
    //   }

    // });
    // Dispatches the event.
    // this.dispatchEvent(selectedEvent);
    // this.showModal = false;
  }

}