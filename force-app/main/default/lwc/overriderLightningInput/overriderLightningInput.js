import { LightningElement, track, wire, api} from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";

export default class FcExposurebasis extends OmniscriptBaseMixin(LightningElement){

    @api isReadOnly;
    @api row;
    @api rowIndex;
    @api fieldName;
    @api label;

    @track value;
    handleRecordChange(event){
        this.row[fieldName]= event.target.value;
        this.updateData();
    }

    connectedCallback(){
       if(this.row!=undefined && this.fieldName!=undefined && this.row[this.fieldName]!=undefined){
           value= this.row[this.fieldName];
       }
    }
    updateData(){
        
        const changeEvent = new CustomEvent('changedataupdate',
            {
                'detail': {currentRow:this.row,currentRowIndex:this.rowIndex}
            }
        );
        this.dispatchEvent(changeEvent);
    }
}