trigger EngagementOpportunityTrigger on Engagement_Opportunity__c (before insert, before update) {
	new TH_EngagementOpportunity().run();
}