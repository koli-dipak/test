trigger EngagementInsuredTrigger on Engagement_Insured__c (before insert, before update) {
	new TH_EngagementInsured().run();
}