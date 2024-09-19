public class DAL_EngagementInsured {
	public static List<Engagement_Insured__c> getEngagementInsuredByEngagementIds(Set<Id> engagementRecordIds){
        return [SELECT Id, Engagement__c, Insured__c, Insured__r.Name
                                                          FROM Engagement_Insured__c
                                                          WHERE Engagement__c IN :engagementRecordIds];
    }
}