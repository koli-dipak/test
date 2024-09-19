public class DAL_OpportunityLineItem {

    public static List<OpportunityLineItem> getAllOpportunityLineItem(Set<Id> oppIds){
        return [Select Id, Name, Product2Id, Product2.Name, Product2.ExternalId__c , OpportunityId From OpportunityLineItem Where OpportunityId IN :oppIds];
    }
}