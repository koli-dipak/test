public class AddRelatedRecordController {
    // Method to fetch lookup search result   
     @AuraEnabled(cacheable=true)
     public static list<sObject> fetchLookupData(string searchKey , string currentRecordId, string sObjectApiName, String apiNameOfFieldSetToSearch, Boolean fetchAllData, Integer limitForDropdownOptions, String allSelectedPicklistValueIds, String recordTypeNamesToFilter, String apiNameOfFieldSetForDataTable, String additionalFielddAPINamesToShow, String fieldValuesToFilter) {
         
         Set<String> fieldAPINames = new Set<String>();
         Set<String> showInResultFieldAPINames = new Set<String>();
         List < sObject > returnList = new List < sObject > ();
         List<String> allSelectedRecordIdsList = new List<String>();
         List<String> recordTypesList = new List<String>();
         List<String> additionalFieldsToShowList = new List<String>();
         List<String> fieldValuesToFilterList = new List<String>();
         Set<String> additionalFieldsToShowSet = new Set<String>();
         Set<String> allSelectedRecordIdsSet = new Set<String>();
         Set<Id> recordTypeIdsSet = new Set<Id>();
         Map<String, String> fieldNameWiseOtherFieldNameMap = new Map<String, String>();
         String whereClauseOfFieldValues = '';

         // to remove already selected records
         if(String.isNotBlank(allSelectedPicklistValueIds)){
            allSelectedRecordIdsList = (List<String>)JSON.deserialize(allSelectedPicklistValueIds, List<String>.class);
            allSelectedRecordIdsSet.addAll(allSelectedRecordIdsList);
         }

         System.debug('@@recordTypeNamesToFilter:::'+recordTypeNamesToFilter);
         // to add record type filter
         if(String.isNotBlank(recordTypeNamesToFilter)){
            recordTypesList = recordTypeNamesToFilter.split(';');
            if(!recordTypesList.isEmpty()){
                List<RecordType> RecordTypeRecords = [SELECT Id FROM RecordType WHERE SObjectType = :sObjectApiName AND DeveloperName IN :recordTypesList];
                if(!RecordTypeRecords.isEmpty()){
                    for(RecordType record : RecordTypeRecords){
                        recordTypeIdsSet.add(record.Id);
                    }
                }
            }
         }

         System.debug('@@fieldValuesToFilter:::'+fieldValuesToFilter);
         // to add field values filter
         if(String.isNotBlank(fieldValuesToFilter)){
            fieldValuesToFilterList = fieldValuesToFilter.split(';');
            if(!fieldValuesToFilterList.isEmpty()){
                for (String fieldMapping : fieldValuesToFilterList) {
                    System.debug('@@fieldMapping:::'+fieldMapping);
                    List<String> fields = fieldMapping.split('=');
                    if(fields.size() == 2){
                        fieldNameWiseOtherFieldNameMap.put(fields[1],fields[0]);
                    }
                }
                if(!fieldNameWiseOtherFieldNameMap.isEmpty()){
                    List<String> fieldsList = new List<String>(fieldNameWiseOtherFieldNameMap.keySet());
                    System.debug('@@fieldsList:::'+fieldsList);
                    String allfieldsForFilter = String.join((Iterable<String>)fieldsList,', ');
                    System.debug('@@allfieldsForFilter::'+allfieldsForFilter);
                    Id currentNewRecordId = (Id)currentRecordId;
                    String currentObjName = currentNewRecordId.getSObjectType().getDescribe().getName();
                    String dynamicQuery = 'SELECT '+allfieldsForFilter+' FROM '+ currentObjName+' WHERE Id =\''+currentRecordId+'\'';
                    System.debug('@@dynamicQuery::'+dynamicQuery);
                    List<SObject> results = Database.query(dynamicQuery);
                    System.debug('@@results::'+results);
                    if(!results.isEmpty()){
                        SObject record = results[0];
                        Integer temp = 0;
                        for(String fieldValue : fieldNameWiseOtherFieldNameMap.keySet()){
                            if(record.get(fieldValue) != null){
                                if(temp == fieldNameWiseOtherFieldNameMap.size()-1){
                                    whereClauseOfFieldValues = whereClauseOfFieldValues + fieldNameWiseOtherFieldNameMap.get(fieldValue) + '= \'' + (String)record.get(fieldValue) + '\'';
                                }else{
                                    whereClauseOfFieldValues = whereClauseOfFieldValues + fieldNameWiseOtherFieldNameMap.get(fieldValue) + '= \'' + (String)record.get(fieldValue) + '\' AND ';
                                }
                            }
                            temp++;
                        }
                    }
                }
            }
         }

         System.debug('@@additionalFielddAPINamesToShow:::'+additionalFielddAPINamesToShow);
         // Additional Fields to Show in search result
         if(String.isNotBlank(additionalFielddAPINamesToShow)){
            additionalFieldsToShowList = additionalFielddAPINamesToShow.split(';');
            additionalFieldsToShowSet.addAll(additionalFieldsToShowList);
            for(String fieldName : additionalFieldsToShowSet){
                showInResultFieldAPINames.add(fieldName);
            }
         }

         showInResultFieldAPINames.add('Id');
         showInResultFieldAPINames.add('Name');
         
         System.debug('@@recordTypeIdsSet:::'+recordTypeIdsSet);
         string searchString = '%' + searchKey.trim() + '%';
         String whereClause = '';

         if (!recordTypeIdsSet.isEmpty()) {
            if (!allSelectedRecordIdsSet.isEmpty()) {
                whereClause = whereClause + 'RecordTypeId IN :recordTypeIdsSet AND ';
            }else{
                whereClause = whereClause + 'RecordTypeId IN :recordTypeIdsSet AND (';
            }
        }

        System.debug('@@whereClauseOfFieldValues::'+whereClauseOfFieldValues);
        if(String.isNotBlank(whereClauseOfFieldValues)){
            if (!allSelectedRecordIdsSet.isEmpty() || !recordTypeIdsSet.isEmpty()) {
                whereClause = whereClause + whereClauseOfFieldValues + ' AND ';
            }else{
                whereClause = whereClause + whereClauseOfFieldValues + ' AND (';
            }
        }

        if (!allSelectedRecordIdsSet.isEmpty()) {
            whereClause = whereClause + 'Id NOT IN :allSelectedRecordIdsSet AND (';
        }

        //fieldset logic for datatable fields
        if(String.isNotBlank(apiNameOfFieldSetForDataTable)){
            FieldSetForm form = new FieldSetForm();        
            form.Fields = getFields(sObjectApiName, apiNameOfFieldSetForDataTable);
            for (FormField field : form.Fields) {
                    fieldAPINames.add(field.APIName);
                }
        }

        if(String.isNotBlank(apiNameOfFieldSetToSearch)){
            FieldSetForm form = new FieldSetForm();        
            form.Fields = getFields(sObjectApiName, apiNameOfFieldSetToSearch);
    		List<FormField> StringOrEmailFields = new List<FormField>();
            
            System.debug('@@form.Fields:::'+form.Fields);
            System.debug('@@whereClause::1st:'+whereClause);
            
            /*for (FormField field : form.Fields) {
                if(apiNameOfFieldSetForDataTable == null){
                    fieldAPINames.add(field.APIName);
                }
                if(field.Type == 'STRING' || field.Type == 'EMAIL'){
                    // fieldAPINames.add(field.APIName);
                    if(form.Fields[form.Fields.size()-1].APIName == field.APIName){
                        whereClause = whereClause + field.APIName + ' LIKE \''+searchString + '\'';
                        if (!allSelectedRecordIdsSet.isEmpty() || !recordTypeIdsSet.isEmpty() || String.isNotBlank(whereClauseOfFieldValues)) {
                            whereClause = whereClause + ')';
                        }
                    }
                    else{
                        whereClause = whereClause + field.APIName + ' LIKE \''+searchString + '\' OR ';
                    }
                    System.debug('@@whereClause:::'+whereClause);
                }
            }*/
            
            for (FormField field : form.Fields) {
                if(apiNameOfFieldSetForDataTable == null){
                    fieldAPINames.add(field.APIName);
                }
                if(field.Type == 'STRING' || field.Type == 'EMAIL'){
                    // fieldAPINames.add(field.APIName);
                    StringOrEmailFields.add(field);
                }
            }
            
            System.debug('@@StringOrEmailFields:::'+StringOrEmailFields);
            
            for (FormField field : StringOrEmailFields) {
                if(field.Type == 'STRING' || field.Type == 'EMAIL'){
                    // fieldAPINames.add(field.APIName);
                    if(StringOrEmailFields[StringOrEmailFields.size()-1].APIName == field.APIName){
                        whereClause = whereClause + field.APIName + ' LIKE \''+searchString + '\'';
                        if (!allSelectedRecordIdsSet.isEmpty() || !recordTypeIdsSet.isEmpty() || String.isNotBlank(whereClauseOfFieldValues)) {
                            whereClause = whereClause + ')';
                        }
                    }
                    else{
                        whereClause = whereClause + field.APIName + ' LIKE \''+searchString + '\' OR ';
                    }
                    System.debug('@@whereClause:::'+whereClause);
                }
            }
        }

        

        System.debug('@@whereClause:::'+whereClause);

        string sQuery = 'SELECT '+ String.join((Iterable<String>)showInResultFieldAPINames,', ') +' FROM ' + sObjectApiName + ' WHERE ';

        if(String.isNotBlank(whereClause)){
            if(fetchAllData == true){
                fieldAPINames.add('Id');
                fieldAPINames.add('Name');
                String allfieldsJoin = String.join((Iterable<String>)fieldAPINames,', ');
                System.debug('@@allfieldsJoin:::'+allfieldsJoin);
                sQuery = 'SELECT ' + allfieldsJoin + ' FROM ' +sObjectApiName + ' WHERE ' + whereClause + ' order by createdDate DESC LIMIT 2000';
            }else{
                sQuery = sQuery + whereClause + ' order by createdDate DESC LIMIT '+limitForDropdownOptions;
            }
        }
        else {
            if(fetchAllData == true){
                sQuery = sQuery  + 'Name Like : searchString order by createdDate DESC LIMIT 2000';
            }
            else{
                sQuery = sQuery  + 'Name Like : searchString order by createdDate DESC LIMIT '+limitForDropdownOptions;
            }
        }

        System.debug('@@sQuery::'+sQuery);
        
         for (sObject obj: database.query(sQuery)) {
             returnList.add(obj);
         }
         return returnList;
     }

     // Method to fetch lookup default value 
     @AuraEnabled
     public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
         string sRecId = recordId;
         string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
         for (sObject obj: database.query(sQuery)) {
             return obj;
         }
         return null;
     }

     @AuraEnabled
     public static string createJunctionObjectRecord(Map<String, String> inputMap){
        try {
            system.debug('inputMap:: ' + inputMap);
            String sObjectApiNameOfJunctionObject = inputMap.get('sObjectApiNameOfJunctionObject');
            String sObjectApiNameToSearch = inputMap.get('sObjectApiNameToSearch');
            String currentSObjectName = inputMap.get('currentSObjectName');
            String fieldAPINameOfCurrentObject = inputMap.get('fieldAPINameOfCurrentObject');
            String fieldAPINameOfSelectedObject = inputMap.get('fieldAPINameOfSelectedObject');
            String allSelectedRecordIdsString =  inputMap.get('allSelectedRecordIds');
            System.debug('@@allSelectedRecordIdsString::'+allSelectedRecordIdsString);
            Id currentRecordId = (Id)inputMap.get('currentRecordId');
            List<sObject> junctionRecordsToInsert = new List<sObject>();
            Set<String> allSelectedRecordIdsSet = new Set<String>();
            List<String> allSelectedRecordIdsList = (List<String>)JSON.deserialize(allSelectedRecordIdsString, List<String>.class);
            System.debug('@@allSelectedRecordIdsList::'+allSelectedRecordIdsList);
            allSelectedRecordIdsSet.addAll(allSelectedRecordIdsList);


            System.debug('@@allSelectedRecordIdsSet::'+allSelectedRecordIdsSet);
            System.debug('@@currentRecordId::'+currentRecordId);
            System.debug('@@sObjectApiNameOfJunctionObject::'+sObjectApiNameOfJunctionObject);
            System.debug('@@fieldAPINameOfCurrentObject::'+fieldAPINameOfCurrentObject);
            System.debug('@@fieldAPINameOfSelectedObject::'+fieldAPINameOfSelectedObject);
            
            for(String recordId :allSelectedRecordIdsSet){
                if(recordId != 'SearchAll' && recordId != 'SearchInAll'){
                    sObject sObj = Schema.getGlobalDescribe().get(sObjectApiNameOfJunctionObject).newSObject();
                    sObj.put(fieldAPINameOfCurrentObject, currentRecordId);
                    sObj.put(fieldAPINameOfSelectedObject, recordId);
                    junctionRecordsToInsert.add(sObj);
                }
            }
            System.debug('@@junctionRecordsToInsert:::'+junctionRecordsToInsert);
            if(!junctionRecordsToInsert.isEmpty()){
                List<Database.SaveResult> results = Database.insert(junctionRecordsToInsert, false);
                for(Database.SaveResult result : results){
                    if(result.isSuccess()){
                        system.debug('@@success::::');
                    }
                    else{
                        system.debug('@@error::::: '+result.getErrors());
                        if(result.getErrors()[0].getStatusCode() == StatusCode.ENTITY_IS_LOCKED) {
                            return 'ERROR: One of the accounts you are trying to add has not been approved. Please remove this account from your selection and try again.';
                        }
                        return 'ERROR: '+String.valueOf(result.getErrors()[0].getMessage());
                    }
                }
            }
            return 'SUCCESS';
        } catch (Exception e) {
            return e.getMessage();
        }
     }

     // Get Record Types code
     @AuraEnabled
     public static List<RecordTypeWrapper> getRecordTypes(String objectName) {
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        List<RecordTypeWrapper> recordTypes = new List<RecordTypeWrapper>();
        for(RecordTypeInfo info: objectType.getDescribe().getRecordTypeInfos()) {
            if(info.isAvailable()) {
                RecordTypeWrapper recordType = new RecordTypeWrapper();
                recordType.recordTypeName = (String) info.getName();
                recordType.recordTypeId = (String) info.getRecordTypeId();
                recordTypes.add(recordType);
                // recordTypeIdWiseName.put((String)info.getRecordTypeId(), (String) info.getName());
            }
        }
        return recordTypes;
     }

     public class RecordTypeWrapper{
        @AuraEnabled
        public String recordTypeName { get;set; }    
        @AuraEnabled
        public String recordTypeId { get;set; }    
     }

     // create new record related methods here
     @AuraEnabled
    public static FieldSetForm getForm(String objectName, String fieldSetName) {
        FieldSetForm form = new FieldSetForm();        
        form.Fields = getFields(objectName, fieldSetName);
        
        return form;
    }
    
    private static List<FormField> getFields(String objectName, String fieldSetName) {
        Schema.SObjectType objectType = null;
        
        if (String.isNotBlank(objectName)) {
            objectType = Schema.getGlobalDescribe().get(objectName);
        }
        
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
        
        List<FormField> fields = new List<FormField>();
        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            FormField f = new FormField(fsm);
            fields.add(f);
        }
        
        return fields;
    }
    
    public class FieldSetForm {
        @AuraEnabled
        public List<FormField> Fields;
        
        public FieldSetForm() {
            Fields = new List<FormField>();
        }
    }

    public class FormField {
    
        public FormField(Schema.FieldSetMember f) {
            this.IsRequired = f.DBRequired;
            this.APIName = f.fieldPath;
            this.Label = f.label;
            this.Required = f.required;
            this.Type = String.valueOf(f.getType());
        }
        
        public FormField(Boolean required) {
            this.IsRequired = required;
        }
        
        @AuraEnabled
        public Boolean IsRequired { get;set; }    
        @AuraEnabled
        public String APIName { get;set; }    
        @AuraEnabled
        public String Label { get;set; }    
        @AuraEnabled
        public Boolean Required { get;set; } 
        @AuraEnabled
        public String Type { get; set; }
    }

 }