import omniscriptEditBlock from 'vlocity_ins/omniscriptEditBlock';
import tmpl from './overrideSelectBinderProductBlock.html';
import {track} from 'lwc';
export default class OverrideSelectBinderProductBlock extends omniscriptEditBlock {
		@track quoteRecords;
		@track showQuoteLineItems;
		//@track qliLength;
		render(){
				console.log('inside override edit block')
				super.render();
				//console.log('_displayValues:: ', this._displayValues);
				var jsondata = JSON.parse(JSON.stringify(this._jsonData));
				console.log('@@jsondata::',jsondata);
				//var QuoteLines = JSON.parse(JSON.stringify(this._jsonData.quoteLineItems[0].QuoteLines));
				//console.log('@@QuoteLines::',QuoteLines);	

				let quoteNumber;
				this._displayValues.forEach(quoteDetail => {
					if(quoteDetail.label == "Quote Number"){
						quoteNumber = quoteDetail.value;
					}
				});
				
				this.quoteRecords = [];
				if(quoteNumber && this._jsonData && this._jsonData.quoteRecords && this._jsonData.quoteRecords.length > 0){
					for (let index = 0; index < this._jsonData.quoteRecords.length; index++) {
						const quoteDetails = this._jsonData.quoteRecords[index];
						if(quoteDetails.QuoteNumber == quoteNumber){
							if(quoteDetails.QuoteLines){
								this.quoteRecords = quoteDetails.QuoteLines instanceof Array? quoteDetails.QuoteLines: [quoteDetails.QuoteLines];
								this.quoteRecords = JSON.parse(JSON.stringify(this.quoteRecords));
								this.quoteRecords.forEach(quoteRec => {
									quoteRec.tranComment = '';
									if(quoteRec.Attributes && quoteRec.Attributes.tranComment){
										quoteRec.tranComment = quoteRec.Attributes.tranComment;
									}
								});
							}
							break;
						}
					}
				}
				
				//this.qliLength = this.quoteLineItems.length;
				if(this.quoteRecords.length > 0){
					this.showQuoteLineItems = true;
				}
				else{
					this.showQuoteLineItems = false;
				}
				return tmpl;
		}
}