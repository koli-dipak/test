import { LightningElement, track,api } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";
export default class EmergecyAssChildPg extends OmniscriptBaseMixin(LightningElement){
    @api excelResponse;
    @api recordTypeData;
    @api isReadOnly=false;

    @track currentCoverageID = '';
    @track exposurecolumn=[{"Label":"Exposure Basis","FieldName":"ExposureBase"},{"Label":"Exposure Amount","FieldName":"ExposureAmount"}]

   // @track recordApi;
   currentLOB = 'EA';
    @track recordApi={}; 
    sendtoOmniscript() {
        const changeEvent = new CustomEvent('changedataupdate',	
        {	
                'detail': {currentLob: this.currentLOB, recordData: this.recordTypeData, updatedCoverage : this.recordApi}	
            }	
        );	
        this.dispatchEvent(changeEvent);
        // var Final = {}
        // Final['ExcelResponse'] = {"Step1":this.recordApi};
        // this.omniApplyCallResp(Final);
    }
    

    getCoverageId(){
        var coverages=JSON.parse(JSON.stringify(this.recordTypeData));	
        for(let i in coverages){		
            if(coverages[i].LOBCode == this.currentLOB){		
                this.currentCoverageID = coverages[i].coverageID;		
                this.recordApi =JSON.parse(JSON.stringify(coverages[i]));		
                // this.recordApi = Object.assign(this.recordTypeData,{		
                //     "OwnedPrivatePassengerAutosLiability" : this.recordTypeData[i].OwnedPrivatePassengerAutosLiability,		
                // })		
            }		
        // for(let i in this.recordApi.coverages){
        //     if(this.recordApi.coverages[i].LOBCode == this.currentLOB){
        //         this.currentCoverageID = this.recordApi.coverages[i].coverageID;
        //     }
        // }
        // console.log('fvwc',this.currentCoverageID)
    }
}

    connectedCallback(){
        
        // this.recordApi = {
        //     amount : 916,
        //     amount1 : 1000000,
        //     dash : '-',
        //     dash1 : '-',
        //     amount2 : 10000,
        //     amount3 : 5000,
        //     amount4 : 5000,
        //     amount5 : 5000,
        //     amount6 : 1000000,
        //     amount7 : 1000,
        //     amount8 : 1000,
        //     amount9 : 1000,
        //     amount10 : 5000,
        //     amount11 : 250,
        //     amount12 : 2500,
        //     amount13 : 2500,
        //     amount14 : 5000,
        //     amount15 : 250000,
        //     amount16 : 250000,
        //     amount17 : 250000,
        //     amount18 : 250000,
        //     amount19 : 250000,
        //     amount20 : 250000,
        //     amount21 : 250000,
        //     amount22 : 250000,
        //     amount23 : 250000,
              
        // }
        if(this.excelResponse != undefined){
            // this.recordApi = JSON.parse(JSON.stringify(this.excelResponse.Step1));
            this.getCoverageId();
        }
        
        //this.sendtoOmniscript();

    }
    EAChangeData(event){
        // if(event.detail.recordData != undefined && event.detail.currentLob != undefined && event.detail.formData != undefined){
        //     console.log('@@@@',event.detail.recordData);
        //     console.log('@@Lob', event.detail.currentLob);
        //     console.log('@@form',event.detail.formData);

        // }
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
        // for(let i in this.recordApi.coverages){
        //     if(this.recordApi.coverages[i].LOBCode == this.currentLOB){
        //         this.recordApi.coverages[i][event.target.name] = event.target.value;
        //         this.recordApi = JSON.parse(JSON.stringify(this.recordApi));
        //     }
        // }
        // this.sendtoOmniscript();
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