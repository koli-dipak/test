import { LightningElement, api, wire, track } from 'lwc';
import fetchLookupData from '@salesforce/apex/ContactController.fetchLookupData'; 
import fetchDefaultRecord from '@salesforce/apex/ContactController.fetchDefaultRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";
import insertContactRecord from '@salesforce/apex/ContactController.insertContactRecord';
const DELAY = 300;

export default class AllContacts extends NavigationMixin(LightningElement) {
  @api label = 'Contact Name';
  @api placeholder = 'Search...';
  @api iconName = 'standard:contact';
  @api sObjectApiName = 'Contact';
  @api defaultRecordId = '';
  @api oEvent;
  @api locationRecordId;
  @api loctionIndex;
  @api emailList=[];
  @api EmailString;
  @api RecordTypeId; //m
  @api accountId; //m
  @api contactRecordTypeId; //m
  @api UnlockAccountorContact = false; // is survey request vendor flow;


  @track showCreateContactComponent = false;
  // @track createContactClick = false; //m
  @track isModalOpen = false; //m
  @track isSpinnerLoad = false;//m
  // @track handleSubmitBtn = {};

  showCreateContact() {
    this.showCreateContactComponent = true;
    console.log('this.CreateContactComponent_______', this.showCreateContactComponent);
  }

  showCreateContactWithNavigation() {
    this[NavigationMixin.Navigate]({
      type: "standard__component",
      attributes: {
        componentName: "c__newContactRecordPage "
      }
    });
  }

  @api lstResult = [];
  hasRecords = true;
  @api searchKey = '';
  isSearchLoading = false;
  @api selectedContacts = [];
  @api selectedRecord = {};

  connectedCallback() {
    if (this.defaultRecordId) {
      fetchDefaultRecord({ recordId: this.defaultRecordId, sObjectApiName: this.sObjectApiName })
        .then((result) => {
          if (result) {
            this.selectedRecord = result;
          }
        })
        .catch((error) => {
          console.error(error);
        });
    }
  }

  @wire(fetchLookupData, { searchKey: '$searchKey', sObjectApiName: '$sObjectApiName' })
  searchResult({ data, error }) {
    this.isSearchLoading = false;
    if (data) {
      this.hasRecords = data.length > 0;
      this.lstResult = JSON.parse(JSON.stringify(data));
      console.log('@@data::', this.lstResult);
    } else if (error) {
      console.error(error);
    }
  }

  handleKeyChange(event) {
    this.isSearchLoading = true;
    clearTimeout(this.delayTimeout);
    const searchKey = event.target.value;
    this.delayTimeout = setTimeout(() => {
      this.searchKey = searchKey;
    }, DELAY);
  }

  toggleResult() {
    // fetchLookupData({ searchKey: this.defaultRecordId, sObjectApiName: this.sObjectApiName })
    //     .then((result) => {
    //       if (result) {
    //         this.lstResult = JSON.parse(JSON.stringify(result));
    //         console.log('@@data::', this.lstResult);
    //       }
    //     })
    //     .catch((error) => {
    //       console.error(error);
    //     });

    const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
    lookupInputContainer.classList.toggle('slds-is-open');
  }

  handleRemoveContact(event) {
    console.log(event.currentTarget.dataset.contactId);
    const contactId = event.currentTarget.dataset.contactId;
    const removeContactIndex = parseFloat(event.currentTarget.dataset.contactIndex);
    this.selectedContacts = this.selectedContacts.filter((contact) => contact.Id !== contactId);

    // mu
    const event1 = new CustomEvent('removeselectedcontact', {
      detail: { contactRecords: contactId, locationRecordId: this.locationRecordId, loctionIndex: this.loctionIndex, removeContactIndex: removeContactIndex }
    });
    this.dispatchEvent(event1);
    this.emailList=this.selectedContacts.map((contact) => contact.Email);
    this.EmailString=this.emailList.join(',');
  }

  handelSelectedRecord(event) {
    const objId = event.target.dataset.recid;
    const selectedContact = this.lstResult.find((data) => data.Id === objId);
    if(selectedContact.Email && !this.emailList.includes(selectedContact.Email)){
      this.emailList.push(selectedContact.Email);
      this.EmailString=this.emailList.join(',');
    }
    const existingContact = this.selectedContacts.find((loc) => loc.Id === selectedContact.Id);
    if (!existingContact) {
      this.selectedContacts = [...this.selectedContacts, selectedContact];
      const event1 = new CustomEvent('selectedcontact', {
        detail: { contactRecords: selectedContact, locationRecordId: this.locationRecordId, loctionIndex: this.loctionIndex, selectedContacts: this.selectedContacts }
      });
      this.dispatchEvent(event1);
    }
  }

  // handel select form new contact record (N2G-526)
  handelSelectFormNewContactRecord(createdContactId) {
    const objId = createdContactId;
    const selectedContact = this.lstResult.find((data) => data.Id === objId);
    if(selectedContact.Email && !this.emailList.includes(selectedContact.Email)){
      this.emailList.push(selectedContact.Email);
      this.EmailString=this.emailList.join(',');
    }
    const existingContact = this.selectedContacts.find((loc) => loc.Id === selectedContact.Id);
    if (!existingContact) {
      this.selectedContacts = [...this.selectedContacts, selectedContact];
      const event1 = new CustomEvent('selectedcontact', {
        detail: { contactRecords: selectedContact, locationRecordId: this.locationRecordId, loctionIndex: this.loctionIndex, selectedContacts: this.selectedContacts }
      });
      this.dispatchEvent(event1);
    }
  }


  handleAddContacts() {
    console.log(this.selectedContacts);
  }

  lookupUpdatehandler(value) {
    this.oEvent = value;
    const customEvent = new CustomEvent('lookupupdate', {
      detail: { selectedRecord: value }
    });
    this.dispatchEvent(customEvent);
  }

  // add for N2G-526
  handleCreateContactRecords(event){
    // this.createContactClick = true;
    this.isModalOpen = true;
  }
  closeModal() {
    this.isModalOpen = false;
    // this.dispatchEvent(new CustomEvent('close'))
  }
  /*handleSubmit(event) {
    let fields = event.detail.fields;
    event.preventDefault(); // Prevent default form submission
    console.log("fields", JSON.parse(JSON.stringify(fields)));
    this.template.querySelector('lightning-record-edit-form').submit(fields); // Call the submit method
    // this.isModalOpen = false;
    this.isSpinnerLoad = true;
  }*/

  handleSubmit(event){
    let fields = event.detail.fields;
    event.preventDefault(); // Prevent default form submission
    if(this.UnlockAccountorContact){
      this.isSpinnerLoad = true;
      insertContactRecord ({contatcRecord: fields})
      .then(result => {
          console.log('outputresult : ',JSON.parse(JSON.parse(result)));
          // for(let x in JSON.parse(JSON.parse(result))){
            // this.searchKey = result[x].LastName;
            this.searchKey = JSON.parse(JSON.parse(result)).LastName;
          // }
          this.isSpinnerLoad = false;
          this.isModalOpen = false;
          this.toggleResult();
      })
      .catch(error => {
        console.error('@@Error',error);
        this.isSpinnerLoad = false;
        this.handleError(error);
      });
    }else {
      this.template.querySelector('lightning-record-edit-form').submit(fields); // Call the submit method
      this.isSpinnerLoad = true;
    }
    
  }


  handleSuccess( event ) {
    this.isSpinnerLoad = false;
    console.log( 'Updated Record Id is ', event.detail.id );
    console.log( 'Record info is ', event.detail.fields.LastName.value);
    this.searchKey = event.detail.fields.LastName.value;
    // this.searchKey = '';
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Successful Contact Created',
            // message: 'Record Created Surccessfully!!!', // This success message is change due to N2G-644
            message: 'Success! Your new contact has been added',
            variant: 'success'
        })
    );
    this.isModalOpen = false;
    this.dispatchEvent(new CustomEvent('close'))
    this.toggleResult();
    // this.handelSelectFormNewContactRecord(event.detail.id);
  }
  handleError( error ) {
      this.isSpinnerLoad = false;
      console.log("error");
      // this.error = true;
      this.dispatchEvent(
          new ShowToastEvent({
              title: 'Error',
              // message: 'Error While Creating Contact Record',
              message: 'Duplicate contact Record Found',
              // title: 'Duplicate Record',
              // message: 'The record you are about to create looks like a duplicate. Open an existing record instead',
              variant: 'error'
          })
      );
  }
  handlesSubmit(){	
    this.template.querySelector('[data-id="Submit_Button"]').click();
  }
}