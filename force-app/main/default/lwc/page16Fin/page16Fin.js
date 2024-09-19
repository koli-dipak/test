import { LightningElement, track, api, wire } from 'lwc';
import { FlexCardMixin } from "vlocity_ins/flexCardMixin";
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin"; 
import {CurrentPageReference} from 'lightning/navigation';
 //import { registerListener, unregisterListener } from 'vlocity_ins/pubsub';
//import { registerListener,unregisterListener } from 'c/pubsub';
import { register } from 'vlocity_ins/pubsub';

export default class Page16Fin extends OmniscriptBaseMixin(LightningElement)  {
   
    @api excelResponse;
    @api isContinueApplicationStep;
    @api applicationId;

    pubsubEvent=[];
    _regexPattern = /\{([a-zA-Z.0-9_]+)\}/g; //for {} fields by default
           
    icnm = 'utility:right';
    show = false;
    @track recordApi = {};
    @track coverageFCAutoLib;
    @track coverageFCGLEmpBenifit;
    @track coverageDataWrkCom;
    @track coverageDataEmAss;
    @track coverageDataTrpAss;
    @track coverageBTA;
    item = [];

    @track ActualPremium;
    @track GLDeductible;
    @track GLOccurenceLimit;

    @wire (CurrentPageReference) pageRef


    sendtoOmniscript() {
        var Final = {}
        Final['ExcelResponse'] = {"Step1":JSON.parse(JSON.stringify(this.recordApi))};
        this.omniApplyCallResp(Final);
      }
    connectedCallback(){ 
       
        if(this.excelResponse!=undefined){
            this.recordApi=JSON.parse(JSON.stringify(this.excelResponse.Step1));
            // this.ActualPremium='$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPTotal!=undefined?this.recordApi.GrossAPTotal.toFixed(0):0);
            this.ActualPremium='$'+this.numberWithCommasnodecimals(this.recordApi.UWOverrideGrossOfCommTpTotal!=undefined?this.recordApi.UWOverrideGrossOfCommTpTotal.toFixed(0):0);
            this.GLOccurenceLimit='$'+this.numberWithCommasnodecimals(this.recordApi.GLOccurenceLimit!=undefined?this.recordApi.GLOccurenceLimit.toFixed(0):0);
            this.GLDeductible='$'+this.numberWithCommasnodecimals((this.recordApi.GLDeductible!=undefined && this.recordApi.GLDeductible!="")?this.recordApi.GLDeductible.toFixed(0):0);

            // this.ActualPremium='$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPTotal!=undefined?this.recordApi.GrossAPTotal.toFixed(0):0);
            // this.GLOccurenceLimit='$'+this.numberWithCommasnodecimals(this.recordApi.GLOccurenceLimit);
            // this.GLDeductible='$'+this.numberWithCommasnodecimals(this.recordApi.GLDeductible);
        }
        /* this.recordApi={
            EffectiveDate:"12/05/1996",
            AccountName:"West Pharmaceutical Service,Inc.",
            ExpiryDate:"02/28/2023",
            ExposureBase: "Payroll",
            ActualPremium:"$360,220.00",
            TotalExposureAmount:"$122,927,4000",
            GLOccurenceLimit:"$2,000,000",
            GLDeductible:"	$1,000,000",	
            CommissiontoEnterinGeRRater:"	23.77%"
        }
        register("pubsubevent",{["data"]:this.handleCallback.bind(this)});*/

        this.coverageFCAutoLib;
        this.coverageFCGLEmpBenifit;
        this.coverageDataWrkCom;
        this.coverageDataEmAss;
        this.coverageDataTrpAss;
        this.coverageBTA;
        var cov=this.recordApi.cov;
        for(var i in cov){
            if(cov[i].code=='FCGLEmpBenefits' && cov[i].show==true){
                this.coverageFCGLEmpBenifit=true;
            }else if(cov[i].code=='FCAULibDiff' && cov[i].show==true){
                this.coverageFCAutoLib=true;
            }else if(cov[i].code=='FCVolWC' && cov[i].show==true){
                this.coverageDataWrkCom=true;
            }else if(cov[i].code=='EmergencyAssis' && cov[i].show==true){
                this.coverageDataEmAss=true;
            }else if(cov[i].code=='TravelAccAndExcessOutOfCount' && cov[i].show==true){
                this.coverageBTA=true;
            }else if(cov[i].code=='TripAssis' && cov[i].show==true){
                this.coverageDataTrpAss=true;
            }
        }
        
        if(this.isContinueApplicationStep!=undefined && this.recordApi.IsContinueCompleted!=true){
            if(this.isContinueApplicationStep>3){
              this.omniNextStep();
            }else{
                this.recordApi.IsContinueCompleted=true;
              //  this.sendtoOmniscript();
             
            }
          
          }
          this.recordApi.currentActiveStep=3;
          this.sendtoOmniscript();
    }

    numberWithCommasnodecimals(x) {
        if(isNaN(x)) return 0;
        x=Number(x).toFixed(0);
        return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }

    disconnectedCallback(){
        //unregisterListener(this);
    }

    handleCallback(detail){
        this.item = detail;
        // const data = this.item.find(element => element === "Foreign Commercial General Liability And Employee Benefits Liability");
        // console.log(data)

        if(this.item.find(element => element === "Foreign Auto Liability Difference In Conditions/Excess Liability") ==  "Foreign Auto Liability Difference In Conditions/Excess Liability"){
            this.coverageFCAutoLib = true
        }else{
            this.coverageFCAutoLib = false
        }
        //-----
        if(this.item.find(element => element === "Foreign Commercial General Liability And Employee Benefits Liability") ==  "Foreign Commercial General Liability And Employee Benefits Liability"){
            this.coverageFCGLEmpBenifit = true
        }else{
            this.coverageFCGLEmpBenifit = false
        }
        //----
        if(this.item.find(element => element === "Foreign Voluntary Workers Compensation And Employers Liability") ==  "Foreign Voluntary Workers Compensation And Employers Liability"){
            this.coverageDataWrkCom = true
        }else{
            this.coverageDataWrkCom = false
        }

        //----
        if(this.item.find(element => element === "Emergency Assistance") ==  "Emergency Assistance"){
            this.coverageDataEmAss = true
        }else {
            this.coverageDataEmAss = false
        }
        // else if(this.item.find(element => element === "Emergency Assistance") != "Emergency Assistance"){
        //     this.coverageDataEmAss = false
        // }

        if(this.item.find(element => element === "Trip Assistance") == "Trip Assistance"){
            this.coverageDataTrpAss = true
        }else {
            this.coverageDataTrpAss = false
        }
        
        if(this.item.find(element => element === "Travel Accident And Excess Out Of Country Medical Expense") == "Travel Accident And Excess Out Of Country Medical Expense"){
            this.coverageBTA = true
        }else{
            this.coverageBTA = false
        }

    }

    icFCAutoLib = 'utility:right';
    showFCAutoLib = false;
    FCAutoLib_handleClick(){
        if (this.showFCAutoLib == false) {
            this.showFCAutoLib = true;
            this.icFCAutoLib = 'utility:down';
            this.template.querySelector('[data-id="divblock5"]').className='drpDwnClrChng firstclassDwn';

        } else {
            this.showFCAutoLib = false;
            this.icFCAutoLib = 'utility:right';
            this.template.querySelector('[data-id="divblock5"]').className='drpRghtClrChng firstclass';
        }
    }

    icFCGLEmpBenifit = 'utility:right';
    showFCGLEmpBenifit = false;
    FCGLEmpBenifit_handleClick() {
        if (this.showFCGLEmpBenifit == false) {
            this.showFCGLEmpBenifit = true;
            this.icFCGLEmpBenifit = 'utility:down';
            this.template.querySelector('[data-id="divblock6"]').className='drpDwnClrChng firstclassDwn';

        } else {
            this.showFCGLEmpBenifit = false;
            this.icFCGLEmpBenifit = 'utility:right';
            this.template.querySelector('[data-id="divblock6"]').className='drpRghtClrChng firstclass';
        }
    }

    icCommonForms = 'utility:right';
    showCommonForms = false;
    commonForm_handleClick() {
        if (this.showCommonForms == false) {
            this.showCommonForms = true;
            this.icCommonForms = 'utility:down';
            this.template.querySelector('[data-id="divblock7"]').className='drpDwnClrChng firstclassDwn';

        } else {
            this.showCommonForms = false;
            this.icCommonForms = 'utility:right';
            this.template.querySelector('[data-id="divblock7"]').className='drpRghtClrChng firstclass';
        }
    }



    handleClick1() {
        if (this.show == false) {
            this.show = true;
            this.icnm = 'utility:down';
            this.template.querySelector('[data-id="divblock"]').className='drpDwnClrChng firstclassDwn';

        } else {
            this.show = false;
            this.icnm = 'utility:right';
            this.template.querySelector('[data-id="divblock"]').className='drpRghtClrChng firstclass';
        }
    }

    icNmEmAs = 'utility:right';
    showEmAs = false;
    handleClick2() {
        console.log("test::" ,this.item);
        // this.icNmEmAs = !this.icNmEmAs;
        this.showEmAs = !this.showEmAs
            console.log(this.showEmAs);
            if (this.showEmAs == true) {
                this.icNmEmAs = 'utility:down';
                this.showEmAs  = true;
                this.template.querySelector('[data-id="divblock2"]').className='drpDwnClrChng firstclassDwn';
            } else {
                this.icNmEmAs = 'utility:right';
                this.showEmAs  = false;
                this.template.querySelector('[data-id="divblock2"]').className='drpRghtClrChng firstclass';
            }
    }

    // handel click div 3 for Trip Assistant

    icNmTrpAs = 'utility:right';
    showTrpAs = false;
    handleClick3() {
        // this.icNmEmAs = !this.icNmEmAs;
        this.showTrpAs = !this.showTrpAs
            console.log(this.showTrpAs);
            if (this.showTrpAs == true) {
                this.icNmTrpAs = 'utility:down';
                this.showTrpAs  = true;
                this.template.querySelector('[data-id="divblock3"]').className='drpDwnClrChng firstclassDwn';
            } else {
                this.icNmTrpAs = 'utility:right';
                this.showTrpAs  = false;
                this.template.querySelector('[data-id="divblock3"]').className='drpRghtClrChng firstclass';
            }
    }

     // handel click div 4 for Local Admitted Policies

     icNmLclAdmtPoly = 'utility:right';
     showLclAdmtPoly = false;
     handleClick4() {
         // this.icNmEmAs = !this.icNmEmAs;
         this.showLclAdmtPoly = !this.showLclAdmtPoly
             console.log(this.showLclAdmtPoly);
             if (this.showLclAdmtPoly == true) {
                 this.icNmLclAdmtPoly = 'utility:down';
                 this.showLclAdmtPoly  = true;
                 this.template.querySelector('[data-id="divblock4"]').className='drpDwnClrChng firstclassDwn';
             } else {
                 this.icNmLclAdmtPoly = 'utility:right';
                 this.showLclAdmtPoly  = false;
                 this.template.querySelector('[data-id="divblock4"]').className='drpRghtClrChng firstclass';
             }
     }



    expnd(){
        this.show = true;
        this.icnm = 'utility:down';
        this.icNmEmAs = 'utility:down';
        this.showEmAs  = true;
        this.icNmTrpAs = 'utility:down';
        this.showTrpAs  = true;
        this.icNmLclAdmtPoly = 'utility:down';
        this.showLclAdmtPoly  = true;
        this.showFCGLEmpBenifit = true;
        this.icFCGLEmpBenifit = 'utility:down';
        this.showCommonForms = true;
        this.icCommonForms = 'utility:down';
        this.showFCAutoLib = true;
        this.icFCAutoLib = 'utility:down';

        // if(this.show == true && this.showEmAs  == true && this.showTrpAs  == true && this.showLclAdmtPoly  == true && this.showFCGLEmpBenifit == true && this.showFCAutoLib == true) {

        //     this.template.querySelector('[data-id="divblock"]').className='drpDwnClrChng firstclassDwn';
        //     this.template.querySelector('[data-id="divblock2"]').className='drpDwnClrChng firstclassDwn';
        //     this.template.querySelector('[data-id="divblock3"]').className='drpDwnClrChng firstclassDwn';
        //     this.template.querySelector('[data-id="divblock4"]').className='drpDwnClrChng firstclassDwn';
        //     this.template.querySelector('[data-id="divblock5"]').className='drpDwnClrChng firstclassDwn';
        //     this.template.querySelector('[data-id="divblock6"]').className='drpDwnClrChng firstclassDwn';
        // }

    }
    collapse(){
        this.show = false;
        this.icnm = 'utility:right';
        this.showEmAs  = false;
        this.icNmEmAs = 'utility:right';
        this.icNmTrpAs = 'utility:right';
        this.showTrpAs  = false;
        this.icNmLclAdmtPoly = 'utility:right';
        this.showLclAdmtPoly  = false;
        this.showFCGLEmpBenifit = false;
        this.icFCGLEmpBenifit = 'utility:right';
        this.showCommonForms = false;
        this.icCommonForms = 'utility:right';
        this.showFCAutoLib = false;
        this.icFCAutoLib = 'utility:right';


        // if(this.show == false && this.showEmAs  == false && this.showTrpAs  == false && this.showLclAdmtPoly  == false && this.showFCGLEmpBenifit == false && this.showFCAutoLib == false) {
            
        //     this.template.querySelector('[data-id="divblock"]').className='drpRghtClrChng firstclass';
        //     this.template.querySelector('[data-id="divblock2"]').className='drpRghtClrChng firstclass';
        //     this.template.querySelector('[data-id="divblock3"]').className='drpRghtClrChng firstclass';
        //     this.template.querySelector('[data-id="divblock4"]').className='drpRghtClrChng firstclass';
        //     this.template.querySelector('[data-id="divblock5"]').className='drpRghtClrChng firstclass';
        //     this.template.querySelector('[data-id="divblock6"]').className='drpRghtClrChng firstclass';
        // }
    }


//Fvwc (page-16-child1) handelChange
onFVWCChange(event){
    this.updateCoverageData(event);
    /*console.log('FvwcRecordData',event.detail.recordData);
    console.log('FvwcRecordData',event.detail.formData);
    console.log('FvwcRecordData',event.detail.currentLob);
    let Allcoverages = JSON.parse(JSON.stringify(event.detail.recordData))
    let CurrentLOBCode = event.detail.currentLob;
    let forms = JSON.parse(JSON.stringify(event.detail.formData));
    for (let i in Allcoverages) {
        if(Allcoverages[i].LOBCode == CurrentLOBCode){
            console.log('currentLOB', CurrentLOBCode)
            this.recordApi.coverages[i]["forms"]=JSON.parse(JSON.stringify(forms));
            for(let j in this.recordApi.coverages[i]["forms"]){
                this.recordApi.coverages[i]["forms"][j]["indexNo"] = Number(j);
            }
            this.recordApi=JSON.parse(JSON.stringify(this.recordApi));
            this.sendtoOmniscript();
        }
    }*/
    

}
onEAChange(event){
    this.updateCoverageData(event);
    /*
    let Allcoverages = JSON.parse(JSON.stringify(event.detail.recordData))
    let CurrentLOBCode = event.detail.currentLob;
    let forms = JSON.parse(JSON.stringify(event.detail.formData));
    for (let i in Allcoverages) {
        if(Allcoverages[i].LOBCode == CurrentLOBCode){
            console.log('currentLOB', CurrentLOBCode)
            this.recordApi.coverages[i]["forms"]=JSON.parse(JSON.stringify(forms));
            for(let j in this.recordApi.coverages[i]["forms"]){
                this.recordApi.coverages[i]["forms"][j]["indexNo"] = Number(j);
            }
            this.recordApi=JSON.parse(JSON.stringify(this.recordApi));
            this.sendtoOmniscript();
        }
    }*/
}
onTRIPChange(event){
    this.updateCoverageData(event);
    /*let Allcoverages = JSON.parse(JSON.stringify(event.detail.recordData))
    let CurrentLOBCode = event.detail.currentLob;
    let forms = JSON.parse(JSON.stringify(event.detail.formData));
    for (let i in Allcoverages) {
        if(Allcoverages[i].LOBCode == CurrentLOBCode){
            console.log('currentLOB', CurrentLOBCode)
            this.recordApi.coverages[i]["forms"]=JSON.parse(JSON.stringify(forms));
            for(let j in this.recordApi.coverages[i]["forms"]){
                this.recordApi.coverages[i]["forms"][j]["indexNo"] = Number(j);
            }
            this.recordApi=JSON.parse(JSON.stringify(this.recordApi));
            this.sendtoOmniscript();
        }
    }*/
}
onBTAChange(event){
    this.updateCoverageData(event);
    /*let Allcoverages = JSON.parse(JSON.stringify(event.detail.recordData))
    let CurrentLOBCode = event.detail.currentLob;
    let forms = JSON.parse(JSON.stringify(event.detail.formData));
    for (let i in Allcoverages) {
        if(Allcoverages[i].LOBCode == CurrentLOBCode){
            console.log('currentLOB', CurrentLOBCode)
            this.recordApi.coverages[i]["forms"]=JSON.parse(JSON.stringify(forms));
            for(let j in this.recordApi.coverages[i]["forms"]){
                this.recordApi.coverages[i]["forms"][j]["indexNo"] = Number(j);
            }
            this.recordApi=JSON.parse(JSON.stringify(this.recordApi));
            this.sendtoOmniscript();
        }
    }*/
}
onGLChange(event){
    this.updateCoverageData(event);
   /* let Allcoverages = JSON.parse(JSON.stringify(event.detail.recordData))
    let CurrentLOBCode = event.detail.currentLob;
    let forms = JSON.parse(JSON.stringify(event.detail.formData));
    for (let i in Allcoverages) {
        if(Allcoverages[i].LOBCode == CurrentLOBCode){
            console.log('currentLOB', CurrentLOBCode)
            this.recordApi.coverages[i]["forms"]=JSON.parse(JSON.stringify(forms));
            for(let j in this.recordApi.coverages[i]["forms"]){
                this.recordApi.coverages[i]["forms"][j]["indexNo"] = Number(j);
            }
            this.recordApi=JSON.parse(JSON.stringify(this.recordApi));
            this.sendtoOmniscript();
        }
    }*/
}
onAUTOChange(event){
    this.updateCoverageData(event);

    /*let Allcoverages = JSON.parse(JSON.stringify(event.detail.recordData))
    let CurrentLOBCode = event.detail.currentLob;
    let forms = JSON.parse(JSON.stringify(event.detail.formData));
    for (let i in Allcoverages) {
        if(Allcoverages[i].LOBCode == CurrentLOBCode){
            console.log('currentLOB', CurrentLOBCode)
            this.recordApi.coverages[i]["forms"]=JSON.parse(JSON.stringify(forms));
            for(let j in this.recordApi.coverages[i]["forms"]){
                this.recordApi.coverages[i]["forms"][j]["indexNo"] = Number(j);
            }
            this.recordApi=JSON.parse(JSON.stringify(this.recordApi));
            this.sendtoOmniscript();
        }
    }*/
}

updateCoverageData(event){
    let Allcoverages = JSON.parse(JSON.stringify(event.detail.recordData))
    let CurrentLOBCode = event.detail.currentLob;
    if(event.detail.formData!=null){
        let forms = JSON.parse(JSON.stringify(event.detail.formData));
        for (let i in Allcoverages) {
            if(Allcoverages[i].LOBCode == CurrentLOBCode){
                console.log('currentLOB', CurrentLOBCode)
                this.recordApi.coverages[i]["forms"]=JSON.parse(JSON.stringify(forms));
                for(let j in this.recordApi.coverages[i]["forms"]){
                    this.recordApi.coverages[i]["forms"][j]["indexNo"] = Number(j);
                }
                this.recordApi=JSON.parse(JSON.stringify(this.recordApi));
                this.sendtoOmniscript();
            }
        }
    }
    if(event.detail.updatedCoverage!=null){
        let coverageData = JSON.parse(JSON.stringify(event.detail.updatedCoverage));
        for (let i in Allcoverages) {
            if(Allcoverages[i].LOBCode == CurrentLOBCode){
                
                var exposure=this.recordApi.coverages[i].exposure;
                var form=this.recordApi.coverages[i].forms;

                this.recordApi.coverages[i]=coverageData;
                this.recordApi.coverages[i].forms=form;
                this.recordApi.coverages[i].exposure=exposure;
                this.recordApi=JSON.parse(JSON.stringify(this.recordApi));
                this.sendtoOmniscript();
            }
        }
    }
    if(event.detail.exposureData!=null){
        let exposure = JSON.parse(JSON.stringify(event.detail.exposureData));
        for (let i in Allcoverages) {
            if(Allcoverages[i].LOBCode == CurrentLOBCode){
                console.log('currentLOB', CurrentLOBCode)
                this.recordApi.coverages[i]["exposure"]=JSON.parse(JSON.stringify(exposure));
                for(let j in this.recordApi.coverages[i]["exposure"]){
                    this.recordApi.coverages[i]["exposure"][j]["indexNo"] = Number(j);
                    this.recordApi.coverages[i]["exposure"][j]["coverageID"] =Allcoverages[i].coverageID;

                    if(CurrentLOBCode=='FVWC'){
                        this.recordApi.coverages[i]["exposure"][j].ExposureAmount=(this.recordApi.coverages[i]["exposure"][j].ExposureAmount1!=undefined && this.recordApi.coverages[i]["exposure"][j].ExposureAmount1!='' && !isNaN(this.recordApi.coverages[i]["exposure"][j].ExposureAmount1))?parseFloat(this.recordApi.coverages[i]["exposure"][j].ExposureAmount1):0;
                        this.recordApi.coverages[i]["exposure"][j].ExposureAmount+=(this.recordApi.coverages[i]["exposure"][j].ExposureAmount2!=undefined && this.recordApi.coverages[i]["exposure"][j].ExposureAmount2!='' && !isNaN(this.recordApi.coverages[i]["exposure"][j].ExposureAmount2))?parseFloat(this.recordApi.coverages[i]["exposure"][j].ExposureAmount2):0;
                        this.recordApi.coverages[i]["exposure"][j].ExposureAmount+=(this.recordApi.coverages[i]["exposure"][j].ExposureAmount3!=undefined && this.recordApi.coverages[i]["exposure"][j].ExposureAmount3!='' && !isNaN(this.recordApi.coverages[i]["exposure"][j].ExposureAmount3))?parseFloat(this.recordApi.coverages[i]["exposure"][j].ExposureAmount3):0;
                        this.recordApi.coverages[i]["exposure"][j].ExposureAmount=''+this.recordApi.coverages[i]["exposure"][j].ExposureAmount;
                    }
                }
                this.recordApi=JSON.parse(JSON.stringify(this.recordApi));
                this.sendtoOmniscript();
            }
        }
    }
    
}
  
ChangeFormData(event){
        
  console.log('OnFormDataChange',event.detail)
  this.recordApi.commonForms=JSON.parse(JSON.stringify(event.detail.formData))
  for(var i in this.recordApi.commonForms){
    this.recordApi.commonForms[i].applicationId=this.applicationId;
    this.recordApi.commonForms[i].indexNo=i;
  }
  this.sendtoOmniscript();
}

    NextPageHandle(event){
         this.omniNextStep();       
      }
    PreviousPage(event)
      {    
          this.omniPrevStep();     
    }
    //     handelChange(){
    //         this.showDetails = !this.showDetails
    //         console.log(this.showDetails);
    //         if (this.showDetails == true) {
    //             this.iconName = 'utility:down';
    //             this.show  = true;
    //         } else {
    //             this.iconName = 'utility:right';
    //             this.show  = false;
    //         }
    //    } 
}