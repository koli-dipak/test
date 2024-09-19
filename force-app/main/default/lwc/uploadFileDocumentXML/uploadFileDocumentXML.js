import tmpl from './uploadFileDocumentXML.html';
import { LightningElement, api ,track} from 'lwc';
import omniscriptFile from 'vlocity_ins/omniscriptFile';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";
//import OmniscriptAtomicElement from 'vlocity_ins/OmniscriptAtomicElement';
//import uploadFile from '@salesforce/apex/CTRL_UploadFileDocument.uploadFile'

export default class UploadFileDocumentXML extends OmniscriptBaseMixin(omniscriptFile){ 

    @track showFile=true;
    @track filemorethanone=true;
    get acceptedFormats() {
        return ['.xml'];
    }
    
    
    render(){
        return tmpl;
    }

    handleUploadFinished(event){
        super.handleUploadFinished(event);
         
         var Final = {};
         Final["validFileUploaded"] = false;
        this.filemorethanone = Final["validFileUploaded"];

         this.showFile=true;
         var jsondata = JSON.parse(JSON.stringify(this.jsonData));
         if(jsondata["FileUploadScreen"]!=undefined &&  jsondata["FileUploadScreen"].UploadDocument!=undefined ){
             if(( jsondata["FileUploadScreen"].UploadDocument.length + event.detail.files.length )==1){
                //Final["validFileUploaded"] = true;
               // this.showFile=false;
               this.enableNextButton();
               console.log('----->1'+this.filemorethanone);
             }
         }else{
            if(event.detail.files.length==1){
              //  Final["validFileUploaded"] = true;
               // this.showFile=false;
               this.enableNextButton();
               console.log('----->2'+this.filemorethanone);
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
        this.filemorethanone = Final["validFileUploaded"];

         this.showFile=true;
         var jsondata = JSON.parse(JSON.stringify(this.jsonData));
         if(jsondata["FileUploadScreen"]!=undefined &&  jsondata["FileUploadScreen"].UploadDocument!=undefined ){
             if(( jsondata["FileUploadScreen"].UploadDocument.length - evt.detail )==1){
               // Final["validFileUploaded"] = true;
               // this.showFile=false;
               this.enableNextButton();
               console.log('----->5'+this.filemorethanone);
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
            this.filemorethanone = Final["validFileUploaded"];
            this.showFile=false;
            console.log('----->6'+this.filemorethanone);
            this.omniApplyCallResp(Final);
            }else{
                setTimeout(enableNext,200);
            }
        }.bind(this);
        setTimeout(enableNext,200);
    }
}