import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin"; 

export default class OverviewOfFc extends OmniscriptBaseMixin(LightningElement) {

    @api excelResponse;
    @api applicationId;
    @api applicationStatus;
    @track recordApi = {};

    @track ActualPremium;
    @track GLDeductible;
    @track GLOccurenceLimit;

    @track isApplicationSubmited=false;
    @track PremiumDetails={};
   /* connectedCallback() {
        // this.recordApi = {
        //   EffectiveDate: "12/05/1998",
        //   AccountName: "West Pharmaceutical Service",
        //   ExpiryDate: "02/28/2023",
        //   ActualPremium: "$360,220.00",
        //   ExposureBase: "Payroll",
        //   GLDeductible: "$20000",
        //   GLOccurenceLimit: "$1734.00",
        //   ActualPremium: "$32300.00"
        // }
        if(this.excelResponse!=null){
            this.recordApi = JSON.parse(JSON.stringify(this.excelResponse.Step1));
        }
    }

    icnm = 'utility:right';
    show = false;
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
    }*/
    connectedCallback(){
       
        if(this.applicationStatus!=undefined && this.applicationStatus=='Submitted'){
            this.isApplicationSubmited=true;
        }
        if(this.excelResponse!=undefined){
            this.recordApi=JSON.parse(JSON.stringify(this.excelResponse.Step1));

            // this.ActualPremium='$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPTotal!=undefined?this.recordApi.GrossAPTotal.toFixed(0):0);
            this.ActualPremium='$'+this.numberWithCommasnodecimals(this.recordApi.UWOverrideGrossOfCommTpTotal!=undefined?this.recordApi.UWOverrideGrossOfCommTpTotal.toFixed(0):0);
            this.GLOccurenceLimit='$'+this.numberWithCommasnodecimals(this.recordApi.GLOccurenceLimit!=undefined?this.recordApi.GLOccurenceLimit.toFixed(0):0);
            this.GLDeductible='$'+this.numberWithCommasnodecimals((this.recordApi.GLDeductible!=undefined && this.recordApi.GLDeductible!="")?this.recordApi.GLDeductible.toFixed(0):0);

            // this.PremiumDetails={};
            // this.PremiumDetails.MasterPremium='$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPMaster.toFixed(0));
            // this.PremiumDetails.MasterComm= (this.recordApi.MstrBrkrComm*100).toFixed(0)+'%'

            // this.PremiumDetails.GL='$'+this.numberWithCommasnodecimals(this.recordApi.MasterGlOtherExt.toFixed(0));
            // this.PremiumDetails.Auto= '$'+this.numberWithCommasnodecimals(this.recordApi.MasterAuto.toFixed(0));
            // this.PremiumDetails.FVWC='$'+this.numberWithCommasnodecimals(this.recordApi.MasterFVWC.toFixed(0));
            // this.PremiumDetails.BTA='$'+this.numberWithCommasnodecimals(this.recordApi.MasterBTA.toFixed(0));
            // this.PremiumDetails.Total='$'+this.numberWithCommasnodecimals(this.recordApi.MasterTotal.toFixed(0));

            // this.PremiumDetails.LocalPremium='$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPLocal.toFixed(0));
            // this.PremiumDetails.LocalComm= (this.recordApi.LclBrkComm*100).toFixed(0)+'%';

            // this.PremiumDetails.TotalPremium='$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPTotal.toFixed(0));
            // this.PremiumDetails.MinimumEarned='$'+this.numberWithCommasnodecimals(this.recordApi.MinimumEarnedPremium.toFixed(0));;
            // this.PremiumDetails.PremiumAudit='None';//(this.recordApi.GrossTPTotal!=this.recordApi.GrossAPTotal)?'$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPTotal.toFixed(0)):'None';

            this.PremiumDetails={};
            // this.PremiumDetails.MasterPremium='$'+this.numberWithCommasnodecimals(this.recordApi.MasterTotal.toFixed(0));
            // this.PremiumDetails.MasterPremium='$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPMaster.toFixed(0));
            this.PremiumDetails.MasterPremium='$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPMasterOverride.toFixed(0));
            this.PremiumDetails.MasterComm= (this.recordApi.MstrBrkrComm*100).toFixed(0)+'%'

            // this.PremiumDetails.GL='$'+this.numberWithCommasnodecimals(this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpGl.toFixed(0));
            this.PremiumDetails.GL='$'+this.numberWithCommasnodecimals(this.recordApi.MasterGlOtherExtWithComm.toFixed(0));
            // this.PremiumDetails.Auto= '$'+this.numberWithCommasnodecimals(this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpAuto.toFixed(0));
            this.PremiumDetails.Auto= '$'+this.numberWithCommasnodecimals(this.recordApi.UWOverrideGrossOfCommTpAuto.toFixed(0));
            // this.PremiumDetails.FVWC='$'+this.numberWithCommasnodecimals(this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpFVWC.toFixed(0));
            this.PremiumDetails.FVWC='$'+this.numberWithCommasnodecimals(this.recordApi.UWOverrideGrossOfCommTpFVWC.toFixed(0));
            // this.PremiumDetails.BTA='$'+this.numberWithCommasnodecimals(this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpBTA.toFixed(0));
            this.PremiumDetails.BTA='$'+this.numberWithCommasnodecimals(this.recordApi.UWOverrideGrossOfCommTpBTA.toFixed(0));
            // this.PremiumDetails.Total='$'+this.numberWithCommasnodecimals(this.recordApi.MasterTotal.toFixed(0));
            this.PremiumDetails.Total='$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPMaster.toFixed(0));

            // this.PremiumDetails.LocalPremium='$'+this.numberWithCommasnodecimals(this.recordApi.LocalTotal.toFixed(0));
            // this.PremiumDetails.LocalPremium='$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPLocal.toFixed(0));
            this.PremiumDetails.LocalPremium='$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPLocalOverride.toFixed(0));
            this.PremiumDetails.LocalComm= (this.recordApi.LclBrkComm*100).toFixed(0)+'%';

            // this.PremiumDetails.TotalPremium='$'+this.numberWithCommasnodecimals(this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpTotal.toFixed(0));
            this.PremiumDetails.TotalPremium='$'+this.numberWithCommasnodecimals(this.recordApi.UWOverrideGrossOfCommTpTotal.toFixed(0));
            this.PremiumDetails.MinimumEarned='$'+this.numberWithCommasnodecimals(this.recordApi.MinimumEarnedPremium.toFixed(0));;
            this.PremiumDetails.PremiumAudit='None';//(this.recordApi.GrossTPTotal!=this.recordApi.GrossAPTotal)?'$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPTotal.toFixed(0)):'None';


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
       
        var Final = {}
        Final['ExcelResponse'] = {"Step1":{"IsContinueCompleted":true,"currentActiveStep":4}};
        this.omniApplyCallResp(Final);
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

    icLocalPolicy = 'utility:right';
    showLocalPolicy = false;;
    localPolicy_handleClick() {
        if (this.showLocalPolicy == false) {
            this.showLocalPolicy = true;
            this.icLocalPolicy = 'utility:down';
            this.template.querySelector('[data-id="divblock8"]').className='drpDwnClrChng firstclassDwn';

        } else {
            this.showLocalPolicy = false;
            this.icLocalPolicy = 'utility:right';
            this.template.querySelector('[data-id="divblock8"]').className='drpRghtClrChng firstclass';
        }
    }

    icnm = 'utility:right';
    show = false;
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
        this.showLocalPolicy = true;
        this.icLocalPolicy = 'utility:down';
        this.showFCAutoLib = true;
        this.icFCAutoLib = 'utility:down';


        // this.template.querySelector('[data-id="divblock"]').className='drpDwnClrChng firstclassDwn';
        // this.template.querySelector('[data-id="divblock2"]').className='drpDwnClrChng firstclassDwn';
        // this.template.querySelector('[data-id="divblock3"]').className='drpDwnClrChng firstclassDwn';
        // this.template.querySelector('[data-id="divblock4"]').className='drpDwnClrChng firstclassDwn';
        // this.template.querySelector('[data-id="divblock5"]').className='drpDwnClrChng firstclassDwn';
        // this.template.querySelector('[data-id="divblock6"]').className='drpDwnClrChng firstclassDwn';

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
        this.showLocalPolicy = false;
        this.icLocalPolicy= 'utility:right';
        this.showFCAutoLib = false;
        this.icFCAutoLib = 'utility:right';


        // this.template.querySelector('[data-id="divblock"]').className='drpRghtClrChng firstclass';
        // this.template.querySelector('[data-id="divblock2"]').className='drpRghtClrChng firstclass';
        // this.template.querySelector('[data-id="divblock3"]').className='drpRghtClrChng firstclass';
        // this.template.querySelector('[data-id="divblock4"]').className='drpRghtClrChng firstclass';
        // this.template.querySelector('[data-id="divblock5"]').className='drpRghtClrChng firstclass';
        // this.template.querySelector('[data-id="divblock6"]').className='drpRghtClrChng firstclass';
    }

    handelCommit(){
        console.log('@@handelCommit',this.recordApi)
        this.omniNextStep();   
    }

    handleEditCovClick(){
        this.omniPrevStep();
        this.omniPrevStep();
    }
    handleEditPreClick(){
        this.omniPrevStep();
        this.omniPrevStep();
        this.omniPrevStep();
    }
    EditClick(){
        this.omniPrevStep();
    }


    @track openModal = false;
    // cloneHandle(){
    //     this.cloneHandle = true;
    // }
    showModal() {
        this.openModal = true;
      }
     
      handleEvent(event){
        this.openModal = event.detail.CancelPage;
      }

}