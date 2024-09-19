import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";

export default class TripAssChildPg extends OmniscriptBaseMixin(LightningElement) {
 
    @api excelResponse;
    @api recordTypeData;
    @api isReadOnly=false;

    @track recordApi={}; 
    currentLOB = 'Trip';

    @track currentCoverageID = '';

    @track exposurecolumn=[{"Label":"Exposure Basis","FieldName":"ExposureBase"},{"Label":"Exposure Amount","FieldName":"ExposureAmount"}]

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
    }
}

    connectedCallback(){
        if(this.excelResponse != undefined){
            // this.recordApi = JSON.parse(JSON.stringify(this.excelResponse.Step1));
            this.getCoverageId();
        }
        
        // this.sendtoOmniscript();
    }
    TripChangeData(event){
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