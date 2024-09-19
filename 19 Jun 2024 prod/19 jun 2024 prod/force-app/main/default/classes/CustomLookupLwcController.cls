public without sharing class CustomLookupLwcController {
   // Method to fetch lookup search result   
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName,String ExtraField,String whereClauseField,String whereClauseValue) {    
        List < sObject > returnList = new List < sObject > ();

        string sWildCardText = '%' + searchKey + '%';
        String ExtraFields='';
        String whereClause='';
        if(ExtraField!=null && !string.isEmpty(ExtraField)){
            ExtraFields=','+ExtraField;
        }  
        if(whereClauseField!=null && whereClauseField!='' && whereClauseValue!=null){
            whereClause =' and '+whereClauseField +' = \''+whereClauseValue +'\'';
        }
        string sQuery = 'Select Id,Name '+ExtraFields+' From ' + sObjectApiName + ' Where Name Like : sWildCardText '+whereClause+' order by createdDate DESC LIMIT 5';
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList; 
    }
    
    // Method to fetch lookup default value 
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName,String ExtraField,String whereClauseField,String whereClauseValue) {
        string sRecId = recordId;   
        String ExtraFields='';
        String whereClause='';
        
        if(ExtraField!=null && !string.isEmpty(ExtraField)){
            ExtraFields=','+ExtraField;
        } 
        if(whereClauseField!=null && whereClauseField!=''  && whereClauseValue!=null){
            whereClause =' and '+whereClauseField +' = \''+whereClauseValue +'\'';
        }
        string sQuery = 'Select Id,Name '+ExtraFields+'  From ' + sObjectApiName + ' Where Id = : sRecId '+whereClause+' LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    } 
    
}