import { LightningElement } from 'lwc';
import tmpl from './overrideDueAtSelectProperties.html';
import omniscriptSelect from 'vlocity_ins/omniscriptSelect';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";
export default class OverrideDueAtSelectProperties extends OmniscriptBaseMixin(omniscriptSelect){
    render(){
        super.render()
        return tmpl;
        
        //
        //console.log('canRepeatadd::',this.canRepeat);
        //console.log('_propSetMap.repeat::',this._propSetMap.repeat);
        //var jsondata = JSON.parse(JSON.stringify(this._jsonData));
    }
    handleChange(evt){
        super.handleChange(evt);
        var jsondata = JSON.parse(JSON.stringify(this._jsonData));
        console.log('DueAt evt value::',evt.target.value)
        if(jsondata.addSubjectivity != undefined && jsondata.addSubjectivity.Block2 != undefined){
            if(!Array.isArray(jsondata.addSubjectivity.Block2)){
                jsondata.addSubjectivity.Block2 = [jsondata.addSubjectivity.Block2];
            }
            for (let index = 0; index < jsondata.addSubjectivity.Block2.length; index++) {
                if (jsondata.addSubjectivity.Block2[index].subjectivities != undefined) {
                    if(!Array.isArray(jsondata.addSubjectivity.Block2[index].subjectivities)){
                        jsondata.addSubjectivity.Block2[index].subjectivities = [jsondata.addSubjectivity.Block2[index].subjectivities];
                    }
                    for (let subindex = 0; subindex < jsondata.addSubjectivity.Block2[index].subjectivities.length; subindex++) {
                        if (jsondata.addSubjectivity.Block2[index].subjectivities[subindex].DueAt != undefined && 
                            jsondata.addSubjectivity.Block2[index].subjectivities[subindex].DueAt != null && 
                            jsondata.addSubjectivity.Block2[index].subjectivities[subindex].DueAt != "") {
                            jsondata.addSubjectivity.Block2[index].subjectivities[subindex].SubDueDate = '';
                        }
                        else if (jsondata.addSubjectivity.Block2[index].subjectivities[subindex].SubDueDate != undefined && 
                            jsondata.addSubjectivity.Block2[index].subjectivities[subindex].SubDueDate != null && 
                            jsondata.addSubjectivity.Block2[index].subjectivities[subindex].SubDueDate != "") {
                            jsondata.addSubjectivity.Block2[index].subjectivities[subindex].DueAt = '';
                        }
                    }
                    
                }
                
            }
            let senddata = {}
            senddata['addSubjectivity'] = jsondata.addSubjectivity;
            this.omniApplyCallResp(senddata)
            console.log('this.omniApplyCallResp');
              
        }
        console.log('DueAtjsondata::',jsondata);
    }

}