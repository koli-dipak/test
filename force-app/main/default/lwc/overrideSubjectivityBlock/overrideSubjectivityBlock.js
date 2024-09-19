import omniScriptBlock from 'vlocity_ins/omniscriptBlock';
import tmpl from './overrideSubjectivityBlock.html';
import blanktmpl from './BlankResponse.html';
import {api,track} from 'lwc';
export default class overrideSubjectivityBlock extends omniScriptBlock {
		
		@track labl = '';
		@track InsId = '';
		@track comments = '';
		@api
		get blocklabel()
		{
				return this.labl;
		}
		set blocklabel(value)
		{
				this.labl=value;
				this.InsId=value;
				this.comments=value;
		}
		render(){
				
				console.log('@@this.labl',this.labl);
				console.log('@@this.InsId',this.InsId);
				console.log('@@this.comments',this.comments);
				var jsondata = JSON.parse(JSON.stringify(this._jsonData));
				console.log('@@jsondata::',jsondata);

				var prods = jsondata.ProductNameList//jsondata.selectProducts.EditBlock1;

				if(!Array.isArray(prods)){
						this.labl = prods;
				}
				else{
						var selectedProds =  jsondata.ProductNameList//prods.filter(prod => prod.Checkbox1 === true)
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
						console.log('@@label::',jsondata.ProductNameList[i])
						
						if(i<selectedProds.length){
								this.labl = selectedProds[i].ProductName
								this.comments = selectedProds[i].Comment

								/*if(jsondata.selectProducts!=undefined){
										if(!Array.isArray(jsondata.selectProducts.EditBlock1)){
											jsondata.selectProducts.EditBlock1 = [jsondata.selectProducts.EditBlock1];
										}

										let selectedProdIndex = 0;
										for (let index = 0; index < jsondata.selectProducts.EditBlock1.length; index++) {
											const selectProduct = jsondata.selectProducts.EditBlock1[index];
											if(selectProduct.Checkbox1){
												if(i == selectedProdIndex){
													this.InsId = jsondata.selectProducts.EditBlock1[index].lineItemDetails.QuoteNo +"-V"+jsondata.selectProducts.EditBlock1[index].lineItemDetails.QuoteSeq;
													this.comments = jsondata.selectProducts.EditBlock1[index].lineItemDetails.comments;
												}
												selectedProdIndex++;
											}
										}
								}else if(jsondata.SelectDocQuoteMap!=undefined){
										if(!Array.isArray(jsondata.SelectDocQuoteMap.EditBlock1)){
											jsondata.SelectDocQuoteMap.EditBlock1 = [jsondata.SelectDocQuoteMap.EditBlock1];
										}

										let selectedProdIndex = 0;
										for (let index = 0; index < jsondata.SelectDocQuoteMap.EditBlock1.length; index++) {
											const selectProduct = jsondata.SelectDocQuoteMap.EditBlock1[index];
												
											if(selectProduct.Checkbox2){
													if(!Array.isArray(jsondata.SelectDocQuoteMap.EditBlock1[index].QuoteLines)){
												jsondata.SelectDocQuoteMap.EditBlock1[index].QuoteLines = [jsondata.SelectDocQuoteMap.EditBlock1[index].QuoteLines];
											}
												if(i == selectedProdIndex){
													this.InsId = jsondata.SelectDocQuoteMap.EditBlock1[index].QuoteLines[index].Attributes.QuoteNo+"-V"+jsondata.SelectDocQuoteMap.EditBlock1[index].QuoteLines[index].Attributes.QuoteSeq;
													this.comments = jsondata.SelectDocQuoteMap.EditBlock1[index].QuoteLines[index].Attributes.comments;
												}
												selectedProdIndex++;
											}
										}
								}*/
								
						}
				}

				if(this.InsId && this.InsId != ''){
					this.InsId = "(" + this.InsId + ')';
				}
				return tmpl;
		}
}