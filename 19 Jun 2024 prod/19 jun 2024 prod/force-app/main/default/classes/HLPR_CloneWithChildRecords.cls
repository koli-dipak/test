public class HLPR_CloneWithChildRecords{
    //private static final String SUCCESS_MESSAGE = 'Clone is Successful you will be redirected to new Record';
    private static final String CLASS_NAME = HLPR_CloneWithChildRecords.class.getName();
    private static final String ERROR_MESSAGE = 'Error Occurred!!';
    public Id recordId{ get; set; }

    public String parentObjName{ get; set; }

    public List<ChildObjectWrapper> childObjWrapperList{ get; set; }

    private Set<String> setSTRChildObjectsToBeConverted = new Set<String>();
    //constructor
    public HLPR_CloneWithChildRecords(String recordId){
        this.recordID = recordId;
        this.childObjWrapperList = new List<ChildObjectWrapper>();
        constructorHelper(recordId);
    }

    //constructor
    public HLPR_CloneWithChildRecords(String recordId, Set<String> setSTRChildObjectsToBeConverted){
        this.recordID = recordId;
        this.childObjWrapperList = new List<ChildObjectWrapper>();
        this.setSTRChildObjectsToBeConverted = setSTRChildObjectsToBeConverted;
        constructorHelper(recordId);
    }

    public void constructorHelper(String recordId){
        parentObjName = UtilityClass.getObjectNameFromId(recordId);
        List<Schema.ChildRelationship> childObjList = UtilityClass.getChildRelationshipsFromId(recordId);
        for (Schema.ChildRelationship child : childObjList){
            String childObjectName = (String) child.getChildSObject().getDescribe().getName();
            if (child.getChildSObject().getDescribe().isQueryable() && setSTRChildObjectsToBeConverted.contains(child.getChildSObject().getDescribe().getName())){
                String fieldName = String.valueOf(child.getField());
                if (child.getField().getDescribe().isCreateable()){
                    childObjWrapperList.add(new ChildObjectWrapper(child.getChildSObject().getDescribe().getName(), true, recordId, String.valueOf(child.getField())));
                }
            }
        }
    }

    public String cloneWithChildren(Map<String, Object> cloneRecNewFieldValues, String byPassCloneParentTrigger, Map<String, Object> childDataMaping, Map<String, Object> cloneChildNewFieldValues){
        SavePoint sp = Database.setSavepoint();
        String message = '';
        //try{
            //get skipped fields list for the parentobject
            Map<String, Set<String>> mapChildObjSkipList = new Map<String, Set<String>>();
            mapChildObjSkipList = DAL_ObjectCloneSkippedField.getChildSkipListByParentName(parentObjName);
            System.debug('cloneRecNewFieldValues:: ' + cloneRecNewFieldValues);
            // Clone parent object record first
            List<Sobject> clonedParentObj = UtilityClass.cloneObject(parentObjName, recordId, true, null, null, mapChildObjSkipList);
            for (String fieldName : cloneRecNewFieldValues.keySet()) {
                Object fieldValue = cloneRecNewFieldValues.get(fieldName);
                for (Sobject clonedParentRec : clonedParentObj) {
                    clonedParentRec.put(fieldName, fieldValue);
                }
                System.debug('fieldName:: ' + fieldName);
                System.debug('fieldValue:: ' + fieldValue);
            }
        	System.debug('clonedParentObj:: ' + clonedParentObj);
            BaseTriggerHandler.bypass(byPassCloneParentTrigger);
        	System.debug('clonedParentObj:: ' + clonedParentObj);
            Insert clonedParentObj;
	       

            System.debug('cloneId::' + clonedParentObj.get(0).Id);
            // Clone child records

            List<sobject> childObjList = new List<sobject>();
            if (childObjWrapperList.size() > 0){
                for (ChildObjectWrapper obj : childObjWrapperList){
                    List<Sobject> clonedChildObj = UtilityClass.cloneObject(obj.objName, obj.recordId, false, obj.relationshipName, clonedParentObj.get(0).Id, mapChildObjSkipList);
                    if (clonedChildObj.size() > 0){
                        /*if(objectWiseDataMapping.containsKey(obj.objName)){
                            Map<String, Map<String, Object>> fieldWiseDataMapping = objectWiseDataMapping.get(obj.objName);
                            if(!fieldWiseDataMapping.isEmpty()){
                                for (Sobject clonedChildRec : clonedChildObj) {
                                    for (String fieldName : fieldWiseDataMapping.keySet()) {
                                        clonedChildRec.put(fieldName, fieldWiseDataMapping.get(fieldName).get(clonedChildRec.get(fieldName)));
                                    }
                                }
                            }
                        }*/
                        if(obj.objName == 'LOB_Management__c'){
                            System.debug('childDataMaping:: ' + childDataMaping);
                            for (Sobject clonedChildRec : clonedChildObj) {
                                if(String.valueOf(clonedChildRec.get('LOB_Stage__c')) =='Bound')
                                {
                                   
                                    clonedChildRec.put('Type__c', 'Renewal');
                                }
                                clonedChildRec.put('LOB_Stage__c', childDataMaping.get(String.valueOf(clonedChildRec.get('LOB_Stage__c'))));
                                for (String fieldName : cloneChildNewFieldValues.keySet()) {
                                    Object fieldValue = cloneChildNewFieldValues.get(fieldName);
                                    clonedChildRec.put(fieldName, fieldValue);
                                }

                                Date effectiveDate = Date.valueOf(clonedChildRec.get('LOB_Effective_Date__c'));
                                //effectiveDate = effectiveDate.addDays(365);
                                effectiveDate = effectiveDate.addYears(1);
                                clonedChildRec.put('LOB_Effective_Date__c', effectiveDate);
                            }
                        }
                        childObjList.addAll(clonedChildObj);
                    }
                }
            }
            Database.SaveResult[] lstSaveResult = Database.insert (childObjList, true);
         	BaseTriggerHandler.clearBypass(byPassCloneParentTrigger);
            // Iterate through each returned result
            for (Database.SaveResult sr : lstSaveResult){
                if (sr.isSuccess()){
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted record ID: ' + sr.getId());
                } else{
                    // Operation failed, so get all errors
                    for (Database.Error err : sr.getErrors()){
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('fields that affected this error: ' + err.getFields());
                    }
                }
            }
            message = String.valueOf(clonedParentObj[0].get('Id'));
            //cloneProductStateStatuses(message);

            // call the future method only after the code control reaches here and delete records
            //cloneAttachmentsToFiles(String.valueOf(recordId), String.valueOf(clonedParentObj[0].Id));

        /*} catch (Exception ex){
            Database.rollback(sp);
            message = ERROR_MESSAGE + ex.getMessage();
        }*/

        UTIL_LogGenerator logger = new UTIL_LogGenerator();
        logger.start(CLASS_NAME, 'cloneWithChildren');
        logger.log('parentObject', cloneRecNewFieldValues);
        logger.log('recordId', recordId);
        logger.log('CloneMsg', message);
        logger.end();
        return message;
    }
	public String cloneOnlyChildren(Map<String, Object> cloneRecNewFieldValues, String byPassCloneParentTrigger, Map<String, Object> childDataMaping, Map<String, Object> cloneChildNewFieldValues,Map<String, Object> filterValueMap,String parentId){
        SavePoint sp = Database.setSavepoint();
        String message = '';
        //try{
            // Clone child records

            Map<String, Set<String>> mapChildObjSkipList = new Map<String, Set<String>>();
            mapChildObjSkipList = DAL_ObjectCloneSkippedField.getChildSkipListByParentName(parentObjName);
            List<sobject> childObjList = new List<sobject>();
            if (childObjWrapperList.size() > 0){
                for (ChildObjectWrapper obj : childObjWrapperList){
                    List<Sobject> clonedChildObj = UtilityClass.cloneObject(obj.objName, obj.recordId, false, obj.relationshipName, parentId, mapChildObjSkipList);
                    if (clonedChildObj.size() > 0){
                        	
                        if(obj.objName == 'FC_Coverage__c'){
                            System.debug('childDataMaping:: ' + childDataMaping);
                            for (Sobject clonedChildRec : clonedChildObj) {
                                if(filterValueMap!=null){
                                    for (String filterKey : filterValueMap.keyset()) {
                                        if(filterValueMap.get(filterKey) instanceof List<String>){
                                            for(String filterValue : ((List<String>)filterValueMap.get(filterKey))){
                                                if(String.valueOf(clonedChildRec.get(filterKey)) == filterValue ){
                                                    childObjList.add(clonedChildRec);
                                                } 
                                            }
                                        }else{
                                            if(String.valueOf(clonedChildRec.get(filterKey)) == String.valueOf(filterValueMap.get(filterKey))){
                                                childObjList.add(clonedChildRec);
                                            }
                                        }
                                    }
                                }else{
                                    childObjList.add(clonedChildRec);
                                }   
                            }
                        }
                        else  if(obj.objName == 'LOB_Management__c'){
                            for (Sobject clonedChildRec : clonedChildObj) {
                                 if(clonedChildRec.get('LOB_Stage__c') != 'Bound')  {
                                     clonedChildRec.put('LOB_Stage__c', childDataMaping.get(String.valueOf(clonedChildRec.get('LOB_Stage__c'))));
                                     
                                     Date effectiveDate = Date.valueOf(clonedChildRec.get('LOB_Effective_Date__c'));
                                     effectiveDate = effectiveDate.addYears(1);
                                     clonedChildRec.put('LOB_Effective_Date__c', effectiveDate);
                                     childObjList.add(clonedChildRec);
                                     System.debug('**childObjList:: '+ childObjList);
                                 }
                             }
                        }
                        else{
                            childObjList.addAll(clonedChildObj);
                            System.debug('@@childObjList:: '+ childObjList);
                        }
                    }
                }
            }
            Database.SaveResult[] lstSaveResult = Database.insert (childObjList, true);
            // Iterate through each returned result
            for (Database.SaveResult sr : lstSaveResult){
                if (sr.isSuccess()){
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted record ID: ' + sr.getId());
                } else{
                    // Operation failed, so get all errors
                    for (Database.Error err : sr.getErrors()){
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('fields that affected this error: ' + err.getFields());
                    }
                }
            }
            message = String.valueOf(parentId);
            //cloneProductStateStatuses(message);

            // call the future method only after the code control reaches here and delete records
            //cloneAttachmentsToFiles(String.valueOf(recordId), String.valueOf(clonedParentObj[0].Id));

        /*} catch (Exception ex){
            Database.rollback(sp);
            message = ERROR_MESSAGE + ex.getMessage();
        }*/

        UTIL_LogGenerator logger = new UTIL_LogGenerator();
        logger.start(CLASS_NAME, 'cloneWithChildren');
        logger.log('parentObject', cloneRecNewFieldValues);
        logger.log('recordId', recordId);
        logger.log('CloneMsg', message);
        logger.end();
        return message;
    }
    public class ChildObjectWrapper{
        public String objName{ get; set; }

        public Boolean isSelected{ get; set; }

        public String recordId{ get; set; }

        public String relationshipName{ get; set; }

        ChildObjectWrapper(String objName, Boolean isSelected, String recordId, String relationshipName){
            this.objName = objName;
            this.isSelected = isSelected;
            this.recordId = recordId;
            this.relationshipName = relationshipName;
        }

    }

}