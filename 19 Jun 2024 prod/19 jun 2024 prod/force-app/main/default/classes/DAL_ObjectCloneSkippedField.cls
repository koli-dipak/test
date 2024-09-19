public class DAL_ObjectCloneSkippedField {
    
public static List<Object_clone_skipped_field__mdt> getListByParentName(String parentObjName) {
        return [Select 
                Id,
                MasterLabel,
                Parent_Object_Name__c,
                Object_Name__c,
                Field_Name__c 
                FROM 
                Object_clone_skipped_field__mdt
                WHERE 
                Parent_Object_Name__c =:parentObjName];
    }
    
    public static Map<String,Set<String>> getChildSkipListByParentName(String parentObjName)
    {
        Map<String,Set<String>> mapChildFieldSkipList = new Map<String,Set<String>>();
        List<Object_clone_skipped_field__mdt> lstSkippedFields = getListByParentName(parentObjName);
        for(Object_clone_skipped_field__mdt skippedField : lstSkippedFields) 
        {
            if(mapChildFieldSkipList.containskey(skippedField.Object_Name__c))
            {
                mapChildFieldSkipList.get(skippedField.Object_Name__c).add(skippedField.Field_Name__c);
            } 
            else
            {
                mapChildFieldSkipList.put(skippedField.Object_Name__c, new Set<String> {skippedField.Field_Name__c});
            }
        }
        return mapChildFieldSkipList;
    }
    
}