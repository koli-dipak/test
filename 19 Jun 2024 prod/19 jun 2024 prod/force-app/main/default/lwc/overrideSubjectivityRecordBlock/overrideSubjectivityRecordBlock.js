import omniScriptBlock from 'vlocity_ins/omniscriptBlock';
import tmpl from './overrideSubjectivityRecordBlock.html';
import {api,track} from 'lwc';

export default class overrideSubjectivityRecordBlock extends omniScriptBlock {

		@track isnew = true;
		@api
		get isNew()
		{
				return this.isnew;
		}
		set isNew(value)
		{
				this.isnew=value;
		}
		render(){
				//var jsondata = JSON.parse(JSON.stringify(this._jsonData));
// 				var label = this.blockLabel;
// 				var i;
// 				console.log('@@jsondata::',jsondata)	
// 				
// 				if(label.length===1){
// 						i = Number(label);
// 				}else{
// 						i = Number(label.charAt(label.length-1));
// 				}
// 				i = i - 1;
				// console.log("index:::",i);
				//console.log('@@subjectivityItemId::',jsondata.addSubjectivity.Block2.subjectivities.subjectivityItemId)
				//this.labl = jsondata.selectProducts.EditBlock1[i].ProductName;
				return tmpl;
		}
}