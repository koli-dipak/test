import { LightningElement,track,api } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";
import { OmniscriptActionCommonUtil } from "vlocity_ins/omniscriptActionUtils";
import pubsub from "vlocity_ins/pubsub";

export default class HelpTxt extends OmniscriptBaseMixin(LightningElement)  {
    @track openModal = false;
    @track showClone=false;
    @track applicationId;
    @track recordApi;
    @track _actionUtil;

    @track recordData;
    @track loaded=false;

    @track enableSaveForLater=false;
    @api
    get jsonData() {
        return this.recordData;
    }

    set jsonData(value) {
       this.recordData = value;
       if(this.recordData!=undefined && this.recordData.ApplicationID!=undefined && this.showClone==false && this.recordData.ExcelResponse!=undefined){
            this.showClone=true;
           
       }
       if(this.recordData!=undefined && this.recordData.ApplicationID!=undefined && this.recordData.ExcelResponse!=undefined){
            this.enableSaveForLater=true;
            if(this.recordData.ExcelResponse.Step1!=undefined && this.recordData.ExcelResponse.Step1.currentActiveStep==4){
                this.enableSaveForLater=false;
            }
           
       }
     //  console.log('helpText render',JSON.parse(JSON.stringify(this.recordData)))
    }
    // @track cloneLwcCall = false;
    // @track openModal = false;
    // // cloneHandle(){
    // //     this.cloneHandle = true;
    // // }
    // showModal() {
    //     this.openModal = true;
    //   }
     
    //   handleEvent(event){
    //     this.openModal = event.detail.CancelPage;
    //   }
  
    connectedCallback(){

        this._actionUtil = new OmniscriptActionCommonUtil();
    }

    saveAsDraftHandler(){
        // If Step 1 then do save from component it self
        if(this.recordData.ExcelResponse.Step1.currentActiveStep==1){
            this.calculate();
        }else{
            this.saveData();
        }
       
        //console.log('Step',this.recordData.ExcelResponse.Step1.currentActiveStep)
    }

  
    // cloneHandle(){
    //     this.cloneHandle = true;
    // }
    showModal() {
        this.openModal = true;
        this.recordApi=JSON.parse(JSON.stringify(this.recordData.ExcelResponse.Step1));
        this.applicationId=this.recordData.ApplicationID;
    }
    
    handleEvent(event){
    this.openModal = event.detail.CancelPage;
    }

    
   
    saveData(data) {
        
        this.loaded = !this.loaded;
        var inputData= {"ExcelResponse":JSON.parse(JSON.stringify(this.recordData.ExcelResponse))};
        inputData.ApplicationID=this.recordData.ApplicationID;
        this.IPInput =inputData;
        if(data!=undefined){
            this.IPInput.ExcelResponse.Step1 = data; 
        } 
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
            if(this.recordData.ExcelResponse.Step1.currentActiveStep==1){
                
                pubsub.fire("HelpTextChannel","Action",{actionName :"saveAsDraft",recordApi :JSON.stringify(this.IPInput.ExcelResponse.Step1)})
            }
            
        })
        .catch((error) => {
    
            this.loaded = !this.loaded;
    
          console.error(error, "IpERROR");
        });
    
      }


  calculate() {

    this.loaded = !this.loaded;
    this.isReCalculated=true;
   
    this.IPInput = {
      "Step1":JSON.parse(JSON.stringify(this.recordData.ExcelResponse.Step1))
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
        }
        //this.recordData.ExcelResponse.Step1=this.recordApi;
      }

      console.log('Ipresponse:: ', response.result);//response.result.IPResult.response
      this.saveData(this.recordApi);
     
    })
    .catch((error) => {

    this.loaded = !this.loaded;

      console.error(error, "IpERROR");
    });

  }

}