import { LightningElement,api, track} from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";
import {NavigationMixin} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class AddForm extends  OmniscriptBaseMixin(NavigationMixin(LightningElement)) {

    @api getCurrentLob;
    @api allCoverages;
    @api commonForms;
    @api isReadOnly=false;
    
    @api excelResponse;
    @api currentCoverageId;
    @track recordApi = {};
    sendtoOmniscript() {
        var Final = {}
        Final['ExcelResponse'] = {"Step1":this.recordApi};
        this.omniApplyCallResp(Final);
    }
   
    @track selectedData = [];
    @track slectedNoData = [];
    @track slectedNoForms = [];
    @track FromNameAndNo = [];
    
    @track isCommon=false;

    // @track FromName = "Voluntary Workers' Compensation and Employers Liability Coverages Part Supplemental Declarations";
    // @track FromNo = "WC SD 4100C-N2G 02 20";

    @track dlt = true;

    
    @api chngVal(){
        console.log("this method has call");
        this.cov1 = "heollo";
    }
    handleShowModal(){
      
        const modal = this.template.querySelector("c-modal-popup");
        // console.log("modalval",modal)
        modal.show(JSON.stringify(this.selectedFormData));
        modal.selectCoverageForm(); 
        // this.title = 'btn clicked';

        //added on 14-oct-2022 for form whereclause
        this.recordApi=JSON.parse(JSON.stringify( this.recordApi));
        this.recordApi["currentLob"]=this.getCurrentLob;
        console.log("curruntLob",this.getCurrentLob);
        this.sendtoOmniscript();
    }

    EditClick(){
       
        const modal = this.template.querySelector("c-modal-popup");
        modal.show(JSON.stringify(this.selectedFormData));
        modal.selectCoverageForm();
        // console.log("avail",this.FromNameAndNo)
       
    }

    DltClick(event){
         console.log("@mydata", this.selectedFormData)
        const dtlid = event.target.dataset.dtlid
        // const data = this.selectedFormData.find((item) => item.FromId == dtlid);
        console.log("@Id",dtlid)
        for(let i=0; i<this.selectedFormData.length; i++){
            var deletedData = this.selectedFormData[i].FromId;
            if(deletedData == dtlid){
                // this.selectedFormData.filter(item => item !== deletedData);
               this.selectedFormData.splice(i, 1);
            // this.selectedFormData = this.selectedFormData.filter(item => item !== deletedData);

               break;
            }
        }
         // this.updateCurrentCoverageInForms();
         console.log('@currentselectedForm::',JSON.parse(JSON.stringify(this.selectedFormData)));
        //  if(this.selectedFormData.length > 0){
             this.updatehandler(JSON.parse(JSON.stringify(this.selectedFormData)));
        //  }
    }
    
     //--------------------23-08-2022
     @track selectedFormData = [];
     hanldeFormDataChange(event){
        this.selectedFormData = JSON.parse(event.detail.FormData);
        console.log("@@@test",this.selectedFormData)

        this.recordApi=JSON.parse(JSON.stringify( this.recordApi));
        this.recordApi["selectedFormsByUW"]=JSON.parse(JSON.stringify(this.selectedFormData));
        if(this.allCoverages!=undefined){
            this.recordApi['coverages']=JSON.parse(JSON.stringify(this.allCoverages));
        }
        
        console.log("@excelResponse:::",this.excelResponse);
        console.log("@rec@",JSON.parse(JSON.stringify(this.recordApi)));
        this.sendtoOmniscript();

         // this.updateCurrentCoverageInForms();
         console.log('@currentselectedForm::',JSON.parse(JSON.stringify(this.selectedFormData)));
         if(this.selectedFormData.length > 0){
             this.updatehandler(JSON.parse(JSON.stringify(this.selectedFormData)));
         }
     } 
     connectedCallback(){
         if(this.getCurrentLob=='Common'){
             this.isCommon=true;
         }
            if(this.allCoverages!=undefined ){
                for(var i in this.allCoverages){
                    if(this.allCoverages[i].LOBCode==this.getCurrentLob && this.allCoverages[i].forms!=undefined){
                        var covForms=JSON.parse(JSON.stringify(this.allCoverages[i].forms));
                        /*var selectedForms=[];
                        var formId=[];
                        for(var k=0;k<covForms.length;k++){
                            if(formId.includes(covForms[k].FromId)){
                                continue;
                            }
                            for(var j=0; j<covForms[k].NoOfCount; j++){ //loop for insert no. of data acc to counter
                                selectedForms.push(covForms[k]);
                            }
                            formId.push(covForms[k].FromId);
                        }*/
                        this.selectedFormData=JSON.parse(JSON.stringify(this.allCoverages[i].forms));//selectedForms;//JSON.parse(JSON.stringify(this.allCoverages[i].forms));

                    }
                }
                this.recordApi=JSON.parse(JSON.stringify( this.recordApi));
                this.recordApi['coverages']=JSON.parse(JSON.stringify(this.allCoverages));
            }
            if(this.commonForms!=undefined ){
                var covForms=JSON.parse(JSON.stringify(this.commonForms));
                /*var selectedForms=[];
                var formId=[];
                for(var k=0;k<covForms.length;k++){
                    if(formId.includes(covForms[k].FromId)){
                        continue;
                    }
                    for(var j=0; j<covForms[k].NoOfCount; j++){ //loop for insert no. of data acc to counter
                        selectedForms.push(covForms[k]);
                    }
                    formId.push(covForms[k].FromId);
                }*/
                this.selectedFormData=covForms;//selectedForms;//JSON.parse(JSON.stringify(this.allCoverages[i].forms));]
            }
        }
    renderedCallback(){
       
    }

    updatehandler(value){    
        console.log("check",value);
         //15-10-2022
          const changeEvent = new CustomEvent('changedataupdate',
          {
              'detail': {currentLob: this.getCurrentLob, recordData: this.recordApi.coverages, formData : value}
          }
      );
      this.dispatchEvent(changeEvent);
    }

    // updateCurrentCoverageInForms(){
    //     for(let i in this.selectedFormData){
    //         this.selectedFormData[i]["CoverageID"]= this.currentCoverageId; 
    //     }
    // }

    previewHandler(event){
        console.log(event.target.dataset.id)
        if(event.target.dataset.id != undefined){
            this[NavigationMixin.Navigate]({ 
                type:'standard__namedPage',
                attributes:{ 
                    pageName:'filePreview'
                },
                state:{ 
                    selectedRecordId: event.target.dataset.id
                }
            })
        }else{
            this.showErrorToast();
        }
       // console.log("fileContentIds", JSON.parse(this.formsIds));


    }
    showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'File Not Found',
            message: '',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    
}