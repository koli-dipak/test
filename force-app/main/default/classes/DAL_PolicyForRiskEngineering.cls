public class DAL_PolicyForRiskEngineering {

    public static List<Case_and_InsurancePolicy__c> getCasePolicyRecordsByCaseIds(Set<Id> caseIds){
        return [SELECT Id, Case__c, Insurance_Policy__c, Insurance_Policy__r.Name FROM Case_and_InsurancePolicy__c WHERE Case__c IN :caseIds];
    }
}