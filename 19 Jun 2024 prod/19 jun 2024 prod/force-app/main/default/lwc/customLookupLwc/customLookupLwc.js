/*
API : 50
Source : lwcFactory.com
*/
import { LightningElement,api,wire, track} from 'lwc';
// import apex method from salesforce module 
import fetchLookupData from '@salesforce/apex/CustomLookupLwcController.fetchLookupData';
import fetchDefaultRecord from '@salesforce/apex/CustomLookupLwcController.fetchDefaultRecord';

const DELAY = 300; // dealy apex callout timing in miliseconds  
// var additionalContact;
// var refereshData;
// var reSelectRec;
// var newRecToSelect;

export default class CustomLookupLwc extends LightningElement {
    // public properties with initial default values 
    @api label = 'custom lookup label';
    @api placeholder = 'search...'; 
    @api iconName = 'standard:account';
    @api sObjectApiName = 'Account';
    @api _defaultRecordId = '';
    @api extraField='';
    @api displayField='Name';
    @api whereClauseField='';
    @api whereClauseValue='';
    @api displayFieldSeprator='';
    @api createNewRecordText='';
    @api _removeSelectedRecord=false;
    @api additionalData;
    @api required=false;
   

    
    @track selectedRecord = {}; // to store selected lookup record in object formate 
    @api additionalContact;
    @api
    get additionalContactRecords() {
        return this.additionalContact;
    }
    set additionalContactRecords(value) { 
        if(value!=null){
        this.additionalContact=JSON.stringify(value); 
            if(this.additionalContact!=null){
                this.newContactList=JSON.parse(this.additionalContact);

                if(this.selectedRecord!=undefined &&  this.createNewRecordText == this.selectedRecord.displayText){
                    let data=JSON.parse(this.additionalContact);
                    if(data.length>0){
                        this.selectedRecord=data[data.length-1];
                        
                        console.log('this.selectedRecord :: ',this.selectedRecord)
                    }
                }else if(this.selectedRecord!=undefined){
                    var record= this.newContactList.find(data => data.Email === this.selectedRecord.Email); 
                    if(record!=undefined){
                        this.selectedRecord=record;
                    }
                
                }

            }
        } 
    
    }

    @api 
    get checkRequired() {
        return false;
    }
    set checkRequired(element) {
        if(element!=undefined && element.index!=undefined && element.index==this.additionalData)this.validateRequired();
    }

    @api
    get removeSelectedRecord() {
        return this._removeSelectedRecord;
    }
    set removeSelectedRecord(value) {
        this._removeSelectedRecord=value;
        if(this._removeSelectedRecord!=undefined && this._removeSelectedRecord.index==this.additionalData){
            if(JSON.stringify(this.selectedRecord) !='{}')this.handleRemove();
        }
        
    }

    @api
    get defaultRecordId() {
        return this._defaultRecordId;
    }
    set defaultRecordId(value) {
        if(typeof value ==='object' && value !==null){
            
            this._defaultRecordId=value.Id;
            if(this._defaultRecordId==undefined && value.Email!=null && value.isCancelled!=true){
                setTimeout(function(){
                    this.selectedRecord=JSON.parse(JSON.stringify(value))
                    if(this.selectedRecord.Name==undefined){
                        this.selectedRecord.Name = (this.selectedRecord.FirstName!=undefined?this.selectedRecord.FirstName:'') +' '+(this.selectedRecord.LastName!=undefined?this.selectedRecord.LastName:'')
                    }
                    if(this.selectedRecord.displayText==undefined){
                        this.selectedRecord.displayText=this.getDisplayText(this.selectedRecord);
                    }
                    this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
                }.bind(this),200);
            }
            // if(this._defaultRecordId==undefined){
            //     if(reSelectRec!=undefined){
            //         newRecToSelect=(JSON.stringify(value));
            //         setTimeout(reSelectRec,300);
            //     }
            // }
            
        }else{
            this._defaultRecordId=value;
        }
        this.connectedCallback();
    }

    @track newContactList=[];
    @track validationClasscode='';
    @track validationError=false;
    // private properties 
    lstResult = []; // to store list of returned records   
    hasRecords = true; 
    searchKey=''; // to store input field value    
    isSearchLoading = false; // to control loading spinner  
    delayTimeout;

    // initial function to populate default selected lookup record if defaultRecordId provided  
    connectedCallback(){

         if(this.defaultRecordId != ''){
            fetchDefaultRecord({ recordId: this.defaultRecordId , 'sObjectApiName' : this.sObjectApiName ,ExtraField :this.extraField,whereClauseField :this.whereClauseField,whereClauseValue : this.whereClauseValue})
            .then((result) => {
                if(result != null){
                    var rec=JSON.parse(JSON.stringify(result));
                    rec["displayText"]=this.getDisplayText(rec);
                    this.selectedRecord = rec;
               
                    this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
                }
            })
            .catch((error) => {
                this.error = error;
                this.selectedRecord = {};
            });
         }

        //  if(refereshData==undefined){
        //     refereshData=function(){
        //         if(additionalContact!=null){
        //             this.newContactList=JSON.parse(additionalContact);
       
        //             let data=JSON.parse(additionalContact);
        //             if(data.length>0){
        //                 this.selectedRecord=data[data.length-1];
                        
        //                console.log('this.selectedRecord :: ',this.selectedRecord)
        //             }
                    
        //         }
        //      }.bind(this);
        //  }
        
        //  if(reSelectRec==undefined){
        //     reSelectRec=function(){
        //         if(newRecToSelect!=null && newRecToSelect!=''){
        //             this.selectedRecord=JSON.parse(newRecToSelect);
        //             newRecToSelect=null;
        //         }
        //      }.bind(this);
        //  }
         

    }
   
    // wire function property to fetch search record based on user input
    @wire(fetchLookupData, { searchKey: '$searchKey' , sObjectApiName : '$sObjectApiName' ,ExtraField :'$extraField',whereClauseField :'$whereClauseField',whereClauseValue : '$whereClauseValue'})
     searchResult(value) {
        const { data, error } = value; // destructure the provisioned value
        this.isSearchLoading = false;
        if (data) {
             this.hasRecords = data.length == 0 ? false : true; 
             let records=[];
             
             for(var i in data){
                var rec=JSON.parse(JSON.stringify(data[i]));
                
                rec["displayText"]=this.getDisplayText(rec);
                records.push(rec);
             }
             if(this.createNewRecordText!=''){
                var rec={}
                rec.Id='';
                rec.displayText=this.createNewRecordText
                records.push(rec);
             }
             this.lstResult = records; 
             this.hasRecords = records.length == 0 ? false : true; 
         }
        else if (error) {
            console.log('(error---> ' + JSON.stringify(error));
         }
    };

    validateRequired(){
        if(this.required){
            this.validationError=false;
            this.validationClasscode='';
            if(this.selectedRecord==undefined || this.selectedRecord.Email==null){
                this.validationError=true;
            }
            this.template.querySelectorAll('lightning-input').forEach(element => {
                if(this.validationError) this.validationClasscode='slds-has-error';
            }); 
        }
    }
    getDisplayText(rec){
        var displayText='';
        var displayFields= this.displayField.split(',');
        var displayFieldSeprators=this.displayFieldSeprator.split(',')
        for(var i in displayFields){
            if(rec[displayFields[i]]==undefined){
                rec[displayFields[i]]="";
            }
            if(displayFieldSeprators.length<=i || rec[displayFields[i]] ==""){
                displayText+=rec[displayFields[i]]+' ';
            }else{

                if(displayFieldSeprators[i].length==2){
                    displayText+=displayFieldSeprators[i][0]+rec[displayFields[i]]+displayFieldSeprators[i][1];
                }else{
                    displayText+=rec[displayFields[i]]+((displayFieldSeprators[i]=='')?' ':displayFieldSeprators[i]);
                }
                
            }
        }
        return displayText.trim();
    }
       
  // update searchKey property on input field change  
    handleKeyChange(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        this.isSearchLoading = true;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
        this.searchKey = searchKey;
        }, DELAY);
    }


    // method to toggle lookup result section on UI 
    toggleResult(event){
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        switch(whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');
               break;
            case 'lookupContainer':
                clsList.remove('slds-is-open');    
            break;                    
           }
    }

   // method to clear selected lookup record  
   handleRemove(){
    console.log('inside handle remove ');
    this.searchKey = '';    
    this.selectedRecord = {};
    this.lookupUpdatehandler(undefined); // update value on parent component as well from helper function 
    
    // remove selected pill and display input field again 
    const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
     searchBoxWrapper.classList.remove('slds-hide');
     searchBoxWrapper.classList.add('slds-show');

     const pillDiv = this.template.querySelector('.pillDiv');
     pillDiv.classList.remove('slds-show');
     pillDiv.classList.add('slds-hide');

     this.validateRequired();
  }

    // method to update selected record from search result 
    handelSelectedRecord(event){   
        var objId = event.target.getAttribute('data-recid'); // get selected record Id
        if(objId!=undefined && objId!=""){
            this.selectedRecord = this.lstResult.find(data => data.Id === objId); // find selected record from list 
            if(this.selectedRecord==undefined){
                this.selectedRecord = this.newContactList.find(data => data.Email === objId); // find selected record from list 
            }
        }else{
            var rec={}
            rec.Id='';
            rec.displayText=this.createNewRecordText
            this.selectedRecord=rec;
        }
        
        this.lookupUpdatehandler(this.selectedRecord); // update value on parent component as well from helper function 
        this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
    }

    /*COMMON HELPER METHOD STARTED*/

    handelSelectRecordHelper(){
        this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');

        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        searchBoxWrapper.classList.remove('slds-show');
        searchBoxWrapper.classList.add('slds-hide');

        const pillDiv = this.template.querySelector('.pillDiv');
        pillDiv.classList.remove('slds-hide');
        pillDiv.classList.add('slds-show');     
    }

    // send selected lookup record to parent component using custom event
    lookupUpdatehandler(value){    
        const oEvent = new CustomEvent('lookupupdate',
        {
            'detail': {selectedRecord: value,additionalData : this.additionalData}
        }
    );
    this.dispatchEvent(oEvent);
    }
    
    showToast(title,message,type) {
        const event = new ShowToastEvent({
            "title": title,
            "message":message,
            "variant":type
        });
        this.dispatchEvent(event);
    }
}