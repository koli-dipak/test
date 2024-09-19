import { LightningElement,track,api} from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin"; 

export default class Page16Child1 extends OmniscriptBaseMixin(LightningElement) {

    @api excelResponse;
    @api recordTypeData;
    @api isReadOnly=false;
   
    @track recordApi;
    currentLOB = 'FVWC';
    @track currentCoverageID = '';
    @track exposurecolumn=[{"Label":"Exposure Basis","FieldName":"ExposureBase"},{"Label":"Exposure Amount - US Nationals","FieldName":"ExposureAmount1"},{"Label":"Exposure Amount - Third Country Nationals","FieldName":"ExposureAmount2"},{"Label":"Exposure Amount - Local Nationals","FieldName":"ExposureAmount3"}]

    sendtoOmniscript() {
        const changeEvent = new CustomEvent('changedataupdate',	
        {	
                'detail': {currentLob: this.currentLOB, recordData: this.recordTypeData, updatedCoverage : this.recordApi}	
            }	
        );	
        this.dispatchEvent(changeEvent);
        // var Final = {}
        // Final['ExcelResponse'] = {"Step1":JSON.parse(JSON.stringify(this.recordApi))};
        // this.omniApplyCallResp(Final);

    }
    getCoverageId(){
        var coverages=JSON.parse(JSON.stringify(this.recordTypeData));	

        // for(let i in this.recordApi.coverages){
        //     if(this.recordApi.coverages[i].LOBCode == this.currentLOB){
        //         this.currentCoverageID = this.recordApi.coverages[i].coverageID;
        //         this.recordApi = Object.assign(this.recordApi,{
        //             ExposureBasis : this.recordApi.coverages[i].ExposureBasis,
        //             UsNational :'if any',
        //             //countrynational: 480757 ,
        //             ThirdCountryNationalEXPO: '' ,
        //             //localnationalnum : 60593642 ,
        //             LocalNationalExpo : '' ,
        //             USEmployees : this.recordApi.coverages[i].USEmployees,
        //             CanadianEmployees :this.recordApi.coverages[i].CanadianEmployees ,
        //             ThirdCountryNationals : this.recordApi.coverages[i].ThirdCountryNationals,
        //             LocalNationals : this.recordApi.coverages[i].LocalNationals,
        //             InjuryByAccident : this.recordApi.coverages[i].InjuryByAccident,
        //             // injurybydisease : this.recordApi.coverages[i].InjuryByAccident,
        //             // InjuryByDiseaseByEndemic: this.recordApi.coverages[i].InjuryByAccident
        //         })
        //     }
        // }
        // console.log('fvwc',this.currentCoverageID)
        for(let i in coverages){		
            if(coverages[i].LOBCode == this.currentLOB){		
                this.currentCoverageID = coverages[i].coverageID;		
                this.recordApi =JSON.parse(JSON.stringify(coverages[i]));		
                // this.recordApi = Object.assign(this.recordTypeData,{		
                //     "OwnedPrivatePassengerAutosLiability" : this.recordTypeData[i].OwnedPrivatePassengerAutosLiability,		
                // })		
            }		
        }
    }

    connectedCallback(){
        if(this.excelResponse!=undefined){
            // this.recordApi=JSON.parse(JSON.stringify(this.excelResponse.Step1));
            this.getCoverageId();
        }

        // this.currentCoverageID = this.recordApi.AllcoveragesID[2].CoverageID;
        // console.log("mycurrentcoverageid",this.currentCoverageID);
        // console.log("myexcl",JSON.parse(JSON.stringify(this.excelResponse)));
       
        //console.log('@@',JSON.parse(JSON.stringify(this.recordTypeData)) );
    

    }
    // disconnectedCallback(){
    //     this.FVWCChangeData();
    // }

   
    FVWCChangeData(event){
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
        // for(let i in this.recordApi.coverages){
        //     if(this.recordApi.coverages[i].LOBCode == this.currentLOB){
        //         this.recordApi.coverages[i][event.target.name] = event.target.value;
        //         this.recordApi = JSON.parse(JSON.stringify(this.recordApi));
        //     }
        // }
        // this.sendtoOmniscript();
        if(event.target.readOnly==false){	
            this.recordApi[event.target.name] = event.target.value;	
            this.sendtoOmniscript();
        }	
    }
    handleExposure(event) {
        // var expData=JSON.parse(JSON.stringify(event.detail.exposureData));
        // for(var i in expData){
        //     expData[i].ExposureAmount=(expData[i].ExposureAmount1!=undefined && expData[i].ExposureAmount1!='' && !isNaN(expData[i].ExposureAmount1))?parseFloat(expData[i].ExposureAmount1):0;
        //     expData[i].ExposureAmount+=(expData[i].ExposureAmount2!=undefined && expData[i].ExposureAmount2!='' && !isNaN(expData[i].ExposureAmount2))?parseFloat(expData[i].ExposureAmount2):0;
        //     expData[i].ExposureAmount+=(expData[i].ExposureAmount3!=undefined && expData[i].ExposureAmount3!='' && !isNaN(expData[i].ExposureAmount3))?parseFloat(expData[i].ExposureAmount3):0;
           
        // }
        // this.recordApi.exposure=expData;
        // this.recordApi=JSON.parse(JSON.stringify(this.recordApi))
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