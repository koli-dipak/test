public class DAL_DocumentChecklistItem {
    
    public static Integer getCompletedChecklistCount(String quoteIds) {
        return [
            SELECT COUNT()
            FROM DocumentChecklistItem
            WHERE Generate_Quote_and_Binder__c = :quoteIds
            AND Status = 'Complete'
            AND Type__c  != 'Note'
            
        ];
    }
    public static Integer getDocumentChecklistItemCount(String quoteIds) {
        return [
            SELECT COUNT()
            FROM DocumentChecklistItem
            WHERE Generate_Quote_and_Binder__c = :quoteIds
            AND Type__c  != 'Note'
            
        ];
    }
    
    public static List<DocumentChecklistItem> getDocumentChecklistItems(List<Id> documentChecklistItemIds) {
        return [
            SELECT Id
            FROM DocumentChecklistItem
            WHERE Id IN :documentChecklistItemIds
        ];
    }
    public static List<DocumentChecklistItem> getDocumentChecklistItems(Set<Id> documentChecklistItemIds) {
        return [
            SELECT Id
            FROM DocumentChecklistItem
            WHERE Id IN :documentChecklistItemIds
        ];
    }
    
    public static List<DocumentChecklistItem> getQuotedChecklist(Id parentId) {
        return [SELECT Id, Name, Generate_Quote_and_Binder__c,Type__c,Country_States__c,Status, Instruction, Line_of_Business__c, Rating_ID__c 
                FROM DocumentChecklistItem 
                WHERE Generate_Quote_and_Binder__c = :parentId AND Quote_Line_Item__r.Stage__c = 'Quoted'];
    }
    
    public static List<DocumentChecklistItem> getBinderChecklist(Id parentId) {
        return [SELECT Id, Name, Generate_Quote_and_Binder__c, Status,Type__c, Instruction, Line_of_Business__c, Rating_ID__c 
                FROM DocumentChecklistItem 
                WHERE Generate_Quote_and_Binder__c = :parentId AND Quote_Line_Item__r.Stage__c = 'Binder' AND Type__c = 'Checklist'];
    }
    
    public static List<DocumentChecklistItem> getRelatedBinderChecklist(Id parentId) {
        return [SELECT Id, Name, Generate_Quote_and_Binder__c,Country_States__c, Quote_Line_Item_Status__c,Status, Type__c, Instruction, Line_of_Business__c, Rating_ID__c 
                FROM DocumentChecklistItem WHERE Generate_Quote_and_Binder__c = :parentId AND Quote_Line_Item_Status__c = 'Binder'];
    }
    
    
}