public class DAL_Case {

    public static List<Case> getCaseRecordsByIdSet(Set<Id> caseIds){
        return [SELECT Id, RecordTypeId,RecordType.Name, SuppliedEmail, SuppliedName, CaseNumber, OwnerId, Status, Subject, Description, ParentId, Priority, ClosedDate, CreatedDate, IsClosed, Closed_Days__c, ContactId, AccountId, Requesting_Office__c, Opportunity__c, Box_Folder_Name__c, Client__c FROM Case WHERE Id IN :CaseIds];
    }
    
    public static List<Case> getCaseRecordsByIdList(List<Case> newCaseList){
        return [select Id, CaseNumber, RecordType.Name, RecordTypeId, Owner.Name, Owner.Email, Subject,Status from Case where id IN :newCaseList];
    }
    
    public static List<Case> getCaseRecordsByIdSet(Set<Case> newCaseList){
        return [select Id, CaseNumber, RecordType.Name, RecordTypeId, Owner.Name, Owner.Email, Subject,Status from Case where id IN :newCaseList];
    }
    
    public static List<Case> getCaseRecordsBySetId(Set<Id> CaseIdRiskEnginer){
        return [SELECT Id, Topic__c, Origin, RecordTypeId FROM Case WHERE Id = :CaseIdRiskEnginer];
    }
}