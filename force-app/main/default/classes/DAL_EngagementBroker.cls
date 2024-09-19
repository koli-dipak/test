public class DAL_EngagementBroker {
	public static List<Engagement_Broker__c> getEngagementBrokerByEngagementIds(Set<Id> engagementRecordIds){
        return [SELECT Id, Broker__c, Broker_Account__c, Broker_Account__r.Name
                                                          FROM Engagement_Broker__c
                                                          WHERE Broker__c IN :engagementRecordIds];
    }
}