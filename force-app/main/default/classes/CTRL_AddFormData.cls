/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-27-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class CTRL_AddFormData implements vlocity_ins.VlocityOpenInterface {
    // implements vlocity_ins.VlocityOpenInterface
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        if (methodName.equals('getFormsDet')) {
            getFormsDet(inputMap, outMap);
        }
         else if(methodName.equals('getDefaultForms')){
             getDefaultForms(inputMap, outMap);
         }
         else if(methodName.equals('dltPrevForms')){
            dltPrevForms(inputMap, outMap);
         }
         else if(methodName.equals('dltPrevExtensions')){
            dltPrevExtensions(inputMap, outMap);
         }
         else if(methodName.equals('getContentDocumentLinks')){
            getContentDocumentLinks(inputMap, outMap);
         }
        return true;
    }
    
    @AuraEnabled
    public static void getFormsDet(Map < String, Object > inputMap, Map < String, Object > outMap) {
        System.debug('@@getInputFromForm@@'+inputMap.keySet());
        String CurrentLob = (String)inputMap.get('CurrentLob');
        List<string> temp = new List<string>();
        temp.add(CurrentLob);
        //temp.add('Common');
        Map<Id,FC_Reference_Form__c> FCFormRecords = new Map<Id,FC_Reference_Form__c>([SELECT Id, Form_Name__c, Form_Name_ID__c, Form_Type__c, LOB_CODE__c, Number__c, Order__c, Symbol__c, Edition__c,Mandatory__c, Default__c FROM FC_Reference_Form__c WHERE LOB_CODE__c IN : temp ORDER BY Order__c]);
        // Map<Id,FC_Reference_Form__c> FCFormRecords = new Map<Id,FC_Reference_Form__c>([SELECT Id, Form_Name__c, Form_Name_ID__c, Form_Type__c, LOB_CODE__c, Number__c, Order__c, Symbol__c, Edition__c FROM FC_Reference_Form__c ORDER BY Form_Name__c]);
        outMap.put('Success',JSON.serialize(FCFormRecords.values()));

        Map<String,String> FormWiseDocMap=new Map<String,String>();
        if(FCFormRecords.keySet().size()>0){
            for(ContentDocumentLink Doc : [SELECT ID,LinkedEntityId,ContentDocumentId From ContentDocumentLink Where LinkedEntityId IN :FCFormRecords.keySet()]){
                FormWiseDocMap.put(Doc.LinkedEntityId,Doc.ContentDocumentId);
            }
        }
        
        outMap.put('DocumentLinks',JSON.serialize(FormWiseDocMap));

        System.debug('@@@'+JSON.serialize(FCFormRecords));
    }

    // @AuraEnabled(cacheable=true)
    // public static void getContentDocumentId(Map < String, Object > inputMap, Map < String, Object > outMap) {
    //      // List<Fc_Form__c> ListId = [SELECT Id FROM FC_Form__c];
    //      string selectedId = String.valueOf(inputMap.get('selectedForm'));
    //      List<ContentDocumentLink> files = [SELECT Id,ContentDocumentId,ContentDocument.Title  FROM ContentDocumentLink  WHERE LinkedEntityId =: selectedId];
    //      List<Id> fileIDs  = new List<Id>();
    //      for(ContentDocumentLink docLink : files){
    //          fileIDs.add(docLink.ContentDocumentId);
    //      }
    //      // for(ContentDocumentLink content : [SELECT Id,ContentDocumentId,ContentDocument.Title, LinkedEntityId  FROM ContentDocumentLink  WHERE LinkedEntityId in: ListOfId]){
    //      //     contentId.add(content);
    //      // }
    //      outMap.put('Successed',JSON.serialize(fileIDs));
    //      System.debug('test'+fileIDs);
    //      System.debug('tet'+files);
    // }
    @AuraEnabled
    public static void getDefaultForms(Map < String, Object > inputMap, Map < String, Object > outMap) {
        Map<String,List<FC_Reference_Form__c>> LobWiseReferenceForm=new Map<String,List<FC_Reference_Form__c>>();
        List<String> formIDs=new List<String>();
        for(FC_Reference_Form__c RF : [SELECT Id, Form_Name__c, Form_Name_ID__c, Form_Type__c, LOB_CODE__c, Number__c, Order__c, Symbol__c, Edition__c,Mandatory__c, Default__c FROM FC_Reference_Form__c WHERE Default__c = true and LOB_CODE__c !=null  ORDER BY Order__c]){
            if(!LobWiseReferenceForm.containsKey(RF.LOB_CODE__c)){
                LobWiseReferenceForm.put(RF.LOB_CODE__c,new List<FC_Reference_Form__c>());
            }
            LobWiseReferenceForm.get(RF.LOB_CODE__c).add(RF);
            formIDs.add(RF.Id);
        }
        System.debug('@@Lob'+LobWiseReferenceForm.size());
       
        Map<String,String> FormWiseDocMap=new Map<String,String>();
        if(formIDs.size()>0){
            for(ContentDocumentLink Doc : [SELECT ID,LinkedEntityId,ContentDocumentId From ContentDocumentLink Where LinkedEntityId IN :formIDs]){
                FormWiseDocMap.put(Doc.LinkedEntityId,Doc.ContentDocumentId);
                //System.debug(formIDs);
            }
        }
        outMap.put('DefaultFormDocumentLinks',JSON.serialize(FormWiseDocMap));
        outMap.put('DefaultForms',JSON.serialize(LobWiseReferenceForm));

        
    }
    @AuraEnabled
    public static void dltPrevForms(Map < String, Object > inputMap, Map < String, Object > outMap){
        System.debug('@@getInputFromForm@@'+inputMap.get('ApplicationID'));
        String ApplicationId = (String)inputMap.get('ApplicationID');
        List<FC_Form__c> FormList = [select Id from FC_Form__c where FC_Coverage__r.Casualty_Premium__r.Application__c  =: ApplicationId or Application__c=:ApplicationId];
		DELETE FormList;
        List<FC_Exposure__c> ExposureList = [select Id from FC_Exposure__c where FC_Coverage__r.Casualty_Premium__r.Application__c  =: ApplicationId];
		DELETE ExposureList;
    }
     @AuraEnabled
    public static void dltPrevExtensions(Map < String, Object > inputMap, Map < String, Object > outMap){
        System.debug('@@getInputFromForm@@'+inputMap.get('ApplicationID'));
        String ApplicationId = (String)inputMap.get('ApplicationID');
        List<FC_Casualty_Local_Extention__c> ExtensionList = [select Id from FC_Casualty_Local_Extention__c where FC_Casualty_Local__r.FC_Casualty_Premium__r.Application__c =: ApplicationId];
        DELETE ExtensionList;
    }
    @AuraEnabled
    public static void getContentDocumentLinks(Map < String, Object > inputMap, Map < String, Object > outMap) {
        String ApplicationId = (String)inputMap.get('ApplicationID');
        set<String> FormList = new set<String>();
        for(FC_Form__c form: [select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Form_Name__c, Form_Type__c, LOB__c, LOB_CODE__c, Symbol__c, Number__c, Order__c, Form_Name_ID__c, FC_Coverage__c,  Edition__c, Index__c, FC_Reference_Form__c from FC_Form__c where FC_Coverage__r.Casualty_Premium__r.Application__c  =: ApplicationId or Application__c=:ApplicationId]){
            FormList.add(form.FC_Reference_Form__c);
        }
        system.debug('@@FormList'+FormList.size());
        Map<String,String> FormWiseDocMap=new Map<String,String>();
        if(FormList.size()>0){
            for(ContentDocumentLink Doc : [SELECT ID,LinkedEntityId,ContentDocumentId From ContentDocumentLink Where LinkedEntityId IN :FormList]){
                FormWiseDocMap.put(Doc.LinkedEntityId,Doc.ContentDocumentId);
            }
        }
        if(!FormWiseDocMap.isEmpty()){
            outMap.put('PreSelectedDocumentLinks',JSON.serialize(FormWiseDocMap));
        }
        
    }
}