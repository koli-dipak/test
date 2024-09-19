import tmpl from './uploadFileDocument.html';
import { LightningElement, api ,track} from 'lwc';
import omniscriptFile from 'vlocity_ins/omniscriptFile';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";
//import OmniscriptAtomicElement from 'vlocity_ins/OmniscriptAtomicElement';
//import uploadFile from '@salesforce/apex/CTRL_UploadFileDocument.uploadFile'

export default class uploadFileDocument extends OmniscriptBaseMixin(omniscriptFile){ 

    @track showFile=true;
    get acceptedFormats() {
        return ['.xlsm'];
    }
    
    
    render(){
        return tmpl;
    }

    handleUploadFinished(event){
        super.handleUploadFinished(event);
         
         var Final = {};
         Final["validFileUploaded"] = false;
         this.showFile=true;
         var jsondata = JSON.parse(JSON.stringify(this.jsonData));
         if(jsondata["Upload Files"]!=undefined &&  jsondata["Upload Files"].FileUpload!=undefined ){
             if(( jsondata["Upload Files"].FileUpload.length + event.detail.files.length )==1){
                //Final["validFileUploaded"] = true;
               // this.showFile=false;
               this.enableNextButton();
             }
         }else{
            if(event.detail.files.length==1){
               // Final["validFileUploaded"] = true;
               // this.showFile=false;
               this.enableNextButton();
             }
         }

        // if(jsondata.Upload_Acord_130!=undefined && (jsondata.Upload_Acord_130.DocType == 'Acord 130' || jsondata.Upload_Acord_130.DocumentType == 'Acord 130' )){
        //     Final["IsAcord130Upload"]=true;
        // }
         this.omniApplyCallResp(Final);
        
        // console.log('test');
    }
    deleteFile(evt){
        super.deleteFile(evt);
        
        var Final = {};
         Final["validFileUploaded"] = false;
         this.showFile=true;
         var jsondata = JSON.parse(JSON.stringify(this.jsonData));
         if(jsondata["Upload Files"]!=undefined &&  jsondata["Upload Files"].FileUpload!=undefined ){
             if(( jsondata["Upload Files"].FileUpload.length - evt.detail )==1){
               // Final["validFileUploaded"] = true;
               // this.showFile=false;
               this.enableNextButton();
             }
         }

        // if(jsondata.Upload_Acord_130!=undefined && (jsondata.Upload_Acord_130.DocType == 'Acord 130' || jsondata.Upload_Acord_130.DocumentType == 'Acord 130' )){
        //     Final["IsAcord130Upload"]=true;
        // }
         this.omniApplyCallResp(Final);
        // var Final={}
        // var jsondata = JSON.parse(JSON.stringify(this.jsonData));

        // if(jsondata.Upload_Acord_130!=undefined && (jsondata.Upload_Acord_130.DocType == 'Acord 130' || jsondata.Upload_Acord_130.DocumentType == 'Acord 130' )){
        //     Final["IsAcord130Upload"]=false;
        // }
        // //Final["IsAcord130Upload"]=false;
        // this.omniApplyCallResp(Final);
        
    }

    enableNextButton(){
        var enableNext=function enableNextBtn(){
            if(this._value!=undefined && this._value.length==1){
            var Final = {};
            Final["validFileUploaded"] = true;
            this.showFile=false;
            this.omniApplyCallResp(Final);
            }else{
                setTimeout(enableNext,200);
            }
        }.bind(this);
        setTimeout(enableNext,200);
    }
}