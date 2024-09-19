import { LightningElement, track, api, wire } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";

export default class SelectReqForm extends OmniscriptBaseMixin(LightningElement) {

     @api getCurrentLob;
     @api currentCoverageId
    //@track recordApi = {};
    // sendtoOmniscript() {
    //     var Final = {}
    //     Final['ExcelResponse'] = {"Step1":this.recordApi};
    //     this.omniApplyCallResp(Final);
    // }

    @api selectedIds;
    @api noOfForms;
    @track FromNameAndNo = [];
    //---------------------------
    // @track selectNo = 1;


    //--
    // value = 1;
    // qty = 1;
    // qtyval = '1';//
    
    // setIncrementCounter(event){
    //     const INC = event.target.dataset.inc
    //     const data = this.FromNameAndNo.find((item)=>item.FromId === INC);
    //     console.log("@@-",data)
    //     data.value = data.value + 1;
        // console.log("INC",INC)
        // this.qty = this.qty + 1;
        // let quantity = this.qty.toString();
        // this.qtyval = quantity

        // const selectNo = event.target.dataset.inc;
        // for(var i=0;i<this.FromNameAndNo.length;i++){
        //     if(this.FromNameAndNo[i].FromId==selectNo){
        //         this.FromNameAndNo[i].NoOfCount = 5;
        //         console.log('@inc', this.FromNameAndNo[i])
        //     }
        // }

    //     for(var i=0;i<this.FromNameAndNo.length;i++){
    //         if(this.FromNameAndNo[i].FromId==selectNo){
    //             this.FromNameAndNo[i].value = data.value;
    //             console.log('@inc', this.FromNameAndNo[i])
    //         }
    //     }
    // }
    // setDecrementCounter(event){
    //     const DEC = event.target.dataset.dec
    //     const data = this.FromNameAndNo.find((item)=>item.FromId === DEC);
    //     if(this.value > 0){
    //         this.value = this.value - 1;
    //     }
        
        // if(this.qty == 1)   this.qty = 1;
        // else    this.qty = this.qty - 1;
        // let quantity = data.qty.toString();
        // this.qtyval = quantity 
    // }
    // qty =1;
    // @track plchldQty = '1';
    // setDecrementCounter(event){
    //     const DEC = event.target.dataset.dec
    //     const data = this.FromNameAndNo.find((item)=>item.FromId === DEC);
    //     if(data.qty == 1){
    //         data.qty = 1;
    //     }   
    //     else{
    //         data.qty = data.qty - 1;
    //     }    
    //     let quantity = data.qty.toString();
    //     data.plchldQty = quantity 
    // }

    // setIncrementCounter(event){
    //     const INC = event.target.dataset.inc
    //     const data = this.FromNameAndNo.find((item)=>item.FromId === INC);
    //     data.qty = this.qty + 1;
    //     console.log("@data", data.qty)
    //     let quantity = data.qty.toString();
    //     data.qtyval = quantity
    //     console.log("@",data.qtyval)
    // }

    quantityCtrl(event){
        console.log('@inc', event.detail)
        const selectNo = event.target.dataset.counter;
        for(var i=0;i<this.FromNameAndNo.length;i++){
            if(this.FromNameAndNo[i].FromId==selectNo){
                this.FromNameAndNo[i].NoOfCount = event.detail;
                console.log('@inc', this.FromNameAndNo[i])
            }
        }

        var selectedForms=[];
        for(var i=0;i<this.FromNameAndNo.length;i++){
            if( this.FromNameAndNo[i].selected){
                this.selectedCounter = this.FromNameAndNo[i].NoOfCount; //
                for(var j=0; j<this.FromNameAndNo[i].NoOfCount; j++){ //loop for insert no. of data acc to counter
                    selectedForms.push(this.FromNameAndNo[i]);
                }
            }
        }
        
        //-------------------------------------23-08-2022---------------------
        var selectedEvent = new CustomEvent("selectedformdataadd", {
            detail: {
                "FormData" :JSON.stringify(selectedForms)
            }
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        
    }


    connectedCallback(){
        console.log('@getCurrentLob',this.getCurrentLob);
        const params = {
            input: {'CurrentLob' : this.getCurrentLob},
            sClassName: 'CTRL_AddFormData',
            sMethodName: 'getFormsDet',
            options: '{}'
        };
        this.omniRemoteCall(params, true).then((response) => {
            console.log("respone", JSON.stringify((response)))
            var FromNameAndNon = JSON.parse(response.result.Success);
            var FormWiseDocMap = JSON.parse(response.result.DocumentLinks);
            var selectedRec=[];
            var selectedData=this.selectedIds==undefined?[]:JSON.parse(this.selectedIds);
            var formWiseCount={};
            for(var i=0; i<selectedData.length;i++){
                selectedRec.push(selectedData[i].FromId)
                formWiseCount[selectedData[i].FromId]=selectedData[i].NoOfCount;
            }

            //var noOfcnt = this.noOfForms==undefined?[]:JSON.parse(this.noOfForms);
            for(let i = 0; i < FromNameAndNon.length; i++){
                var tempObj = {
                    "coverageID": this.currentCoverageId,
                    "FromName" : FromNameAndNon[i].Form_Name__c,
                    "FromNo" : FromNameAndNon[i].Form_Name_ID__c,
                    "FromId" : FromNameAndNon[i].Id,
                    "DocumentLink" : FormWiseDocMap[FromNameAndNon[i].Id],
                    "selected":selectedRec.includes(FromNameAndNon[i].Id),
                    "NoOfCount": formWiseCount[FromNameAndNon[i].Id]==undefined?1:formWiseCount[FromNameAndNon[i].Id],
                    "FormType": FromNameAndNon[i].Form_Type__c,
                    "LOBCode": FromNameAndNon[i].LOB_CODE__c,
                    "Number": FromNameAndNon[i].Number__c,
                    "Order": FromNameAndNon[i].Order__c,
                    "Symbol": FromNameAndNon[i].Symbol__c,
                    "Edition": FromNameAndNon[i].Edition__c,
                    "Mandatory": FromNameAndNon[i].Mandatory__c,
                    "Default": FromNameAndNon[i].Default__c,
      
                }
                console.log("filter::"+FromNameAndNon[i].Id)
                this.FromNameAndNo.push(tempObj)
            }

            var selectedForms=[];
        for(var i=0;i<this.FromNameAndNo.length;i++){
            
            if( this.FromNameAndNo[i].selected){
                console.log("count",this.FromNameAndNo[i].NoOfCount)
                this.selectedCounter = this.FromNameAndNo[i].NoOfCount; //
                for(var j=0; j<this.FromNameAndNo[i].NoOfCount; j++){ //loop for insert no. of data acc to counter
                    selectedForms.push(this.FromNameAndNo[i]);
                }
            }
        }
        
        //-------------------------------------23-08-2022---------------------
        var selectedEvent = new CustomEvent("selectedformdataadd", {
            detail: {
                "FormData" :JSON.stringify(selectedForms)
            }
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
            
            console.log('response:: ', response);
        
        }).catch((error) => {
            console.log('error:: ', error);
            this.error = error;
         });
    }

  
    selectedCounter = 1; //
    tglVal(event) {
        const formName = event.target.name;
        const valno = event.target.checked;
        const selectedId = event.target.dataset.id;
        console.log("select", selectedId)
        var selectedForms=[];
        for(var i=0;i<this.FromNameAndNo.length;i++){
            if(this.FromNameAndNo[i].FromId==selectedId){
                this.FromNameAndNo[i].selected=valno;
            }
            if( this.FromNameAndNo[i].selected){
                console.log("count",this.FromNameAndNo[i].NoOfCount)
                this.selectedCounter = this.FromNameAndNo[i].NoOfCount; //
                for(var j=0; j<this.FromNameAndNo[i].NoOfCount; j++){ //loop for insert no. of data acc to counter
                    selectedForms.push(this.FromNameAndNo[i]);
                }
            }
        }
        
        //-------------------------------------23-08-2022---------------------
        var selectedEvent = new CustomEvent("selectedformdataadd", {
            detail: {
                "FormData" :JSON.stringify(selectedForms)
            }
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

        // this.recordApi=JSON.parse(JSON.stringify( this.recordApi));
        // this.recordApi["selectedFormsByUW"]=JSON.parse(JSON.stringify(selectedForms));
        // console.log("@rec@",JSON.parse(JSON.stringify(this.recordApi)));
        // this.sendtoOmniscript();

    }
    
}