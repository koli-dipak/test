import { LightningElement,api,track } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin"; 

export default class FcAuLiabilityDifferenceInConditionsExLiability extends OmniscriptBaseMixin(LightningElement) {
    @api recordTypeData;
    @api recordTypeIndex;

    @api isReadOnly=false;
    
    @api excelResponse;
   
    @track currentCoverageID = '';

    @track recordApi = {};

    currentLOB = 'Auto';

    @track exposurecolumn=[{"Label":"Exposure Basis","FieldName":"ExposureBase","defaultValue":"Payroll"},{"Label":"Exposure Amount","FieldName":"ExposureAmount"}]
    sendtoOmniscript() {
        const changeEvent = new CustomEvent('changedataupdate',
        {
                'detail': {currentLob: this.currentLOB, recordData: this.recordTypeData, updatedCoverage : this.recordApi}
            }
        );
        this.dispatchEvent(changeEvent);
        /*var Final = {}
        Final['ExcelResponse'] = {"Step1":JSON.parse(JSON.stringify(this.recordApi))};
        this.omniApplyCallResp(Final);*/
    }

    getCoverageId(){
        var coverages=JSON.parse(JSON.stringify(this.recordTypeData));
        for(let i in coverages){
            if(coverages[i].LOBCode == this.currentLOB){
                this.currentCoverageID = coverages[i].coverageID;
                this.recordApi =JSON.parse(JSON.stringify(coverages[i]));

                this.recordApi = Object.assign({
                    "OwnedPrivatePassengerAutosComp":"",
                    "OwnedPrivatePasengerAutosCollision":"",
                    "OwnedPrivatePassengerAutosSpecifie":"",
                    "OwnedAutosComp":"",
                    "OwnedAutosnonpvtpsngrCollision":"",
                    "OwnAtoNonpvtSpecifiedcausesofLoss":"",
                    "NonOwnedAndHiredAutosComp":"",
                    "NonOwnedHiredAutosCollision":"",
                    "NonOwnedhiredautosSpecifiedCauses":"",
                },this.recordApi)
                // this.recordApi = Object.assign(this.recordTypeData,{
                //     "OwnedPrivatePassengerAutosLiability" : this.recordTypeData[i].OwnedPrivatePassengerAutosLiability,
                // })
            }
        }
    }

    connectedCallback(){
        if(this.excelResponse!=undefined){
            //this.recordApi=JSON.parse(JSON.stringify(this.excelResponse.Step1));
            this.getCoverageId();
        }
        // this.recordApi = {
        //     OwnedPrivatePassengerAutosLiability : this.recordTypeData[1].OwnedPrivatePassengerAutosLiability,
        // }
    }
    AUTOChangeData(event){
        
            const changeEvent = new CustomEvent('changedataupdate',
              {
                  'detail': {currentLob: event.detail.currentLob, recordData: event.detail.recordData, formData : event.detail.formData}
              }
          );
          this.dispatchEvent(changeEvent);
    
        
    }
    handleChange(event){
        if(event.target.readOnly==false){
            this.recordApi[event.target.name] = event.target.value;
            this.sendtoOmniscript();
        }
       
        /*for(let i in this.recordApi.coverages){
            if(this.recordApi.coverages[i].LOBCode == this.currentLOB){
                this.recordApi.coverages[i][event.target.name] = event.target.value;
                this.recordApi = JSON.parse(JSON.stringify(this.recordApi));
            }
        }*/
       
    }
    @track checkValue = false;
    handleCheckValueChange(event){
        if(event.target.readOnly==false){
            this.recordApi[event.target.name] = event.target.checked;


            // Blank Value
            if(event.target.name=='OwnedPrivatePassengerAutosComprehens') this.recordApi.OwnedPrivatePassengerAutosComp= '';
            if(event.target.name=='OwnedPrivatePassengerAutosCollision') this.recordApi.OwnedPrivatePasengerAutosCollision= '';
            if(event.target.name=='OwnedPrivatePassengerAutosSpecifed') this.recordApi.OwnedPrivatePassengerAutosSpecifie= '';
            
            if(event.target.name=='OwnedAutosComprehensive') this.recordApi.OwnedAutosComp= '';
            if(event.target.name=='OwnedAutosCollision') this.recordApi.OwnedAutosnonpvtpsngrCollision= '';
            if(event.target.name=='OwnedAutoSpecifiedcausesofLoss') this.recordApi.OwnAtoNonpvtSpecifiedcausesofLoss= '';

            if(event.target.name=='NonOwnedAndHiredAutosComprehensive') this.recordApi.NonOwnedAndHiredAutosComp= '';
            if(event.target.name=='NonOwnedAndHiredAutosCollision') this.recordApi.NonOwnedHiredAutosCollision= '';
            if(event.target.name=='NonOwnedAndHiredAutosSpecifedCaus') this.recordApi.NonOwnedhiredautosSpecifiedCauses= '';

            this.sendtoOmniscript();
        }
       
        /*
        for(let i in this.recordApi.coverages){
            if(this.recordApi.coverages[i].LOBCode == this.currentLOB){
                this.recordApi.coverages[i][event.target.name] = event.target.checked;
                this.recordApi = JSON.parse(JSON.stringify(this.recordApi));
            }
        }*/
        
    }

    handleExposure(event) {
        const changeEvent = new CustomEvent('changedataupdate',
        {
                'detail': {currentLob: this.currentLOB, recordData: this.recordTypeData, exposureData :  event.detail.exposureData}
            }
        );
        this.dispatchEvent(changeEvent);
        /*var Final = {}
        Final['ExcelResponse'] = {"Step1":JSON.parse(JSON.stringify(this.recordApi))};
        this.omniApplyCallResp(Final);*/
    }

}