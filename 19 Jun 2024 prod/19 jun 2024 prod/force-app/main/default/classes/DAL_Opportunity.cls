public class DAL_Opportunity {

    /*public Static List<Opportunity> getAllOpportunityByAccount(Set<Id> accIds){
        return [Select Id, AccountId, Box_Folder_Name__c  From Opportunity Where AccountId IN :accIds];
    } */
    
    public Static List<Opportunity> getAllOpportunityById(Set<Id> oppIds){
        return [Select Id,Name, Underwriting_Associate__c, Underwriter_Name__c, StageName,owner.Account_Manager__c,Owner.FirstName,Owner.LastName,AccountId,Instructions_to_BPO__c,
                Account.Name,Submission_Type__c,Type,Zone__c,CloseDate,Submission_Source__c,leadsource
                From Opportunity Where Id IN :oppIds];
    } 
    
    public Static Map<Id,Opportunity> getAllOpportunityMapById(Set<Id> oppIds){
        Map<Id,Opportunity> oppMap = new Map<Id, Opportunity>(getAllOpportunityById(oppIds));
        return oppMap;
    }
    
    public Static Opportunity getOpportunityById(Id oppId){
        return [SELECT Id, Name, AccountId, Line_of_Business__c, CloseDate, External_Key__c
                FROM Opportunity Where id = :oppId];
    }
    
    public static List<Product_category__mdt> getAllProductCategoryMdt(){
        return [Select Id,DeveloperName,MasterLabel,Category__c From Product_category__mdt];
    }
    
    public Static List<USER> getUserByCurrentUserId(Set<Id> userIds){
        return [SELECT Id, Account_Manager__c, Underwriting_Associate__c, Territory__c FROM USER WHERE ID IN : userIds];
    }
    
    Static public List<Opportunity> getOpportunityAppliedEpicKeyPrefixList(Set<String> appliedEpickey){
       return [SELECT ID,Applied_Epic_key__c, Applied_Epic_key_Prefix__c FROM Opportunity WHERE Applied_Epic_key_Prefix__c IN :appliedEpickey];
    }
    
    public Static Group getQueue(){
        return [SELECT Id FROM Group WHERE Name = 'Clearance Queue' AND Type = 'Queue'][0];
    }
    public static List<Opportunity> getOppByAccountIds(Set<Id> accIds){
        return [SELECT Id, vlocity_ins__AgencyBrokerageId__c, Region__c FROM Opportunity WHERE vlocity_ins__AgencyBrokerageId__c IN :accIds];
    }
    
    public static List<Opportunity> getListOfOpp(Map<String, String> ParentAndChildOpportunityId) {
        return [select Id, Renewed_Opportunity__c, Prospect_Opportunity__c  from Opportunity where Id = :ParentAndChildOpportunityId.keySet()];
    }
    
}