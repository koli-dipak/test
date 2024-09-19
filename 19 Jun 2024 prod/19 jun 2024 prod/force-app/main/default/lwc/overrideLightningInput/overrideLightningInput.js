import { LightningElement, track, wire, api} from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";

export default class overrideLightningInput extends OmniscriptBaseMixin(LightningElement){

    @api isReadOnly;
    @api row;
    @api rowIndex;
    @api fieldName;
    @api label;
    @api columnReadOnly;
    @track data={};

    @track value;
    @track readOnly=false;
    handleRecordChange(event){
        this.data[this.fieldName]= event.target.value;
        this.value=event.target.value;
        this.updateData();
    }

    connectedCallback(){
       this.readOnly=this.isReadOnly; 
       if(this.columnReadOnly!=undefined && this.columnReadOnly==true){
            this.readOnly=this.columnReadOnly; 
       }
       if(this.row!=undefined && this.fieldName!=undefined && this.row[this.fieldName]!=undefined){
            this.data=JSON.parse(JSON.stringify(this.row));
            this.value= this.data[this.fieldName];
           
       }
    }
    updateData(){
        
        const changeEvent = new CustomEvent('changedataupdate',
            {
                'detail': {currentRow:this.data,currentRowIndex:this.rowIndex,fieldName:this.fieldName,value:this.value}
            }
        );
        this.dispatchEvent(changeEvent);
    }
}