import { LightningElement, track, wire, api} from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";

export default class FcExposurebasis extends OmniscriptBaseMixin(LightningElement){




    @track topCarriers=[];
    @track topCarrierDeleteEnable=false;
   
    @api columns=[{"Label":"Exposure base","FieldName":"ExposureBase"},{"Label":"Exposure Amount2","FieldName":"ExposureAmount2"}];
    @api coverage;
    @api isReadOnly=false;
    @track rows;
    @track rowsDeleteEnable=false;
   

    connectedCallback(){
        
        if(this.coverage!=undefined && this.coverage.exposure!=undefined){
           // this.rows=[{"coverageID":this.coverage.coverageID}];
            this.rows=JSON.parse(JSON.stringify(this.coverage.exposure));
         
        }
         if(this.rows==undefined){ 
            var defaultRow={"coverageID":this.coverage.coverageID};
            for(var i in this.columns){
                if(this.columns[i].defaultValue!=undefined){
                    defaultRow[this.columns[i].FieldName]=this.columns[i].defaultValue;
                }
            }
            this.rows=[defaultRow];
          }
        this.rowsDeleteEnable=this.rows.length>1;
    }
    addRows(event){
      
        this.rows.push({"coverageID":this.coverage.coverageID});
        this.rowsDeleteEnable=this.rows.length>1;
        this.updateData();
    }
    deleteRows(event){
        console.log('@@event',event.target.dataset.index)
        var indx=parseInt(event.target.dataset.index);
     
        var data=JSON.parse(JSON.stringify(this.rows));
        data.splice(indx, 1);
        this.rows=JSON.parse(JSON.stringify(data));
        this.rowsDeleteEnable=this.rows.length>1;
        this.updateData();

    }
    handleDataChange(event){

        console.log('@@event',event.detail.currentRow)
        var indx=parseInt(event.detail.currentRowIndex);
        var data=JSON.parse(JSON.stringify(this.rows));
        data[indx][event.detail.fieldName]= event.detail.value;
        //data[indx]={...data[indx], ...event.detail.currentRow};
        this.rows=data;
        this.updateData();
    }
    handleRecordChange(event){
        console.log('@@event',event.target.dataset.index)
        var indx=parseInt(event.target.dataset.index);
        var data=JSON.parse(JSON.stringify(this.rows));
        data[indx][event.target.name]= event.target.value;
        this.rows=data;
        this.updateData();
    }
    updateData(){
        
        const changeEvent = new CustomEvent('changedataupdate',
            {
                'detail': {exposureData:this.rows}
            }
        );
        this.dispatchEvent(changeEvent);
    }
}