public with sharing class DocumentChecklistSelectionTableControlle {

    // @AuraEnabled(cacheable=true)
    // public static List<DocumentChecklistItem> getRelatedChecklistItems(Id parentId) {
    //     return [SELECT Id, Name, Generate_Quote_and_Binder__c,Country_States__c, Status, Stage__c, Type__c, Instruction, Line_of_Business__c, Rating_ID__c 
    //             FROM DocumentChecklistItem 
    //             WHERE ((Quote_Line_Item__r.Stage__c = 'Binder' AND Type__c = 'Checklist') 
    //                     OR Quote_Line_Item__r.Stage__c = 'Quoted' 
    //                     OR Quote_Line_Item__r.Stage__c = 'Rated'
    //                     OR isSelectedForDocument__c = true)
    //                     AND isSelectedForDocument__c = true 
    //                 AND Generate_Quote_and_Binder__c = :parentId 
    //             ORDER BY Stage__c ASC];
    // }
    
    
    @AuraEnabled(cacheable=true)
    public static List<DocumentChecklistItem> getQuotedChecklistItems(Id parentId) {
        return  DAL_DocumentChecklistItem.getQuotedChecklist(parentId);
    }

    @AuraEnabled(cacheable=true)
    public static List<DocumentChecklistItem> getBinderChecklistItems(Id parentId) {
        return DAL_DocumentChecklistItem.getBinderChecklist(parentId);
    }

    // @AuraEnabled(cacheable=true)
    // public static List<DocumentChecklistItem> getRatedChecklistItems(Id parentId) {
    //     return [SELECT Id, Name, Generate_Quote_and_Binder__c, Status,Type__c, Instruction, Line_of_Business__c, Rating_ID__c 
    //             FROM DocumentChecklistItem 
    //             WHERE Generate_Quote_and_Binder__c = :parentId AND Quote_Line_Item__r.Stage__c = 'Rated'];
    // }

    @AuraEnabled(cacheable=true)
    public static List<String> getStatusPicklistValues() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = DocumentChecklistItem.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple) {
            picklistValues.add(p.getLabel());
        }
        return picklistValues;
    }

    @AuraEnabled
    public static void updateRecords(List<Map<String, Object>> recordsToUpdate) {
        List<DocumentChecklistItem> recordsToUpdateList = new List<DocumentChecklistItem>();
        for (Map<String, Object> recordMap : recordsToUpdate) {
            DocumentChecklistItem recordToUpdate = new DocumentChecklistItem(
                Id = (Id)recordMap.get('Id'),
                Status = (String)recordMap.get('Status')
            );
            recordsToUpdateList.add(recordToUpdate);
        }
        update recordsToUpdateList;
    }

    @AuraEnabled(cacheable=true)
    public static List<DocumentChecklistItem> getRelatedBinderChecklistItems(Id parentId) {
        return DAL_DocumentChecklistItem.getRelatedBinderChecklist(parentId);
    }
   

    
}