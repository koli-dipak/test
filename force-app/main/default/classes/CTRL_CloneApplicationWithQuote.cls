global with sharing class CTRL_CloneApplicationWithQuote implements vlocity_ins.VlocityOpenInterface{

   global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
      if (methodName.equals('cloneProducts')) {
         cloneProducts(inputMap, outMap);
      }
      // else if(methodName.equals('getContentDocumentId')){
      //     getContentDocumentId(inputMap, outMap);
      // }
      return true;
  }
    @AuraEnabled()
     public static String cloneProducts(Map < String, Object > inputMap, Map < String, Object > outMap){ 
        //System.debug('formType@@'+formType);
        String recordId = String.valueOf(inputMap.get('recordId'));
        List<String> recordTypeList = (List<String>) System.JSON.deserialize(String.valueOf(inputMap.get('recordType')), List<String>.class);
        List<String> formsList =(List<String>) System.JSON.deserialize(String.valueOf(inputMap.get('forms')), List<String>.class);// (List<String>) inputMap.get('forms');
       
         //  List<String> lstFontVolumeWrapper= (List<String>)System.JSON.deserialize(recordType, List<String>.class);
         //  List<String> lstForms= (List<String>)System.JSON.deserialize(forms, List<String>.class);
         
         
         vlocity_ins__Application__c ApplicationRec = [Select Id , Name , LineofBusiness__c, Program_Id__c From vlocity_ins__Application__c where ID = :recordId];
		
		 // Get latest Version numner
		 vlocity_ins__Application__c lastestVersion = [Select Id , Name , LineofBusiness__c, Program_Id__c,Version__c From vlocity_ins__Application__c where LineofBusiness__c = :ApplicationRec.LineofBusiness__c and Program_Id__c=:ApplicationRec.Program_Id__c order by createddate  desc limit 1];
		         
         Set<String> setSTRChildObjectsToBeConverted = new Set<String>();
         setSTRChildObjectsToBeConverted.add('FC_Casualty_Premium__c');
         setSTRChildObjectsToBeConverted.add('FC_Form__c');
         
         Map<String, Object> newRecordFieldsValue = new Map<String, Object>();
         newRecordFieldsValue.put('Name', ApplicationRec.Name);
         newRecordFieldsValue.put('Version__c',String.valueOf(Integer.valueOf(lastestVersion.Version__c)+1));
         newRecordFieldsValue.put('vlocity_ins__Status__c', null);
        
         HLPR_CloneWithChildRecords cloneProductObj = new HLPR_CloneWithChildRecords(recordId, setSTRChildObjectsToBeConverted);
         
         String ApplicationId=cloneProductObj.cloneWithChildren(newRecordFieldsValue, '', null, null);
         
         List<FC_Casualty_Premium__c> CasualPremium  = [Select Id, Name,Application__c From FC_Casualty_Premium__c where Application__c = :ApplicationId];
          List<FC_Casualty_Premium__c> ExistingCasualPremium  = [Select Id, Name,Application__c From FC_Casualty_Premium__c where Application__c = :recordId];
      
         String CPId=CasualPremium.size()>0?CasualPremium[0].Id:null;
         String existingCPId=ExistingCasualPremium.size()>0?ExistingCasualPremium[0].Id:null;
         
         List<String> listFormToClone=new List<String>();
           
         List<String> recordTypeFilterList=new list<String>();
         String recordTypeId='';
         for(String con:recordTypeList){
            
             
             System.debug('Con####'+con);
             if (con == 'Coverage:General Liability') {
                recordTypeId=Schema.SObjectType.FC_Coverage__c.getRecordTypeInfosByName().get('Foreign Commercial General Liability').getRecordTypeId();
            }
             else if (con == 'Coverage:Auto Liability') {
                recordTypeId=Schema.SObjectType.FC_Coverage__c.getRecordTypeInfosByName().get('Foreign Auto Liability').getRecordTypeId();
             }
             else if (con == 'Coverage:Workers\'Comp Liability') {
                recordTypeId=Schema.SObjectType.FC_Coverage__c.getRecordTypeInfosByName().get('Foreign Voluntary Workers Compensation').getRecordTypeId();
             }
             else if (con == 'Coverage:Emergency Assistance') {
                recordTypeId=Schema.SObjectType.FC_Coverage__c.getRecordTypeInfosByName().get('Emergency Assistance').getRecordTypeId();
             }
             else if (con == 'Coverage:Travel Accident and Medical Expense') {
                recordTypeId=Schema.SObjectType.FC_Coverage__c.getRecordTypeInfosByName().get('Travel Accident And Excess').getRecordTypeId();
             }
             else if (con == 'Coverage:Trip Assistance') {
                recordTypeId=Schema.SObjectType.FC_Coverage__c.getRecordTypeInfosByName().get('Trip Assistance Coverage').getRecordTypeId();
             }
             recordTypeFilterList.add(recordTypeId);
             if(formsList.contains(con+' Forms')){
                listFormToClone.add(recordTypeId);
             }            
         }
        //  recordTypeFilterList.add(Schema.SObjectType.FC_Coverage__c.getRecordTypeInfosByName().get('Emergency Assistance').getRecordTypeId());
        //  recordTypeFilterList.add(Schema.SObjectType.FC_Coverage__c.getRecordTypeInfosByName().get('Foreign Auto Liability').getRecordTypeId());
        //  recordTypeFilterList.add(Schema.SObjectType.FC_Coverage__c.getRecordTypeInfosByName().get('Foreign Voluntary Workers Compensation').getRecordTypeId());
        //  recordTypeFilterList.add(Schema.SObjectType.FC_Coverage__c.getRecordTypeInfosByName().get('Travel Accident And Excess').getRecordTypeId());
        //  recordTypeFilterList.add(Schema.SObjectType.FC_Coverage__c.getRecordTypeInfosByName().get('Trip Assistance Coverage').getRecordTypeId());
         Map<string, Object> recordTypeFCFilter = new Map<string, Object>();
         recordTypeFCFilter.put('RecordTypeId',recordTypeFilterList);
         
         
         setSTRChildObjectsToBeConverted = new Set<String>();
         setSTRChildObjectsToBeConverted.add('FC_Coverage__c');
         setSTRChildObjectsToBeConverted.add('FC_Casualty_Local__c');
         
         cloneProductObj = new HLPR_CloneWithChildRecords(existingCPId, setSTRChildObjectsToBeConverted); 
         cloneProductObj.cloneOnlyChildren(null, '', null, null,recordTypeFCFilter,CPId);
         
         List<FC_Coverage__c> coverageList = [Select Id,Name,Casualty_Premium__c,RecordTypeId from FC_Coverage__c where Casualty_Premium__c = :CPId];
         List<FC_Coverage__c> existingCoverage = [Select Id,Name,Casualty_Premium__c,RecordTypeId from FC_Coverage__c where Casualty_Premium__c = :existingCPId];
         
         Map<String, FC_Coverage__c> recordTypeWiseCoverageMap = new Map<String, FC_Coverage__c>();
         for(FC_Coverage__c coverage: coverageList){
             recordTypeWiseCoverageMap.put(coverage.RecordTypeId,coverage);
         } 
         setSTRChildObjectsToBeConverted = new Set<String>();
         setSTRChildObjectsToBeConverted.add('FC_Form__c');
         setSTRChildObjectsToBeConverted.add('FC_Exposure__c');
          
        
         
         for(FC_Coverage__c coverage: existingCoverage){
             if(recordTypeWiseCoverageMap.containsKey(coverage.RecordTypeId) && listFormToClone.contains(coverage.RecordTypeId)){
                 cloneProductObj = new HLPR_CloneWithChildRecords(coverage.Id, setSTRChildObjectsToBeConverted);
                 cloneProductObj.cloneOnlyChildren(null, '', null, null,recordTypeFCFilter,recordTypeWiseCoverageMap.get(coverage.RecordTypeId).Id);
             }
         }
         
         // extension
         List<FC_Casualty_Local__c> fcLocalList = [Select Id,Name,Country__c,LOB_Type__c  from FC_Casualty_Local__c where FC_Casualty_Premium__c  = :CPId];
         List<FC_Casualty_Local__c> existingfcLocal = [Select Id,Name,Country__c,LOB_Type__c  from FC_Casualty_Local__c where FC_Casualty_Premium__c  = :existingCPId];
         
         Map<String, FC_Casualty_Local__c> recordTypeWiseFCLocalMap = new Map<String, FC_Casualty_Local__c>();
         for(FC_Casualty_Local__c local: fcLocalList){
             recordTypeWiseFCLocalMap.put(local.Country__c+'_'+local.LOB_Type__c ,local);
         } 
         setSTRChildObjectsToBeConverted = new Set<String>();
         setSTRChildObjectsToBeConverted.add('FC_Casualty_Local_Extention__c');
          
         
         for(FC_Casualty_Local__c local: existingfcLocal){
             if(recordTypeWiseFCLocalMap.containsKey(local.Country__c+'_'+local.LOB_Type__c)){
                 cloneProductObj = new HLPR_CloneWithChildRecords(local.Id, setSTRChildObjectsToBeConverted);
                 cloneProductObj.cloneOnlyChildren(null, '', null, null,null,recordTypeWiseFCLocalMap.get(local.Country__c+'_'+local.LOB_Type__c).Id);
             }
         }
         outMap.put('NewApplicationId',ApplicationId);
         
         // Clone GeRRater File
         List<ContentDocumentLink> listCDL=[SELECT ID,ContentDocumentId FROM ContentDocumentLink Where LinkedEntityId =:recordId and ContentDocument.FileType='EXCEL_M' order by ContentDocument.CreatedDate DESC limit 1];
         if(listCDL.size()>0){
             ContentDocumentLink CDL=new ContentDocumentLink();
             CDL.LinkedEntityId=ApplicationId;
             CDL.ContentDocumentId=listCDL[0].ContentDocumentId;
             Insert CDL;
         }
         return ApplicationId;
     }

   //  @AuraEnabled
   //  public static List<FC_Casualty_Premium__c> getForeignCasualtyFields(String recordId){
   //      return [Select Id, Name,Company_Name__c, Effective_Date__c, Expiry_Date__c,	Exposure_base__c,GL_Occurrence_Limit__c,GL_Deductible__c,Application__c From FC_Casualty_Premium__c where Application__c = :recordId limit 1];
   //  }
    
 }