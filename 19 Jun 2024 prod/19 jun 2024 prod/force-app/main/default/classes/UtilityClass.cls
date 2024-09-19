public with sharing class UtilityClass {

  /** Method name : getObjectNameFromId
     * Arguments : Id recordId - the id of the record whose name needs to be identified
     * Return type : String
     * Description : Pass the record id to this method and it will return you the name of associated object
    **/
    public static String getObjectNameFromId(Id recordId){
        Schema.DescribeSObjectResult dr = getDescribeSObjectResultFromId(recordId);
        return dr.getName(); 
    }
    
    /** Method name : getChildRelationshipsFromId
     * Arguments : Id recordId - the id of the record whose name child relationships needs to be identified
     * Return type : List<Schema.ChildRelationship>
     * Description : Pass the record id to this method and it will return you a list of all associated child relationships
    **/
    public static List<Schema.ChildRelationship> getChildRelationshipsFromId(Id recordId){
         //system.debug('recordId222:::'+recordId);
        Schema.DescribeSObjectResult dr = getDescribeSObjectResultFromId(recordId);
        //system.debug('dr:::'+dr);
       try{
       for(Schema.ChildRelationship cd:dr.getChildRelationships())
       {
       	 //system.debug('cd222:::'+cd.getChildSObject());
       }
       }
       catch(Exception e)
       {
       	 system.debug('eee:::'+e);
       }
       
        return dr.getChildRelationships();
    }
    
    /** Method name : cloneObject
     * Arguments : String objName : Name of the object which needs to be cloned
     * Id orgRecordId : Id of the parent record on which clone button is created
     * Boolean isSelfId : Boolean flag to determine whether the agrument orgRecordId is self id or parent object id
     * String relationshipField : Used when the orgRecordId is parent id
     * String parentRecordId : Id of parent record
     * Return type : List<Sobject> - List of object which is cloned
     * Description : Clones the parent or related list record based on the parameters passed
    **/
    public static List<Sobject> cloneObject(String objName, Id orgRecordId, Boolean isSelfId,String relationshipField, String parentRecordId, Map<String,Set<String>> mapChildObjectSkippedFields){
        SObjectType objToken = Schema.getGlobalDescribe().get(objName);
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap();
        List<String> fieldslist = new List<String>();
        Set<String> skippedFields = new Set<String>();
        if(mapChildObjectSkippedFields!=null && mapChildObjectSkippedFields.containsKey(objName)) {
            skippedFields = toLowerSet(mapChildObjectSkippedFields.get(objName));
        }
        System.debug('--skippedfields--'+skippedFields);
        for(String fieldName : fields.keySet()) {
            System.debug('--fieldname--'+ fieldName);
            if(fields.containsKey(fieldName) && fields.get(fieldName).getDescribe().isCreateable() && !skippedFields.contains(fieldName)){
                fieldslist.add(fieldName);
            }
        }
        
        String query;
        if(isSelfId){
            query   = 'SELECT ' + String.join(fieldslist, ',') + ' FROM '+ objName +' WHERE Id =\''+ orgRecordId +'\' LIMIT 1';
        }else{
            query   = 'SELECT ' + String.join(fieldslist, ',') + ' FROM '+ objName +' WHERE '+ relationshipField +' =\''+ orgRecordId +'\'';
        }
        List<SObject> sObjList = new List<SObject>();
        if(fieldslist.size() > 0){
            sObjList = Database.query(query); 
        }
        List<SObject> clonedObjList = new List<SObject>();
        SObject clonedSobj;
        for(Sobject obj : sObjList){
            clonedSobj  = obj.clone(false, false, false, false);
            if(objName == 'LOB_Management__c'){
                clonedSobj.put('Renewed_Line_of_Business__c', obj.get('Id'));
            }
            if(!isSelfId && clonedSobj!=null){
                // update relationshipField with parentRecordId
                if(String.isNotBlank(relationshipField) && String.isNotBlank(parentRecordId)){
                    clonedSobj.put(relationshipField,parentRecordId);
                }
            }
            clonedObjList.add(clonedSobj);
        }
        return clonedObjList;
    }
    
    /** Method name : getDescribeSObjectResultFromId
     * Arguments : Id recordId
     * Return type : Schema.DescribeSObjectResult
     * Description : Returns the describe information about the passed record id
    **/
    public static Schema.DescribeSObjectResult getDescribeSObjectResultFromId(Id recordId){
        Schema.SObjectType token = recordId.getSObjectType();
        return token.getDescribe();
    }
    private static Set<String> toLowerSet(Set<String> setString) {
        Set<String> lowerStringSet = new Set<String>();
        for(String str: setString) {
         lowerStringSet.add(str.toLowerCase());   
        }
        return lowerStringSet;
    }
}