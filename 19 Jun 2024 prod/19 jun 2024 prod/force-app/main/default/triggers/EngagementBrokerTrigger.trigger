trigger EngagementBrokerTrigger on Engagement_Broker__c (before insert, before update) {
	new TH_EngagementBroker().run();
}