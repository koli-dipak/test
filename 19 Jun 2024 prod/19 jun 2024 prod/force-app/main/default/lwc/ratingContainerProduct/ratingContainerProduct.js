import { LightningElement,track,api,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
/* call Apex Method */ 
import quoteLineItem from'@salesforce/apex/CTRL_RatingContainerProduct.quoteLineItem';
import getRatingContainerConfigs from'@salesforce/apex/CTRL_RatingContainerProduct.getRatingContainerConfigs';
import productAttributeUpdateQuoteLineItemRecord from'@salesforce/apex/CTRL_RatingContainerProduct.productAttributeUpdateQuoteLineItemRecord';
import cloneQuoteLine from'@salesforce/apex/CTRL_RatingContainerProduct.cloneQuoteLine';
import deleteQuoteLine from'@salesforce/apex/CTRL_RatingContainerProduct.deleteQuoteLine';
import updateQuoteLineItemWithSubSectionData from'@salesforce/apex/CTRL_RatingContainerProduct.updateQuoteLineItemWithSubSectionData';
import getListOfEditablePolicyNo from'@salesforce/apex/DAL_Utility.getListOfEditablePolicyNo';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
//import quoteLineStage from '@salesforce/schema/QuoteLineItem.Stage__c';
import QuoteLineItem_OBJECT from '@salesforce/schema/QuoteLineItem';

export default class RatingContainerProduct extends LightningElement {
		/* attribute  */
		@api recordId;
		@api spinnerStatus = false;
		@track record;
		@track attributeDataList;
		@track allAttributeList;
		@track filterButtons;
		@track hasQuoteLineData;
		@track stagePickListValues = [
			{ label: 'Rated', value: 'Rated' },
			{ label: 'Quoted', value: 'Quoted' },
			{ label: 'Binder', value: 'Binder' },
			{ label: 'Sent for Policy Issuance', value: 'Sent for Policy Issuance' },
			{ label: 'Enforced Policy', value: 'Enforced Policy' },
			{ label: 'Archived', value: 'Archived' }
		]
		RatingInformationDetailsVisible = false;
		sectionWiseFieldMapping = {};
		fieldWiseSectionMapping = {};
		PolNoList = [];

		// sectionWiseFieldMapping = {
		// 	//'Forms::Forms': 'Forms__c',
		// 	'Subjectivites::Subjectivites': 'Subjectivities__c',
		// 	'Underlying Policies::UNDERLYING POLICIES': 'Underlying_Policies__c',
		// 	//'Exposure::Exposure': 'Exposures__c'
		// 	//'LARGE DEDUCTIBLES::DEDUCTIBLE' : 'LARGE_DEDUCTIBLES__c',
		// 	//'SMALL DEDUCTIBLES::DEDUCTIBLE' : 'SMALL_DEDUCTIBLES__c',
		// 	//'STATE SPECIFIC LIMITS DEDUCTIBLES::State Specific Limits Deductibles' : 'State_Specific_Limits_Deductibles__c'
		// };

		// fieldWiseSectionMapping = {
		// 	'Forms__c': 'Forms::Forms',
		// 	'Subjectivities__c': 'Subjectivites::Subjectivites',
		// 	'Underlying_Policies__c': 'Underlying Policies::UNDERLYING POLICIES',
		// 	'Exposures__c': 'Exposure::Exposure',
		// 	'LARGE_DEDUCTIBLES__c' : 'LARGE DEDUCTIBLES::DEDUCTIBLE',
		// 	'SMALL_DEDUCTIBLES__c' : 'SMALL DEDUCTIBLES::DEDUCTIBLE',
		// 	'Experience_Modifications__c' : 'EXPERIENCE MODIFICATIONS::Experience Modification',
		// 	'State_Specific_Limits_Deductibles__c' : 'STATE SPECIFIC LIMITS DEDUCTIBLES::State Specific Limits Deductibles'
		// };

		// @wire(getObjectInfo, { objectApiName: QuoteLineItem_OBJECT })
    	// quoteLineObjectInfo;
		
		// @wire(getPicklistValues, { recordTypeId: '$quoteLineObjectInfo.data.defaultRecordTypeId', fieldApiName : quoteLineStage })
		// wiredPickListValue({ data, error }){
		// 	if(data){
		// 		console.log('Picklist values are', data.values);
		// 		this.stagePickListValues = data.values;
		// 		this.error = undefined;
		// 	}
		// 	if(error){
		// 		console.log('Error while fetching Picklist values  ${error}');
		// 		this.error = error;
		// 		this.pickListvalues = undefined;
		// 	}
		// }
		
		/* showmoredetails subsection update record in Enter */
		handleOnKeyPress(event){
			if ((event.key === 'Enter' && event.currentTarget.tagName != 'LIGHTNING-TEXTAREA') || (event.key === "\n" && event.ctrlKey)) {
				this.productAttributeUpdateRecord(event);
			}
		}

		onChangeQuoteType(event){
			this.spinnerStatus = true;
			let UniqueValue = event.currentTarget.name;
			let selectedValue = event.currentTarget.value;

			for (let index = 0; index < this.attributeDataList.length; index++) {
				if(this.attributeDataList[index].UniqueValue == UniqueValue){
					this.attributeDataList[index].quoteLineRec.Stage__c = selectedValue;
					updateQuoteLineItemWithSubSectionData({ quoteLineItemId: this.attributeDataList[index].quoteLineRec.Id, updatedAddSectionData: selectedValue, fieldName: 'Stage__c' })
					.then( (result) => {
						this.spinnerStatus = false;
						const event = new ShowToastEvent({
							title: 'Successfully updated quote line item',
							variant: 'success'
						});
						this.dispatchEvent(event);
						console.log('seletedAttributeData:: ', result);
					}).catch((error) => {
						this.spinnerStatus = false;
						const event = new ShowToastEvent({
							title: 'Something went wrong',
							variant: 'error'
						});
						this.dispatchEvent(event);
					});
					break;
				}
			}
		}
		/* showmoredetails subsection update record */
		productAttributeUpdateRecord(event){
			let uniqueKey = event.currentTarget.name.split('||');
			let quotelineindex = parseInt(uniqueKey[0]);

			for (let index = 0; index < this.attributeDataList.length; index++) {
				if(this.attributeDataList[index].quoteLineRec.Id == this.allAttributeList[quotelineindex].quoteLineRec.Id){
					let quoteLineWrapper = this.attributeDataList[index];
					let quoteLineId = quoteLineWrapper.quoteLineRec.Id;
					let seletedAttributeData = {};
					let isValueChanged = false;
					let quoteLineRec = quoteLineWrapper.quoteLineRec;
						if(quoteLineRec.vlocity_ins__AttributeSelectedValues__c != undefined && 
						quoteLineRec.vlocity_ins__AttributeSelectedValues__c != null && 
						quoteLineRec.vlocity_ins__AttributeSelectedValues__c != '' &&
						quoteLineRec.vlocity_ins__AttributeSelectedValues__c != "null")
					{
						seletedAttributeData = JSON.parse(quoteLineRec.vlocity_ins__AttributeSelectedValues__c);
					}
					
					for (let index = 0; index < quoteLineWrapper.subSections.length; index++) {
						for (let attributeIndex = 0; attributeIndex < quoteLineWrapper.subSections[index].attributeList.length; attributeIndex++) {
							let attributeRecWrp = quoteLineWrapper.subSections[index].attributeList[attributeIndex];
							if(attributeRecWrp.attributeRec.vlocity_ins__AttributeUniqueCode__c == uniqueKey[1]){
								/*if(attributeRecWrp.value != event.currentTarget.value){
									isValueChanged = true;
								}*/
								attributeRecWrp.value = event.currentTarget.type == 'checkbox'? event.currentTarget.checked: event.currentTarget.value;
							}
							//seletedAttributeData[attributeRecWrp.attributeRec.vlocity_ins__AttributeUniqueCode__c] = attributeRecWrp.value;
						}
					}
					if((seletedAttributeData[uniqueKey[1]] != event.currentTarget.value) || event.currentTarget.type == 'checkbox'){
						isValueChanged = true;
					}
					var val = event.currentTarget.type == 'checkbox'? event.currentTarget.checked: event.currentTarget.value;
					seletedAttributeData[uniqueKey[1]] = val;
						
						
					console.log('seletedAttributeData:: ', seletedAttributeData);
					seletedAttributeData = JSON.stringify(seletedAttributeData);
					quoteLineRec.vlocity_ins__AttributeSelectedValues__c = seletedAttributeData;
					if(isValueChanged){
						this.spinnerStatus = true;
						productAttributeUpdateQuoteLineItemRecord({ quoteLineItemId: quoteLineId , seletedAttributeJson: seletedAttributeData })
						.then( (result) => {
							this.spinnerStatus = false;
							const event = new ShowToastEvent({
								title: 'Successfully updated quote line item',
								variant: 'success'
							});
							this.dispatchEvent(event);
							console.log('seletedAttributeData:: ', result);
						}).catch((error) => {
							this.spinnerStatus = false;
							const event = new ShowToastEvent({
								title: 'Something went wrong',
								variant: 'error'
							});
							this.dispatchEvent(event);
						});
					}
					break;
				}
			}
		}

		handleCoverageOnKeyPress(event){
			if (event.key === 'Enter') {
				this.productCoverageAttributeUpdateRecord(event);
			}
		}

		productCoverageAttributeUpdateRecord(event){
			console.log('productCoverageAttributeUpdateRecord::');
			let uniqueKey = event.currentTarget.name.split('||');
			let quotelineindex = parseInt(uniqueKey[0]);
			let attributeList=JSON.parse(JSON.stringify(this.attributeDataList));
			let quoteLineWrapper = attributeList[quotelineindex];
			let quoteLineId = quoteLineWrapper.quoteLineRec.Id;
			let seletedAttributeData = {};
			let isValueChanged = false;
			
			for (let index = 0; index < quoteLineWrapper.coverageSections.length; index++) {
				for (let attributeIndex = 0; attributeIndex < quoteLineWrapper.coverageSections[index].attributeList.length; attributeIndex++) {
					let attributeRecWrp = quoteLineWrapper.coverageSections[index].attributeList[attributeIndex];
					if(attributeRecWrp.childQuoteLineItemId == uniqueKey[2]){
						if(attributeRecWrp.attributeRec.vlocity_ins__AttributeUniqueCode__c == uniqueKey[1]){
							if((attributeRecWrp.value != event.currentTarget.value) || event.currentTarget.type == 'checkbox'){
								isValueChanged = true;
							}
							attributeRecWrp.value = event.currentTarget.type == 'checkbox'? event.currentTarget.checked: event.currentTarget.value;
						}
						if (uniqueKey[1] == 'AllStates' && attributeRecWrp.attributeRec.vlocity_ins__AttributeUniqueCode__c == 'StatLmt') {
							attributeRecWrp.attributeRec.vlocity_ins__IsConfigurable__c = event.currentTarget.value == 'Yes'? true: false;
							// if(event.currentTarget.value == 'Yes'){
							// 	attributeRecWrp.attributeRec.vlocity_ins__IsConfigurable__c = true;
							// }
							// else{
							// 	attributeRecWrp.attributeRec.vlocity_ins__IsConfigurable__c = false;
							// }
						}	
						seletedAttributeData[attributeRecWrp.attributeRec.vlocity_ins__AttributeUniqueCode__c] = attributeRecWrp.value;
					}
				}
			}
			this.attributeDataList=attributeList;
			console.log('seletedAttributeData:: ', seletedAttributeData);
			seletedAttributeData = JSON.stringify(seletedAttributeData);

			if(isValueChanged){
				this.spinnerStatus = true;
				productAttributeUpdateQuoteLineItemRecord({ quoteLineItemId: uniqueKey[2] , seletedAttributeJson: seletedAttributeData })
				.then( (result) => {
					this.spinnerStatus = false;
					const event = new ShowToastEvent({
						title: 'Successfully updated quote line item',
						variant: 'success'
					});
					this.dispatchEvent(event);
					console.log('seletedAttributeData:: ', result);
				}).catch((error) => {
					this.spinnerStatus = false;
					const event = new ShowToastEvent({
						title: 'Something went wrong',
						variant: 'error'
					});
					this.dispatchEvent(event);
				});
			}
		}
		/* dropdownMenu onclick */
		handleMenuClick(event){
			debugger;
			console.log('test');
			event.stopPropagation();
		}
		/* dropdownMenu onselect */
		handleOnMenubuttonClick(event) {
			let sectionFullName = event.detail.value;
			let quoteLineIndex = parseInt(event.currentTarget.dataset.index);
			let quoteLineId = event.currentTarget.dataset.quotelineid;
			let buttonValue = sectionFullName.split('::')[0];
 
			if(buttonValue == "Clone"){
				this.cloneQuoteLineRecJS(quoteLineId);
			}
			else if(buttonValue == "RemovefromQuote"){
				this.removeQuoteLineRecJS(quoteLineId);
			}
			else{
				this.handleOnAddSubsectionClick(quoteLineIndex, quoteLineId, buttonValue, sectionFullName);
			}
			/*else if(buttonLabel == "AddSubjectivites"){
				this.handleOnAddSubjectivitesClick(quoteLineIndex, quoteLineId);
			}
			else if(buttonLabel == "AddUnderlyingPolicies"){
				this.handleOnAddUndPoliciesClick(quoteLineIndex, quoteLineId);
			}
			else if(buttonLabel == "AddExposure"){
				
			}
			else if(buttonLabel == "AddForms"){
				
			}*/
		}
		/* dropdownMenu clone */
		cloneQuoteLineRecJS(quoteLineId){
			this.spinnerStatus = true;
			cloneQuoteLine({ quoteLineItemId: quoteLineId })
            .then( (result) => {
				this.spinnerStatus = false;
				this.quoteLineItemcall();
			})
			.catch((error) => {
				this.spinnerStatus = false;
			});
		}
		/* dropdownMenu removefromquote */
		removeQuoteLineRecJS(quoteLineId){
			this.spinnerStatus = true;
			deleteQuoteLine({ quoteLineItemId: quoteLineId })
            .then( (result) => {
				this.quoteLineItemcall();
				this.spinnerStatus = false;
			})
			.catch((error) => {
				this.spinnerStatus = false;
			});
		}

		// Add Subsection Data related Code
		handleOnAddSubsectionClick(quoteLineIndex, quoteLineId, buttonValue, sectionFullName) {
			for (let index = 0; index < this.attributeDataList.length; index++) {
				if(this.attributeDataList[index].quoteLineRec.Id == quoteLineId){
					quoteLineIndex = index;
					break;
				}
			}

			// to open modal set isModalOpen tarck value as true
			this.attributeDataList[quoteLineIndex].showAddSubSectionPopup = true;
			let addSubSectionPopupWrp = {};
			addSubSectionPopupWrp.popupHeader = 'Add ' + buttonValue;
			addSubSectionPopupWrp.sectionName = buttonValue;
			addSubSectionPopupWrp.sectionFullName = sectionFullName;
			addSubSectionPopupWrp.addSubSectionPopupValues = {};

			if(this.attributeDataList[quoteLineIndex].SubsectionRelatedData[sectionFullName]){
				this.attributeDataList[quoteLineIndex].SubsectionRelatedData[sectionFullName].forEach(attributeRec => {
					attributeRec.value = null;
				});
				addSubSectionPopupWrp.attributeRecList = this.attributeDataList[quoteLineIndex].SubsectionRelatedData[sectionFullName];
			}
			else{
				addSubSectionPopupWrp.attributeRecList = [];
			}
			this.attributeDataList[quoteLineIndex].addSubSectionPopupWrp = addSubSectionPopupWrp;
		}
		handleOnAddSubsectionCloseClick(event) {
			let quoteLineIndex = parseInt(event.currentTarget.name);
			console.log('quoteLineIndex:: ', quoteLineIndex);
			
			for (let index = 0; index < this.attributeDataList.length; index++) {
				if(this.attributeDataList[index].quoteLineRec.Id == this.allAttributeList[quoteLineIndex].quoteLineRec.Id){
					quoteLineIndex = index;
					break;
				}
			}

			// to close modal set isModalOpen tarck value as false
			this.attributeDataList[quoteLineIndex].showAddSubSectionPopup = false;
		}
		handleOnAddSubsectionSubmitClick(event) {
			this.spinnerStatus = true;
			let quoteLineIndex = parseInt(event.currentTarget.name);

			for (let index = 0; index < this.attributeDataList.length; index++) {
				if(this.attributeDataList[index].quoteLineRec.Id == this.allAttributeList[quoteLineIndex].quoteLineRec.Id){
					quoteLineIndex = index;
					break;
				}
			}

			let updatedAddSectionData = [];
			let newRecFromPopup = this.attributeDataList[quoteLineIndex].addSubSectionPopupWrp.addSubSectionPopupValues;
			for (let index = 0; index < this.attributeDataList[quoteLineIndex].subSectionDataList.length; index++) {
				if(this.attributeDataList[quoteLineIndex].subSectionDataList[index].sectionName == this.attributeDataList[quoteLineIndex].addSubSectionPopupWrp.sectionName){
					this.attributeDataList[quoteLineIndex].subSectionDataList[index].dataList.forEach(rowWrp => {
						let rec = {};
						rowWrp.rowData.forEach(cellData => {
							rec[cellData.key] = cellData.data;
						});
						updatedAddSectionData.push(rec);
					});

					let newRowWrp = {};
					newRowWrp.UniqueValue = this.attributeDataList[quoteLineIndex].subSectionDataList[index].dataList.length;
					newRowWrp.rowData = [];
					let rowCount = 0;
					let rec = {};
					this.attributeDataList[quoteLineIndex].subSectionDataList[index].tableAttributes.forEach(attributeName => {
						rec[attributeName] = newRecFromPopup[attributeName];
						newRowWrp.rowData.push({'UniqueValue': rowCount, 'data': newRecFromPopup[attributeName], 'key': attributeName});
						rowCount++;
					});
					updatedAddSectionData.push(rec);
					if(!this.attributeDataList[quoteLineIndex].subSectionDataList[index].hasData)
					{
						this.attributeDataList[quoteLineIndex].subSectionDataList[index].hasData = true;
					}
					this.attributeDataList[quoteLineIndex].subSectionDataList[index].dataList.push(newRowWrp);
				}
			}
			// to close modal set isModalOpen tarck value as false
			updateQuoteLineItemWithSubSectionData({ 
				quoteLineItemId: this.attributeDataList[quoteLineIndex].quoteLineRec.Id, 
				updatedAddSectionData: JSON.stringify(updatedAddSectionData),
				fieldName: this.sectionWiseFieldMapping[this.attributeDataList[quoteLineIndex].addSubSectionPopupWrp.sectionFullName]
			})
            .then( (result) => {
				this.spinnerStatus = false;
			})
			.catch((error) => {
				this.spinnerStatus = false;
			});
			this.attributeDataList[quoteLineIndex].showAddSubSectionPopup = false;
		}
		AddSubsectionFieldOnKeypress(event){
			if ((event.key === 'Enter' && event.currentTarget.tagName != 'LIGHTNING-TEXTAREA') || (event.key === "\n" && event.ctrlKey)) {
				this.onAddSubsectionFieldOnChange(event);
			}
		}
		onAddSubsectionFieldOnChange(event){
			let uniqueKey = event.currentTarget.name.split('||');
			let quotelineindex = parseInt(uniqueKey[0]);

			for (let index = 0; index < this.attributeDataList.length; index++) {
				if(this.attributeDataList[index].quoteLineRec.Id == this.allAttributeList[quotelineindex].quoteLineRec.Id){
					quotelineindex = index;
					break;
				}
			}

			let quoteLineWrapper = this.attributeDataList[quotelineindex];
			let quoteLineId = quoteLineWrapper.quoteLineRec.Id;
			let seletedAttributeData = {};
			
			for (let attributeIndex = 0; attributeIndex < quoteLineWrapper.addSubSectionPopupWrp.attributeRecList.length; attributeIndex++) {
				let attributeRecWrp = quoteLineWrapper.addSubSectionPopupWrp.attributeRecList[attributeIndex];
				if(attributeRecWrp.attributeRec.vlocity_ins__AttributeUniqueCode__c == uniqueKey[1]){
					attributeRecWrp.value = event.currentTarget.type == 'checkbox'? event.currentTarget.checked: event.currentTarget.value;
				}
				seletedAttributeData[attributeRecWrp.attributeRec.vlocity_ins__AttributeUniqueCode__c] = attributeRecWrp.value;
			}
			this.attributeDataList[quotelineindex].addSubSectionPopupWrp.addSubSectionPopupValues = seletedAttributeData;
			console.log('seletedAttributeData::', seletedAttributeData);
		}
		// End: Add Subsection Data

		/* ShowMoreDetails Expand/collapse */
		ShowMoreDetailsInfoSec(event){
			let prodwrpindex = event.currentTarget.dataset.prodwrpindex;
			prodwrpindex = parseInt(prodwrpindex);

			for (let index = 0; index < this.attributeDataList.length; index++) {
				if(this.attributeDataList[index].quoteLineRec.Id == this.allAttributeList[prodwrpindex].quoteLineRec.Id){
					prodwrpindex = index;
					break;
				}
			}

			this.attributeDataList[prodwrpindex].ShowMoreDetails = !this.attributeDataList[prodwrpindex].ShowMoreDetails;
			this.ratingInfoSec(event);
		}
		/* subsection[RatingInformationDetails] */
		ratingInfoSec(event) {
			let prodwrpindex = event.currentTarget.dataset.prodwrpindex;
			prodwrpindex = parseInt(prodwrpindex);

			for (let index = 0; index < this.attributeDataList.length; index++) {
				if(this.attributeDataList[index].quoteLineRec.Id == this.allAttributeList[prodwrpindex].quoteLineRec.Id){
					prodwrpindex = index;
					break;
				}
			}

			this.attributeDataList[prodwrpindex].RatingInformationDetailsVisible = !this.attributeDataList[prodwrpindex].RatingInformationDetailsVisible;
		}
		/* coveragesection[showCoverage] */
		coverageInfoSec(event){
			let prodwrpindex = event.currentTarget.dataset.prodwrpindex;
			prodwrpindex = parseInt(prodwrpindex);

			for (let index = 0; index < this.attributeDataList.length; index++) {
				if(this.attributeDataList[index].quoteLineRec.Id == this.allAttributeList[prodwrpindex].quoteLineRec.Id){
					prodwrpindex = index;
					break;
				}
			}

			this.attributeDataList[prodwrpindex].showCoverage = !this.attributeDataList[prodwrpindex].showCoverage;
		}
		/* insuredItemSections[show/hide] */
		showHideInsuredItemSections(event){
			let index = event.currentTarget.dataset.index;
			let prodwrpindex = event.currentTarget.dataset.prodwrpindex;
			console.log('index:: ' + index);
			console.log('prodwrpindex:: ' + prodwrpindex);
			index = parseInt(index);
			prodwrpindex = parseInt(prodwrpindex);

			for (let index = 0; index < this.attributeDataList.length; index++) {
				if(this.attributeDataList[index].quoteLineRec.Id == this.allAttributeList[prodwrpindex].quoteLineRec.Id){
					prodwrpindex = index;
					break;
				}
			}

			this.attributeDataList[prodwrpindex].insuredItemSections[index].showInsuredItemSection = !this.attributeDataList[prodwrpindex].insuredItemSections[index].showInsuredItemSection;
		}
		/* method call function [doinit type] */
		connectedCallback(){
			console.log('connectedCallback:: ');
			// this.quoteLineItemcall();
			getRatingContainerConfigs()
			.then( (ratingContainerConfigs) => {
				// 'STATE SPECIFIC LIMITS DEDUCTIBLES::State Specific Limits Deductibles' : 'State_Specific_Limits_Deductibles__c'
				ratingContainerConfigs.forEach(ratingContainerConfig => {
					let uniqueCombination = ratingContainerConfig.Additional_Item_Product_Name__c + '::' + ratingContainerConfig.Additional_Item_Product_Category__c;

					this.sectionWiseFieldMapping[uniqueCombination] = ratingContainerConfig.Source_Field_Name__c;
					this.fieldWiseSectionMapping[ratingContainerConfig.Source_Field_Name__c] = uniqueCombination;
				});
				this.quoteLineItemcall();
			})
			.catch((error) => {
				this.spinnerStatus = false;
				this.error = error;
				this.record = undefined;
			});

			this.filterButtons = [
				{'label': 'All', 'name': 'All', 'key': '0', 'isSelected': false, 'class': 'slds-m-left_x-small'},
				{'label': 'Rated', 'name': 'Rated', 'key': '1', 'isSelected': false, 'class': 'slds-m-left_x-small'},
				{'label': 'Quoted', 'name': 'Quoted', 'key': '2', 'isSelected': false, 'class': 'slds-m-left_x-small'},
				{'label': 'Binder', 'name': 'Binder', 'key': '3', 'isSelected': false, 'class': 'slds-m-left_x-small'},
				{'label': 'Archived', 'name': 'Archived', 'key': '4', 'isSelected': false, 'class': 'slds-m-left_x-small'},
				{'label': 'Sent for Policy Issuance', 'name': 'Sent for Policy Issuance', 'key': '5', 'isSelected': false, 'class': 'slds-m-left_x-small'}
			];

			getListOfEditablePolicyNo()
            .then( (result) => {
				console.log('result:::::', result)
				for(let x in result){
					this.PolNoList.push(result[x].DeveloperName);
				}
			})
			.catch((error) => {
				console.log('error:::::', error);
            });
		}
		
		filterHandleClick(event){
			let status = event.detail.value;
			let attributeDataWrapperList = [];

			let selectedFilters = [];
			/*this.filterButtons.forEach(filterButton => {
				if(filterButton.name == status){
					if(!filterButton.isSelected){
						filterButton.isSelected = true;
						filterButton.class = 'filterSelected';
					}
					else{
						filterButton.isSelected = false;
						filterButton.class = '';
					}
				}
				if(filterButton.isSelected){
					selectedFilters.push(filterButton.name);
				}
			});*/

			this.filterButtons.forEach(filterButton => {
				if(filterButton.name == status){
					filterButton.isSelected = true;
					filterButton.class = 'slds-m-left_x-small filterSelected';
				}
				else{
					filterButton.isSelected = false;
					filterButton.class = 'slds-m-left_x-small';
				}
				
				if(filterButton.isSelected || status == "All"){
					selectedFilters.push(filterButton.name);
				}
			});

			this.allAttributeList.forEach(wrapper => {
				//if(selectedFilters.indexOf(wrapper.status) > -1){
				if(selectedFilters.indexOf(wrapper.quoteLineRec.Stage__c) > -1){
					attributeDataWrapperList.push(wrapper);
				}
			});
			this.attributeDataList = attributeDataWrapperList;
			this.hasQuoteLineData = attributeDataWrapperList.length > 0;
		}

		/* Dynamic[show/hide] */
		showHideSubSections(event){
			let index = event.currentTarget.dataset.index;
			let prodwrpindex = event.currentTarget.dataset.prodwrpindex;
			console.log('index:: ' + index);
			console.log('prodwrpindex:: ' + prodwrpindex);
			index = parseInt(index);
			prodwrpindex = parseInt(prodwrpindex);
			for (let index = 0; index < this.attributeDataList.length; index++) {
				if(this.attributeDataList[index].quoteLineRec.Id == this.allAttributeList[prodwrpindex].quoteLineRec.Id){
					prodwrpindex = index;
					break;
				}
			}
			
			this.attributeDataList[prodwrpindex].subSectionDataList[index].expandSubsection = !this.attributeDataList[prodwrpindex].subSectionDataList[index].expandSubsection;
		}
		/* All display data and get data Attribute */
		quoteLineItemcall(){
			this.spinnerStatus = true;

			quoteLineItem({ quoteId: this.recordId })
            .then( (result) => {
				this.spinnerStatus = false;
				console.log('result:::::', result);
				let attributeDataWrapperList = [];
				let UniqueValue = 0;

				let productWrapperIndex = 0;
				for (let index = 0; index < result.quoteLineItems.length; index++) {
					let quoteLineRec = result.quoteLineItems[index];
					console.log('quoteLineRec',quoteLineRec);
					let productWrp = {};
					productWrp.quoteLineindex = "" + index;
					productWrp.quoteLineRec = quoteLineRec;
					productWrp.UniqueValue = UniqueValue;
					productWrp.productName = quoteLineRec.Product2.Name;
					//console.log("Name"+quoteLineRec.Product2.Name);

					/*productWrp.quoteLineRec.Stage__c = 'Rated';
					if(quoteLineRec.Policy_Number__c != null && quoteLineRec.Policy_Number__c != ''){
						productWrp.quoteLineRec.Stage__c = "Binder";
					}
					if(quoteLineRec.Send_to_Instec__c == true){
						productWrp.quoteLineRec.Stage__c = "Sent for Policy Issuance";
					}
					if(quoteLineRec.Quote_Created__c == true){
						productWrp.quoteLineRec.Stage__c = "Quoted";
					}*/
					productWrp.parentindex = productWrapperIndex;

					productWrp.subSections = [];

					productWrp.coverageSections = [];
					productWrp.insuredItemSections = [];

					let selectedAttribute = {};
					if(quoteLineRec.vlocity_ins__AttributeSelectedValues__c != undefined && 
						quoteLineRec.vlocity_ins__AttributeSelectedValues__c != null && 
						quoteLineRec.vlocity_ins__AttributeSelectedValues__c != '' &&
						quoteLineRec.vlocity_ins__AttributeSelectedValues__c != "null")
					{
						selectedAttribute = JSON.parse(quoteLineRec.vlocity_ins__AttributeSelectedValues__c);
					}

					productWrp.QuoteNo = selectedAttribute.QuoteNo;
					productWrp.QuoteSeq = selectedAttribute.QuoteSeq;
					productWrp.tranComment = selectedAttribute.tranComment;
					productWrp.TotalEstimatedPremium = selectedAttribute.Total;
					if(selectedAttribute.isAu==true || selectedAttribute.isWC==true)
					{  
						if(selectedAttribute.ratingname!=null)
							productWrp.productName = selectedAttribute.ratingname;
						else
							productWrp.productName = quoteLineRec.Product2.Name;
					}
					else
					{
					 	productWrp.productName = quoteLineRec.Product2.Name;	
					}

					productWrp.SubsectionRelatedData = {};
					productWrp.AddSubsectionRelatedDataButtons = [];

					console.log('selectedAttribute::::',selectedAttribute);
					for (const subSectionName in result.quoteRelatedMetadata[quoteLineRec.Product2Id]) {
						let subSectionWrp = {};
						subSectionWrp.sectionName = subSectionName;
						subSectionWrp.attributeList = [];

						for (let index = 0; index < result.quoteRelatedMetadata[quoteLineRec.Product2Id][subSectionName].length; index++) {
							let attributeRec = result.quoteRelatedMetadata[quoteLineRec.Product2Id][subSectionName][index];
							if(attributeRec.vlocity_ins__IsHidden__c || attributeRec.vlocity_ins__AttributeUniqueCode__c==undefined){
								continue;
							}
							// Added N2G-CA207 -> added JSON parser 
							let attributeRecWrp = {'attributeRec': JSON.parse(JSON.stringify(attributeRec))};
							attributeRecWrp.key = productWrp.quoteLineindex + '||' + attributeRec.vlocity_ins__AttributeUniqueCode__c;
							if(selectedAttribute[attributeRec.vlocity_ins__AttributeUniqueCode__c]){
								attributeRecWrp.value = selectedAttribute[attributeRec.vlocity_ins__AttributeUniqueCode__c];
							}
							if(attributeRec.vlocity_ins__ValueDataType__c == "Date" && attributeRecWrp.value!=null ){
								const splitValue = attributeRecWrp.value.split('/');
								attributeRecWrp.value = splitValue[2] + '/' + splitValue[0] + '/' + splitValue[1];
								console.log('attributeRecWrpsplitvalue',attributeRecWrp.value);
							}

							if(attributeRec.vlocity_ins__AttributeUniqueCode__c && attributeRec.vlocity_ins__AttributeUniqueCode__c.toLowerCase().indexOf('comment') > -1){
								attributeRecWrp.isTextAreaField = true;
							}
							else{
								attributeRecWrp.isTextAreaField = false;
							}

							//N2G-830 
							for(let x in this.PolNoList){
								if(attributeRec.vlocity_ins__AttributeUniqueCode__c == 'PolNo' && attributeRecWrp.value == this.PolNoList[x]){
									attributeRecWrp.attributeRec.vlocity_ins__IsConfigurable__c = true;
								}
							}
							

							attributeRecWrp.isPicklist = false;
							if(attributeRec.vlocity_ins__ValueDataType__c == 'Picklist'){
								attributeRecWrp.isPicklist = true;
								attributeRecWrp.pickValues = [];

								if(attributeRec.vlocity_ins__ValidValuesData__c && attributeRec.vlocity_ins__ValidValuesData__c != ''){
									let pickValues = JSON.parse(attributeRec.vlocity_ins__ValidValuesData__c);
									for (let index = 0; index < pickValues.length; index++) {
										const pickValue = pickValues[index];
										if(pickValue.isAvailable){
											attributeRecWrp.pickValues.push({ label: pickValue.displayText, value: pickValue.value });
										}
									}
								}
							}
							attributeRecWrp.isNumber = false;
							attributeRecWrp.isPercent= false;
							if(attributeRec.vlocity_ins__ValueDataType__c == 'Number'){
								attributeRecWrp.isNumber = true;
							}
							if(attributeRec.vlocity_ins__ValueDataType__c == 'Percent'){
								attributeRecWrp.isPercent = true;
							}
							// Added N2G-CA207
							if(attributeRec.vlocity_ins__AttributeUniqueCode__c=="PolNo" && selectedAttribute.isAu!=undefined && selectedAttribute.isAu==true && selectedAttribute.IsPolicyNumberEditable!=undefined && selectedAttribute.IsPolicyNumberEditable==false){
								attributeRecWrp.attributeRec.vlocity_ins__IsConfigurable__c=false;
							}
							// Added N2G-CA250
							if(attributeRec.vlocity_ins__AttributeUniqueCode__c=="tranComment" && selectedAttribute.isAu!=undefined && selectedAttribute.isAu==true && selectedAttribute.isPDAUProduct!=undefined && selectedAttribute.isPDAUProduct==true){
								attributeRecWrp.attributeRec.vlocity_ins__IsConfigurable__c=true;
							}
							//Added N2G WC new Requirment 
						//	console.log("MY Test"+attributeRec.vlocity_ins__AttributeUniqueCode__c);
						//console.log("Test1---->"+ttributeRec.vlocity_ins__AttributeUniqueCode__c);
						// if(attributeRec.vlocity_ins__AttributeUniqueCode__c=="BROKERCOMMISSION" && selectedAttribute.isWC!=undefined && selectedAttribute.isWC==true && selectedAttribute.isWkOtherStatesInsuranceAvaliable!=undefined && selectedAttribute.isWkOtherStatesInsuranceAvaliable==false){
						// 	attributeRecWrp.attributeRec.vlocity_ins__IsConfigurable__c=false;
							
						// }
							subSectionWrp.attributeList.push(attributeRecWrp);
						}
						UniqueValue++;
						subSectionWrp.UniqueValue = UniqueValue;
						if (subSectionWrp.attributeList.length > 0){
							productWrp.subSections.push(subSectionWrp);
						}
					}
					// coverage section
					for (const coverageSectionName in result.coverageSpecChildItemMap[quoteLineRec.Product2Id]) {
						// if(result.parentChildQLIProductMap[quoteLineRec.Id].indexOf(coverageSectionName) < 0){
						// 	continue;
						// }
						

		//Coverage section for ALl Products				
						let coverageSectionFields = result.coverageSpecChildItemMap[quoteLineRec.Product2Id][coverageSectionName];
						
						let coverageSectionWrp = {};
						coverageSectionWrp.sectionName = coverageSectionName;
						coverageSectionWrp.attributeList = [];
						for (let index = 0; index < coverageSectionFields.length; index++) {
							let attributeRec = JSON.parse(JSON.stringify(coverageSectionFields[index]));
							if(attributeRec.vlocity_ins__IsHidden__c){
								continue;
							}

							let attributeRecWrp = {'attributeRec': attributeRec};
							let coverageDataValue = result.coverageDataMap[quoteLineRec.Id + '||' + attributeRec.vlocity_ins__ObjectId__c]? result.coverageDataMap[quoteLineRec.Id + '||' + attributeRec.vlocity_ins__ObjectId__c].split('::'): ['', ''];
							
							attributeRecWrp.key = productWrp.quoteLineindex + '||' + attributeRec.vlocity_ins__AttributeUniqueCode__c + '||' + coverageDataValue[0];
							attributeRecWrp.childQuoteLineItemId = coverageDataValue[0];

							let coverageData = coverageDataValue[1];
							let coverageDataMap = {};
							if(coverageData != undefined && 
								coverageData != null && 
								coverageData != '' &&
								coverageData != "null")
							{
								coverageDataMap = JSON.parse(coverageData);
							}
							console.log("Coverage Data"+coverageData);
							if(coverageDataMap[attributeRec.vlocity_ins__AttributeUniqueCode__c]){
								attributeRecWrp.value = coverageDataMap[attributeRec.vlocity_ins__AttributeUniqueCode__c];
								if(attributeRec.vlocity_ins__ValueDataType__c == "Date"){
									const splitValue = attributeRecWrp.value.split('/');
									attributeRecWrp.value = splitValue[2] + '/' + splitValue[0] + '/' + splitValue[1];
									console.log('attributeRecWrpsplitvalue',attributeRecWrp.value);
								}
								console.log('attributeRecWrp.value',attributeRecWrp.value);
								console.log('attributeRecWrp.Name',attributeRecWrp.Name);
								console.log('attributeRec.vlocity_ins__ValueDataType__c',attributeRec.vlocity_ins__ValueDataType__c);

							}
							
							if(attributeRec.vlocity_ins__AttributeUniqueCode__c && attributeRec.vlocity_ins__AttributeUniqueCode__c.toLowerCase().indexOf('comment') > -1){
								attributeRecWrp.isTextAreaField = true;
							}
							else{
								attributeRecWrp.isTextAreaField = false;
							}
							console.log("Value 1--->"+attributeRec.vlocity_ins__AttributeUniqueCode__c+"  "+coverageDataMap.isWkOtherStatesInsuranceAvaliable);
						
							if(attributeRec.vlocity_ins__AttributeUniqueCode__c=="AllStates"  && coverageDataMap.isWkOtherStatesInsuranceAvaliable==true){
								attributeRecWrp.attributeRec.vlocity_ins__IsHidden__c=true;
								//attributeRecWrp.attributeRec.vlocity_ins__IsConfigurable__c=true
								
							}
							
						
						//	console.log("myyy"+coverageData.isWkOtherStatesInsuranceAvaliable.value);
							
							attributeRecWrp.isPicklist = false;
							if(attributeRec.vlocity_ins__ValueDataType__c == 'Picklist'){
								attributeRecWrp.isPicklist = true;
								attributeRecWrp.pickValues = [];

								if(attributeRec.vlocity_ins__ValidValuesData__c && attributeRec.vlocity_ins__ValidValuesData__c != ''){
									let pickValues = JSON.parse(attributeRec.vlocity_ins__ValidValuesData__c);
									for (let index = 0; index < pickValues.length; index++) {
										const pickValue = pickValues[index];
										if(pickValue.isAvailable){
											attributeRecWrp.pickValues.push({ label: pickValue.displayText, value: pickValue.value });
										}
									}
								}
							}
							attributeRecWrp.isNumber = false;
							attributeRecWrp.isPercent= false;
							if(attributeRec.vlocity_ins__ValueDataType__c == 'Number'){
								attributeRecWrp.isNumber = true;
							}
							if(attributeRec.vlocity_ins__ValueDataType__c == 'Percent'){
								attributeRecWrp.isPercent = true;
							}
							//	console.log()
						

							/*if(this.textAreaFields.indexOf(attributeRec.vlocity_ins__AttributeUniqueCode__c) > -1){
								attributeRecWrp.isTextAreaField = true;
							}
							else{
								attributeRecWrp.isTextAreaField = false;
							}*/
							coverageSectionWrp.attributeList.push(attributeRecWrp);
						}
						if (coverageSectionWrp.attributeList.length > 0){
							productWrp.coverageSections.push(coverageSectionWrp);
						}
						console.log('coverageSectionWrp::',coverageSectionWrp);
					}
					// Total Number of Coverages
					productWrp.totalNumberOfCoverages = productWrp.coverageSections.length;

					// Insured Item section
					let showAddNewRecButton = [];
					for (const insuredItemSpectionName in result.insuredItemSpecChildItemMap[quoteLineRec.Product2Id]) {
						let insuredItemSpectionFields = result.insuredItemSpecChildItemMap[quoteLineRec.Product2Id][insuredItemSpectionName];
						for (let index = 0; index < insuredItemSpectionFields.length; index++) {
							let attributeRec = insuredItemSpectionFields[index];

							if(result.addNewRecordButton.indexOf(attributeRec.vlocity_ins__ObjectId__c) > -1 && showAddNewRecButton.indexOf(insuredItemSpectionName) == -1){
								showAddNewRecButton.push(insuredItemSpectionName);
							}
							
							if(attributeRec.vlocity_ins__IsHidden__c || result.showSection.indexOf(attributeRec.vlocity_ins__ObjectId__c) == -1){
								continue;
							}

							let attributeRecWrp = {'attributeRec': attributeRec};
							attributeRecWrp.key = productWrp.quoteLineindex + '||' + attributeRec.vlocity_ins__AttributeUniqueCode__c;

							// Picklist value add in DueAt field in Subjectivites
							attributeRecWrp.isPicklist = false;
							if(attributeRec.vlocity_ins__ValueDataType__c == 'Picklist'){
								attributeRecWrp.isPicklist = true;
								attributeRecWrp.pickValues = [];

								if(attributeRec.vlocity_ins__ValidValuesData__c && attributeRec.vlocity_ins__ValidValuesData__c != ''){
									let pickValues = JSON.parse(attributeRec.vlocity_ins__ValidValuesData__c);
									for (let index = 0; index < pickValues.length; index++) {
										const pickValue = pickValues[index];
										if(pickValue.isAvailable){
											attributeRecWrp.pickValues.push({ label: pickValue.displayText, value: pickValue.value });
										}
									}
								}
							}
							attributeRecWrp.isNumber = false;
							attributeRecWrp.isPercent= false;
							if(attributeRec.vlocity_ins__ValueDataType__c == 'Number'){
								attributeRecWrp.isNumber = true;
							}
							if(attributeRec.vlocity_ins__ValueDataType__c == 'Percent'){
								attributeRecWrp.isPercent = true;
							}
							if(productWrp.SubsectionRelatedData[insuredItemSpectionName]){
								productWrp.SubsectionRelatedData[insuredItemSpectionName].push(attributeRecWrp);
							}
							else{
								productWrp.SubsectionRelatedData[insuredItemSpectionName] = [attributeRecWrp];
							}
							//insuredItemSectionWrp.attributeList.push(attributeRecWrp);
						}
					}

					productWrp.subSectionDataList = [];
					let subSectionCount = 0;
					for (const fieldName in this.fieldWiseSectionMapping) {
						const subSectionNameInfo = this.fieldWiseSectionMapping[fieldName];
						const subSectionName = this.fieldWiseSectionMapping[fieldName].split('::')[0];
						if(!productWrp.SubsectionRelatedData[subSectionNameInfo]){
							continue;
						}

						let subSectionDataWrp = {};
						subSectionDataWrp.UniqueValue = subSectionCount;
						subSectionDataWrp.tableHeaders = [];
						let tableAttributes = [];

						let recCount = 0;
						productWrp.SubsectionRelatedData[subSectionNameInfo].forEach(attributeRecWrp => {
							subSectionDataWrp.tableHeaders.push({UniqueValue: recCount, header: attributeRecWrp.attributeRec.vlocity_ins__AttributeName__c});
							tableAttributes.push(attributeRecWrp.attributeRec.vlocity_ins__AttributeUniqueCode__c);
							recCount++;
						});

						subSectionDataWrp.sectionName = subSectionName;
						subSectionDataWrp.sectionFullName = subSectionNameInfo;
						subSectionDataWrp.dataList = [];
						if(quoteLineRec[fieldName] != undefined && 
							quoteLineRec[fieldName] != null && 
							quoteLineRec[fieldName] != '' &&
							quoteLineRec[fieldName] != "null")
						{
							let dataList = JSON.parse(quoteLineRec[fieldName]);
							if(!(dataList instanceof Array)){
								dataList = [dataList];
							}
							
							recCount = 0;
							dataList.forEach(subsectionData => {
								if(subsectionData!=null){
									let rowWrp = {};
									rowWrp.rowData = [];
									let rowCount = 0;
									tableAttributes.forEach(tableAttribute => {
										rowWrp.rowData.push({'UniqueValue': rowCount, 'data': subsectionData[tableAttribute], 'key': tableAttribute});
										rowCount++;
									});
									rowWrp.UniqueValue = recCount;
									subSectionDataWrp.dataList.push(rowWrp);
									recCount++;
								}
							});
						}

						subSectionDataWrp.hasData = subSectionDataWrp.dataList.length > 0;
						subSectionDataWrp.expandSubsection = false;
						subSectionDataWrp.tableAttributes = tableAttributes;
						productWrp.subSectionDataList.push(subSectionDataWrp);
						subSectionCount++;
					}

					let buttonIndex = 0;
					for (const sectionName of showAddNewRecButton) {
						if(!this.sectionWiseFieldMapping[sectionName]){
							continue;
						}

						const subSectionName = sectionName.split('::')[0];

						productWrp.AddSubsectionRelatedDataButtons.push({'buttonName': sectionName, 'buttonLabel': 'Add ' + subSectionName, key: buttonIndex});
					}
					productWrp.hasAddSubsectionRelatedDataButtons = productWrp.AddSubsectionRelatedDataButtons.length > 0;
					productWrp.showCoverage = false;
					attributeDataWrapperList.push(productWrp);
					UniqueValue++;
					productWrapperIndex++;
				}
				console.log('attributeDataWrapperList:: ', attributeDataWrapperList);
				this.attributeDataList = attributeDataWrapperList;
				this.allAttributeList = attributeDataWrapperList;
				this.hasQuoteLineData = this.attributeDataList.length > 0;
                this.error = undefined;
            })
            .catch((error) => {
				this.spinnerStatus = false;
                this.error = error;
                this.record = undefined;
            });

		}
}