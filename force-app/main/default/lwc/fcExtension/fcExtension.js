import { api, LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";

export default class FcExtension extends OmniscriptBaseMixin(LightningElement) {
    @track openSelecteOptionMenu;
    @track value = 'option2';
    @track AddExt;
    @track UpdateExt;
    @api countryData;
    @track country = {};
    @track showExtToInsertData;
    @track recordIndex;
    @track extensionType =[];
    @track selectedExtension;
    @track Aggregate_Limit;
    @track Occurence_Limit;
    @track Deductible;
    @track Premium;
    @track updateSuccess;
    @track isBtnDisable = true;
    @track extensionData = {};
    @track updateSuccessUpdatePage = false;
    @api extensionRecord;
    @api addExtSection;
    @api updateBtnClick;
    @track errorMessage = '';
    @track displayPrem;
    @track errorIndexMatch;
    @track noChckbx = [];
    @track isUpdateBtnDisable = false;
    @track isOtherExtType = false;
    @track otherExtValue;

    @api countryList;
    @track countryRec=[];


    get options() {
        return [
            { label: 'Add Local Extension', value: 'option1'},
            { label: 'Update Aggregate Limit & Actual premium', value: 'option2' }
        ];
    }

    changeHandler(event){
        this.value = event.target.value;
        console.log("#Thevalue", this.value)
    }

    handleNextClick(){
        this.openSelecteOptionMenu = false;
        if(this.value == "option1"){
            this.AddExt = true;
            this.UpdateExt = false;
        }else {
            this.UpdateExt = true;
            this.AddExt = false;
        }
    }

    connectedCallback(){
        // 
        //this.template.querySelector('lightning-combobox[data-id="ExtField"]');
        // 
        this.openSelecteOptionMenu = this.updateBtnClick;
        // if(this.addExtSection == true && this.extensionRecord!=undefined){
        //     this.selectedExtension = extensionList.includes(this.extensionRecord.extensionType)?this.extensionRecord.extensionType:'Other';
        //     this.Occurence_Limit = this.extensionRecord.OccurenceLimit;
        //     this.Aggregate_Limit = this.extensionRecord.AggregateLimit;
        //     this.Deductible = this.extensionRecord.Deductible;
        //     this.Premium = this.extensionRecord.Premium;
        //     this.otherExtValue = this.extensionRecord.Other;
        // }
        
        // if(this.selectedExtension == 'Other'){
        //     this.isOtherExtType = true;
        // }else {
        //     this.isOtherExtType = false;
        // }
        this.countryRec=JSON.parse(JSON.stringify(this.countryList));
        
        if(this.countryData != undefined){
            this.country = JSON.parse(JSON.stringify(this.countryData));
            for(var i in this.country){
                this.country[i].displayPrem = parseFloat(this.country[i].displayPrem).toFixed(0);
                if(this.country[i].AggregateCurrency==undefined || this.country[i].AggregateCurrency==""){
                    this.country[i].AggregateCurrency="USD";
                }
                if(this.country[i].type=='GL'){
                   // this.country[i].displayActualPrem=(this.country[i].AllocatedActualGLLocalPrem!=undefined && this.country[i].AllocatedActualGLLocalPrem!="")?this.country[i].AllocatedActualGLLocalPrem.toFixed(0):null
                    this.country[i].displayMinPrem=(this.country[i].MinimumPremiumRequired!=undefined && this.country[i].MinimumPremiumRequired!="")?parseFloat(""+this.country[i].MinimumPremiumRequired).toFixed(0):null
                    if(this.country[i].LobDicDil==false){
                        
                    }
                }else{
                  //  this.country[i].displayActualPrem=(this.country[i].LocalELTechnicalpremium!=undefined && this.country[i].LocalELTechnicalpremium!="")?this.country[i].LocalELTechnicalpremium.toFixed(0):null
                    this.country[i].displayMinPrem=(this.country[i].SepELPolMinPre!=undefined && this.country[i].SepELPolMinPre!="")?parseFloat(""+this.country[i].SepELPolMinPre).toFixed(0):null
                    if(this.country[i].LocalELActualPrem != undefined && this.country[i].type=='EL'){
                        this.country[i].UWOverrideGLLocalPrem = this.country[i].LocalELActualPrem;
                    }
                }
                
            }
        }

        var extensionList;
        const params = {
            input: JSON.stringify({}),
            sClassName: 'FcLocalExtension',
            sMethodName: 'getDefaultData',
            options: '{}'
        };
        this.omniRemoteCall(params, true).then((response) => {
            console.log("respone", JSON.stringify((response)))
            var data = response.result.ExtensionTypeList;
            extensionList = response.result.ExtensionTypeList;
            if(this.addExtSection == true && this.extensionRecord!=undefined){
                if(extensionList != undefined){
                    // for(let x in extensionList){
                    //    if(extensionList[x] != this.selectedExtension){
                    //        this.isOtherExtType = true;
                    //    }else {
                    //        this.isOtherExtType = false;
                    //    }
                    // 
                    // this.isOtherExtType = !extensionList.includes(this.selectedExtension);
                    // this.isOtherExtType = !extensionList.includes(this.extensionRecord.extensionType);
                    this.isOtherExtType = this.extensionRecord.extensionType=='Other'?true:false;
                }
            }
            
            for(const item of data){
                const option = {
                    label: item, value: item
                }
                this.extensionType = [...this.extensionType,option];
            }
            console.log('response:: ', this.extensionType[0]);

            if(this.addExtSection == true && this.extensionRecord!=undefined){
                // this.selectedExtension = extensionList.includes(this.extensionRecord.extensionType)?this.extensionRecord.extensionType:'Other';
                this.selectedExtension = this.extensionRecord.extensionType;
                this.Occurence_Limit = this.extensionRecord.OccurenceLimit;
                this.Aggregate_Limit = this.extensionRecord.AggregateLimit;
                this.Deductible = this.extensionRecord.Deductible;
                this.Premium = this.extensionRecord.Premium;
                this.otherExtValue = this.extensionRecord.Other;
            }
            
        
        }).catch((error) => {
            console.log('error:: ', error);
            this.error = error;
         });

    }

    handleSelectCountry(event){
        // console.log("currentIndex", event.target.dataset.index);
        // console.log("currentRecord", event.target.dataset.allcountry);
        this.recordIndex = parseInt(event.target.dataset.index);
        const index = parseInt(event.target.dataset.index);
        const countryVal = event.target.dataset.country;
        let countryType= this.country[index].type;
        console.log("countryVal", countryVal);
        // this.country[index].SelectedExtCountry = true;
        //this.updatehandler();

        // var btndsply = 1
        // this.isBtnDisable = true;
        // for(var i in this.country){
        //     if(this.country[i].SelectedExtCountry == true){
        //         this.isBtnDisable = false;
        //     }
        // }

       ////////////////////////////////////////////////////

      let currentIndex;
      for (let x in this.country) {
        let data= this.country[x];
        
        if(data.Country == countryVal && data.type == countryType){
            currentIndex=x;
            data.SelectedExtCountry = data.SelectedExtCountry==undefined?true:(!data.SelectedExtCountry)
            console.log("data.SelectedExtCountry",data.SelectedExtCountry)
            data.SelectedExtCountry==true?this.noChckbx.push(true):this.noChckbx.pop();
            console.log("noChckbx",this.noChckbx);
            //   if (data.SelectedExtCountry == true) {
            //     noChckbx++
            //   } else {
            //     noChckbx--
            //   }
            }
        }
        this.noChckbx.length == 0?this.isBtnDisable=true:this.isBtnDisable=false;
        console.log("noChckbx.length",this.noChckbx.length)
        console.log("this.isBtnDisable",this.isBtnDisable)
       ////////////////////////////////////////////////////

        // var selectedRecords =  this.template.querySelector("lightning-input");
        // console.log(selectedRecords);
        // if(selectedRecords.length > 0){
        //     this.isBtnDisable = true;
        // }else{
        //     this.isBtnDisable = false;
        // }
        

    }

    handleAddExtNextClick(){
        this.AddExt = false;
        this.showExtToInsertData = true;
        this.isBtnDisable = true;
    }

 

    changeHandleUpdate(event){
        this.recordIndex = parseInt(event.target.dataset.index);
        // const index = parseInt(event.target.dataset.index);
        this.country[this.recordIndex][event.target.name] = event.target.value;
        this.country[this.recordIndex]["valueChange"] = true;
        
        if(event.target.name=="UWOverrideGLLocalPrem"){
            if(this.country[this.recordIndex].type=="EL"){
                this.country[this.recordIndex]["LocalELActualPrem"] = event.target.value;
            }
            if(this.country[this.recordIndex]["MinimumPremiumRequired"] != undefined && (parseFloat(event.currentTarget.value) < parseFloat(this.country[this.recordIndex]["MinimumPremiumRequired"]))){
                if(event.currentTarget.value != ''){
                    this.country[this.recordIndex].errorMessage ='ERROR-below minimum('+this.country[this.recordIndex]["MinimumPremiumRequired"]+')';
                    this.isUpdateBtnDisable = true;
                }else{
                    this.country[this.recordIndex].errorMessage = '';
                    this.isUpdateBtnDisable = false;
                }
            }else{
                this.country[this.recordIndex].errorMessage = '';
                this.isUpdateBtnDisable = false;
            }
            this.country = JSON.parse(JSON.stringify(this.country));
            //this.updatehandler();
        }
    }

    handleUpdateExtClick(){
        for(let x in this.country){
            if(this.country[x].valueChange == true){
                this.country[x].show=false;
                this.country[x].icnNm= 'utility:right';
            }
        }
        this.UpdateExt = false;
        this.updateSuccessUpdatePage = true;
        this.updatehandler();
       // this.handleCloseClick();
    }

    handlePicklist(event){
        this.selectedExtension = String(event.detail.value);
        if(this.selectedExtension == "Other"){
            this.isOtherExtType = true;
        }else {
            this.isOtherExtType = false;
        }
    }

    handleOther(event){
        this.otherExtValue = String(event.target.value);
        // if(this.selectedExtension == 'Other' && this.otherExtValue != undefined){
        //     this.selectedExtension = this.otherExtValue;
        // }
    }

    handleDeductible(event){
        this.Deductible = event.target.value;
    }

    handlePremium(event){
        this.Premium = event.target.value;
    }
    handleOccurenceLim(event){
        this.Occurence_Limit = event.target.value;
    }
    handleAggregateLim(event){
        this.Aggregate_Limit = event.target.value;
    }

    // handleAddExtChange(event){
    //     this.extensionData.push( event.target.name,':' , event.target.value )
    //     console.log("extensionData",this.extensionData);
    //     if(this.extensionData.LclExt_Premium){
    //         this.isBtnDisable = false;
    //     }
    // }

    handleInsertAddExtNextClick(){
        // let element = this.template.querySelector('lightning-input[data-id="ExtField"]');
        // element.reportValidity();
        

        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                 isValid = false;
            }
            // this.contact[inputField.name] = inputField.value;
        });
        if(!isValid) return;
        // return isValid;

        // if(this.selectedExtension == 'Other' && this.otherExtValue != undefined){
        //     this.selectedExtension = this.otherExtValue;
        // }
        
        if(this.selectedExtension == null || this.Occurence_Limit == "" || this.Aggregate_Limit == ""  ||  this.Deductible == "" || this.Premium == ""){
            return;
        }

        // for (const el of document.getElementById('ExtField').querySelectorAll("[required]")) {
        //     if (!el.reportValidity()) {
        //      return;
        //     }
        //   }
        if(this.Premium != null && this.extensionType != null && this.Occurence_Limit != null && this.Aggregate_Limit != null && this.Deductible != null ){
        var extensionData = {
            "extensionType" : this.selectedExtension,
            "OccurenceLimit" : this.Occurence_Limit,
            "AggregateLimit" : this.Aggregate_Limit,
            "Deductible" : this.Deductible,
            "Premium" : this.Premium,
            "Other" : this.otherExtValue
        }
        if(this.country != undefined){
            for(let x in this.country){
                // this.country.show=false;
                // this.country.icnNm= 'utility:right';
                if(this.country[x].SelectedExtCountry == true){
                    this.country[x].show=false;
                    this.country[x].icnNm= 'utility:right';
                    this.recordIndex = x;
                    if(this.country[x].extensions==undefined){
                        this.country[x].extensions=[];
                    }
                    extensionData.indexNo = this.country[x].extensions.length+1;
                    extensionData.CasualityLocalID = this.country[x].CasualityLocalID;
                    extensionData.Country = this.country[x].Country
                    extensionData.showOtherExtvalue = this.selectedExtension=='Other'&&(this.otherExtValue!=undefined || this.otherExtValue!='')?true:false;
                    this.country[x].extensions.push(JSON.parse(JSON.stringify(extensionData)));
                    //this.updatehandler();
                }
                this.country[x].SelectedExtCountry=false;
            }
           
        }
            this.country = JSON.parse(JSON.stringify(this.country));
            this.showExtToInsertData = false;
            this.updateSuccess = true;
            this.updatehandler();
           // this.handleCloseClick();
        }
       
       
    }
    handleInsertEditExtNextClick(){

        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                 isValid = false;
            }
            // this.contact[inputField.name] = inputField.value;
        });
        if(!isValid) return;
        
        // if(this.selectedExtension == 'Other' && this.otherExtValue != undefined){
        //     this.selectedExtension = this.otherExtValue;
        // }

        if(this.selectedExtension == null || this.Occurence_Limit == "" || this.Aggregate_Limit == ""  ||  this.Deductible == "" || this.Premium == ""){
            return;
        }
        
        if(this.Premium != "" && this.extensionType != "" && this.Occurence_Limit != "" && this.Aggregate_Limit != "" && this.Deductible != "" ){
            if(this.country != undefined){
                for(let x in this.country){
                    for(let y in this.country[x].extensions){
                        if(this.country[x].extensions[y].indexNo == this.extensionRecord.indexNo && this.country[x].extensions[y].Country == this.extensionRecord.Country && this.country[x].type == this.extensionRecord.type){
                            this.country[x].show=false;
                            this.country[x].icnNm= 'utility:right';
                            this.country[x].extensions[y].extensionType=this.selectedExtension;
                            this.country[x].extensions[y].OccurenceLimit=this.Occurence_Limit;
                            this.country[x].extensions[y].AggregateLimit=this.Aggregate_Limit;
                            this.country[x].extensions[y].Deductible=this.Deductible;
                            this.country[x].extensions[y].Premium=this.Premium;
                            this.country[x].extensions[y].Other= this.otherExtValue;
                            this.country[x].extensions[y].showOtherExtvalue = this.selectedExtension=='Other'&&(this.otherExtValue!=undefined || this.otherExtValue!='')?true:false;
                        }
                    }
                    
                }
            }
            this.addExtSection = false;
            this.updateSuccess = true;
            this.updatehandler();
         //   this.handleCloseClick();
        }
    }

    handleCloseClick(){
        const closeEvent = new CustomEvent('closehandle',
            {
                'detail' : {isCloseClick : true}
            }
        );
        this.dispatchEvent(closeEvent);
    }

    updatehandler(value){    
        /*const oEvent = new CustomEvent('extdataupdate',
        {
            'detail': {recordData: this.country[this.recordIndex], recordIndex : this.recordIndex}
        }*/
        const oEvent = new CustomEvent('extdataupdate',
        {
            'detail': {recordData: this.country}
        }
    );
    this.dispatchEvent(oEvent);
}
}