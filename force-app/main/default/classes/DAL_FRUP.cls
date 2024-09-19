public class DAL_FRUP {
	Static public List<box__FRUP__c> getFRUPByRecordIdAndObjectName(Id recId, String objectName){
        return [Select Id,box__Folder_ID__c,box__Object_Name__c,box__Permission__c 
                       from box__FRUP__c where box__Record_ID__c = :recId And box__Object_Name__c = :objectName];
    }
}