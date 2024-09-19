public class DAL_EngagementOpportunity {
    public static List<Engagement_Opportunity__c> getEngagementOpportunityByEngagementIds(Set<Id> engagementRecordIds){
        return [SELECT Id, Engagement__c, Opportunity__c, Opportunity__r.Name
                FROM Engagement_Opportunity__c
                WHERE Engagement__c IN :engagementRecordIds];
    }
}