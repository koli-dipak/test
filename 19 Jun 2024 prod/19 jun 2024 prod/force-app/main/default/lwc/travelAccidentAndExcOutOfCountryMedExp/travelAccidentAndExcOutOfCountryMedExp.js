import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";

export default class TravelAccidentAndExcOutOfCountryMedExp extends OmniscriptBaseMixin(LightningElement) {
  @api excelResponse;

  @api recordTypeData;
  @api isReadOnly = false;

  currentLOB = 'BTA';
  @track currentCoverageID = '';
  @track exposurecolumn=[{"Label":"Exposure Basis","FieldName":"ExposureBase"},{"Label":"Exposure Amount","FieldName":"ExposureAmount"}]

  @track recordApi = {};
  sendtoOmniscript() {
    const changeEvent = new CustomEvent('changedataupdate',	
        {	
                'detail': {currentLob: this.currentLOB, recordData: this.recordTypeData, updatedCoverage : this.recordApi}	
            }	
        );	
        this.dispatchEvent(changeEvent);
    // var Final = {}
    // Final['ExcelResponse'] = { "Step1": this.recordApi };
    // this.omniApplyCallResp(Final);
  }

  getCoverageId() {
    var coverages=JSON.parse(JSON.stringify(this.recordTypeData));	
    // for (let i in this.recordApi.coverages) {
    //   if (this.recordApi.coverages[i].LOBCode == this.currentLOB) {
    //     this.currentCoverageID = this.recordApi.coverages[i].coverageID;
    //     this.recordApi = Object.assign(this.recordApi, {
    //       ExposureBasis: this.recordApi.coverages[i].ExposureBasis,
    //       AccidentalDeathDismembermentParalysis: this.recordApi.coverages[i].AccidentalDeathDismembermentParalysis,
    //       AccidentalDeathDismembermentParalysisSuffix: this.recordApi.coverages[i].AccidentalDeathDismembermentParalysisSuffix,
    //       DisappearanceAndExposure: this.recordApi.coverages[i].DisappearanceAndExposure,
    //       Carjacking: this.recordApi.coverages[i].Carjacking,
    //       CarjackingSuffix: this.recordApi.coverages[i].CarjackingSuffix,
    //       ChildCareFacility: this.recordApi.coverages[i].ChildCareFacility,
    //       ChildCareFacilitySuffix: this.recordApi.coverages[i].ChildCareFacilitySuffix,
    //       ChildEducatiOnGrant: this.recordApi.coverages[i].ChildEducatiOnGrant,
    //       ChildEducationGrantSuffix: this.recordApi.coverages[i].ChildEducationGrantSuffix,
    //       CommonCarrier: this.recordApi.coverages[i].CommonCarrier,
    //       CommonCarrierSuffix: this.recordApi.coverages[i].CommonCarrierSuffix,
    //       CompassionateVisit: this.recordApi.coverages[i].CompassionateVisit,
    //       CompassionateVisitSuffix: this.recordApi.coverages[i].CompassionateVisitSuffix,
    //       Counseling: this.recordApi.coverages[i].Counseling,
    //       CounselingSuffix: this.recordApi.coverages[i].CounselingSuffix,
    //       FeloniousAssault: this.recordApi.coverages[i].FeloniousAssault,
    //       FeloniousAssaultSuffix: this.recordApi.coverages[i].FeloniousAssaultSuffix,
    //       HearingAidProstheticAppliance: this.recordApi.coverages[i].HearingAidProstheticAppliance,
    //       HearingAidProstheticApplianceSuffix: this.recordApi.coverages[i].HearingAidProstheticApplianceSuffix,
    //       HomeAlterationVehicleModification: this.recordApi.coverages[i].HomeAlterationVehicleModification,
    //       HomeAlterationVehicleModificationSuffix: this.recordApi.coverages[i].HomeAlterationVehicleModificationSuffix,
    //       Rehabilitation: this.recordApi.coverages[i].Rehabilitation,
    //       RehabilitationSuffix: this.recordApi.coverages[i].RehabilitationSuffix,
    //       SpousalDomesticPartnerCivialPartnerRetraining: this.recordApi.coverages[i].SpousalDomesticPartnerCivialPartnerRetraining,
    //       SpousalCivialPartnerSuffix: this.recordApi.coverages[i].SpousalCivialPartnerSuffix,
    //       VehicleSafetyCredit: this.recordApi.coverages[i].VehicleSafetyCredit,
    //       VehicleSafetyCreditSuffix: this.recordApi.coverages[i].VehicleSafetyCreditSuffix,
    //       BrainDamage: this.recordApi.coverages[i].BrainDamage,
    //       BrainDamageSuffix: this.recordApi.coverages[i].BrainDamageSuffix,
    //       InHospitalIndemnity: this.recordApi.coverages[i].InHospitalIndemnity,
    //       InHospitalIndemnitySuffix: this.recordApi.coverages[i].InHospitalIndemnitySuffix,
    //       MedicalExpenseSicknesOrAccident: this.recordApi.coverages[i].MedicalExpenseSicknesOrAccident,
    //       MedicalExpenseSicknesSuffix: this.recordApi.coverages[i].MedicalExpenseSicknesSuffix,
    //       MedicalExpenseSicknessOrInjury: this.recordApi.coverages[i].MedicalExpenseSicknessOrInjury,
    //       MedicalExpenseSicknessSuffix: this.recordApi.coverages[i].MedicalExpenseSicknessSuffix,
    //       Deductible: this.recordApi.coverages[i].Deductible,
    //       DeductibleSuffix: this.recordApi.coverages[i].MedicalExpenseSicknessSuffix,
    //       SevereBurns: this.recordApi.coverages[i].SevereBurns,
    //       SevereBurnsSuffix: this.recordApi.coverages[i].SevereBurnsSuffix,
    //       CarRentalLateReturnCosts: this.recordApi.coverages[i].CarRentalLateReturnCosts,
    //       CarRentalLateReturnCostsSuffix: this.recordApi.coverages[i].CarRentalLateReturnCostsSuffix,
    //       HomeGuard: this.recordApi.coverages[i].HomeGuard,
    //       HomeGuardSuffix: this.recordApi.coverages[i].HomeGuardSuffix,
    //       PetCare: this.recordApi.coverages[i].PetCare,
    //       PetCareSuffix: this.recordApi.coverages[i].PetCareSuffix,
    //       AggregateLimitOfInsurance: this.recordApi.coverages[i].AggregateLimitOfInsurance,
    //       AggregateLimitOfInsuranceSuffix: this.recordApi.coverages[i].AggregateLimitOfInsuranceSuffix,
    //       MaximumPeriodOfCoverage: this.recordApi.coverages[i].MaximumPeriodOfCoverage,
    //       MaximumperiodcoverageSuffix: this.recordApi.coverages[i].MaximumperiodcoverageSuffix,
    //     })
    //   }
    // }
    for(let i in coverages){		
      if(coverages[i].LOBCode == this.currentLOB){		
          this.currentCoverageID = coverages[i].coverageID;		
          this.recordApi =JSON.parse(JSON.stringify(coverages[i]));		
          // this.recordApi = Object.assign(this.recordTypeData,{		
          //     "OwnedPrivatePassengerAutosLiability" : this.recordTypeData[i].OwnedPrivatePassengerAutosLiability,		
          // })		
      }		
  }
    // console.log('fvwc', this.currentCoverageID)

  }

  connectedCallback() {
    if (this.excelResponse != undefined) {
      // this.recordApi = JSON.parse(JSON.stringify(this.excelResponse.Step1));
      this.getCoverageId();
    }
    //         this.recordApi = {
    //             ExposureBasisTA: 120,
    //             AccidentalDeathDismembermentParalysis: 50000,
    //             AccidentalDeathDismembermentParalysisSuffix: "Ms",
    //         }
    //this.sendtoOmniscript();
  }
  BTAChangeData(event) {

    // if(event.detail.recordData != undefined && event.detail.currentLob != undefined && event.detail.formData != undefined){
    //     console.log('@@@@',event.detail.recordData);
    //     console.log('@@Lob', event.detail.currentLob);
    //     console.log('@@form',event.detail.formData);

    // }
    const changeEvent = new CustomEvent('changedataupdate',
      {
        'detail': { currentLob: event.detail.currentLob, recordData: event.detail.recordData, formData: event.detail.formData }
      }
    );
    this.dispatchEvent(changeEvent);


  }
  handleChange(event) {
    // for (let i in this.recordApi.coverages) {
    //   if (this.recordApi.coverages[i].LOBCode == this.currentLOB) {
    //     this.recordApi.coverages[i][event.target.name] = event.target.value;
    //     this.recordApi = JSON.parse(JSON.stringify(this.recordApi));
    //   }
    // }
    if(event.target.readOnly==false){	
      this.recordApi[event.target.name] = event.target.value;	
      this.sendtoOmniscript();
  }	
    
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