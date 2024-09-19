import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";

export default class LobGlLoclPolFos extends OmniscriptBaseMixin(LightningElement) {
    @api isReadOnly=false;
    @api recordData;
    @api recordIndex;
    @api countryList;


    @track policyRecord;
    @track errorMessage=''
    @track exposureBaseOptions=[{"label":"Revenue/Sales","value":"ReVenue"},{"label":"Autos","value":"Autos"},{"label":"Payroll","value":"Payroll"},{"label":"Trips","value":"Trips"},{"label":"Locations","value":"Locations"},{"label":"Sq. Ft.","value":"Sqft"},{"label":"Other","value":"Other"}];
    @track disablePer = true;
    @track showExtTable=false;
    @track countryRec=[];

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
            this.exposureBaseOptions=[{"label":"Revenue/Sales","value":"ReVenue","isSelected":this.policyRecord["ExposureBaseData"]=="ReVenue"},{"label":"Autos","value":"Autos","isSelected":this.policyRecord["ExposureBaseData"]=="Autos"},{"label":"Payroll","value":"Payroll","isSelected":this.policyRecord["ExposureBaseData"]=="Payroll"},{"label":"Trips","value":"Trips","isSelected":this.policyRecord["ExposureBaseData"]=="Trips"},{"label":"Locations","value":"Locations","isSelected":this.policyRecord["ExposureBaseData"]=="Locations"},{"label":"Sq. Ft.","value":"Sqft","isSelected":this.policyRecord["ExposureBaseData"]=="Sqft"},{"label":"Other","value":"Other","isSelected":this.policyRecord["ExposureBaseData"]=="Other"}];

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
            if(this.policyRecord.extensions!=undefined && this.policyRecord.extensions.length > 0){
                this.showExtTable=true;
            }
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
        if(this.policyRecord["MinimumPremiumRequired"] != undefined && (parseFloat(event.currentTarget.value) < parseFloat(this.policyRecord["MinimumPremiumRequired"]))){
            this.errorMessage='ERROR-below minimum('+this.policyRecord["MinimumPremiumRequired"]+')';
        }else{
            this.errorMessage='';
            
        }
        this.policyRecord[event.currentTarget.name]=parseFloat(event.currentTarget.value);
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