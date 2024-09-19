import { LightningElement, track, api } from 'lwc';
import { FlexCardMixin } from "vlocity_ins/flexCardMixin";
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";
import pubsub from "vlocity_ins/pubsub";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import { getNamespaceDotNotation } from "vlocity_ins/omniscriptInternalUtils";
import { OmniscriptActionCommonUtil } from "vlocity_ins/omniscriptActionUtils";
// import logoN2g from '@salesforce/resourceUrl/logoN2g';

export default class FCFirstPage extends OmniscriptBaseMixin(LightningElement) {

  @track GLDeductible
  @track GLOccurenceLimit
  @track ActualPremium
  @track isEventRegister=false;
  countryValue;
  @api excelResponse;
  @api defaultForms;
  @api applicationId;
  @api isContinueApplicationStep;
  @api selectedFormLink;

  @track recordApi = {};
  @track firstStep = true;
  @track secoundStep = false;
  @track thirdStep = false;
  @track fourthStep = false;
  @track Step = "step-1";

  @track value1
  @track value2
  @track value3
  @track value4
  @track value5
  @track value6


  @track UWScltMstrPremium
  @track saveData=false;

  @track MinPremExpThre;
  @track FOSMinPre;
  @track MastBroComm;
  @track MinErnPrem;
  @track DIC;
  @track MinPreforLarPre;
  @track SepELPolMinPre;
  @track GLMasterMin;
  @track LocBroComm;
  @track LocMinErnPrem;
  @track premBreakDown = [];
  @track premBreakDownOverview = [];
  @track pricingInfo=[];

  @track openModal = false;
  @track radioOption = true;
  @api openALE = false;
  @api openUp = false;
  @track visibleALC = false;
  @track visibleUp = false;
  value = 'option2';
  @track isOpen = false;
  @track issecondOpen = false;
  @track isthirdOpen = false;
  @track loaded = false;
  @track selectedOptions;
  @track recordIndex;
  @track localExtensionData;
  @track newLocalExtensionData;
  @track isReCalculated=false;

  @track hidePrevBtn = true;
  @track oldRecords={};

  @track selectedCountryWithExt;
  @track countrywithExt;

  @track extensionRecord;
  @track addExtSection;
  @track updateBtnClick;

  @track moveToNext = false;
  @track TotalPremiumHigh = false;
  @track GLMasterMin = false;
  @track MasterMinFVWC = false;
  @track MasterMinAuto = false;
  @track MasterMinBTA = false;
  @track CountryList;
  

  sendtoOmniscript() {
    var Final = {}
    Final['ExcelResponse'] = {"Step1":JSON.parse(JSON.stringify(this.recordApi))};
    this.omniApplyCallResp(Final);
  }
  extBtnClck(){
    const addExtmodal = this.template.querySelector("c-add-extension-modal");
    addExtmodal.showTheExtension();
    // console.log("country val",this.countryVal);
}
handleChange(event){
  this.recordApi=JSON.parse(JSON.stringify( this.recordApi));
  this.recordApi[event.target.name]=event.target.value;
  this.sendtoOmniscript();
}
handleMinPremPerChange(event){
  this.recordApi=JSON.parse(JSON.stringify( this.recordApi));
  this.recordApi[event.target.name]=event.target.value;
  if(event.target.value==null){
    event.target.value=0;
  }
  this.recordApi.MinimumEarnedPremium=this.recordApi.GrossAPTotal * parseFloat((event.target.value==null || event.target.value=="") ? "0":event.target.value)
  this.BelowMinPreEarnedError="";
  if(this.recordApi.MinimumEarnedPremium!=null && this.recordApi.SumMasterMinPremium!=null && this.recordApi.MinimumEarnedPremium<this.recordApi.SumMasterMinPremium){
       this.BelowMinPreEarnedError="Below the minimum required premium";
  }   
 this.sendtoOmniscript();
}
handlePremiumChange(event){
  this.recordApi=JSON.parse(JSON.stringify( this.recordApi));
  this.recordApi[event.target.name]=parseFloat(event.target.value);
  for(var i in this.premBreakDown){
    if(this.premBreakDown[i].fieldUpdateKey==event.target.name){
      this.premBreakDown[i].UWSelectedMasterPremium=event.target.value;
    }
  }
  if(event.target.name=='UWOverrideGrossAPTotal'){
    for(var i in this.premBreakDown){
      if(this.premBreakDown[i].fieldUpdateKey=='UWOverrideGrossAPTotal'){
        this.premBreakDown[i].ErrorWarningFlag='';
        if(parseFloat((event.target.value==null || event.target.value=="") ? "0":event.target.value)<this.recordApi.MasterMinPremium){
          this.premBreakDown[i].ErrorWarningFlag='Master premium is below minimum';
        }
      }
    }
    this.premBreakDown=JSON.parse(JSON.stringify(this.premBreakDown));
  }
   this.sendtoOmniscript();
}

handleGrossActualIntialChange(event){
  this.recordApi= JSON.parse(JSON.stringify(this.recordApi));
  this.recordApi[event.target.name]=event.target.value!=undefined && event.target.value!=''?parseFloat(event.target.value):0;
  let premiumBreakDownIndex;
  for(var i in this.premBreakDown){
    if(this.premBreakDown[i].fieldUpdateKey==event.target.name){
      this.premBreakDown[i].UWSelectedGrossActualIntial=event.target.value!=undefined && event.target.value!=''?event.target.value:0;
      premiumBreakDownIndex = i;
    }
  }
  if(this.premBreakDown[premiumBreakDownIndex].fieldUpdateKey=='UWOverrideGrossOfCommTpAuto'){
    this.premBreakDown[premiumBreakDownIndex].ErrMsg='';
    if(parseFloat((event.target.value==null || event.target.value=="") ? "0":event.target.value)<500){
      this.premBreakDown[premiumBreakDownIndex].ErrMsg='"Auto Gross Actual Initial" is below Minimum';
    }
  }
  if(this.premBreakDown[premiumBreakDownIndex].fieldUpdateKey=='UWOverrideGrossOfCommTpFVWC'){
    this.premBreakDown[premiumBreakDownIndex].ErrMsg='';
    if(parseFloat((event.target.value==null || event.target.value=="") ? "0":event.target.value)<1000){
      this.premBreakDown[premiumBreakDownIndex].ErrMsg='"FVWC Gross Actual Initial" is below Minimum';
    }
  }

  let index;
  for(var i in this.premBreakDownOverview){
    if(this.premBreakDownOverview[i].fieldUpdateKey==event.target.name){
        this.premBreakDownOverview[i].Master=event.target.value!=undefined && event.target.value!=''?event.target.value:0;
        index = i;
    }
  }
  if(this.premBreakDownOverview[index].fieldUpdateKey=='UWOverrideGrossOfCommTpFVWC'){
    this.premBreakDownOverview[index].ErrorWarningFlag='';
    if(parseFloat((event.target.value==undefined || event.target.value=='') ? 0:event.target.value)<0){
      this.premBreakDownOverview[index].ErrorWarningFlag='"FVWC Master premium" is below Minimum';
    }
  }

  if(this.premBreakDownOverview[index].fieldUpdateKey=='UWOverrideGrossOfCommTpAuto'){
    this.premBreakDownOverview[index].ErrorWarningFlag='';
    if(parseFloat((event.target.value==null || event.target.value=="") ? "0":event.target.value)<0){
      this.premBreakDownOverview[index].ErrorWarningFlag='"Auto Master premium" is below Minimum';
    }
  }

  if(this.premBreakDownOverview[index].fieldUpdateKey=='UWOverrideGrossOfCommTpBTA'){
    this.premBreakDownOverview[index].ErrorWarningFlag='';
    if(parseFloat((event.target.value==null || event.target.value=="") ? "0":event.target.value)<0){
      this.premBreakDownOverview[index].ErrorWarningFlag='"BTA Master premium" is below Minimum';
    }
  }
  
  this.premBreakDown=JSON.parse(JSON.stringify(this.premBreakDown));
   this.sendtoOmniscript();
}


handleMasterValueChange(event){
  this.recordApi= JSON.parse(JSON.stringify(this.recordApi));
  this.recordApi[event.target.name]=event.target.value!=undefined && event.target.value!=''?parseFloat(event.target.value):0;
  // for(var i in this.premBreakDownOverview){
  //   if(this.premBreakDownOverview[i].fieldUpdateKey==event.target.name){
  //     this.premBreakDownOverview[i].UWSelectedGrossActualIntial=event.target.value;
  //   }
  // }
  let index;
  for(var i in this.premBreakDownOverview){
    if(this.premBreakDownOverview[i].fieldUpdateKey==event.target.name){
        this.premBreakDownOverview[i].Master=event.target.value!=undefined && event.target.value!=''?event.target.value:0;
        index = i;
    }
  }
  

    // if(this.premBreakDownOverview[index].fieldUpdateKey=='MasterGlOtherExt'){
      // this.premBreakDownOverview[index].ErrorWarningFlag='';

      // this.GLMasterMin = false;
      // if(parseFloat((event.target.value==null || event.target.value=="") ? 0:event.target.value)<this.recordApi.GLMasterMin){
      //   this.premBreakDownOverview[index].ErrorWarningFlag='GL Master Premium" is Below Minimum';
      //   this.GLMasterMin = true;
      // }

      // this.TotalPremiumHigh = false;
      // if(parseFloat((event.target.value==null || event.target.value=="") ? 0:event.target.value)>this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpGl){
      //   this.premBreakDownOverview[index].ErrorWarningFlag='Total premium, is too high';
      //   this.recordApi[event.target.name]=0;
      //   this.TotalPremiumHigh = true;
      // }
    // }

    if(this.premBreakDownOverview[index].fieldUpdateKey=='UWOverrideGrossOfCommTpFVWC'){
      this.premBreakDownOverview[index].ErrorWarningFlag='';
      if(parseFloat((event.target.value==undefined || event.target.value=='') ? 0:event.target.value)<0){
        this.premBreakDownOverview[index].ErrorWarningFlag='"FVWC Master premium" is below Minimum';
      }
    }

    if(this.premBreakDownOverview[index].fieldUpdateKey=='UWOverrideGrossOfCommTpAuto'){
      this.premBreakDownOverview[index].ErrorWarningFlag='';
      if(parseFloat((event.target.value==null || event.target.value=="") ? "0":event.target.value)<0){
        this.premBreakDownOverview[index].ErrorWarningFlag='"Auto Master premium" is below Minimum';
      }
    }

    if(this.premBreakDownOverview[index].fieldUpdateKey=='UWOverrideGrossOfCommTpBTA'){
      this.premBreakDownOverview[index].ErrorWarningFlag='';
      if(parseFloat((event.target.value==null || event.target.value=="") ? "0":event.target.value)<0){
        this.premBreakDownOverview[index].ErrorWarningFlag='"BTA Master premium" is below Minimum';
      }
    }
  this.premBreakDownOverview=JSON.parse(JSON.stringify(this.premBreakDownOverview));
   this.sendtoOmniscript();
}

handleExposureChange(event){
  this.recordApi=JSON.parse(JSON.stringify( this.recordApi));
  if(this.recordApi.coverages != undefined){
    for(let x in this.recordApi.coverages){
      if(this.recordApi.coverages[x].LOBCode == "EA"){
         for(let y in this.recordApi.coverages[x].exposure){
          // this.recordApi.coverages[x].exposure[y].ExposureAmount = event.target.value !='' && event.target.value != undefined?event.target.value:undefined;
          this.recordApi.coverages[x].exposure[y].ExposureAmount = event.target.value;
          // this.recordApi.coverages[x].exposure[y].ExposureBase = event.target.value !='' && event.target.value != undefined?"Trips":undefined;
          this.recordApi.coverages[x].exposure[y].ExposureBase = "Trips";
          this.recordApi.Exposure = parseFloat(event.target.value);
         }
      }

      if(this.recordApi.coverages[x].LOBCode == "BTA"){
        for(let y in this.recordApi.coverages[x].exposure){
        //  this.recordApi.coverages[x].exposure[y].ExposureAmount = event.target.value !='' && event.target.value != undefined?event.target.value:undefined;
         this.recordApi.coverages[x].exposure[y].ExposureAmount = event.target.value;
        //  this.recordApi.coverages[x].exposure[y].ExposureBase = event.target.value !='' && event.target.value != undefined?"Trips":undefined;
         this.recordApi.coverages[x].exposure[y].ExposureBase = "Trips";
        }
     }

     if(this.recordApi.coverages[x].LOBCode == "Trip"){
      for(let y in this.recordApi.coverages[x].exposure){
      //  this.recordApi.coverages[x].exposure[y].ExposureAmount = event.target.value !='' && event.target.value != undefined?event.target.value:undefined;
       this.recordApi.coverages[x].exposure[y].ExposureAmount = event.target.value;
      //  this.recordApi.coverages[x].exposure[y].ExposureBase = event.target.value !='' && event.target.value != undefined?"Trips":undefined;
       this.recordApi.coverages[x].exposure[y].ExposureBase = "Trips";
      }
   }
     
    }
  }
  this.recordApi=JSON.parse(JSON.stringify( this.recordApi));
   this.sendtoOmniscript();
}

registerEvents(){
  this.isEventRegister=true;
  pubsub.register("HelpTextChannel",{["Action"]:helpTextAction.bind(this)});

  function helpTextAction(event){
    if(event.actionName !=null){
        if(event.actionName=="saveAsDraft"){
          this.recordApi=JSON.parse(event.recordApi);
          this.oldRecords=JSON.parse(JSON.stringify( this.recordApi));
          this.pricingAndBreakdownDetails();
          this.sendtoOmniscript();   
        }
    }
  }

}

  getCountryList(){
    const params = {
        input: JSON.stringify({}),
        sClassName: 'FcLocalExtension',
        sMethodName: 'getCountryList',
        options: '{}'
    };
    this.omniRemoteCall(params, true).then((response) => {
        console.log("respone", JSON.stringify((response)))
        this.CountryList=[];
        var data = JSON.parse(JSON.stringify(response.result.CountryList)) ;
        for(var i in data) {

          this.CountryList.push({"label":data[i],"value":data[i]});

        }
        
        
    }).catch((error) => {
        console.log('error:: ', error);
        this.error = error;
     });
  }

  //added for N2GFCB495 
  // removeDuplicatesCountry(arr) {
  //   const result = [];
  //   const map = new Map();
  
  //   for (const obj of arr) {
  //     let objKey = '';
  //     for (const key in obj) {
  //       if (typeof obj[key] !== 'object') {
  //         objKey += obj[key] + '-';
  //       } else {
  //         objKey += JSON.stringify(obj[key]) + '-';
  //       }
  //     }
  
  //     if (!map.has(objKey)) {
  //       map.set(objKey, true);
  //       result.push(obj);
  //     }
  //   }
  
  //   return result;
  // }

  connectedCallback() {
    if(this.isEventRegister==false)this.registerEvents();
     if(this.excelResponse != undefined){
      this.recordApi=JSON.parse(JSON.stringify(this.excelResponse.Step1));
      console.log('####@@@',this.recordApi);

      // added for N2GFCB495 
      // if(this.recordApi.Data != undefined || this.recordApi.Data != ''){
      //     this.recordApi.Data = this.removeDuplicatesCountry(this.recordApi.Data);
      //     this.recordApi.Data = this.recordApi.Data.sort((a, b) => a.Country.localeCompare(b.Country));
      // }

      //for Dic/Dil Ticket---------------
    for(let i=0; i < this.recordApi.Data.length; i++){
       
      if ((this.recordApi.Data[i].type == "GL" && this.recordApi.Data[i].LoclPolReq == "Yes")
       ||(this.recordApi.Data[i].type == "EL" )
       ||(this.recordApi.Data[i].type == "GL" && this.recordApi.Data[i].LoclPolReq == "FOS")){
          this.recordApi.Data[i].LobDicDil = false;
          if(this.recordApi.Data[i].type == "GL"){
              this.recordApi.Data[i].isGL=true;
          }else if(this.recordApi.Data[i].type == "EL"){
              this.recordApi.Data[i].isEL=true;
          }
      } else{
        this.recordApi.Data[i].LobDicDil = true;
      }
        
    //N2GFCB321
    if(this.recordApi.Data[i].type == "EL"){
      this.recordApi.Data[i].LoclPolReq = "Yes";
    }

      if(this.recordApi.Data[i].extensions!=undefined &&   !Array.isArray(this.recordApi.Data[i].extensions)){
        if(this.recordApi.Data[i].extensions.CasualityLocalID==null || this.recordApi.Data[i].extensions.CasualityLocalID==""){
          this.recordApi.Data[i].extensions=[];
        }else{
          this.recordApi.Data[i].extensions=[this.recordApi.Data[i].extensions];
        }
        // for(let j=0; j<this.recordApi.Data[i].extensions.length; j++){
        //   this.recordApi.Data[i].extensions[j].indexNo=j;
        //   // this.recordApi.Data[i].extensions[j].indexNo=j;
        // }
      }
      if(this.recordApi.Data[i].extensions != undefined){
        for(let j=0; j<this.recordApi.Data[i].extensions.length; j++){
          this.recordApi.Data[i].extensions[j].indexNo=j;
          this.recordApi.Data[i].extensions[j].Country=this.recordApi.Data[i].Country;
          // this.recordApi.Data[i].extensions[j].indexNo=j;
        }
      }
      //according to N2GFCB111
      //this.recordApi.Data[i].Limit = this.recordApi.Data[i].Limit.toFixed(0);
      //this.recordApi.Data[i].Exposure = this.recordApi.Data[i].Exposure.toFixed(0);
    }
    console.log('@DicDilData',this.recordApi.Data);
    this.getCountryList();
      //---------------------------------

      // this.ActualPremium='$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPTotal!=undefined?this.recordApi.GrossAPTotal.toFixed(0):0);
      this.ActualPremium='$'+this.numberWithCommasnodecimals(this.recordApi.UWOverrideGrossOfCommTpTotal!=undefined?this.recordApi.UWOverrideGrossOfCommTpTotal.toFixed(0):0);
      this.GLOccurenceLimit='$'+this.numberWithCommasnodecimals(this.recordApi.GLOccurenceLimit!=undefined?this.recordApi.GLOccurenceLimit.toFixed(0):0);
      this.GLDeductible='$'+this.numberWithCommasnodecimals((this.recordApi.GLDeductible!=undefined && this.recordApi.GLDeductible!="")?this.recordApi.GLDeductible.toFixed(0):0);
  
      // this.ActualPremium='$'+this.numberWithCommasnodecimals(this.recordApi.ActualPremium);
      // this.GLOccurenceLimit='$'+this.numberWithCommasnodecimals(this.recordApi.GLOccurenceLimit);
      // this.GLDeductible='$'+this.numberWithCommasnodecimals(this.recordApi.GLDeductible);
      var defaultForms=this.defaultForms!=undefined?JSON.parse(JSON.parse(JSON.stringify(this.defaultForms)).DefaultForms) :{};
      var FormWiseDocMap=this.defaultForms!=undefined?JSON.parse(JSON.parse(JSON.stringify(this.defaultForms)).DefaultFormDocumentLinks):{};
      var PreSelectedDocumentLinks=this.selectedFormLink!=undefined ? JSON.parse(JSON.stringify(this.selectedFormLink)).PreSelectedDocumentLinks!=null && JSON.parse(JSON.stringify(this.selectedFormLink)).PreSelectedDocumentLinks!=undefined ? JSON.parse(JSON.parse(JSON.stringify(this.selectedFormLink)).PreSelectedDocumentLinks):{}:{};
      
      var CoverageWiseDefaultForms={};
      for(var key in defaultForms){
        CoverageWiseDefaultForms[key]=[];
        var FromNameAndNon=defaultForms[key];
        for(var i in FromNameAndNon){
            var tempObj = {
              "FromName" : FromNameAndNon[i].Form_Name__c,
              "FromNo" : FromNameAndNon[i].Form_Name_ID__c,
              "FromId" : FromNameAndNon[i].Id,
              "DocumentLink" : FormWiseDocMap[FromNameAndNon[i].Id],
              "selected":true,
              "NoOfCount": 1,
              "FormType": FromNameAndNon[i].Form_Type__c,
              "LOBCode": FromNameAndNon[i].LOB_CODE__c,
              "Number": FromNameAndNon[i].Number__c,
              "Order": FromNameAndNon[i].Order__c,
              "Symbol": FromNameAndNon[i].Symbol__c,
              "Edition": FromNameAndNon[i].Edition__c,
              "Mandatory": FromNameAndNon[i].Mandatory__c,
              "Default": FromNameAndNon[i].Default__c,

          }
          if(FromNameAndNon[i].Id!=undefined){
            CoverageWiseDefaultForms[key].push(tempObj)
          }
          
        }
       
      }

      if(this.recordApi.commonForms!=undefined &&   !Array.isArray(this.recordApi.commonForms)){
        if(this.recordApi.commonForms.applicationId ==null || this.recordApi.commonForms.applicationId==""){
          this.recordApi.commonForms=[];
        }else{
          this.recordApi.commonForms=[this.recordApi.commonForms];
        }
        
    }

    if(CoverageWiseDefaultForms['Common']!=undefined &&  (this.recordApi.commonForms==undefined ||  this.recordApi.commonForms.length==0)){
      this.recordApi.commonForms=[];
      for(var j in CoverageWiseDefaultForms['Common']){
        var fm=JSON.parse(JSON.stringify(CoverageWiseDefaultForms['Common'][j]));
        fm.applicationId=this.applicationId;
        fm.indexNo=j;
        this.recordApi.commonForms.push( fm);
      }
    }else{
       // Restructure Existing Form Data
       var KeyWiseForm={}
       var FormData=JSON.parse(JSON.stringify(this.recordApi.commonForms));
       for(var k in FormData){
           if(KeyWiseForm[FormData[k].FromId]==undefined){
             KeyWiseForm[FormData[k].FromId]=FormData[k];
             KeyWiseForm[FormData[k].FromId].DocumentLink= PreSelectedDocumentLinks[FormData[k].FromId],
             KeyWiseForm[FormData[k].FromId].selected=true;
             KeyWiseForm[FormData[k].FromId].NoOfCount=1;
           }else{
             KeyWiseForm[FormData[k].FromId].NoOfCount+=1;
           }
       }
       this.recordApi.commonForms=[];

       for(var k in FormData){
         var data=JSON.parse(JSON.stringify(KeyWiseForm[FormData[k].FromId]));
         data.indexNo=k;
        this.recordApi.commonForms.push(data);
       }
    }

      var existingCoverageSelected=[];
      for(let i in this.recordApi.coverages){
          if(this.recordApi.coverages[i].iscoverageSelected!=undefined && this.recordApi.coverages[i].iscoverageSelected==true){
            existingCoverageSelected.push(this.recordApi.coverages[i].RecordTypeName);
          }
          if(this.recordApi.coverages[i].exposure!=undefined &&   !Array.isArray(this.recordApi.coverages[i].exposure)){
            if(this.recordApi.coverages[i].exposure.coverageID==null || this.recordApi.coverages[i].exposure.coverageID==""){
              // this.recordApi.coverages[i].exposure=null;
              this.recordApi.coverages[i].exposure=[{}];
            }else{
              this.recordApi.coverages[i].exposure=[this.recordApi.coverages[i].exposure];
            }
            
          }
          
          if (this.recordApi.coverages[i].forms!=undefined && !Array.isArray(this.recordApi.coverages[i].forms)) {
            if(this.recordApi.coverages[i].forms.coverageID==null || this.recordApi.coverages[i].forms.coverageID==""){
              this.recordApi.coverages[i].forms=[];
            }else{
              this.recordApi.coverages[i].forms=[this.recordApi.coverages[i].forms];
            }
           
          }
          if(this.recordApi.coverages[i].LOBCode==undefined){
            if(this.recordApi.coverages[i].RecordTypeName=='FC_Foreign_Commercial_General_Liability'){
                this.recordApi.coverages[i].LOBCode='GL';
            }
            if(this.recordApi.coverages[i].RecordTypeName=='FC_Foreign_Auto_Liability'){
              this.recordApi.coverages[i].LOBCode='Auto';
            }
            if(this.recordApi.coverages[i].RecordTypeName=='FC_Foreign_Voluntary_Workers_Compensation'){
              this.recordApi.coverages[i].LOBCode='FVWC';
            }
            if(this.recordApi.coverages[i].RecordTypeName=='FC_Emergency_Assistance'){
              this.recordApi.coverages[i].LOBCode='EA';
            }
            if(this.recordApi.coverages[i].RecordTypeName=='FC_Travel_Accident_And_Excess'){
              this.recordApi.coverages[i].LOBCode='BTA';
            }
            if(this.recordApi.coverages[i].RecordTypeName=='FC_Trip_Assistance_Coverage'){
              this.recordApi.coverages[i].LOBCode='Trip';
            }
          }
          if(this.recordApi.AllcoveragesID!=undefined){
            this.recordApi.coverages[i].coverageID =  this.recordApi.AllcoveragesID[i]!=undefined?this.recordApi.AllcoveragesID[i].CoverageID:null;
          }
          if(this.recordApi.coverages[i].exposure!=undefined &&   Array.isArray(this.recordApi.coverages[i].exposure)){
            for(var j in this.recordApi.coverages[i].exposure){
              if(this.recordApi.coverages[i].exposure[j].coverageID==null || this.recordApi.coverages[i].exposure[j].coverageID==""){
                this.recordApi.coverages[i].exposure[j].coverageID=this.recordApi.coverages[i].coverageID;
              }
            }
            
          }
          if(this.recordApi.coverages[i].forms==undefined || this.recordApi.coverages[i].forms.length==0){
           
            this.recordApi.coverages[i].forms=[];
            /*if(CoverageWiseDefaultForms['Common']!=undefined){
              for(var j in CoverageWiseDefaultForms['Common']){
                var fm=JSON.parse(JSON.stringify(CoverageWiseDefaultForms['Common'][j]));
                fm.coverageID=this.recordApi.coverages[i].coverageID;
                this.recordApi.coverages[i].forms.push( fm);
              }
            }*/
            if(this.recordApi.coverages[i].RecordTypeName=='FC_Foreign_Commercial_General_Liability'){
              for(var j in CoverageWiseDefaultForms['GL']){
                var fm=JSON.parse(JSON.stringify(CoverageWiseDefaultForms['GL'][j]));
                fm.coverageID=this.recordApi.coverages[i].coverageID;
                this.recordApi.coverages[i].forms.push( fm);
              }
            }
            if(this.recordApi.coverages[i].RecordTypeName=='FC_Foreign_Auto_Liability'){
              for(var j in CoverageWiseDefaultForms['Auto']){
                var fm=JSON.parse(JSON.stringify(CoverageWiseDefaultForms['Auto'][j]));
                fm.coverageID=this.recordApi.coverages[i].coverageID;
                this.recordApi.coverages[i].forms.push( fm);
              }
            }
            if(this.recordApi.coverages[i].RecordTypeName=='FC_Foreign_Voluntary_Workers_Compensation'){
              for(var j in CoverageWiseDefaultForms['FVWC']){
                var fm=JSON.parse(JSON.stringify(CoverageWiseDefaultForms['FVWC'][j]));
                fm.coverageID=this.recordApi.coverages[i].coverageID;
                this.recordApi.coverages[i].forms.push( fm);
              }
            }
            if(this.recordApi.coverages[i].RecordTypeName=='FC_Emergency_Assistance'){
              for(var j in CoverageWiseDefaultForms['EA']){
                var fm=JSON.parse(JSON.stringify(CoverageWiseDefaultForms['EA'][j]));
                fm.coverageID=this.recordApi.coverages[i].coverageID;
                this.recordApi.coverages[i].forms.push( fm);
              }
            }
            if(this.recordApi.coverages[i].RecordTypeName=='FC_Travel_Accident_And_Excess'){
              for(var j in CoverageWiseDefaultForms['BTA']){
                var fm=JSON.parse(JSON.stringify(CoverageWiseDefaultForms['BTA'][j]));
                fm.coverageID=this.recordApi.coverages[i].coverageID;
                this.recordApi.coverages[i].forms.push( fm);
              }
            }
            if(this.recordApi.coverages[i].RecordTypeName=='FC_Trip_Assistance_Coverage'){
              for(var j in CoverageWiseDefaultForms['Trip']){
                var fm=JSON.parse(JSON.stringify(CoverageWiseDefaultForms['Trip'][j]));
                fm.coverageID=this.recordApi.coverages[i].coverageID;
                this.recordApi.coverages[i].forms.push( fm);
              }
            }

                
              
          }else{

            if(this.isContinueApplicationStep!=undefined && (this.recordApi.IsContinueCompleted==undefined || this.recordApi.IsContinueCompleted!=true)){
                
              // Restructure Existing Form Data
              var KeyWiseForm={}
              var FormData=JSON.parse(JSON.stringify(this.recordApi.coverages[i].forms));
              for(var k in FormData){
                  if(KeyWiseForm[FormData[k].FromId]==undefined){
                    KeyWiseForm[FormData[k].FromId]=FormData[k];
                    KeyWiseForm[FormData[k].FromId].DocumentLink= PreSelectedDocumentLinks[FormData[k].FromId],
                    KeyWiseForm[FormData[k].FromId].selected=true;
                    KeyWiseForm[FormData[k].FromId].NoOfCount=1;
                  }else{
                    KeyWiseForm[FormData[k].FromId].NoOfCount+=1;
                  }
              }
              this.recordApi.coverages[i].forms=[];

              for(var k in FormData){
                var data=JSON.parse(JSON.stringify(KeyWiseForm[FormData[k].FromId]));
                data.indexNo=k;
                this.recordApi.coverages[i].forms.push(data);
              }

             
            }

          }
          
      }
      for(let i in this.recordApi.Data){
        if(this.recordApi.CasualtyLocalIDs!=undefined){
          this.recordApi.Data[i].CasualityLocalID = this.recordApi.CasualtyLocalIDs[i]!=undefined? this.recordApi.CasualtyLocalIDs[i].Id:null;
        }
        this.recordApi.Data[i].icnNm='utility:right';
        this.recordApi.Data[i].uniqueKey=this.recordApi.Data[i].Country+"_"+this.recordApi.Data[i].type;
       
      }
      // added to handle continue
      if( this.recordApi.cov==undefined){
          this.recordApi.cov=[{
                label: "Foreign Commercial General Liability And Employee Benefits Liability",
                code: "FCGLEmpBenefits",
                show: existingCoverageSelected.includes('FC_Foreign_Commercial_General_Liability')
                
            },
            {
                label: "Foreign Auto Liability Difference In Conditions/Excess Liability",
                code: "FCAULibDiff",
                show: existingCoverageSelected.includes('FC_Foreign_Auto_Liability')
            },
            {
                label: "Foreign Voluntary Workers Compensation And Employers Liability",
                code: "FCVolWC",
                show: existingCoverageSelected.includes('FC_Foreign_Voluntary_Workers_Compensation')
            },
            {
                label: "Emergency Assistance",
                code: "EmergencyAssis",
                show: existingCoverageSelected.includes('FC_Emergency_Assistance')
            },
            {
                label: "Travel Accident And Excess Out Of Country Medical Expense",
                code: "TravelAccAndExcessOutOfCount",
                show: existingCoverageSelected.includes('FC_Travel_Accident_And_Excess')
            },
            {
                label: "Trip Assistance",
                code: "TripAssis",
                show: existingCoverageSelected.includes('FC_Trip_Assistance_Coverage')
            },
        ];
      }
      if(this.isContinueApplicationStep!=undefined){
        if(this.isContinueApplicationStep>1){
        
        }else{
          this.recordApi.IsContinueCompleted=true;
        }
      }
      

  
    }

    if(!isNaN(this.recordApi.AutoExposure)){
      this.recordApi.AutoExposure=parseFloat(this.recordApi.AutoExposure)
    }
    
    this.pricingAndBreakdownDetails();
    this.checkMinimumPremiumValidation();
    this.recordApi.currentActiveStep=1;
    this.oldRecords=JSON.parse(JSON.stringify( this.recordApi));
    this.sendtoOmniscript();
   
    this._actionUtil = new OmniscriptActionCommonUtil();

    if(this.isContinueApplicationStep!=undefined && this.recordApi.IsContinueCompleted!=true){
      if(this.isContinueApplicationStep>1){
        this.omniNextStep();
      }
    
    }
  }
  pricingAndBreakdownDetails(){

    // this.ActualPremium='$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPTotal!=undefined?this.recordApi.GrossAPTotal.toFixed(0):0);
    this.ActualPremium='$'+this.numberWithCommasnodecimals(this.recordApi.UWOverrideGrossOfCommTpTotal!=undefined?this.recordApi.UWOverrideGrossOfCommTpTotal.toFixed(0):0);
      this.GLOccurenceLimit='$'+this.numberWithCommasnodecimals(this.recordApi.GLOccurenceLimit!=undefined?this.recordApi.GLOccurenceLimit.toFixed(0):0);
      this.GLDeductible='$'+this.numberWithCommasnodecimals((this.recordApi.GLDeductible!=undefined && this.recordApi.GLDeductible!="")?this.recordApi.GLDeductible.toFixed(0):0);
  
   this.BelowMinPreEarnedError="";

   

   if(this.recordApi.MinimumEarnedPremium!=null && this.recordApi.SumMasterMinPremium!=null && this.recordApi.MinimumEarnedPremium<this.recordApi.SumMasterMinPremium){
        this.BelowMinPreEarnedError="Below the minimum required premium";
   }   
   for(var i in this.recordApi.Data){
      if(this.recordApi.Data[i].type=='GL'){
        this.recordApi.Data[i].displayPrem=this.recordApi.Data[i].ActualGLLocalPrem;
        //above code was old logic without commision on ActualGlLocalPrem
        //this.recordApi.Data[i].displayPrem=this.recordApi.Data[i].ActualGLLocalPremWithCommision;
        // this.recordApi.Data[i].displayPrem=this.recordApi.Data[i].AllocatedActualGLLocalPrem;
      }
      if(this.recordApi.Data[i].type=='EL'){
        //this.recordApi.Data[i].displayPrem=(this.recordApi.Data[i].LocalELActualPrem==undefined || this.recordApi.Data[i].LocalELActualPrem=="")?this.recordApi.Data[i].LocalELTechnicalpremium:this.recordApi.Data[i].LocalELActualPrem;
        //above code was old logic change due to N2GFCB354
        this.recordApi.Data[i].displayPrem=(this.recordApi.Data[i].LocalELActualPrem==undefined || this.recordApi.Data[i].LocalELActualPrem=="")?this.recordApi.Data[i].LocalELTechnicalGrossOfComm:this.recordApi.Data[i].LocalELActualPrem;
      }
   } 
   var pricingDetails=[
      
      /*{
        Label: "Actual Premium(Gross of Commission)",
        Total: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPTotal!=undefined?this.recordApi.GrossAPTotal.toFixed(0):0),
        Local: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPLocal!=undefined?this.recordApi.GrossAPLocal.toFixed(0):0),
        Master: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPMaster!=undefined?this.recordApi.GrossAPMaster.toFixed(0):0),
        ErrorWarningFlag: "-"
      },*/
      {
        Label: "Technical Premium(Gross of Commission)",
        Total: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossTPTotal!=undefined?this.recordApi.GrossTPTotal.toFixed(0):0),
        // Total: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossTechnicalPremium!=undefined?this.recordApi.GrossTechnicalPremium.toFixed(0):0),
        Local: '-',
        Master: '-',
        ErrorWarningFlag: "-"
      },
      {
        Label: "%Master vs. Local",
        Total: "100%",
        Local: (this.recordApi.GrossPerLocal!=undefined?((this.recordApi.GrossPerLocal)*100).toFixed(0):0 )+'%',
        Master: (this.recordApi.GrossPerMaster!=undefined?((this.recordApi.GrossPerMaster)*100).toFixed(0):0) +'%',
        ErrorWarningFlag: "-"
      },
      {
        Label: "AP/TP",
        Total: (this.recordApi.APTPTotal!=undefined?(this.recordApi.APTPTotal*100).toFixed(0):0)+'%',
        Local: "-",
        Master: "-",
        ErrorWarningFlag: "-"
      },
      {
        //Label: "Commission to Enter in GeR Rater",
        Label: "Commission % from Gerater",
        // Total: (this.recordApi.CommToEnterGerRate!=undefined?((this.recordApi.CommToEnterGerRate)*100).toFixed(1):0) +'%',
        Total: (this.recordApi.Commission!=undefined?((this.recordApi.Commission)*100).toFixed(1):0) +'%',
        Local: "-",
        Master: "-",
        ErrorWarningFlag: "-"
      }
  ];
  this.pricingInfo=JSON.parse(JSON.stringify(pricingDetails));

  var premBreakDown=[
    // {
    //   Label: "Actual Premium",
    //   Total: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPTotal.toFixed(0)),
    //   Local: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPLocal.toFixed(0)),
    //   Master: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPMaster.toFixed(0)),
    //   UWSelectedMasterPremium: (this.recordApi.UWOverrideGrossAPTotal!=undefined && this.recordApi.UWOverrideGrossAPTotal!="")?this.recordApi.UWOverrideGrossAPTotal.toFixed(0):null,
    //   Rates: "1.2%",
    //   MinPrem: "", 
    //   fieldUpdateKey:"UWOverrideGrossAPTotal",
    //   flag: true,
    //   placeHolder: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossAPTotal.toFixed(0)),
    //   ErrorWarningFlag:( this.recordApi.UWOverrideGrossAPTotal!=undefined && this.recordApi.UWOverrideGrossAPTotal!="" && this.recordApi.UWOverrideGrossAPTotal!='' && this.recordApi.UWOverrideGrossAPTotal<this.recordApi.MasterMinPremium)?'Master premium is below minimum':''
    
    //   },
      {
        //Label: "Total",
        //Total: '$'+this.numberWithCommasnodecimals(this.recordApi.totalTotal.toFixed(0)),
        //Local: '$'+this.numberWithCommasnodecimals(this.recordApi.LocalTotal.toFixed(0)),
        //Master: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterTotal.toFixed(0)),
        //UWSelectedMasterPremium: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterTotal.toFixed(0)),
        //Rates: "1.4%",
        //MinPrem: "-",
        // fieldUpdateKey:"totalTotal",
        

        Coverage: "Total",
        GrossTechnical: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossOfCommTpTotal.toFixed(0)),
        GrossActualIntialEditField: true,
        isExcludedEnable:true,
        default_Excluded_Flag: false,
        isExcludeExposure:true,
        // GrossActualIntial: '$'+this.numberWithCommasnodecimals(this.recordApi.totalTotal.toFixed(0)),
        UWSelectedGrossActualIntial: (this.recordApi.UWOverrideGrossOfCommTpTotal.toFixed(0)),
        Exposure: "",
        Rates: "",
        flag: false,
        fieldUpdateKey:"UWOverrideGrossOfCommTpTotal",
        ApTp: false
      },
      {
        // Label: "GL+ Other Extension",
        // Total: '$'+this.numberWithCommasnodecimals(this.recordApi.TotalGlOtherExt.toFixed(0)),
        // Local: '$'+this.numberWithCommasnodecimals(this.recordApi.LocalGlOtherExt.toFixed(0)),
        // Master: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterGlOtherExt.toFixed(0)),
        // UWSelectedMasterPremium:  '$'+this.numberWithCommasnodecimals(this.recordApi.MasterGlOtherExt.toFixed(0)),
        // Rates: "3.1%",
        // MinPrem: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterMinPremiumGLOtherExt!=undefined?this.recordApi.MasterMinPremiumGLOtherExt.toFixed(0):0),
        // flag: false,
        // fieldUpdateKey:"TotalGlOtherExt"
        
        Coverage: "GL",
        GrossTechnical: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossOfCommTpGl.toFixed(0)),
        GrossActualIntialEditField: false,
        isExcludedEnable:true,
        default_Excluded_Flag: false,
        isExcludeExposure:true,
        // GrossActualIntial: '$'+this.numberWithCommasnodecimals(this.recordApi.TotalGlOtherExt.toFixed(0)),
        UWSelectedGrossActualIntial: (this.recordApi.UWOverrideGrossOfCommTpGl.toFixed(0)),
        Exposure: '$'+this.numberWithCommasnodecimals(this.recordApi.ExposureAmount.toFixed(2)),
        Rates: (this.recordApi.UWOverrideGrossOfCommTpGl!=undefined && this.recordApi.ExposureAmount!=undefined && (this.recordApi.UWOverrideGrossOfCommTpGl/this.recordApi.ExposureAmount * 1000).toFixed(4) != 'NaN' && (this.recordApi.UWOverrideGrossOfCommTpGl/this.recordApi.ExposureAmount * 1000).toFixed(4) != 'Infinity'?(this.recordApi.UWOverrideGrossOfCommTpGl/this.recordApi.ExposureAmount * 1000).toFixed(4):0),
        flag: false,
        fieldUpdateKey:"UWOverrideGrossOfCommTpGl",
        ApTp: false
      },
      {
        // Label: "FVWC",
        // Total: '$'+this.numberWithCommasnodecimals(this.recordApi.NetOfCommTpFVWC.toFixed(0)),
        // Local: "-",
        // Master: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterFVWC.toFixed(0)),
        // UWSelectedMasterPremium: this.recordApi.NetOfCommTpFVWC.toFixed(0),
        // Rates: "1.2%",
        // MinPrem: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterMinPremiumFVWC!=undefined?this.recordApi.MasterMinPremiumFVWC.toFixed(0):0),
        // flag: true,
        // fieldUpdateKey:"NetOfCommTpFVWC",
        Coverage: "FVWC",
        GrossTechnical: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossOfCommTpFVWC.toFixed(0)),
        GrossActualIntialEditField: true,
        isExcludedEnable:false,
        isExcludeExposure:true,
        // GrossActualIntial: '$'+this.numberWithCommasnodecimals(this.recordApi.NetOfCommTpFVWC.toFixed(0)),
        UWSelectedGrossActualIntial: (this.recordApi.UWOverrideGrossOfCommTpFVWC.toFixed(0)),
        Exposure: '$'+this.numberWithCommasnodecimals(this.recordApi.FvwcExposure.toFixed(2)),
        Rates: (this.recordApi.UWOverrideGrossOfCommTpFVWC!=undefined && this.recordApi.FvwcExposure!=undefined && (this.recordApi.UWOverrideGrossOfCommTpFVWC/this.recordApi.FvwcExposure * 100).toFixed(4) != 'NaN' && (this.recordApi.UWOverrideGrossOfCommTpFVWC/this.recordApi.FvwcExposure * 100).toFixed(4) != 'Infinity' ?(this.recordApi.UWOverrideGrossOfCommTpFVWC/this.recordApi.FvwcExposure * 100).toFixed(4):0),
        flag: false,
        default_Excluded_Flag: false,
        fieldUpdateKey:"UWOverrideGrossOfCommTpFVWC",
        ApTp: false,
        GrossActualIntialEditField: this.recordApi.UWOverrideGrossOfCommTpFVWCExclude!=undefined?!this.recordApi.UWOverrideGrossOfCommTpFVWCExclude:true,
        checked:this.recordApi.UWOverrideGrossOfCommTpFVWCExclude,
        ErrMsg: (this.recordApi.UWOverrideGrossOfCommTpFVWC.toFixed(0)) < 1000 ? 'FVWC Gross Actual Initial is below minimum' : ''
      },
      {
        // Label: "Auto",
        // Total: '$'+this.numberWithCommasnodecimals(this.recordApi.NetOfCommTpAuto.toFixed(0)),
        // Local: "-",
        // Master: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterAuto.toFixed(0)),
        // UWSelectedMasterPremium: this.recordApi.NetOfCommTpAuto.toFixed(0),
        // Rates: "2.1%",
        // MinPrem:'$'+this.numberWithCommasnodecimals(this.recordApi.MasterMinPremiumAuto!=undefined?this.recordApi.MasterMinPremiumAuto.toFixed(0):0),
        // flag: true,
        // fieldUpdateKey:"NetOfCommTpAuto",
        
        Coverage: "Auto",
        GrossTechnical: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossOfCommTpAuto.toFixed(0)),
        GrossActualIntialEditField: true,
        isExcludedEnable:false,
        isExcludeExposure:true,
        // GrossActualIntial: '$'+this.numberWithCommasnodecimals(this.recordApi.NetOfCommTpAuto.toFixed(0)),
        UWSelectedGrossActualIntial: (this.recordApi.UWOverrideGrossOfCommTpAuto.toFixed(0)),
        Exposure: (isNaN(this.recordApi.AutoExposure)?0:this.numberWithCommasnodecimals(this.recordApi.AutoExposure.toFixed(2))) ,
        // Rates: (this.recordApi.UWOverrideGrossOfCommTpAuto!=undefined && this.recordApi.AutoExposure!=undefined && !isNaN(this.recordApi.AutoExposure) && (this.recordApi.UWOverrideGrossOfCommTpAuto/this.recordApi.AutoExposure * 100).toFixed(4) != 'NaN' && (this.recordApi.UWOverrideGrossOfCommTpAuto/this.recordApi.AutoExposure * 100).toFixed(4) != 'Infinity' ?(this.recordApi.UWOverrideGrossOfCommTpAuto/this.recordApi.AutoExposure * 100).toFixed(4):(parseInt('0').toFixed(4))),
        // changes for N2GFCB483
        Rates: (this.recordApi.UWOverrideGrossOfCommTpAuto!=undefined && this.recordApi.AutoExposure!=undefined && !isNaN(this.recordApi.AutoExposure) && (this.recordApi.UWOverrideGrossOfCommTpAuto/this.recordApi.AutoExposure).toFixed(4) != 'NaN' && (this.recordApi.UWOverrideGrossOfCommTpAuto/this.recordApi.AutoExposure).toFixed(4) != 'Infinity' ?(this.recordApi.UWOverrideGrossOfCommTpAuto/this.recordApi.AutoExposure).toFixed(4):(parseInt('0').toFixed(4))),
        flag: false,
        default_Excluded_Flag: false,
        fieldUpdateKey:"UWOverrideGrossOfCommTpAuto",
        ApTp: false,
        GrossActualIntialEditField: this.recordApi.UWOverrideGrossOfCommTpAutoExclude!=undefined?!this.recordApi.UWOverrideGrossOfCommTpAutoExclude:true,
        checked:this.recordApi.UWOverrideGrossOfCommTpAutoExclude,
        ErrMsg: (this.recordApi.UWOverrideGrossOfCommTpAuto.toFixed(0)) < 500 ? 'Auto Gross Actual Initial is below minimum' : ''
      },
      {
        // Label: "BTA",
        // Total: '$'+this.numberWithCommasnodecimals(this.recordApi.NetOfCommTpBTA.toFixed(0)),
        // Local: "-",
        // Master: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterBTA.toFixed(0)),
        // UWSelectedMasterPremium: this.recordApi.NetOfCommTpBTA.toFixed(0),
        // Rates: "0.1%",
        // MinPrem: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterMinPremiumBTA!=undefined?this.recordApi.MasterMinPremiumBTA.toFixed(0):0),
        // flag: true,
        // fieldUpdateKey:"NetOfCommTpBTA",
        
        Coverage: "BTA",
        GrossTechnical: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossOfCommTpBTA.toFixed(0)),
        GrossActualIntialEditField: true,
        isExcludedEnable:false,
        default_Excluded_Flag: false,
        isExcludeExposure:false,
        // GrossActualIntial: '$'+this.numberWithCommasnodecimals(this.recordApi.NetOfCommTpBTA.toFixed(0)),
        UWSelectedGrossActualIntial: (this.recordApi.UWOverrideGrossOfCommTpBTA.toFixed(0)),
        Exposure: this.recordApi.Exposure,
        Rates: (this.recordApi.UWOverrideGrossOfCommTpBTA!=undefined && this.recordApi.Exposure!=undefined && (this.recordApi.UWOverrideGrossOfCommTpBTA/this.recordApi.Exposure).toFixed(4) != 'NaN' && (this.recordApi.UWOverrideGrossOfCommTpBTA/this.recordApi.Exposure).toFixed(4) != 'Infinity' ?(this.recordApi.UWOverrideGrossOfCommTpBTA/this.recordApi.Exposure).toFixed(4):'0.0000'),
        flag: true,
        // fieldUpdateKey:"Exposure",
        fieldUpdateKey:"UWOverrideGrossOfCommTpBTA",
        ApTp: false,
        GrossActualIntialEditField: this.recordApi.UWOverrideGrossOfCommTpBTAExclude!=undefined?!this.recordApi.UWOverrideGrossOfCommTpBTAExclude:true,
        checked:this.recordApi.UWOverrideGrossOfCommTpBTAExclude
      },
      {
        // Label: "Local EL",
        // Total: '$'+this.numberWithCommasnodecimals(this.recordApi.NetOfCommTpLocalEl.toFixed(0)),
        // Local: '$'+this.numberWithCommasnodecimals(this.recordApi.NetOfCommTpLocalEl.toFixed(0)),
        // Master: "-",
        // UWSelectedMasterPremium: "-",
        // Rates: "-",
        // MinPrem: "-",
        // flag: false,
        // fieldUpdateKey:"NetOfCommTpLocalEl",

        
        Coverage: "Local EL",
        GrossTechnical: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossOfCommTpLocalEl.toFixed(0)),
        GrossActualIntialEditField: false,
        isExcludedEnable:true,
        default_Excluded_Flag: false,
        isExcludeExposure:true,
        // GrossActualIntial: '$'+this.numberWithCommasnodecimals(this.recordApi.NetOfCommTpLocalEl.toFixed(0)),
        UWSelectedGrossActualIntial: (this.recordApi.totalLocalELTechnicalGrossOfComm.toFixed(0)),
        Exposure: "",
        Rates: "",
        flag: false,
        fieldUpdateKey:"UWOverrideGrossOfCommTpLocalEl",
        ApTp: false
      },
      {
        // Total: '$'+this.numberWithCommasnodecimals(this.recordApi.TotalGlOtherExt.toFixed(0)),
        // Local: '$'+this.numberWithCommasnodecimals(this.recordApi.LocalGlOtherExt.toFixed(0)),
        // Master: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterGlOtherExt.toFixed(0)),
        // UWSelectedMasterPremium:  '$'+this.numberWithCommasnodecimals(this.recordApi.MasterGlOtherExt.toFixed(0)),
        // Rates: "3.1%",
        // MinPrem: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterMinPremiumGLOtherExt!=undefined?this.recordApi.MasterMinPremiumGLOtherExt.toFixed(0):0),
        Coverage: "AP/TP",
        GrossTechnical: "",
        GrossActualIntialEditField: false,
        isExcludedEnable:true,
        default_Excluded_Flag: false,
        isExcludeExposure:true,
        UWSelectedGrossActualIntial: "",
        Exposure: "",
        Rates: "",
        flag: false,
        fieldUpdateKey:"TotalGlOtherExt",
        ApTp: ((this.recordApi.UWOverrideGrossOfCommTpTotal.toFixed(0) / this.recordApi.GrossOfCommTpTotal.toFixed(0)) * 100).toFixed(0) +'%'
      },
      
      // {
      //   Label: "GL+ Other Extension",
      //   Total: '$'+this.numberWithCommasnodecimals(this.recordApi.TotalGlOtherExt.toFixed(0)),
      //   Local: '$'+this.numberWithCommasnodecimals(this.recordApi.LocalGlOtherExt.toFixed(0)),
      //   Master: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterGlOtherExt.toFixed(0)),
      //   UWSelectedMasterPremium:  '$'+this.numberWithCommasnodecimals(this.recordApi.MasterGlOtherExt.toFixed(0)),
      //   Rates: "3.1%",
      //   MinPrem: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterMinPremiumGLOtherExt!=undefined?this.recordApi.MasterMinPremiumGLOtherExt.toFixed(0):0),
      //   fieldUpdateKey:"TotalGlOtherExt",
      //   flag: false
      // },
      // {
      //   Label: "Total",
      //   Total: '$'+this.numberWithCommasnodecimals(this.recordApi.totalTotal.toFixed(0)),
      //   Local: '$'+this.numberWithCommasnodecimals(this.recordApi.LocalTotal.toFixed(0)),
      //   Master: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterTotal.toFixed(0)),
      //   UWSelectedMasterPremium: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterTotal.toFixed(0)),
      //   Rates: "1.4%",
      //   MinPrem: "-",
      //   fieldUpdateKey:"totalTotal",
      //   flag: false
      // },
      // {
      //   Label: "% of Total",
      //   Total: "100%",
      //   Local: (this.recordApi.LocalPerToTotal*100).toFixed(0)+'%',
      //   Master: (this.recordApi.MstrPerOfTotal*100).toFixed(0)+'%',
      //   UWSelectedMasterPremium: "-",
      //   Rates: "-",
      //   MinPrem: "-",
      //   fieldUpdateKey:"LocalPerToTotal",
      //   flag: false
      // },

    ]

    this.premBreakDown=JSON.parse(JSON.stringify(premBreakDown));

    // for the fourth screeen 
    var premBreakDownOverview=[
      {
        //Total: '$'+this.numberWithCommasnodecimals(this.recordApi.totalTotal.toFixed(0)),
        //Local: '$'+this.numberWithCommasnodecimals(this.recordApi.LocalTotal.toFixed(0)),
        //Master: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterTotal.toFixed(0)),
        //UWSelectedMasterPremium: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterTotal.toFixed(0)),
        //Rates: "1.4%",
        //MinPrem: "-",
        // fieldUpdateKey:"totalTotal",
        Coverage: "Total",
        GrossTechnical: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossOfCommTpTotal.toFixed(0)),
        GrossActualIntialEditField: false,
        // UWSelectedGrossActualFinal: (this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpTotal.toFixed(0)),
        UWSelectedGrossActualFinal: (this.recordApi.UWOverrideGrossOfCommTpTotal.toFixed(0)),
        // Local: (this.recordApi.LocalTotal.toFixed(0)),
        // Master: (this.recordApi.MasterTotal.toFixed(0)),
        Local: (this.recordApi.GrossAPLocalOverride.toFixed(0)),
        Master: (this.recordApi.GrossAPMasterOverride.toFixed(0)),
        Exposure: "",
        Rates: "",
        flag: false,
        // fieldUpdateKey:"totalTotal",
        fieldUpdateKey:"UWOverrideGrossOfCommTpTotal",
        ApTp: false
      },
      {
        // Label: "GL+ Other Extension",
        // Total: '$'+this.numberWithCommasnodecimals(this.recordApi.TotalGlOtherExt.toFixed(0)),
        // Local: '$'+this.numberWithCommasnodecimals(this.recordApi.LocalGlOtherExt.toFixed(0)),
        // Master: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterGlOtherExt.toFixed(0)),
        // UWSelectedMasterPremium:  '$'+this.numberWithCommasnodecimals(this.recordApi.MasterGlOtherExt.toFixed(0)),
        // Rates: "3.1%",
        // MinPrem: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterMinPremiumGLOtherExt!=undefined?this.recordApi.MasterMinPremiumGLOtherExt.toFixed(0):0),
        // flag: false,
        // fieldUpdateKey:"TotalGlOtherExt"
        
        Coverage: "GL",
        GrossTechnical: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossOfCommTpGl.toFixed(0)),
        GrossActualIntialEditField: false,
        // UWSelectedGrossActualFinal: (this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpGl.toFixed(0)),
        // UWSelectedGrossActualFinal: (this.recordApi.UWOverrideGrossOfCommTpGl.toFixed(0)),
        UWSelectedGrossActualFinal: (this.recordApi.UWOverrideGrossOfCommTpGl.toFixed(0)),
        // Local: (this.recordApi.LocalGlOtherExt.toFixed(0)),
        // Local: (this.recordApi.LocalGlOtherExtWithComm.toFixed(0)),
        Local: (this.recordApi.TotalLocalGlOtherExtWithComm.toFixed(0)),
        // Master: (this.recordApi.MasterGlOtherExt.toFixed(0)),
        Master: (this.recordApi.MasterGlOtherExtWithComm.toFixed(0)),
        Exposure: '$'+this.numberWithCommasnodecimals(this.recordApi.ExposureAmount.toFixed(2)),
        // Rates: (this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpGl!=undefined && this.recordApi.ExposureAmount!=undefined && (this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpGl/this.recordApi.ExposureAmount * 1000).toFixed(4) != 'NaN' && (this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpGl/this.recordApi.ExposureAmount * 1000).toFixed(4) != 'Infinity' ?(this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpGl/this.recordApi.ExposureAmount * 1000).toFixed(4):0),
        Rates: (this.recordApi.UWOverrideGrossOfCommTpGl!=undefined && this.recordApi.ExposureAmount!=undefined && (this.recordApi.UWOverrideGrossOfCommTpGl/this.recordApi.ExposureAmount * 1000).toFixed(4) != 'NaN' && (this.recordApi.UWOverrideGrossOfCommTpGl/this.recordApi.ExposureAmount * 1000).toFixed(4) != 'Infinity' ?(this.recordApi.UWOverrideGrossOfCommTpGl/this.recordApi.ExposureAmount * 1000).toFixed(4):0),
        flag: false,
        // fieldUpdateKey:"TotalGlOtherExt",
        // fieldUpdateKey:"MasterGlOtherExt",
        fieldUpdateKey:"UWOverrideGrossOfCommTpGl",
        ApTp: false,
        ErrorMsg: (this.recordApi.MasterGlOtherExtWithComm.toFixed(0))<parseFloat(this.recordApi.GLMasterMin)?'"GL Master Premium" is Below Minimum':'',
        LclErrorMsg: (this.recordApi.TotalLocalGlOtherExtWithComm.toFixed(0))<0?'"Local GL Premium" is Below Minimum':'',
        UWSelectedGrossActualFinalErrorMsg: (this.recordApi.UWOverrideGrossOfCommTpGl.toFixed(0))<0?'"Gross Actual Final GL Premium" is Below Minimum':''
      },
      {
        // Label: "FVWC",
        // Total: '$'+this.numberWithCommasnodecimals(this.recordApi.NetOfCommTpFVWC.toFixed(0)),
        // Local: "-",
        // Master: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterFVWC.toFixed(0)),
        // UWSelectedMasterPremium: this.recordApi.NetOfCommTpFVWC.toFixed(0),
        // Rates: "1.2%",
        // MinPrem: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterMinPremiumFVWC!=undefined?this.recordApi.MasterMinPremiumFVWC.toFixed(0):0),
        // flag: true,
        // fieldUpdateKey:"NetOfCommTpFVWC",
        Coverage: "FVWC",
        GrossTechnical: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossOfCommTpFVWC.toFixed(0)),
        GrossActualIntialEditField: false,
        // UWSelectedGrossActualFinal: (this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpFVWC.toFixed(0)),
        UWSelectedGrossActualFinal: (this.recordApi.UWOverrideGrossOfCommTpFVWC.toFixed(0)),
        Local: "",
        // Master: (this.recordApi.MasterFVWC.toFixed(0)),
        Master: (this.recordApi.UWOverrideGrossOfCommTpFVWC.toFixed(0)),
        Exposure: '$'+this.numberWithCommasnodecimals(this.recordApi.FvwcExposure.toFixed(2)),
        // Rates: (this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpFVWC!=undefined && this.recordApi.FvwcExposure!=undefined && (this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpFVWC/this.recordApi.FvwcExposure * 100).toFixed(4) != 'NaN' && (this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpFVWC/this.recordApi.FvwcExposure * 100).toFixed(4) != 'Infinity' ?(this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpFVWC/this.recordApi.FvwcExposure * 100).toFixed(4):0),
        Rates: (this.recordApi.UWOverrideGrossOfCommTpFVWC!=undefined && this.recordApi.FvwcExposure!=undefined && (this.recordApi.UWOverrideGrossOfCommTpFVWC/this.recordApi.FvwcExposure * 100).toFixed(4) != 'NaN' && (this.recordApi.UWOverrideGrossOfCommTpFVWC/this.recordApi.FvwcExposure * 100).toFixed(4) != 'Infinity' ?(this.recordApi.UWOverrideGrossOfCommTpFVWC/this.recordApi.FvwcExposure * 100).toFixed(4):0),
        flag: true,
        // fieldUpdateKey:"NetOfCommTpFVWC",
        // fieldUpdateKey:"MasterFVWC",
        fieldUpdateKey:"UWOverrideGrossOfCommTpFVWC",
        ApTp: false,
        // GrossActualIntialEditField: this.recordApi.MasterFVWCExclude!=undefined?!this.recordApi.MasterFVWCExclude:false,
        GrossActualIntialEditField: this.recordApi.UWOverrideGrossOfCommTpFVWCExclude!=undefined?!this.recordApi.UWOverrideGrossOfCommTpFVWCExclude:true,

      },
      {
        // Label: "Auto",
        // Total: '$'+this.numberWithCommasnodecimals(this.recordApi.NetOfCommTpAuto.toFixed(0)),
        // Local: "-",
        // Master: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterAuto.toFixed(0)),
        // UWSelectedMasterPremium: this.recordApi.NetOfCommTpAuto.toFixed(0),
        // Rates: "2.1%",
        // MinPrem:'$'+this.numberWithCommasnodecimals(this.recordApi.MasterMinPremiumAuto!=undefined?this.recordApi.MasterMinPremiumAuto.toFixed(0):0),
        // flag: true,
        // fieldUpdateKey:"NetOfCommTpAuto",
        
        Coverage: "Auto",
        GrossTechnical: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossOfCommTpAuto.toFixed(0)),
        GrossActualIntialEditField: false,
        // UWSelectedGrossActualFinal: (this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpAuto.toFixed(0)),
        UWSelectedGrossActualFinal: (this.recordApi.UWOverrideGrossOfCommTpAuto.toFixed(0)),
        Local: "",
        // Master: (this.recordApi.MasterAuto.toFixed(0)),
        Master: (this.recordApi.UWOverrideGrossOfCommTpAuto.toFixed(0)),
        Exposure: (isNaN(this.recordApi.AutoExposure)?0:this.numberWithCommasnodecimals(this.recordApi.AutoExposure.toFixed(2))) ,
        // Rates: (this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpAuto!=undefined && this.recordApi.AutoExposure!=undefined && (this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpAuto/this.recordApi.AutoExposure * 100).toFixed(4) != 'NaN' && (this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpAuto/this.recordApi.AutoExposure * 100).toFixed(4) != 'Infinity' ?(this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpAuto/this.recordApi.AutoExposure * 100).toFixed(4):0),
        Rates: (this.recordApi.UWOverrideGrossOfCommTpAuto!=undefined && this.recordApi.AutoExposure!=undefined && !isNaN(this.recordApi.AutoExposure) && (this.recordApi.UWOverrideGrossOfCommTpAuto/this.recordApi.AutoExposure * 100).toFixed(4) != 'NaN' && (this.recordApi.UWOverrideGrossOfCommTpAuto/this.recordApi.AutoExposure * 100).toFixed(4) != 'Infinity' ?(this.recordApi.UWOverrideGrossOfCommTpAuto/this.recordApi.AutoExposure * 100).toFixed(4):(parseInt('0').toFixed(4))),
        flag: true,
        // fieldUpdateKey:"NetOfCommTpAuto",
        // fieldUpdateKey:"MasterAuto",
        fieldUpdateKey:"UWOverrideGrossOfCommTpAuto",
        ApTp: false,
        GrossActualIntialEditField: this.recordApi.UWOverrideGrossOfCommTpAutoExclude!=undefined?!this.recordApi.UWOverrideGrossOfCommTpAutoExclude:true,

      },
      {
        // Label: "BTA",
        // Total: '$'+this.numberWithCommasnodecimals(this.recordApi.NetOfCommTpBTA.toFixed(0)),
        // Local: "-",
        // Master: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterBTA.toFixed(0)),
        // UWSelectedMasterPremium: this.recordApi.NetOfCommTpBTA.toFixed(0),
        // Rates: "0.1%",
        // MinPrem: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterMinPremiumBTA!=undefined?this.recordApi.MasterMinPremiumBTA.toFixed(0):0),
        // flag: true,
        // fieldUpdateKey:"NetOfCommTpBTA",
        
        Coverage: "BTA",
        GrossTechnical: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossOfCommTpBTA.toFixed(0)),
        GrossActualIntialEditField: false,
        // UWSelectedGrossActualFinal: (this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpBTA.toFixed(0)),
        UWSelectedGrossActualFinal: (this.recordApi.UWOverrideGrossOfCommTpBTA.toFixed(0)),
         Local: "",
        // Master: (this.recordApi.MasterBTA.toFixed(0)),
        Master: (this.recordApi.UWOverrideGrossOfCommTpBTA.toFixed(0)),
        Exposure: this.recordApi.Exposure,
        // Rates: (this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpBTA!=undefined && this.recordApi.Exposure!=undefined && (this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpBTA/this.recordApi.Exposure).toFixed(4) != 'NaN' && (this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpBTA/this.recordApi.Exposure).toFixed(4) != 'Infinity' ?(this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpBTA/this.recordApi.Exposure).toFixed(4):0),
        Rates: (this.recordApi.UWOverrideGrossOfCommTpBTA!=undefined && this.recordApi.Exposure!=undefined && (this.recordApi.UWOverrideGrossOfCommTpBTA/this.recordApi.Exposure).toFixed(4) != 'NaN' && (this.recordApi.UWOverrideGrossOfCommTpBTA/this.recordApi.Exposure).toFixed(4) != 'Infinity' ?(this.recordApi.UWOverrideGrossOfCommTpBTA/this.recordApi.Exposure).toFixed(4):'0.0000'),
        flag: true,
        // fieldUpdateKey:"Exposure",
        // fieldUpdateKey:"NetOfCommTpBTA",
        // fieldUpdateKey:"MasterBTA",
        fieldUpdateKey:"UWOverrideGrossOfCommTpBTA",
        ApTp: false,
        GrossActualIntialEditField: this.recordApi.UWOverrideGrossOfCommTpBTAExclude!=undefined?!this.recordApi.UWOverrideGrossOfCommTpBTAExclude:true
      },
      {
        // Label: "Local EL",
        // Total: '$'+this.numberWithCommasnodecimals(this.recordApi.NetOfCommTpLocalEl.toFixed(0)),
        // Local: '$'+this.numberWithCommasnodecimals(this.recordApi.NetOfCommTpLocalEl.toFixed(0)),
        // Master: "-",
        // UWSelectedMasterPremium: "-",
        // Rates: "-",
        // MinPrem: "-",
        // flag: false,
        // fieldUpdateKey:"NetOfCommTpLocalEl",

        
        Coverage: "Local EL",
        GrossTechnical: '$'+this.numberWithCommasnodecimals(this.recordApi.GrossOfCommTpLocalEl.toFixed(0)),
        GrossActualIntialEditField: false,
        // UWSelectedGrossActualFinal: (this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpLocalEl.toFixed(0)),
        UWSelectedGrossActualFinal: (this.recordApi.totalLocalELTechnicalGrossOfComm.toFixed(0)),
        // Local: (this.recordApi.NetOfCommTpLocalEl.toFixed(0)),
        Local: (this.recordApi.totalLocalELTechnicalGrossOfComm.toFixed(0)),
        Master: "",
        Exposure: "",
        Rates: "",
        flag: false,
        // fieldUpdateKey:"NetOfCommTpLocalEl",
        fieldUpdateKey:"UWOverrideGrossOfCommTpLocalEl",
        ApTp: false
      },
      {
        // Total: '$'+this.numberWithCommasnodecimals(this.recordApi.TotalGlOtherExt.toFixed(0)),
        // Local: '$'+this.numberWithCommasnodecimals(this.recordApi.LocalGlOtherExt.toFixed(0)),
        // Master: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterGlOtherExt.toFixed(0)),
        // UWSelectedMasterPremium:  '$'+this.numberWithCommasnodecimals(this.recordApi.MasterGlOtherExt.toFixed(0)),
        // Rates: "3.1%",
        // MinPrem: '$'+this.numberWithCommasnodecimals(this.recordApi.MasterMinPremiumGLOtherExt!=undefined?this.recordApi.MasterMinPremiumGLOtherExt.toFixed(0):0),
        Coverage: "AP/TP",
        GrossTechnical: "",
        GrossActualIntialEditField: false,
        UWSelectedGrossActualFinal: "",
        Local: "",
        Master: "",
        Exposure: "",
        Rates: "",
        flag: false,
        fieldUpdateKey:"TotalGlOtherExt",
        // ApTp: ((this.recordApi.UWOverrideGrossActualFinalGrossOfCommTpTotal.toFixed(0) / this.recordApi.GrossOfCommTpTotal.toFixed(0)) * 100).toFixed(0) +'%'
        ApTp: ((this.recordApi.UWOverrideGrossOfCommTpTotal.toFixed(0) / this.recordApi.GrossOfCommTpTotal.toFixed(0)) * 100).toFixed(0) +'%'
      }
    ]
    this.premBreakDownOverview=JSON.parse(JSON.stringify(premBreakDownOverview));

    this.countryValue = this.recordApi["Data"]; 
    
  }

  @track icnNm ;
  @track show = false;
  @track lobGLPolY = false;
  @track lobELPolY = false;
  @track lobGLPolFOS = false;
  // @track lobDicPolDil = false;
  // @track country;
  

  actionChg(event) {
    console.log("buttonClicked")
    const countryVal = event.target.alternativeText;
    const typeVal=event.target.dataset.type;
    let index;
    let apiData=[];
    
    //const data = this.recordApi.Data.find((item)=>item.Country === country);
    /*for (let x in this.recordApi["Data"]) {
      let data= JSON.parse(JSON.stringify(this.recordApi["Data"][x]));
      
      if(data.Country == country){
          index=x;
          //console.log("country",this.country);
          //console.log("data",this.data);
          // const country = event.target.dataset.country
          data.show = data.show==undefined?true:(!data.show)
          // console.log("mytrue",data.show)
          // console.log("myfalse",!data.show);
          // console.log("myLOB",data.LOB);  
            
            if (data.show == true) {
              // console.log("you are inside if")
              data.icnNm = 'utility:down';
              data.show = true;
            } else {
              data.icnNm = 'utility:right';
              data.show = false;
            }

            if (data.LOB == "GL" && data.LoclPolReq == "Y") {
                  data.lobGLPolY = true;
                  data.lobELPolY = false;
                  data.lobGLPolFOS = false;

                } else if (data.LOB == "EL" && data.LoclPolReq == "Y") {
                  // console.log(this.lobELPolY)
                  data.lobELPolY = true;
                  data.lobGLPolY = false;
                  data.lobGLPolFOS = false;

                } else if (data.LOB == "GL" && data.LoclPolReq == "FOS") {
                  // console.log(this.lobGLPolFOS)
                  data.lobGLPolFOS = true;
                  data.lobELPolY = false;
                  data.lobGLPolY = false;

                }
          }
      }
      if(index!=null){
        this.recordApi["Data"][index]=data;
        this.recordApi["Data"]=JSON.parse(JSON.stringify(this.recordApi["Data"]))
      }

      */
      var data
      for (let x in this.recordApi["Data"]) {
        let data= this.recordApi["Data"][x];
        
        if(data.Country == countryVal && data.type == typeVal){
            index=x;
            //console.log("country",this.country);
            //console.log("data",this.data);
            // const country = event.target.dataset.country
            data.show = data.show==undefined?true:(!data.show)
            // console.log("mytrue",data.show)
            // console.log("myfalse",!data.show);
            // console.log("myLOB",data.LOB);  
              
              if (data.show == true) {
                // console.log("you are inside if")
                data.icnNm = 'utility:down';
                data.show = true;
              } else {
                data.icnNm = 'utility:right';
                data.show = false;
              }

              
              // testing end
              if (data.type == "GL" && data.LoclPolReq == "Yes") {
                  console.log("@@GLYes", data.type+data.LoclPolReq );
                    data.lobGLPolY = true;
                    data.lobELPolY = false;
                    data.lobGLPolFOS = false;
                
              } else if (data.type == "EL" ){//&& data.LoclPolReq == "Yes") {
                // console.log(this.lobELPolY)
                data.lobELPolY = true;
                data.lobGLPolY = false;
                data.lobGLPolFOS = false;

              } else if (data.type == "GL" && data.LoclPolReq == "FOS") {
                // console.log(this.lobGLPolFOS)
                data.lobGLPolFOS = true;
                data.lobELPolY = false;
                data.lobGLPolY = false;

              }
              // else{
              //   data.lobDicPolDil = true;
              // }
            }
        }
        this.recordApi["Data"]=JSON.parse(JSON.stringify(this.recordApi["Data"]))
    // -------------------------------------------------------------------------------------
    // this.lobGLPolY = false;
    // this.lobELPolY = false;
    // this.lobGLPolFOS = false;

    // console.log("rect",this.recordApi)
    // console.log("this.recordApi0]['LOB']",this.recordApi["Data"][0]['LOB'])
    // for (let x in this.recordApi["Data"]) {

    //   console.log("xxxxxx", x);

    //   if (this.recordApi["Data"][x]['LOB'] == "GL" && this.recordApi["Data"][x]['LoclPolReq'] == "Y") {
    //     data.lobGLPolY = true;
    //     data.lobELPolY = false;
    //     data.lobGLPolFOS = false;

    //   } else if (this.recordApi["Data"][x]['LOB'] == "EL" && this.recordApi["Data"][x]['LoclPolReq'] == "Y") {
    //     // console.log(this.lobELPolY)
    //     data.lobELPolY = true;
    //     data.lobGLPolY = false;
    //     data.lobGLPolFOS = false;

    //   } else if (this.recordApi["Data"][x]['LOB'] == "GL" && this.recordApi["Data"][x]['LoclPolReq'] == "FOS") {
    //     // console.log(this.lobGLPolFOS)
    //     data.lobGLPolFOS = true;
    //     data.lobELPolY = false;
    //     data.lobGLPolY = false;

    //   }
    // }
  }

  handleFormInputChange(event) 
  {
    this.recordApi[event.target.name] = event.target.value;
    console.log(event.target.name + ' now is set to ' + event.target.value);

    let tempAllRecords = this.recordApi.map(
      innerList => innerList.map(
        innerItem => ({ ...innerItem, UWBId: event.target.value })
      )
    );
  }

  handleClick(event) {
    this.currentStep = event.target.value;
    this.firstStep = false;
    this.secoundStep = false;
    this.thirdStep = false;
    this.fourthStep = false;
    this.hidePrevBtn = false;
    if (this.currentStep == "step-1") {
      this.firstStep = true;
      this.hidePrevBtn = true;
    }
    else if (this.currentStep == "step-2") {
      this.secoundStep = true;
      this.hidePrevBtn = false;
    }
    else if (this.currentStep == "step-3") {
      this.thirdStep = true;
      this.hidePrevBtn = false;
    }
    else if(this.currentStep == "step-4"){
      this.fourthStep = true;
      this.hidePrevBtn = false;
    }
    this.Step = this.currentStep;
    console.debug(this.currentStep);
  }

  NextPageHandle(event) {
    //below code to handle if Total Premium is too high then block user to go next.
    // if(this.TotalPremiumHigh || this.GLMasterMin || this.MasterMinFVWC || this.MasterMinAuto || this.MasterMinBTA){
    //   return;
    // }
    if(this.recordApi.UWOverrideGrossOfCommTpFVWC < 0 || this.recordApi.UWOverrideGrossOfCommTpAuto < 0 || this.recordApi.UWOverrideGrossOfCommTpBTA < 0){
      return;
    }
    if(this.fourthStep == true && ((this.recordApi.MasterGlOtherExtWithComm.toFixed(0))<parseFloat(this.recordApi.GLMasterMin) || (this.recordApi.TotalLocalGlOtherExtWithComm.toFixed(0))<0 || (this.recordApi.UWOverrideGrossOfCommTpGl.toFixed(0))<0)){
      return;
    }
    if(this.secoundStep == true && ((this.recordApi.UWOverrideGrossOfCommTpAuto < 500 && this.recordApi.UWOverrideGrossOfCommTpAutoExclude==false )|| (this.recordApi.UWOverrideGrossOfCommTpFVWC < 1000 && this.recordApi.UWOverrideGrossOfCommTpFVWCExclude==false))){
      return;
    }
    if (this.Step == "step-3"){
      this.checkMinimumPremiumValidation();
      for(let i in this.recordApi.Data){
        if(this.recordApi.Data[i].hasMinmumError){
          const event = new ShowToastEvent({
              title: 'Error',
              message: 'Please Resolve Minimum Premium Error to proceed further.',
              variant: 'error',
              mode: 'dismissable'
          });
          this.dispatchEvent(event);
          return;
        }
      }
    }

    if(this.recordApi.MinPremExpThre != "" && this.recordApi.FOSMinPre != "" && this.recordApi.MstrBrkrComm !== "" && this.recordApi.MinimumEarnedPremium != "" && this.recordApi.DIC != "" && this.recordApi.MinPreforLarPre != "" && this.recordApi.SepELPolMinPre != "" && this.recordApi.LclBrkComm !== "" && this.recordApi.LocMinErnPrem != "" && this.recordApi.GLMasterMin !=""){
    console.log(this.Step)
    if (this.Step == "step-1") {
      // popover
      this.isOpen = true;
      
    } else if (this.Step == "step-2") {
      this.issecondOpen = true;
      //this.secoundStep = false;
      //this.thirdStep = true;
      //this.Step = "step-3";
      
    } else if (this.Step == "step-3"){
      this.isthirdOpen = true;
    }
    else {
      if( this.recordApi["Data"] != undefined){
        for(let x in this.recordApi["Data"]){
          // this.recordApi.Data[x].icnNm= 'utility:right';
          this.recordApi.Data[x].lobGLPolY = false;
          this.recordApi.Data[x].lobELPolY = false;
          this.recordApi.Data[x].lobGLPolFOS = false;
        }
      }
      // this.calculate();
      this.sendtoOmniscript();
      this.moveToNext=true;
      this.calculate();
     // this.omniNextStep();
    }
  }
  }

   // --------------- POPOVER -------------------
  //  @track isOpen = false;
 
   isCloseConfirmPopup() {
  
       this.isOpen = false;
       this.recordApi=JSON.parse(JSON.stringify(this.oldRecords));
       this.sendtoOmniscript();
       this.pricingAndBreakdownDetails();
       if(this.isReCalculated){
        this.submitChanges();
       }else{
        
        this.firstStep = false;
        this.secoundStep = true;
        
        this.Step = "step-2";
          this.isOpen = false;
       }
       
   }
   submitChanges() {
     
     this.firstStep = false;
     this.secoundStep = true;
     
     this.Step = "step-2";
       this.isOpen = false;
       this.saveData=true;
       this.recordApi.ReCalculateGL = true;
       this.calculate();
   }

   isCloseConfirmPopup2  (){
     this.issecondOpen = false;
     this.recordApi=JSON.parse(JSON.stringify(this.oldRecords));
     this.sendtoOmniscript();
     this.pricingAndBreakdownDetails();
     if(this.isReCalculated){
      this.submitChangesStep2();
     }else{
      
      this.firstStep = false;
    this.secoundStep = false;
    this.thirdStep=true;
    
    this.Step = "step-3";
      this.issecondOpen = false;
     }
    
     
  }
  submitChangesStep2() {
    this.firstStep = false;
    this.secoundStep = false;
    this.thirdStep=true;
    
    this.Step = "step-3";
      this.issecondOpen = false;
      this.saveData=true;
      this.recordApi.ReCalculateGL = true;
       this.calculate();
  }

  isCloseConfirmPopup3() {
    this.isthirdOpen = false;
    
    this.recordApi=JSON.parse(JSON.stringify(this.oldRecords));
    this.sendtoOmniscript();
    this.pricingAndBreakdownDetails();
    this.checkMinimumPremiumValidation();
    for(let i in this.recordApi.Data){
      if(this.recordApi.Data[i].hasMinmumError){
        const event = new ShowToastEvent({
            title: 'Error',
            message: 'Please Resolve Minimum Premium Error to proceed further.',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
        return;
      }
    }

    
    if(this.isReCalculated){
     this.submitChangesStep3();
    }else{
     
     this.firstStep = false;
   this.secoundStep = false;
   this.thirdStep=false;
   this.fourthStep = true;
   
   this.Step = "step-4";
     this.isthirdOpen = false;
    }
  }

  submitChangesStep3() {
    this.firstStep = false;
    this.secoundStep = false;
    this.thirdStep=false;
    this.fourthStep = true;
    
    this.Step = "step-4";
      this.isthirdOpen = false;
      this.saveData=true;
      this.recordApi.ReCalculateGL = true;
      this.calculate();
  }

 // --------------- POPOVER -------------------
 

  PreviousPage(event) {
    // To enable the next button if premium is to high
    // for(var i in this.premBreakDownOverview){
      // if(this.premBreakDownOverview[i].fieldUpdateKey=='MasterGlOtherExt'){
      //     if(this.premBreakDownOverview[i].ErrorWarningFlag=='Total premium, is too high'){
      //       this.TotalPremiumHigh = false;
      //     }
      //     if(this.premBreakDownOverview[i].ErrorWarningFlag=='GL Master Premium" is Below Minimum'){
      //       this.GLMasterMin = false;
      //     }
      // }
    //   if(this.premBreakDownOverview[i].fieldUpdateKey=='UWOverrideGrossOfCommTpFVWC'){
    //     if(this.premBreakDownOverview[i].ErrorWarningFlag=='"FVWC Master premium" is below Minimum'){
    //       this.MasterMinFVWC = false;
    //     }
    //   }
    //   if(this.premBreakDownOverview[i].fieldUpdateKey=='UWOverrideGrossOfCommTpAuto'){
    //     if(this.premBreakDownOverview[i].ErrorWarningFlag=='"Auto Master premium" is below Minimum'){
    //       this.MasterMinAuto = false;
    //     }
    //   }
    //   if(this.premBreakDownOverview[i].fieldUpdateKey=='UWOverrideGrossOfCommTpBTA'){
    //     if(this.premBreakDownOverview[i].ErrorWarningFlag=='"BTA Master premium" is below Minimum'){
    //       this.MasterMinBTA = false;
    //     }
    //   }
    // }
    if(this.recordApi.UWOverrideGrossOfCommTpFVWC < 0 || this.recordApi.UWOverrideGrossOfCommTpAuto < 0 || this.recordApi.UWOverrideGrossOfCommTpBTA < 0){
      return;
    }

    this.hidePrevBtn = false;
    console.log(this.Step)
    if (this.Step == "step-1") {
      this.hidePrevBtn = true;
      // this.omniPrevStep();
    } else if (this.Step == "step-2") {
      this.secoundStep = false;
      this.firstStep = true;
      this.Step = "step-1";
      this.hidePrevBtn = true;
    } else if (this.Step == "step-3") {
      this.thirdStep = false;
      this.secoundStep = true;
      this.Step = "step-2";
      this.hidePrevBtn = true;
    } else {
      this.fourthStep = false;
      this.thirdStep = true;
      this.Step = "step-3";
      this.hidePrevBtn = false;
    }
  }

  
  calculate() {
    if(this.recordApi.UWOverrideGrossOfCommTpFVWC < 0 || this.recordApi.UWOverrideGrossOfCommTpAuto < 0 || this.recordApi.UWOverrideGrossOfCommTpBTA < 0){
      return;
    }
    

    this.loaded = !this.loaded;
    this.isReCalculated=true;
    //var data=JSON.parse(JSON.stringify(this.recordApi));
    //data.pricing[0].Local=Number(this.DIC)+200;
    //this.recordApi=data;
    this.IPInput = {
      "Step1":this.recordApi
      //url: ''
      // input attribute Name: value
    };

    const options = {};
    const params = {
      input: JSON.stringify(this.IPInput),
      sClassName: 'vlocity_ins.IntegrationProcedureService',
      sMethodName: "FC_Calculate", // "integration_IPNAME"
      options: JSON.stringify(options)
    };
    this._actionUtil
    .executeAction(params, null, this, null, null)
    .then((response) => {

      this.loaded = !this.loaded;
       if(response.result.IPResult!=null && response.result.IPResult.RA_CalculateFC!=null){
        this.recordApi=JSON.parse(JSON.stringify(response.result.IPResult.RA_CalculateFC.Step1));
        for(var i in this.recordApi.Data){
          this.recordApi.Data[i].show=false;
          this.recordApi.Data[i].icnNm= 'utility:right';
          // this.recordApi.Data[i].lobGLPolY = false;
          // this.recordApi.Data[i].lobELPolY = false;
          // this.recordApi.Data[i].lobGLPolFOS = false;
        }
        this.pricingAndBreakdownDetails();
        this.checkMinimumPremiumValidation();
        if(this.Step == "step-4" && this.saveData){
          for(let i in this.recordApi.Data){
            if(this.recordApi.Data[i].hasMinmumError){
              const event = new ShowToastEvent({
                  title: 'Error',
                  message: 'Please Resolve Minimum Premium Error to proceed further.',
                  variant: 'error',
                  mode: 'dismissable'
              });
              this.dispatchEvent(event);
              this.Step = "step-3"
              this.fourthStep = false;
              this.thirdStep = true;
              return;
            }
          }
        }
        this.sendtoOmniscript(); // commented as we will not update data when user do calculation
       }

      
        console.log('Ipresponse:: ', response.result);//response.result.IPResult.response
       if(this.saveData){
         this.updatePremiumData();
       }
       if(this.moveToNext){
         this.moveToNext=false;
         this.omniNextStep();
       }
        this.saveData=false;

     
    })
    .catch((error) => {

    this.loaded = !this.loaded;

      console.error(error, "IpERROR");
    });

  }

  updatePremiumData() {

    this.loaded = !this.loaded;

    //var data=JSON.parse(JSON.stringify(this.recordApi));
    //data.pricing[0].Local=Number(this.DIC)+200;
    //this.recordApi=data;
    this.IPInput = {"ExcelResponse":{
      "Step1":JSON.parse(JSON.stringify(this.recordApi))
      //url: ''
      // input attribute Name: value
    },
  "ApplicationID":this.applicationId};

    const options = {};
    const params = {
      input: JSON.stringify(this.IPInput),
      sClassName: 'vlocity_ins.IntegrationProcedureService',
      sMethodName: "FC_SaveData", // "integration_IPNAME"
      options: JSON.stringify(options)
    };
    this._actionUtil
    .executeAction(params, null, this, null, null)
    .then((response) => {

      this.loaded = !this.loaded;
      
      this.sendtoOmniscript(); 
      this.oldRecords=JSON.parse(JSON.stringify(this.recordApi));
    
      this.isReCalculated=false;
      
        console.log('Ipresponse:: ', response.result);//response.result.IPResult.response
     
    })
    .catch((error) => {

    this.loaded = !this.loaded;

      console.error(error, "IpERROR");
    });

  }

  fetchValue( event ) {

    console.log('Value from Child LWC is' + event.detail );
    this.value1 = event.detail[0];
    this.value2 = event.detail[1];
    this.value3 = event.detail[2];
    this.value4 = event.detail[3];
    this.value5 = event.detail[4];
    this.value6 = event.detail[5];


  }
  // --------------- POPOVER -------------------
  // @track isOpen = false;
 
  // isCloseConfirmPopup() {
 
  //     this.isOpen = false;
  // }
  // submitChanges() {
  //   this.firstStep = false;
  //   this.secoundStep = true;
    
  //   this.Step = "step-2";
  //     this.isOpen = false;
  // }
// --------------- POPOVER -------------------

// Update Local Policies modal
  changeHandler(e){
    this.value = e.detail.value;
  }

  codesToUpdate = ["EA", "BTA", "Trip"];
  resetExposure(coverage) {
    for (let y in coverage.exposure) {
      coverage.exposure[y].ExposureAmount = '';
      coverage.exposure[y].ExposureBase = '';
    }
  }

  isExcludeEvent(event)
  {
   
    this.recordIndex = parseInt(event.target.dataset.index);
    let key = (event.target.dataset.key);
    this.recordApi= JSON.parse(JSON.stringify(this.recordApi));
  this.recordApi[key]=0
  this.recordApi[key+'Exclude'] = event.target.checked;

  for(var i in this.premBreakDown){
    if(this.premBreakDown[i].fieldUpdateKey==key){
      this.premBreakDown[i].UWSelectedGrossActualIntial=0;
      this.premBreakDown[i].GrossActualIntialEditField=!event.target.checked; 
      if(this.premBreakDown[i].Coverage=='BTA'){
        this.premBreakDown[i].Exposure=0;
        this.recordApi.Exposure=0;
        
        // this.recordApi=JSON.parse(JSON.stringify( this.recordApi));
        // for (let x in this.recordApi.coverages) {
        //   if (this.codesToUpdate.includes(this.recordApi.coverages[x].LOBCode)) {
        //     this.resetExposure(this.recordApi.coverages[x]);
        //   }
        // }
        //this.recordApi = JSON.parse(JSON.stringify(this.recordApi));

        const codesToUpdate = ["EA", "BTA", "Trip"];
        this.recordApi.coverages.forEach(coverage => {
          if (codesToUpdate.includes(coverage.LOBCode)) {
            // if(coverage.exposure != undefined){
              coverage.exposure.forEach(exposure => {
                exposure.ExposureAmount = '';
                exposure.ExposureBase = '';
              });
            // }
          }
        });
        this.recordApi = JSON.parse(JSON.stringify(this.recordApi));
    }
  }

    

  }
  this.premBreakDown=JSON.parse(JSON.stringify(this.premBreakDown));
  this.sendtoOmniscript();
    
  }
  showModal() {
    this.openModal = true;
    this.updateBtnClick = true;
    this.addExtSection = false;
  }
  closeModal() {
    this.openModal = false;
  }

  showALC(event){
    console.log("In showAlc");
    console.log("option befor: " +this.visibleALC);
    console.log("option after: " +this.visibleALC);
    //this.value = event.target.checked;        
    console.log("Todo: " + event.target.value);
    if(this.value == 'option1'){
        console.log("option inside: " +this.visibleALC);
        this.visibleALC = true;
        this.openModal = false;
        this.visibleUp = true;
        this.selectedOptions = 'firstOption';

    }else{
        this.visibleUp = true;
        this.openModal = false;
        this.visibleALC = false;

        this.selectedOptions = 'secondOption';
        
        
    }
    
  }

  get options() {
    return [
        { label: 'Add Local Extension', value: 'option1'},
        { label: 'Update Min & Actual premium', value: 'option2' }
    ];
  }

  closeChild(event){
    this.visibleALC = false;
    this.visibleUp = false;
  }

  showupdatemodal(event){
    this.localExtensionData=event.detail;
    this.visibleALC = false;
    this.visibleUp = true;
    console.log('TTTTT');
  }

  sendNewExtensionData(event){
    console.log('@@event::'+event);
    console.log('@@event.detail::'+event.detail);
    this.newLocalExtensionData=event.detail;
    console.log('@@this.newLocalExtensionData::'+this.newLocalExtensionData);
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

onLobGLPolYChange(event){
  if(event.detail!=null){
    console.log(event.detail.recordData);
    this.recordApi.Data[event.detail.recordIndex]=event.detail.recordData;
    if(this.recordApi.Data[event.detail.recordIndex].type=='GL'){
      this.recordApi.Data[event.detail.recordIndex].displayPrem=(this.recordApi.Data[event.detail.recordIndex].UWOverrideGLLocalPrem==undefined || this.recordApi.Data[event.detail.recordIndex].UWOverrideGLLocalPrem=="")?this.recordApi.Data[event.detail.recordIndex].ActualGLLocalPrem:this.recordApi.Data[event.detail.recordIndex].UWOverrideGLLocalPrem;
    }
    if(this.recordApi.Data[event.detail.recordIndex].type=='EL'){
      this.recordApi.Data[event.detail.recordIndex].displayPrem=(this.recordApi.Data[event.detail.recordIndex].LocalELActualPrem==undefined || this.recordApi.Data[event.detail.recordIndex].LocalELActualPrem=="")?this.recordApi.Data[event.detail.recordIndex].LocalELTechnicalGrossOfComm:this.recordApi.Data[event.detail.recordIndex].LocalELActualPrem;
    }
    this.recordApi=JSON.parse(JSON.stringify(this.recordApi));
    this.checkMinimumPremiumValidation();
    this.sendtoOmniscript();
  }
}

onLobGLPolFOSChange(event){
  console.log(event.detail);
  if(event.detail!=null){
    console.log(event.detail.recordData);
    this.recordApi.Data[event.detail.recordIndex]=event.detail.recordData;
    if(this.recordApi.Data[event.detail.recordIndex].type=='GL'){
      this.recordApi.Data[event.detail.recordIndex].displayPrem=(this.recordApi.Data[event.detail.recordIndex].UWOverrideGLLocalPrem==undefined || this.recordApi.Data[event.detail.recordIndex].UWOverrideGLLocalPrem=="")?this.recordApi.Data[event.detail.recordIndex].ActualGLLocalPrem:this.recordApi.Data[event.detail.recordIndex].UWOverrideGLLocalPrem;
    }
    if(this.recordApi.Data[event.detail.recordIndex].type=='EL'){
      this.recordApi.Data[event.detail.recordIndex].displayPrem=(this.recordApi.Data[event.detail.recordIndex].LocalELActualPrem==undefined || this.recordApi.Data[event.detail.recordIndex].LocalELActualPrem=="")?this.recordApi.Data[event.detail.recordIndex].LocalELTechnicalGrossOfComm:this.recordApi.Data[event.detail.recordIndex].LocalELActualPrem;
    }
    this.recordApi=JSON.parse(JSON.stringify(this.recordApi));
    this.checkMinimumPremiumValidation();
    this.sendtoOmniscript();
  }
}
onLobELPolYChange(event){
  console.log(event.detail);
  if(event.detail!=null){
    console.log(event.detail.recordData);
    this.recordApi.Data[event.detail.recordIndex]=event.detail.recordData;
    if(this.recordApi.Data[event.detail.recordIndex].type=='GL'){
      this.recordApi.Data[event.detail.recordIndex].displayPrem=(this.recordApi.Data[event.detail.recordIndex].UWOverrideGLLocalPrem==undefined || this.recordApi.Data[event.detail.recordIndex].UWOverrideGLLocalPrem=="")?this.recordApi.Data[event.detail.recordIndex].ActualGLLocalPrem:this.recordApi.Data[event.detail.recordIndex].UWOverrideGLLocalPrem;
    
    }
    if(this.recordApi.Data[event.detail.recordIndex].type=='EL'){
      this.recordApi.Data[event.detail.recordIndex].displayPrem=(this.recordApi.Data[event.detail.recordIndex].LocalELActualPrem==undefined || this.recordApi.Data[event.detail.recordIndex].LocalELActualPrem=="")?this.recordApi.Data[event.detail.recordIndex].LocalELTechnicalGrossOfComm:this.recordApi.Data[event.detail.recordIndex].LocalELActualPrem;
    }
    if(event.detail.recordIndex!=0){
      if(this.recordApi.Data[event.detail.recordIndex-1].Country==this.recordApi.Data[event.detail.recordIndex].Country){
        this.recordApi.Data[event.detail.recordIndex-1].LocalELActualPrem=this.recordApi.Data[event.detail.recordIndex].LocalELActualPrem;
      }
    }
    this.recordApi=JSON.parse(JSON.stringify(this.recordApi));
    this.checkMinimumPremiumValidation();
    this.sendtoOmniscript();
  }
}

handleAddExt(event){
  if(event.detail!=null){
    console.log(event.detail.recordData);
    this.recordApi.Data=JSON.parse(JSON.stringify(event.detail.recordData));
    for(var i=0; i<this.recordApi.Data.length;i++){
        if(this.recordApi.Data[i].type=='EL' && i>0){
          if (this.recordApi.Data[i - 1].Country == this.recordApi.Data[i].Country) {
              this.recordApi.Data[i - 1].LocalELActualPrem = this.recordApi.Data[i].LocalELActualPrem;
          }
            
        }
        if(this.recordApi.Data[i].type=='GL'){
          this.recordApi.Data[i].displayPrem=(this.recordApi.Data[i].UWOverrideGLLocalPrem==undefined || this.recordApi.Data[i].UWOverrideGLLocalPrem=="")?this.recordApi.Data[i].ActualGLLocalPrem:this.recordApi.Data[i].UWOverrideGLLocalPrem;
        }
        if(this.recordApi.Data[i].type=='EL'){
          this.recordApi.Data[i].displayPrem=(this.recordApi.Data[i].LocalELActualPrem==undefined || this.recordApi.Data[i].LocalELActualPrem=="")?this.recordApi.Data[i].LocalELTechnicalGrossOfComm:this.recordApi.Data[i].LocalELActualPrem;
        }
    }
    this.recordApi.Data=JSON.parse(JSON.stringify(this.recordApi.Data));
    
    this.recordApi=JSON.parse(JSON.stringify(this.recordApi));
    this.sendtoOmniscript();
  }
}

handleExtEditClick(event){
  this.openModal = true;
  this.updateBtnClick = false;
  this.extensionRecord =  event.detail.extensionRecord;
  this.addExtSection= true;
}


handleUpdateCountryData(event){
  console.log('@@handleUpdateCountryData::event.detail:: ',event.detail);
  this.recordApi.Data = JSON.parse(JSON.stringify(event.detail));
  this.recordApi=JSON.parse(JSON.stringify(this.recordApi));
  
  this.sendtoOmniscript();
}
  // n2g logo
  // logoN2gUrl = logoN2g+'/salesforceN2gLogo/n2gLogo.webp';
  // logoN2gUrl="/sfc/dist/version/download/?oid=00D7i000000FgMc&ids=0687i0000013T4xAAE&d=/a/7i000000KzGA/C60w2waDIq3PR7HvdLWj.xCujAwVbdJl5mraeQXCDFw&operationContext=DELIVERY&viewId=05H7i000000KyrtEAC&dpt=";
 
  handleCountrydatawithExt(event){
    console.log('@@handlecountryDetail', event.detail);
    this.countrywithExt = JSON.parse(JSON.stringify(event.detail));
    
    // this.recordApi=JSON.parse(JSON.stringify(this.recordApi));
    // this.sendtoOmniscript();
  }

  checkMinimumPremiumValidation(){
      for(let i in this.recordApi.Data){
        this.recordApi.Data[i].hasMinmumError=false;
        if(this.recordApi.Data[i].type == "GL" ){
          this.recordApi.Data[i].displayAllocatedActualGLLocalPrem=(this.recordApi.Data[i].AllocatedActualGLLocalPrem!=undefined && this.recordApi.Data[i].AllocatedActualGLLocalPrem!="")?this.recordApi.Data[i].AllocatedActualGLLocalPrem.toFixed(0):null
          if(this.recordApi.Data[i]["UWOverrideGLLocalPrem"]!=undefined 
              && this.recordApi.Data[i]["UWOverrideGLLocalPrem"]!="") {
              if(parseFloat(this.recordApi.Data[i]["UWOverrideGLLocalPrem"])<this.recordApi.Data[i]["MinimumPremiumRequired"]){
                this.recordApi.Data[i].hasMinmumError=true;
              }
          }else if (parseFloat(this.recordApi.Data[i]["displayAllocatedActualGLLocalPrem"])<this.recordApi.Data[i]["MinimumPremiumRequired"]){
                this.recordApi.Data[i].hasMinmumError=true;
          }
        }
        
        if(this.recordApi.Data[i].type == "EL" ){
          this.recordApi.Data[i].displayLocalELTechnicalpremium=(this.recordApi.Data[i].LocalELTechnicalGrossOfComm!=undefined && this.recordApi.Data[i].LocalELTechnicalGrossOfComm!="")?this.recordApi.Data[i].LocalELTechnicalGrossOfComm.toFixed(0):null

          if(this.recordApi.Data[i]["LocalELActualPrem"]!=undefined 
              && this.recordApi.Data[i]["LocalELActualPrem"]!=""){ 
              if(parseFloat(this.recordApi.Data[i]["LocalELActualPrem"])<this.recordApi.SepELPolMinPre){
                this.recordApi.Data[i].hasMinmumError=true;
              }
          }else if (parseFloat(this.recordApi.Data[i]["displayLocalELTechnicalpremium"])<this.recordApi.SepELPolMinPre){
              this.recordApi.Data[i].hasMinmumError=true;
          }
        }
      }
  }
  
  handleCountryWithExt(event){
    this.selectedCountryWithExt = JSON.parse(JSON.stringify(event.detail.selectedInsertCountry));
    for(let i in this.countrywithExt){
      for(let j in this.recordApi.Data){
        if(this.recordApi.Data[j].uniqueKey == this.countrywithExt[i].uniqueKey){
          for(let x in this.selectedCountryWithExt){
            if(this.selectedCountryWithExt[x].country == this.recordApi.Data[j].Country){
              this.countrywithExt[i].ExternalExtension = this.recordApi.ApplicationID+this.recordApi.Data[j].uniqueKey;
              this.recordApi.Data[j] = this.countrywithExt[i];
              
            }
          }
          
        }
      }
    }
    // console.log(selectedRec)
    // for(let x in selectedRec){
    //   for(let y in this.recordApi.Data){
    //     if(this.recordApi.Data[y].Country == selectedRec[x].country){
    //       this.recordApi=JSON.parse(JSON.stringify(this.recordApi));
    //       this.sendtoOmniscript();
    //     }else{
    //       delete this.recordApi.Data[y].ExtensionTypeRecord;
    //       delete this.recordApi.Data[y].ExternalExtension;
          this.recordApi=JSON.parse(JSON.stringify(this.recordApi));
          this.sendtoOmniscript();
    //     }
    //   }
    // }

  }


}