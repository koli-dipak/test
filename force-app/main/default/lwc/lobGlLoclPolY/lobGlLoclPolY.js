import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";

export default class LobGlLoclPolY extends OmniscriptBaseMixin(LightningElement) {
    @api recordData;
    @api recordIndex;
    @api isReadOnly=false;
    @api countryList;


    @track errorMessage=''
    @track ELErrorMessage='';
    @track policyRecord;
    @track elOptions=[{"label":"YES","value":"Yes"},{"label":"NO","value":"No"}];
    @track otherExtOptions=[{"label":"YES","value":"Yes"},{"label":"NO","value":"No"}];
    @track exposureBaseOptions=[{"label":"Revenue/Sales","value":"ReVenue"},{"label":"Autos","value":"Autos"},{"label":"Payroll","value":"Payroll"},{"label":"Trips","value":"Trips"},{"label":"Locations","value":"Locations"},{"label":"Sq. Ft.","value":"Sqft"},{"label":"Other","value":"Other"}];
    @track hideEl='';
    @track disablePer = true;
 
    @track elLoadingDisabled=true;
    @track otherLoadingDisabled=true;
    @track showExtTable=false;
    @track showELRow=false;
    @track countryRec=[];
    @track defaultELExtensionData = {
				"extensionType" : "Employers Liability",
				"OccurenceLimit" : "Included",
				"AggregateLimit" : "Included",
				"Deductible" : "Included",
				"Premium" : "Included",
				"Other" : false,
				"IsEL":true
		}

    connectedCallback(){
        if(this.recordData!=undefined){
            this.policyRecord=JSON.parse(JSON.stringify(this.recordData));
            this.countryRec=JSON.parse(JSON.stringify(this.countryList));
            for(var i in this.countryRec){
                this.countryRec[i].isSelected=false;
                if(this.countryRec[i].value==this.policyRecord["AggregateCurrency"]){
                    this.countryRec[i].isSelected=true;
                }
            }
             this.policyRecord.displayAllocatedActualGLLocalPrem=(this.policyRecord.AllocatedActualGLLocalPrem!=undefined && this.policyRecord.AllocatedActualGLLocalPrem!="")?this.policyRecord.AllocatedActualGLLocalPrem.toFixed(0):null
            //above code is change due to new requirement N2GFCB353
            //this.policyRecord.displayAllocatedActualGLLocalPrem=(this.policyRecord.ActualGLLocalPremWithCommision!=undefined && this.policyRecord.ActualGLLocalPremWithCommision!="")?this.policyRecord.ActualGLLocalPremWithCommision.toFixed(0):null
            this.elOptions=[{"label":"YES","value":"Yes","isSelected":this.policyRecord["ELIncluded"]=='Yes'},{"label":"NO","value":"No","isSelected":this.policyRecord["ELIncluded"]=='No'}];
            this.otherExtOptions=[{"label":"YES","value":"Yes","isSelected":this.policyRecord["OtherLocalExtensionPFLIncluded"]=='Yes'},{"label":"NO","value":"No","isSelected":this.policyRecord["OtherLocalExtensionPFLIncluded"]=='No'}];
            this.exposureBaseOptions=[{"label":"Revenue/Sales","value":"ReVenue","isSelected":this.policyRecord["ExposureBaseData"]=="ReVenue"},{"label":"Autos","value":"Autos","isSelected":this.policyRecord["ExposureBaseData"]=="Autos"},{"label":"Payroll","value":"Payroll","isSelected":this.policyRecord["ExposureBaseData"]=="Payroll"},{"label":"Trips","value":"Trips","isSelected":this.policyRecord["ExposureBaseData"]=="Trips"},{"label":"Locations","value":"Locations","isSelected":this.policyRecord["ExposureBaseData"]=="Locations"},{"label":"Sq. Ft.","value":"Sqft","isSelected":this.policyRecord["ExposureBaseData"]=="Sqft"},{"label":"Other","value":"Other","isSelected":this.policyRecord["ExposureBaseData"]=="Other"}];

            if(this.policyRecord["LocalELIncluded"] == 'Included in GL'){
                this.hideEl = true;
            }else{
                this.hideEl = false;
            }

            if(this.policyRecord["UWOverrideGLLocalPrem"]!=undefined 
                && this.policyRecord["UWOverrideGLLocalPrem"]!=""){
                if(parseFloat(this.policyRecord["UWOverrideGLLocalPrem"])<this.policyRecord["MinimumPremiumRequired"]){
                    this.errorMessage='ERROR-below minimum('+this.policyRecord["MinimumPremiumRequired"]+')';
                }
            }else if (parseFloat(this.policyRecord["displayAllocatedActualGLLocalPrem"])<this.policyRecord["MinimumPremiumRequired"]){
                this.errorMessage='ERROR-below minimum('+this.policyRecord["MinimumPremiumRequired"]+')';
            }
            if(this.policyRecord["ExposureBaseData"] == "Other"){
                this.disablePer = false;
            }
            if(this.policyRecord["ELIncluded"]=='Yes'){
                this.elLoadingDisabled=false;
                this.showExtTable=true;
                this.showELRow=true;
								if(this.policyRecord.extensions!=undefined && this.policyRecord.extensions.length > 0){
										this.policyRecord.extensions[0].IsEL=true; 
										this.policyRecord.extensions[0].indexNo = -1;
                    this.policyRecord.extensions[0].CasualityLocalID =this.policyRecord.CasualityLocalID;
                    this.policyRecord.extensions[0].Country =this.policyRecord.Country
								}
            }
            if(this.policyRecord["OtherLocalExtensionPFLIncluded"]=='Yes'){
                this.otherLoadingDisabled=false;
            }
            if(this.policyRecord.extensions!=undefined && this.policyRecord.extensions.length > 0){
                this.showExtTable=true;
            }

            // if(this.policyRecord.extensions!=undefined){
            //     for(let x in this.policyRecord.extensions){
            //         this.policyRecord.extensions[x].showOtherExtvalue = this.policyRecord.extensions[x].extensionType=='Other'&&(this.policyRecord.extensions[x].Other!=undefined || this.policyRecord.extensions[x].Other!='')?true:false;
            //     }
            // }
        }
        

    }
    // send selected lookup record to parent component using custom event
    updatehandler(value){    
        const oEvent = new CustomEvent('dataupdate',
        {
            'detail': {recordData: this.policyRecord,recordIndex : this.recordIndex}
        }
    );
    this.dispatchEvent(oEvent);
    }
    changeHandler(event){
        this.policyRecord[event.currentTarget.name]=event.currentTarget.value;
        // this.updatehandler();
        console.log("currentTargetName",this.policyRecord);
        if(this.policyRecord[event.currentTarget.name]=="Payroll" || this.policyRecord[event.currentTarget.name]=="Sqft"){
            this.policyRecord["Per"] = 100; 
            this.disablePer = true;
        }else if(this.policyRecord[event.currentTarget.name]=="ReVenue"){
            this.policyRecord["Per"] = 1000; 
            this.disablePer = true;
        }else if(this.policyRecord[event.currentTarget.name]=="Autos" || this.policyRecord[event.currentTarget.name]=="Trips" || this.policyRecord[event.currentTarget.name]=="Locations"){
            this.policyRecord["Per"] = 1; 
            this.disablePer = true;
        }else if(this.policyRecord[event.currentTarget.name]=="Other"){
            this.policyRecord["Per"] = ""; 
            this.disablePer = false;
        }
        this.updatehandler();
    }
    changeLoadingHandler(event){
        this.policyRecord[event.currentTarget.name]=parseFloat(event.currentTarget.value);
        this.updatehandler();
    }
    actualChangeLoadingHandler(event){
        if(event.currentTarget.value==null || event.currentTarget.value==''){
            this.errorMessage='';
            if (parseFloat(this.policyRecord["displayAllocatedActualGLLocalPrem"])<this.policyRecord["MinimumPremiumRequired"]){
                this.errorMessage='ERROR-below minimum('+this.policyRecord["MinimumPremiumRequired"]+')';
            }
            this.policyRecord[event.currentTarget.name]=(event.currentTarget.value);
            this.updatehandler();
            return;
        }
        if((event.currentTarget.value<this.policyRecord["MinimumPremiumRequired"])){
            this.errorMessage='ERROR-below minimum('+this.policyRecord["MinimumPremiumRequired"]+')';
        }else{
            this.errorMessage='';
            this.policyRecord[event.currentTarget.name]=parseFloat(event.currentTarget.value);
            this.updatehandler();
        }
        
    }
    actualELChangeLoadingHandler(event){
        if(event.currentTarget.value==null || event.currentTarget.value==''){
            this.ELErrorMessage='';
            this.policyRecord[event.currentTarget.name]=(event.currentTarget.value);
            this.updatehandler();
            return;
        }
        
        if(this.policyRecord["LocalELMinimumPremiumRequired"] != undefined && (parseFloat(event.currentTarget.value) < parseFloat(this.policyRecord["LocalELMinimumPremiumRequired"]))){
            this.ELErrorMessage='ERROR-below minimum('+this.policyRecord["LocalELMinimumPremiumRequired"]+')';
        }else{
            this.ELErrorMessage='';
            if(this.policyRecord["LocalELMinimumPremiumRequired"]==undefined){
                this.ELErrorMessage='ERROR-Local EL actual premium';
            }
           
        }
        this.policyRecord[event.currentTarget.name]=parseFloat(event.currentTarget.value);
        this.updatehandler();
        
    }
    elIncludechangeHandler(event){
				
        if(event.currentTarget.value=='Yes'){
            this.policyRecord['ELLoding']=this.policyRecord['ELLodingDefault'];
            this.elLoadingDisabled=false;
            this.showELRow=true;
            this.showExtTable=true;
						if(this.policyRecord.extensions==undefined ){
								this.policyRecord.extensions=[];
						}
						this.defaultELExtensionData.indexNo = -1;
						this.defaultELExtensionData.CasualityLocalID =this.policyRecord.CasualityLocalID;
						this.defaultELExtensionData.Country =this.policyRecord.Country
						this.policyRecord.extensions.splice(0, 0, this.defaultELExtensionData);
        }else{
            this.policyRecord['ELLoding']=0;
            this.elLoadingDisabled=true;
            this.showELRow=false;
            this.showExtTable=false;
						if(this.policyRecord.extensions!=undefined && this.policyRecord.extensions.length > 0 && this.policyRecord.extensions[0].IsEL==true){
								this.policyRecord.extensions.splice(0, 1);
						}
            if(this.policyRecord.extensions!=undefined && this.policyRecord.extensions.length > 0){
                this.showExtTable=true;
            }
        }
        this.policyRecord[event.currentTarget.name]=event.currentTarget.value;
        this.policyRecord=JSON.parse(JSON.stringify(this.policyRecord));
        this.updatehandler();
    }
    otherExtensionchangeHandler(event){
        if(event.currentTarget.value=='Yes'){
            this.policyRecord['Otherlocalextensionloading']=this.policyRecord['OtherlocalextensionloadingDefault'];
            this.otherLoadingDisabled=false;
        }else{
            this.policyRecord['Otherlocalextensionloading']=0;
            this.otherLoadingDisabled=true;

        }
        this.policyRecord[event.currentTarget.name]=event.currentTarget.value;
        this.policyRecord=JSON.parse(JSON.stringify(this.policyRecord));
        this.updatehandler();
    }
    aggregateLimitChangeHandler(event){
        this.policyRecord[event.currentTarget.name]=event.currentTarget.value;
        this.updatehandler();
    }


    deleteRows(event){
        console.log('@@event',event.target.dataset.index)
        var indx=parseInt(event.target.dataset.index);
     
        var data=JSON.parse(JSON.stringify(this.policyRecord.extensions));
        data.splice(indx, 1);
        this.policyRecord.extensions=JSON.parse(JSON.stringify(data));
        if(this.policyRecord.extensions!=undefined && this.policyRecord.extensions.length > 0){
            this.showExtTable=true;
        }
        this.updatehandler();
    }

    EditRows(event){
        console.log('@@event',event.target.dataset.index)
        var indx=parseInt(event.target.dataset.index);

        var data=JSON.parse(JSON.stringify(this.policyRecord.extensions[indx]));
        data.type=this.policyRecord.type;
        const oEvent = new CustomEvent('extensioneditclick',
        {
            'detail': {"extensionRecord": data}
        }
        );
        this.dispatchEvent(oEvent);

    }

}