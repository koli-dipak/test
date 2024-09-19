import omniScriptBlock from 'vlocity_ins/omniscriptBlock';
import tmpl from './overrideAddSubjforBinderOS.html';
//import blanktmpl from './BlankResponse.html';
import {api,track} from 'lwc';
export default class OverrideAddSubjforBinderOS extends omniScriptBlock {
		@track labl = '';
		@api
		get blocklabel()
		{
				return this.labl;
		}
		set blocklabel(value)
		{
				this.labl=value;
		}
		render(){
				console.log('@@this.labl',this.labl);
				var jsondata = JSON.parse(JSON.stringify(this._jsonData));
				var prods = jsondata.QuoteLineList;
				if(!Array.isArray(prods)){
						this.labl = prods.ProductName;
				}
				else{
						
						var QuoteLineList =  jsondata.QuoteLineList//prods.filter(prod => prod.Checkbox1 === true)
						var label = this.blockLabel;
						console.log("blockLabel:::",label)
						var i;
						console.log('@@jsondata::',jsondata)	

						if(label.length===1){
								i = Number(label);
						}else{
								i = Number(label.charAt(label.length-1));
						}
						i = i - 1;
						console.log("index:::",i);
						console.log('@@label::',jsondata.QuoteLineList[i].ProductName)
						if(i<QuoteLineList.length){
								this.labl = QuoteLineList[i].ProductName
						}else
						{
								return blanktmpl;
						}
						//this.labl = selectedProds.length<i?'':selectedProds[i].ProductName;
				}
				return tmpl;
		}
}