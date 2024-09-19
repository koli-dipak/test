import { LightningElement, track, api, wire } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin"; 
import {CurrentPageReference} from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class Sixcheckbox extends OmniscriptBaseMixin(LightningElement) {

    @api excelResponse;
    @api isContinueApplicationStep;
    @api applicationId;
    @track recordApi = {};
    @track show = false;
    @track txtcolor
    @track coverages = [];

    @track ActualPremium;
    @track GLDeductible;
    @track GLOccurenceLimit;


    //add 4/10/2022
    sendtoOmniscript() {
        var Final = {}
        Final['ExcelResponse'] = {"Step1":this.recordApi};
        this.omniApplyCallResp(Final);
    }

    connectedCallback(){
        // var selectedId=this.coverages==undefined?[]:JSON.parse(this.coverages);
        /*this.recordApi={
            EffectiveDate:"12/05/1998",
            AccountName:"West Pharmaceutical Service,Inc.",
            ExpiryDate:"02/28/2023",
            ExposureBase: "Payroll",
            ActualPremium:"$360,220.00",
            TotalExposureAmount:"$122,927,4000",
            GLOccurenceLimit:"$2,000,000",
            GLDeductible:"	$1,000,000",	
            CommissiontoEnterinGeRRater:"	23.77%",

            
            cov: [
                {label: "Foreign Commercial General Liability And Employee Benefits Liability"},
                {label: "Foreign Auto Liability Difference In Conditions/Excess Liability"},
                {label: "Foreign Voluntary Workers Compensation And Employers Liability"},
                {label: "Emergency Assistance"},
                {label: "Travel Accident And Excess Out Of Country Medical Expense"},
                {label: "Trip Assistance"},
            ]
        }*/
        if(this.excelResponse!=undefined){
            this.recordApi = JSON.parse(JSON.stringify(this.excelResponse.Step1));
            // this.ActualPremium='$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPTotal!=undefined?this.recordApi.GrossAPTotal.toFixed(0):0);
            this.ActualPremium='$'+this.numberWithCommasnodecimals(this.recordApi.UWOverrideGrossOfCommTpTotal!=undefined?this.recordApi.UWOverrideGrossOfCommTpTotal.toFixed(0):0);
            this.GLOccurenceLimit='$'+this.numberWithCommasnodecimals(this.recordApi.GLOccurenceLimit!=undefined?this.recordApi.GLOccurenceLimit.toFixed(0):0);
            this.GLDeductible='$'+this.numberWithCommasnodecimals((this.recordApi.GLDeductible!=undefined && this.recordApi.GLDeductible!="")?this.recordApi.GLDeductible.toFixed(0):0);
        

            // check mandatory coverage selection
            for(var i in this.recordApi.cov){
                this.recordApi.cov[i].isDisabled=false;
                if(this.recordApi.cov[i].code=="FCAULibDiff"){
                    if(this.recordApi.UWOverrideGrossOfCommTpAutoExclude ){
                        this.recordApi.cov[i].isDisabled=true;
                        this.recordApi.cov[i].show=false;
                    }
                    else if( (this.recordApi.UWOverrideGrossOfCommTpAuto!=undefined && parseFloat(this.recordApi.UWOverrideGrossOfCommTpAuto)>0)){
                        this.recordApi.cov[i].isDisabled=true;
                        this.recordApi.cov[i].show=true;
                        
                    }
                }
                if(this.recordApi.cov[i].code=="FCVolWC"){
                    if(this.recordApi.UWOverrideGrossOfCommTpFVWCExclude ){
                        this.recordApi.cov[i].isDisabled=true;
                        this.recordApi.cov[i].show=false;
                    }
                    else if( (this.recordApi.UWOverrideGrossOfCommTpFVWC!=undefined && parseFloat(this.recordApi.UWOverrideGrossOfCommTpFVWC)>0)){
                        this.recordApi.cov[i].isDisabled=true;
                        this.recordApi.cov[i].show=true;
                        
                    }
                }
                if(this.recordApi.cov[i].code=="TripAssis"){
                    if(this.recordApi.UWOverrideGrossOfCommTpBTAExclude ){
                        this.recordApi.cov[i].isDisabled=true;
                        this.recordApi.cov[i].show=false;
                    }
                    else if( (this.recordApi.UWOverrideGrossOfCommTpBTA!=undefined && parseFloat(this.recordApi.UWOverrideGrossOfCommTpBTA)>0)){
                        this.recordApi.cov[i].isDisabled=true;
                        this.recordApi.cov[i].show=true;
                        
                    }
                }
                if(this.recordApi.cov[i].show == true) {
                    this.recordApi.cov[i].txtcolor = "color: rgb(0, 92, 167);"
                }else{
                    this.recordApi.cov[i].txtcolor = "color: rgb(97, 97, 97);"
                }

            }

           
            for(let i in this.recordApi.coverages){
                this.recordApi.coverages[i].iscoverageSelected =  this.recordApi.cov[i].show;
            }
            // this.ActualPremium='$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPTotal!=undefined?this.recordApi.GrossAPTotal.toFixed(0):0);
            // this.GLOccurenceLimit='$'+this.numberWithCommasnodecimals(this.recordApi.GLOccurenceLimit);
            // this.GLDeductible='$'+this.numberWithCommasnodecimals(this.recordApi.GLDeductible);
            if(this.isContinueApplicationStep!=undefined){
                if(this.isContinueApplicationStep>2){
                
                }else{
                  this.recordApi.IsContinueCompleted=true;
                 // this.sendtoOmniscript();
                }
              }
              this.recordApi.currentActiveStep=2;
              this.sendtoOmniscript();
        }
        if(this.isContinueApplicationStep!=undefined && this.recordApi.IsContinueCompleted!=true){
            if(this.isContinueApplicationStep>2){
              this.omniNextStep();
            }
          
          }
        //this.sendtoOmniscript();

}
/*connectedCallback(){
    this.recordApi = this.excelResponse.Step1;
    this.sendtoOmniscript();
}*/
numberWithCommasnodecimals(x) {
    if(isNaN(x)) return 0;
    x=Number(x).toFixed(0);
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

checked = false;
tglBtn(event) {
    this.checked = !this.checked;
    this.recordApi=JSON.parse(JSON.stringify( this.recordApi));
    this.recordApi[event.target.name]= this.checked;

    // let currentLbl = event.target.value
    let currentLbl = event.target.value
    const data = this.recordApi.cov.find((item)=>item.label === currentLbl);
    // data.dataId = `[data-id=${currentLbl}]`;
    // console.log(data.dataId);
    // console.log("currentlabel",currentLbl)
    data.show = !data.show; 
    if(data.show == true) {
        data.txtcolor = "color: rgb(0, 92, 167);"
        this.coverages.push(currentLbl);
        // console.log("@SelectedCoverages",this.coverages);
    }else{
        data.txtcolor = "color: rgb(97, 97, 97);"
        this.coverages = this.coverages.filter(v => v != currentLbl);
    }
    for(let i in this.recordApi.coverages){
        this.recordApi.coverages[i].iscoverageSelected =  this.recordApi.cov[i].show;
    }
    this.sendtoOmniscript(); 
}



@wire (CurrentPageReference) pageRef;
NextPageHandle(event){
    var coverageSelected=false;
    for(let i in this.recordApi.coverages){
        if( this.recordApi.cov[i].show==true){
            coverageSelected=true;
        }
    }
    if(coverageSelected==false){
        this.showErrorToast();
        return;
    }
    
        var eventParam = this.coverages;
        //fireEvent(this.pageRef, 'pubsubevent', eventParam);
        for(let i in this.recordApi.coverages){
            this.recordApi.coverages[i].iscoverageSelected =  this.recordApi.cov[i].show;
        }
        this.sendtoOmniscript(); 
        this.omniNextStep(); 
    
  }

  PreviousPage(event){    
    this.omniPrevStep(); 
  }

  showErrorToast() {
    const evt = new ShowToastEvent({
        title: 'Atleast one coverage is mandatory.',
        message: '',
        variant: 'warning',
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
}
}