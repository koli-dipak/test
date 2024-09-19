import omniScriptBlock from 'vlocity_ins/omniscriptBlock';
import tmpl from './overrideBinderAddLabel.html';
import {api,track} from 'lwc';
export default class overrideBinderAddLabel extends omniScriptBlock {
	@track labl = '';
	@track showAddIcon = false;
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
				super.render();
				//console.log('jsondatageneratedocument::',JSON.parse(JSON.stringify(this._jsonData)));
				//console.log('canRepeatadd::',this.canRepeat);
				//console.log('_propSetMap.repeat::',this._propSetMap.repeat);
				var jsondata = JSON.parse(JSON.stringify(this._jsonData));
				
				console.log('jsondata1::' , jsondata);
				console.log('blockLabel2:: ', this.blockLabel);
				console.log('_propSetMap3:: ', this._propSetMap);
				console.log('_blockContentContainer:: ', this._blockContentContainer);

				var prods = jsondata.ProductNameList//jsondata.selectProducts.EditBlock1;
				if(!Array.isArray(prods)){
						this.labl = prods;
				}
				else{
						
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
						if(i == 0){
							this.showAddIcon = true;
						}
						console.log('showAddIcon::' + this.showAddIcon);
				}
				
				return tmpl;
		}
}