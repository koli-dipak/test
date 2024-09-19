public class DAL_LOB_Management {

    public static List<LOB_Management__c> getAllLOBManagementByOpp(Set<Id> oppIds){
        return [Select Id,  Name, RecordType.Name,LOB_Stage__c,Instructions_to_BPO__c,Priority_Rating__c,Opportunity_Related__r.Submission_Type__c,Type__c,Opportunity_Related__r.CloseDate,Opportunity_Related__r.Account.Name,Loss_Reason__c,Lost_Reason__c,Declined_Reason__c, Opportunity_Related__c,Opportunity_Related__r.Line_of_Business__c,Opportunity_Related__r.Name  From LOB_Management__c Where Opportunity_Related__c IN :oppIds]; 
    }
    
    public static List<RecordType> getAllLOBManagementRecordType(){
        return [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType Where SobjectType = 'LOB_Management__c'];
    }
    
    public Static LOB_Management__c getLOBManagementById(Id recId){
        return [SELECT Id, Opportunity_Related__r.Id, recordType.Name FROM LOB_Management__c Where id = :recId];
    }
    
    public Static List<LOB_Management__c> getLOBManagementByIds(Id recIds){
        return [SELECT Id, Opportunity_Related__r.Id,Opportunity_Related__r.Box_Folder_Id__c, recordType.Name,Opportunity_Related__r.Account.BillingState FROM LOB_Management__c Where id = :recIds];
    }

    public Static List<LOB_Management__c> getLOBRecordsByOppId(String OpportunityId){
        return [SELECT Id, Name, Estimated_LOB_Premium__c, LOB_Effective_Date__c, LOB_Stage__c, RecordType.Name, Referred_by__c, Underwriter__c, LOB_Underwriter_Instructions__c, Probability__c, Opportunity_Related__r.Prospect_Opportunity__c
                FROM LOB_Management__c
                WHERE Opportunity_Related__c = :OpportunityId];
    }
    public static List<Probability_Default_Percentage__mdt> getAllProbabilityDefaultPerMdt(){
        return [Select Id, MasterLabel,Percentage__c from Probability_Default_Percentage__mdt];
    }
    public static List<LOB_Management__c> getListOfLob(Id lobIds) {
        return [SELECT Id, LOB_Effective_Date__c, LOB_Stage__c, Opportunity_Related__c, Opportunity_Related__r.Prospect_Opportunity__c FROM LOB_Management__c where Id =:lobIds];
    }
    public static List<LOB_Management__c> getOrginalLob(List<Id> lobId){
       return [Select Id,Original_is_Cloned__c from LOB_Management__c where Id IN :lobId];
    }
    public static List<Lob_Stage_Picklist__mdt > getLobStageMdt(){
        return [select Id, DeveloperName,  Label from Lob_Stage_Picklist__mdt where DeveloperName = 'Declined' OR DeveloperName = 'Lost'];
    }
    public static List<LOB_Management__c> incGerRaterProgramId(){
       return [SELECT GerRater_Program_ID__c FROM LOB_Management__c WHERE GerRater_Program_ID__c != null ORDER BY CreatedDate DESC LIMIT 1];
    }
}