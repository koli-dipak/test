import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";

export default class LobGlLoclPolFos extends OmniscriptBaseMixin(LightningElement) {
    @api recordData;
    @api isReadOnly=false;
    @api countryList;

    @api recordIndex;
    @track policyRecord;
    @track recordApi;
    @track errorMessage;
    @api minimumPremium;
    @track showExtTable=false;

    @track exposureBaseOptions=[{"label":"Revenue/Sales","value":"ReVenue"},{"label":"Autos","value":"Autos"},{"label":"Payroll","value":"Payroll"},{"label":"Trips","value":"Trips"},{"label":"Locations","value":"Locations"},{"label":"Sq. Ft.","value":"Sqft"},{"label":"Other","value":"Other"}];
    @track disablePer = true;
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
            /*if(this.policyRecord["ExposureBaseData"]==undefined || this.policyRecord["ExposureBaseData"]==""){
                this.policyRecord["ExposureBaseData"]="Payroll";
                this.policyRecord["Per"] = 100; 
            }*/
            //this.policyRecord.displayLocalELTechnicalpremium=(this.policyRecord.LocalELTechnicalpremium!=undefined && this.policyRecord.LocalELTechnicalpremium!="")?this.policyRecord.LocalELTechnicalpremium.toFixed(0):null
            //above code is change due to N2GFCB354
            this.policyRecord.displayLocalELTechnicalpremium=(this.policyRecord.LocalELTechnicalGrossOfComm!=undefined && this.policyRecord.LocalELTechnicalGrossOfComm!="")?this.policyRecord.LocalELTechnicalGrossOfComm.toFixed(0):null

            this.exposureBaseOptions=[{"label":"Revenue/Sales","value":"ReVenue","isSelected":this.policyRecord["ExposureBaseData"]=="ReVenue"},{"label":"Autos","value":"Autos","isSelected":this.policyRecord["ExposureBaseData"]=="Autos"},{"label":"Payroll","value":"Payroll","isSelected":this.policyRecord["ExposureBaseData"]=="Payroll"},{"label":"Trips","value":"Trips","isSelected":this.policyRecord["ExposureBaseData"]=="Trips"},{"label":"Locations","value":"Locations","isSelected":this.policyRecord["ExposureBaseData"]=="Locations"},{"label":"Sq. Ft.","value":"Sqft","isSelected":this.policyRecord["ExposureBaseData"]=="Sqft"},{"label":"Other","value":"Other","isSelected":this.policyRecord["ExposureBaseData"]=="Other"}];

            if(this.policyRecord["ExposureBaseData"] == "Other"){
                this.disablePer = false;
            }
            if(this.policyRecord.extensions!=undefined && this.policyRecord.extensions.length > 0){
                this.showExtTable=true;
            }
            
            if(this.policyRecord["LocalELActualPrem"]!=undefined 
                && this.policyRecord["LocalELActualPrem"]!="" ){
                if(parseFloat(this.policyRecord["LocalELActualPrem"])<this.minimumPremium){
                    this.errorMessage='ERROR-below minimum('+this.minimumPremium+')';
                }
            }else if (parseFloat(this.policyRecord["displayLocalELTechnicalpremium"])<this.minimumPremium){
                this.errorMessage='ERROR-below minimum('+this.minimumPremium+')';
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
    elIncludechangeHandler(event){
        if(event.currentTarget.value=='Yes'){
            this.policyRecord['ELLoding']=this.policyRecord['ELLodingDefault'];
        }else{
            this.policyRecord['ELLoding']=0;
        }
        this.policyRecord[event.currentTarget.name]=event.currentTarget.value;
        this.policyRecord=JSON.parse(JSON.stringify(this.policyRecord));
        this.updatehandler();
    }
   
    actualELChangeLoadingHandler(event){
      
        if(event.currentTarget.value==null || event.currentTarget.value==''){
            this.errorMessage='';
            if (parseFloat(this.policyRecord["displayLocalELTechnicalpremium"])<this.minimumPremium){
                this.errorMessage='ERROR-below minimum('+this.minimumPremium+')';
            }
            this.policyRecord[event.currentTarget.name]=(event.currentTarget.value);
            this.updatehandler();
            return;
        }

        if(this.minimumPremium != undefined && (parseFloat(event.currentTarget.value) < parseFloat(this.minimumPremium))){
            this.errorMessage='ERROR-below minimum('+this.minimumPremium+')';
        }else{
            this.errorMessage='';
            if(this.minimumPremium==undefined){
                this.errorMessage='ERROR-Local EL actual premium';
            }
            
        }
        this.policyRecord[event.currentTarget.name]=parseFloat(event.currentTarget.value);
            this.updatehandler();
        
    }
    otherExtensionchangeHandler(event){
        if(event.currentTarget.value=='Yes'){
            this.policyRecord['Otherlocalextensionloading']=this.policyRecord['OtherlocalextensionloadingDefault'];
        }else{
            this.policyRecord['Otherlocalextensionloading']=0;
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