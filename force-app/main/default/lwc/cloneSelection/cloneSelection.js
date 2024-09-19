import { LightningElement, track,api,wire } from 'lwc';
//import cloneProducts from '@salesforce/apex/CTRL_CloneApplicationWithQuote.cloneProducts';
//import getPremiumData from '@salesforce/apex/CTRL_CloneApplicationWithQuote.getForeignCasualtyFields';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";
//import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
export default class CloneSelection extends OmniscriptBaseMixin(NavigationMixin(LightningElement)) {
    @track recordApi = {};
    @track formInclude = false;
    @track isShowModal = false;
    @api recordApiData;

   
    showModalBox() {  
        this.isShowModal = true;
    }
    
    //  @api _recordId;
    @track _recordId;
    @api get recordId() {
        return _recordId;
    }
    set recordId(element) {
        this._recordId=element;
    //    if(element!=null){
    //         this.getPremiumDetail(element);
    //    }
    }

    @track coverages = [];
    @track formType=false;
    @track loaded = false;
    
     
    // @track AccountName;
    // @track EffectiveDate;
    // @track ExpiryDate;
    @track ActualPremium;
    // @track ExposureBase;
    @track GLOccurenceLimit;
    @track GLDeductible;

    connectedCallback(){
        if(this.recordApiData != undefined){

               // this._recordId = this.recordApiData.ApplicationID;
                // this.ActualPremium='$'+this.numberWithCommasnodecimals(this.recordApiData.GrossAPTotal!=undefined?this.recordApiData.GrossAPTotal.toFixed(0):0);
                this.ActualPremium='$'+this.numberWithCommasnodecimals(this.recordApiData.UWOverrideGrossOfCommTpTotal!=undefined?this.recordApiData.UWOverrideGrossOfCommTpTotal.toFixed(0):0);
                this.GLOccurenceLimit='$'+this.numberWithCommasnodecimals(this.recordApiData.GLOccurenceLimit!=undefined?this.recordApiData.GLOccurenceLimit.toFixed(0):0);
                this.GLDeductible='$'+this.numberWithCommasnodecimals((this.recordApiData.GLDeductible!=undefined && this.recordApiData.GLDeductible!="")?this.recordApiData.GLDeductible.toFixed(0):0);
            
                // this.ActualPremium='$'+this.numberWithCommasnodecimals(this.recordApi.ActualPremium);
                // this.GLOccurenceLimit='$'+this.numberWithCommasnodecimals(this.recordApi.GLOccurenceLimit);
                // this.GLDeductible='$'+this.numberWithCommasnodecimals(this.recordApi.GLDeductible);
              }
        
        // console.log("@@recordApiData", this.recordApi);
    
        this.recordApi = {
            cov : [
            {label: "Casualty Premium:(Includes Local Policies & Rater Excel File)", disabled : true, show : true, enable:true},
            {label: "Coverage:General Liability",disabled : true, show : true, enable:true , isCoverage:true},
            {label: "Coverage:General Liability Forms",disabled : true, show : true, enable:true ,isForm:true},
            {label: "Coverage:Auto Liability", disabled : true, show : true, enable:true, isCoverage:true},
            {label: "Coverage:Auto Liability Forms",disabled : true, show : true, enable:true,isForm:true},
            {label: "Coverage:Workers'Comp Liability", disabled : true, show : true, enable:true, isCoverage:true},
            {label: "Coverage:Workers'Comp Liability Forms",disabled : true, show : true, enable:true,isForm:true},
            {label: "Coverage:Emergency Assistance", disabled : true, show : true, enable:true, isCoverage:true},
            {label: "Coverage:Emergency Assistance Forms", disabled : true, show : true, enable:true,isForm:true},
            {label: "Coverage:Travel Accident and Medical Expense",disabled : true, show : true, enable:true, isCoverage:true},
            {label: "Coverage:Travel Accident and Medical Expense Forms",disabled : true, show : true, enable:true,isForm:true},
            {label: "Coverage:Trip Assistance", disabled : true, show : true, enable:true, isCoverage:true},
            {label: "Coverage:Trip Assistance Forms", disabled : true, show : true, enable:true,isForm:true}
                ]
        }
        console.log("@appliId",this._recordId)
        
        
 }

    checked = false;
    
    toggleButton(event) {
        this.checked = !this.checked;
        // this.recordApi=JSON.parse(JSON.stringify( this.recordApi));
        this.recordApi[event.target.name]= this.checked;
        console.log("this.checked@@@@",this.checked);
        // let currentLbl = event.target.value
        let currentLbl = event.target.value
        let isFormSelected = event.target.checked;
            if (currentLbl=='Forms and Endorsements') {
                this.formType=isFormSelected;
            }
            console.log("%%formType",this.formType);
        const data = this.recordApi.cov.find((item)=>item.label === currentLbl);
        console.log("@@lavb",data);
         data.dataId = `[data-id=${currentLbl}]`;
         console.log(data.dataId);
        // console.log("currentlabel",currentLbl)
        //cloneProducts().then(result=>{this.Applications=result});
        
        data.show = !data.show; 
        if(data.show == true) {
            data.txtcolor = "color: rgb(0, 92, 167);"
            this.coverages.push(currentLbl);
            // for(i=0;i<this.coverages.size();i++){
            //     if (this.coverages[i]=='Forms and Endorsements') {
            //         this.formType=true;
            //     }
            //                 }
            console.log("@SelectedCoverages111111111",this.coverages);
            console.log('this.formType@@',this.formType);
        }else{
            data.txtcolor = "color: rgb(97, 97, 97);"
            this.coverages = this.coverages.filter(v => v != currentLbl);
        }
       // cloneProducts({"recordId" : this.recordId , "recordType" : JSON.stringify(this.coverages)});
    }
    // getPremiumDetail(record){
    //     getPremiumData({"recordId" : record})
    //     .then((result) => {
    //         console.log(result);
    //         if(result != null){
    //             this.AccountName=result[0].Company_Name__c;
    //             this.EffectiveDate=result[0].Effective_Date__c;
    //             this.ExpiryDate=result[0].Expiry_Date__c;
    //             this.ExposureBase=result[0].Exposure_base__c;
    //             this.GLOccurenceLimit=result[0].GL_Occurrence_Limit__c;
    //             this.GLDeductible=result[0].GL_Deductible__c;
    //         }
    //     })
    //     .catch((error) => {
    //        console.log(error)
    //     });
    // }
    

    handleDataChange(event){
        for(var i=0;i<this.recordApi.cov.length;i++){
            if(this.recordApi.cov[i].label==event.target.value){
                this.recordApi.cov[i].show=event.target.checked;
            }
            if(this.recordApi.cov[i].label==event.target.value+' Forms'){
                this.recordApi.cov[i].enable=event.target.checked;
            }
        }
        this.recordApi=JSON.parse(JSON.stringify(this.recordApi));
    }
    CancelPage(){
        const selectEvent = new CustomEvent('modalclose', {
            detail: {'CancelPage' : false}
        });
        this.dispatchEvent(selectEvent);
    }
 
    CloneHandle(){
        this.loaded = !this.loaded
        var covg=[];
        var forms=[];
        for(var i in this.recordApi.cov){
            if(this.recordApi.cov[i].show &&  this.recordApi.cov[i].isCoverage){
                covg.push(this.recordApi.cov[i].label);
            }
            if(this.recordApi.cov[i].show &&  this.recordApi.cov[i].isForm){
                forms.push(this.recordApi.cov[i].label);
            }
        }
        //console.log("this.coverages",JSON.stringify(this.coverages));

        var inputData = {
            'recordId': this._recordId,
            'recordType': (JSON.stringify(covg)),
            'forms': (JSON.stringify(forms)),
            'formType':this.formType         // Need to change this later on further requirement.
        }
        // {"recordId" : this._recordId , "recordType" : JSON.stringify(covg),"forms" : JSON.stringify(forms),"formType":this.formType},
        const params = {
            input: JSON.parse(JSON.stringify(inputData)),
            sClassName: 'CTRL_CloneApplicationWithQuote',
            sMethodName: 'cloneProducts',
            options: '{}'
        };

        this.omniRemoteCall(params, true).then((response) => {
            console.log('success:: ', response);
            if(response!=undefined && response.result!=undefined && response.result.NewApplicationId!=undefined){
                var navURL="/lightning/cmp/vlocity_ins__vlocityLWCOmniWrapper?c__target=c%3AfCContinueEnglish&c__layout=lightning&c__ContextId="+response.result.NewApplicationId+"&c__tabLabel=Continue%20Application";
            
                /*this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: response.result.NewApplicationId,
                        objectApiName: 'vlocity_ins__Application__c',
                        actionName: 'view'
                    }
                });*/
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url:navURL
                    }
                });
                this.loaded = !this.loaded
                this.CancelPage();
            }
            
            
            // if(response){
            //     new CloseActionScreenEvent();
            // }
        }).catch((error) => {
            console.log('error:: ', error);
            this.error = error;
         });
        //cloneProducts({"recordId" : this._recordId , "recordType" : JSON.stringify(covg),"forms" : JSON.stringify(forms),"formType":this.formType})
    //     .then((result) => {
    //         console.log(result);
    //         if(result != null){
               
    //             this[NavigationMixin.Navigate]({
    //                 type: 'standard__recordPage',
    //                 attributes: {
    //                     recordId: result,
    //                     objectApiName: 'vlocity_ins__Application__c',
    //                     actionName: 'view'
    //                 }
    //             });
    //             this.dispatchEvent(new CloseActionScreenEvent());
    //         }
    //     })
    //     .catch((error) => {
    //        console.log(error)
    //     });
    //     //this.navigateToRecordPage();
    // }
    // navigateToRecordPage() {
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__recordPage',
    //         attributes: {
    //             recordId: this._recordId,
    //             objectApiName: 'vlocity_ins__Application__c',
    //             actionName: 'view'
    //         }
    //     });
    // }

//  
 }
 numberWithCommas(x) {
    if(isNaN(x)) return 0;
    x=Number(x).toFixed(2);
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
  }

  numberWithCommasnodecimals(x) {
    if(isNaN(x)) return 0;
    x=Number(x).toFixed(0);
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}
}