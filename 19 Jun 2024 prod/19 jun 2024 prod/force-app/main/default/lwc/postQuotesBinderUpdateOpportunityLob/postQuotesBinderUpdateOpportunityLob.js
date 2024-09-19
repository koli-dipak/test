import { LightningElement, api, track, wire } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";
import { OmniscriptActionCommonUtil } from "vlocity_ins/omniscriptActionUtils";

export default class PostQuotesBinderUpdateOpportunityLob extends OmniscriptBaseMixin(LightningElement) {
  _actionUtil;

    @api opportunityDetails;
    @api defaultStage;
    @api defaultProbability;
    @api productResponse;
    @api isBinder;
    @api isRevisedBinder;
    @api selectedProducts;
    @api allQuotelineitemWithPolicyDetails;

    @track records;
    imgsrc = 'data:@file/png;base64,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';
    @track oppName;
    @track lobRecords = [];
    @track QuoteLineItemProductDetails = [];
    @track updatedLobRecords = {};
    statusOptions;
    @track recordsIndex;
    @track recordsArray = [];
    @track isUpdatedLob = false;
    @track BoundSelectProductArray;

    @track dependentPicklistValues;  // get this value from apex class name DependentPicklistPopulation.cls
    @track stageIsLostOrDeclined;
    @track policyRecords = [];

    //LOB percentage Changes
    percentageOptions;

    LostHelpText = 'A submission for which we provided a quote, but ultimately did not win.';
    DeclinedHelpText = 'An opportunity where we have received the submission email from the broker and decided not to provide a formal quote or only provide a verbal indication.';
    NotSubmittedHelpText = 'An opportunity for which we expressed interest to the broker, but were not able to obtain a formal submission.';

    sendtoOmniscript() {
        var Final = {}
        Final['LobRecords'] = {"LobUpdatedRecords":JSON.parse(JSON.stringify(this.lobRecords)), "QuoteLineItemsUpdatedRecords":JSON.parse(JSON.stringify(this.QuoteLineItemProductDetails)) ,"isUpdatedLob" : this.isUpdatedLob, "PolicyHolder" : JSON.parse(JSON.stringify(this.policyRecords))};
        this.omniApplyCallResp(Final);
    }
  
    handleChange(event) {
        this.recordsIndex = event.target.dataset.index;
        let key = event.target.dataset.key
        this.lobRecords=JSON.parse(JSON.stringify(this.lobRecords));
        this.lobRecords[this.recordsIndex][event.target.name] = event.target.value == undefined || event.target.value == ''? 0 :event.target.value;

        if(event.target.name == 'LobStage'){
          this.lobRecords[this.recordsIndex]['stageIsLostOrDeclined'] =  event.target.value == 'Lost' || event.target.value == 'Declined'?true:false;
          this.lobRecords[this.recordsIndex]['stageIsLostOrDeclinedorNotsubmitted'] =  event.target.value == 'Lost' || event.target.value == 'Declined' || event.target.value == 'Not Submitted'?true:false;
          this.lobRecords[this.recordsIndex]['Indicationprovided'] = event.target.value == 'Declined'?true:false;
        }
        

        if(event.target.name == 'LobStage' && event.target.value == 'Lost'){
          this.lobRecords[this.recordsIndex]['reasonCodeOptions'] = this.dependentPicklistValues.Lost;
          this.lobRecords[this.recordsIndex]['helpText'] = this.LostHelpText;
        }

        if(event.target.name == 'LobStage' && event.target.value == 'Declined'){
          this.lobRecords[this.recordsIndex]['reasonCodeOptions'] = this.dependentPicklistValues.Declined;
          this.lobRecords[this.recordsIndex]['helpText'] = this.DeclinedHelpText;
        }

        if(event.target.name == 'LobStage' && event.target.value == 'Not Submitted'){
          //this.lobRecords[this.recordsIndex]['reasonCodeOptions'] = this.dependentPicklistValues.Declined;
          this.lobRecords[this.recordsIndex]['helpText'] = this.NotSubmittedHelpText;
        }
       
        if(event.target.name == 'LobStage'){
          console.log('Probability==','label==',event.target.value,'value==',this.percentageOptions[event.target.value])
          this.lobRecords[this.recordsIndex]['Probability'] = this.percentageOptions[event.target.value] != 'undefined'?this.percentageOptions[event.target.value]:0;
        }
    }
    reasonHandleChange(event){
      this.template.querySelectorAll('lightning-combobox, lightning-textarea').forEach((field) => {
        const fieldName = field.getAttribute('data-id');
        if (fieldName && !field.value) {
            // field.setCustomValidity(`${fieldName} is required.`);
            field.setCustomValidity(`required field are missing.`);
        } else {
            field.setCustomValidity('');
        }
        field.reportValidity();
    });

      this.lobRecords[event.target.dataset.index][event.target.name] = event.target.value;
    }

    handleIndicationChange(event){
      this.lobRecords[event.target.dataset.index][event.target.name] = event.target.checked;
      // console.log('checkedVAlue',event.target.checked);
      // console.log('!checkedVAlue',!event.target.checked);
    }

    connectedCallback(){
      this._actionUtil = new OmniscriptActionCommonUtil();

      const globalValuesetParams = {
        input: JSON.stringify({}),
        sClassName: 'DependentPicklistPopulation',
        sMethodName: 'getDependentPicklistValues',
        options: '{}'
      };
      this.omniRemoteCall(globalValuesetParams, true).then((response) => {
        // var stageResult = JSON.parse(response.result.stageSuccess);
        // var reasoncodeResult = JSON.parse(response.result.reasoncodeSuccess);
        var dependentPicklistValues =JSON.parse(JSON.parse(response.result.dependentPicklistValues));

        // console.log('stageResult',stageResult);
        // console.log('reasoncodeResult',reasoncodeResult);
        console.log('dependentPicklistValues',dependentPicklistValues);
        this.dependentPicklistValues = dependentPicklistValues;

        // if lob and quotelineitem not matched 
        for(let x in this.lobRecords){
          if(this.lobRecords[x]['LobStage'] == 'Lost'){
            this.lobRecords[x]['reasonCodeOptions'] = this.dependentPicklistValues.Lost;
            this.lobRecords[x]['helpText'] = this.LostHelpText;
          }

          if(this.lobRecords[x]['LobStage'] == 'Declined'){
            this.lobRecords[x]['reasonCodeOptions'] = this.dependentPicklistValues.Declined;
            this.lobRecords[x]['helpText'] = this.DeclinedHelpText;
          }

          if(this.lobRecords[x]['LobStage'] == 'Not Submitted'){
            this.lobRecords[x]['helpText'] = this.NotSubmittedHelpText;
          }
        }
    }).catch((error) => {
        console.log('error:: ', error);
    });

        this.records = JSON.parse(JSON.stringify(this.opportunityDetails));
        this.oppName = this.records.Name;
        // this.lobRecords = this.records.LobDetails;
        if (Array.isArray(this.records.LobDetails)) {
            this.lobRecords = this.records.LobDetails;
        } else {
            this.lobRecords = [this.records.LobDetails];
        }

        this.QuoteLineItemProductDetails = Array.isArray(this.records.QuoteLineItemProductDetails) ? this.records.QuoteLineItemProductDetails : [this.records.QuoteLineItemProductDetails];

        this.statusOptions = this.records.LobStageDetails;
        // this.reasonCodeOptions = this.records.ReasonCodePicklistValues;
        console.log("logggg",this.records)
        console.log("defaultStage",this.defaultStage)
        this.percentageOptions = this.records.LobDefaultPercentages;
        this.percentageOptions = this.records.LobDefaultPercentages.reduce(function(map, obj) {
          map[obj.label] = obj.Percent;
          return map;
      }, {});
      console.log("percentageOptions",this.percentageOptions);

        console.log("PerLogg",this.records);

        // for set stageIsLostOrDeclined to true if stage is Declined or lost 
        for(let x in this.lobRecords){
          this.lobRecords[x]['stageIsLostOrDeclined'] = this.lobRecords[x]['LobStage'] == 'Lost' || this.lobRecords[x]['LobStage'] == 'Declined'?true:false;
          this.lobRecords[x]['stageIsLostOrDeclinedorNotsubmitted'] =  this.lobRecords[x]['LobStage'] == 'Lost' || this.lobRecords[x]['LobStage'] == 'Declined' || this.lobRecords[x]['LobStage'] == 'Not Submitted'?true:false;
          this.lobRecords[x]['Indicationprovided'] = this.lobRecords[x]['LobStage'] == 'Declined'?true:false;
        }

        // This is for relate Lob to QuoteLineItem---
        this.lobToQuoteLineItemChildRelate(this.lobRecords, this.records.LobQuoteRecordtypeDetails, this.QuoteLineItemProductDetails)
        // this.lobToQuoteLineItemChildRelate(this.lobRecords, this.records.LobQuoteRecordtypeDetails, Array.isArray(this.records.QuoteLineItemProductDetails) ? this.records.QuoteLineItemProductDetails : [this.records.QuoteLineItemProductDetails])
        // this will call when omniscript call from Generate Quote Binder Document
        if(this.defaultStage == "Bound" && this.isBinder){
            this.BoundSelectProductArray = JSON.parse(JSON.stringify(this.productResponse));
            console.log('@@@ram', this.BoundSelectProductArray);

        }
        // this will call when omniscript call from Generate Quote Document
        // if(this.defaultStage == "Quote"){
            // this.getDefaultMatched(this.lobRecords, this.records.LobQuoteRecordtypeDetails, Array.isArray(this.records.QuoteLineItemProductDetails) ? this.records.QuoteLineItemProductDetails : [this.records.QuoteLineItemProductDetails]);
            this.getDefaultMatched(this.lobRecords, this.records.LobQuoteRecordtypeDetails, this.QuoteLineItemProductDetails);
        // }

        
    }
   
    updateRecords(event){
      let isValid = true;
        this.template.querySelectorAll('lightning-combobox, lightning-textarea').forEach((field) => {
            const fieldName = field.getAttribute('data-id');
            if (fieldName && !field.value) {
                // field.setCustomValidity(`${fieldName} is required.`);
                field.setCustomValidity(`required field are missing.`);
                isValid = false;
            } else {
                field.setCustomValidity('');
            }
            field.reportValidity();
        });
        if (isValid) {
            this.isUpdatedLob = !this.isUpdatedLob;
            this.sendtoOmniscript();
            this.omniNextStep();
        }
        
        // this.isUpdatedLob = !this.isUpdatedLob;
        // this.sendtoOmniscript();
        // this.omniNextStep();
    }
    cancelBtn(){
        this.omniNextStep();
    }

    lobToQuoteLineItemChildRelate(lobRecords, LobQuoteRecordtypeDetails, QuoteLineItemProductDetails){
        console.log('lobRecords',lobRecords);
        console.log('LobQuoteRecordtypeDetails',LobQuoteRecordtypeDetails);
        let QuoteMatchingName = [];
        let lobandquoteLineItemMatchedName = [];
        for(let x in lobRecords){
            for(let y in LobQuoteRecordtypeDetails){
                if(lobRecords[x].LobRecordTypeName == LobQuoteRecordtypeDetails[y].MasterLabel){
                    console.log("LobQuoteRecordtypeDetails[y]", LobQuoteRecordtypeDetails[y]);
                    QuoteMatchingName.push(LobQuoteRecordtypeDetails[y].QuoteMatchingName)
                    lobandquoteLineItemMatchedName.push(LobQuoteRecordtypeDetails[y].MasterLabel)
                }
            }
        }

        this.lobRecords = this.lobRecords.map(record => {
            const matchedProduct = LobQuoteRecordtypeDetails.find(product => product.MasterLabel === record.LobRecordTypeName);
            if (matchedProduct) {
              record.LobQuoteLineMatchedName = matchedProduct.QuoteMatchingName;
            }
            return record;
          });


        this.QuoteLineItemProductDetails = this.QuoteLineItemProductDetails.map(record => {
            const matchedProduct = QuoteMatchingName.find(product => product === record.ProductName);
            if (matchedProduct) {
              const lobRecord = this.lobRecords.find(lob => lob.LobQuoteLineMatchedName === matchedProduct);
              if (lobRecord) {
                record.LobId = lobRecord.Id;
              }
            }
            return record;
          });
          console.log(this.QuoteLineItemProductDetails);
          
          
    }

    getDefaultMatched(lobRecords, LobQuoteRecordtypeDetails, QuoteLineItemProductDetails){
        console.log(lobRecords);
        console.log(LobQuoteRecordtypeDetails);
        console.log(QuoteLineItemProductDetails);
        let QuoteMatchingName = [];
        for(let x in lobRecords){
            for(let y in LobQuoteRecordtypeDetails){
                if(lobRecords[x].LobRecordTypeName == LobQuoteRecordtypeDetails[y].MasterLabel){
                    QuoteMatchingName.push(LobQuoteRecordtypeDetails[y].QuoteMatchingName)
                }
            }
        }

        this.QuoteLineItemProductDetails = QuoteLineItemProductDetails.map(record => {
            const matchedProduct = LobQuoteRecordtypeDetails.find(product => product.QuoteMatchingName === record.ProductName);
            if (matchedProduct) {
              record.MatchedQuoteAndLob = matchedProduct.MasterLabel;
            }
            return record;
          });
          console.log(this.QuoteLineItemProductDetails);

        if(this.defaultStage == "Quote"){
          let selectedProducts = JSON.parse(JSON.stringify(Array.isArray(this.selectedProducts) ? this.selectedProducts : [this.selectedProducts]));
          console.log("result", this.getlatestmodifybyobject(selectedProducts));
          let LastModifiedDateResult = this.getlatestmodifybyobject(selectedProducts);
            // this.lobRecords = this.lobRecords.map(record => {
            //     // const matchedProduct = QuoteLineItemProductDetails.find(product => product.MatchedQuoteAndLob === record.LobRecordTypeName);
            //     const matchedProduct = QuoteLineItemProductDetails.find(product => product.MatchedQuoteAndLob === record.LobRecordTypeName);
            //     if (matchedProduct) {
            //       record.LobPremium = parseFloat(matchedProduct.Total).toFixed(2);
            //       record.LobStage = this.defaultStage;
            //       record.Probability = this.defaultProbability;
            //       record.stageIsLostOrDeclined = false;
            //     }
            //     return record;
            //   });
          console.log('ramlob',JSON.parse(JSON.stringify(this.lobRecords)));
          console.log('ramselectedProducts',JSON.parse(JSON.stringify( selectedProducts)));
            this.lobRecords = this.lobRecords.map(record => {
              const matchedProduct = LastModifiedDateResult.find(product => product.ProductNameInfo === record.LobQuoteLineMatchedName);
              console.log('matchedProduct',matchedProduct)
              if (matchedProduct) {
                record.LobPremium = parseFloat(matchedProduct.lineItemDetails.Total).toFixed(2);
                record.LobStage = this.defaultStage;
                record.Probability = this.defaultProbability;
                record.stageIsLostOrDeclined = false;
                record.stageIsLostOrDeclinedorNotsubmitted = false;
                record.Indicationprovided = false;
              }
              return record;
            });

            // added in sprint 2 for effective date logic
            // let selectedProducts = JSON.parse(JSON.stringify(Array.isArray(this.selectedProducts) ? this.selectedProducts : [this.selectedProducts]));
            let SelectedProductDateAndName = [];
            for(let x in selectedProducts){
              let tempNameAndDate = {
                productName : selectedProducts[x].ProductNameInfo,
                EffectiveDate : selectedProducts[x].lineItemDetails.EffectiveDate
              }
              SelectedProductDateAndName.push(tempNameAndDate);
            } 
            console.log('SelectedProductDateAndName', SelectedProductDateAndName);
            let finalEffectedDate = this.getMinimumEffectiveDates(SelectedProductDateAndName)
            console.log("finalEffectedDate", finalEffectedDate);
            // console.log("this.lobRecords",this.lobRecords);

            finalEffectedDate.forEach(finalEffectedDateItem => {
              this.lobRecords.forEach(lobrecItem => {
                if(finalEffectedDateItem.productName === lobrecItem.LobQuoteLineMatchedName) {
                  lobrecItem.EffectiveDate = finalEffectedDateItem.EffectiveDate;
                }
              });
            });
            console.log("this.lobRecords",this.lobRecords);
        }

       

        if(this.defaultStage == "Bound" && this.isBinder){
            this.BoundSelectProductArray = this.BoundSelectProductArray.map(record => {
                const matchedProduct = LobQuoteRecordtypeDetails.find(product => product.QuoteMatchingName === record.ProductName);
                if (matchedProduct) {
                  record.MatchedQuoteAndLob = matchedProduct.MasterLabel;
                }
                return record;
              });
              console.log(this.BoundSelectProductArray);

            let SumOfMatchedPremium = 0;

            this.lobRecords = this.lobRecords.map(record => {
                const matchedProduct = this.BoundSelectProductArray.filter(product => product.MatchedQuoteAndLob === record.LobRecordTypeName);
                if (matchedProduct && matchedProduct.length > 0) {
                  const SumOfMatchedPremium = matchedProduct.reduce((sum, product) => sum + parseFloat(product.phGLTotalEstPremium), 0);
                  record.LobPremium =parseFloat(SumOfMatchedPremium).toFixed(2);
                  record.LobStage = this.defaultStage;
                  record.Probability = this.defaultProbability;
                  record.stageIsLostOrDeclined = false;
                  record.stageIsLostOrDeclinedorNotsubmitted = false;
                  record.Indicationprovided = false;
                  record.isDisablePicklist = true;
                }
                return record;
              });

            // added in sprint 2 for effective date logic
            let selectedProducts = JSON.parse(JSON.stringify(this.BoundSelectProductArray));
            let SelectedProductDateAndName = [];
            for(let x in selectedProducts){
              let tempNameAndDate = {
                productName : selectedProducts[x].ProductNameInfo,
                EffectiveDate : selectedProducts[x].phGLEffectiveDate
              }
              SelectedProductDateAndName.push(tempNameAndDate);
            } 
            console.log('SelectedProductDateAndName', SelectedProductDateAndName);
            let finalEffectedDate = this.getMinimumEffectiveDates(SelectedProductDateAndName)
            console.log("finalEffectedDate", finalEffectedDate);
            // console.log("this.lobRecords",this.lobRecords);

            finalEffectedDate.forEach(finalEffectedDateItem => {
              this.lobRecords.forEach(lobrecItem => {
                if(finalEffectedDateItem.productName === lobrecItem.LobQuoteLineMatchedName) {
                  lobrecItem.EffectiveDate = finalEffectedDateItem.EffectiveDate;
                }
              });
            });
            console.log("this.lobRecords",this.lobRecords);

            //added for N2G-65 put the data of policy holder name 
            this.policyRecords = this.createNewArray(JSON.parse(JSON.stringify(this.BoundSelectProductArray)) ,JSON.parse(JSON.stringify(Array.isArray(this.records.PolicyHolder) ? this.records.PolicyHolder : [this.records.PolicyHolder])));
            console.log('this.policyRecords', this.policyRecords);
        }

        // logic for revise binder
        if(this.defaultStage == "Bound" && this.isRevisedBinder){
            this.lobRecords = this.lobRecords.map(record => {
                // const matchedProduct = QuoteLineItemProductDetails.find(product => product.MatchedQuoteAndLob === record.LobRecordTypeName);
                const matchedProduct = QuoteLineItemProductDetails.filter(product => product.MatchedQuoteAndLob === record.LobRecordTypeName && product.PolicyNumber != undefined);
                if (matchedProduct && matchedProduct.length > 0) {
                  const SumOfMatchedPremium = matchedProduct.reduce((sum, product) => sum + parseFloat(product.Total), 0);
                  record.LobPremium =parseFloat(SumOfMatchedPremium).toFixed(2);
                  record.LobStage = this.defaultStage;
                  record.Probability = this.defaultProbability;
                  record.stageIsLostOrDeclined = false;
                  record.stageIsLostOrDeclinedorNotsubmitted = false;
                  record.Indicationprovided = false;
                  record.isDisablePicklist = true;
                }
                return record;
              });

            // added in sprint 2 for effective date logic
            let selectedProducts = JSON.parse(JSON.stringify(Array.isArray(this.allQuotelineitemWithPolicyDetails) ? this.allQuotelineitemWithPolicyDetails : [this.allQuotelineitemWithPolicyDetails]));
            let SelectedProductDateAndName = [];
            for(let x in selectedProducts){
              let tempNameAndDate = {
                productName : selectedProducts[x].ProductNameInfo,
                EffectiveDate : selectedProducts[x].phGLEffectiveDate
              }
              SelectedProductDateAndName.push(tempNameAndDate);
            } 
            console.log('SelectedProductDateAndName', SelectedProductDateAndName);
            let finalEffectedDate = this.getMinimumEffectiveDates(SelectedProductDateAndName)
            console.log("finalEffectedDate", finalEffectedDate);
            // console.log("this.lobRecords",this.lobRecords);

            finalEffectedDate.forEach(finalEffectedDateItem => {
              this.lobRecords.forEach(lobrecItem => {
                if(finalEffectedDateItem.productName === lobrecItem.LobQuoteLineMatchedName) {
                  lobrecItem.EffectiveDate = finalEffectedDateItem.EffectiveDate;
                }
              });
            });
            console.log("this.lobRecords",this.lobRecords);

            //added for N2G-65 put the data of policy holder name 
            this.policyRecords = this.createNewArray(JSON.parse(JSON.stringify(Array.isArray(selectedProducts) ? selectedProducts : [selectedProducts])), JSON.parse(JSON.stringify(Array.isArray(this.records.PolicyHolder) ? this.records.PolicyHolder : [this.records.PolicyHolder])));
            console.log('this.policyRecords', this.policyRecords);
        }
    }

    // method to find minimum effective date
    getMinimumEffectiveDates(data) {
      // Create an empty object to store the minimum EffectiveDate for each ProductName
      const result = {};
    
      // Loop through the array of objects
      data.reduce((prev, current) => {
        // If the ProductName is not in the result object or the current EffectiveDate is less than the one in the result object, add/update the entry in the result object
        if (!result[current.productName] || Date.parse(current.EffectiveDate) < Date.parse(result[current.productName])) {
          result[current.productName] = current.EffectiveDate;
        }
      }, {});
    
      // Convert the result object into an array of objects with the format you specified
      return Object.keys(result).map(key => ({ productName: key, EffectiveDate: result[key] }));
    }   
    
    // method to make new array of object where have policy no.
    createNewArray(A, B) {			
			// create an empty array to hold the matched objects
      let matchedObjects = [];

      // iterate through each object in array B
      for(let i=0; i<B.length; i++) {
        // iterate through each object in array A
        for(let j=0; j<A.length; j++) {
          // check if phGLPolNo and ProductName match
          if(A[j].phGLPolNo === B[i].PolicyNumber && A[j].ProductName === B[i].PolicyProductName) {
            // push the matching object from arrayB into the new array
            matchedObjects.push(B[i]);
            // exit the inner loop, since we've found a match
            break;
          }
        }
      }
			return matchedObjects;
    }

    getlatestmodifybyobject(arr){
    const result = arr.reduce((acc, curr) => {
      const matchingObj = acc.find((obj) => obj.ProductNameInfo === curr.ProductNameInfo);
      if (matchingObj) {
        if (curr.LastModifiedDate > matchingObj.LastModifiedDate) {
          const index = acc.indexOf(matchingObj);
          acc[index] = curr;
        }
      } else {
        acc.push(curr);
      }
      return acc;
    }, []);

    return result;

    }
    
}