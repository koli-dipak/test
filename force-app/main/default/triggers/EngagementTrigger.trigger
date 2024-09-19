trigger EngagementTrigger on Engagement__c (before insert, before update) {
	new TH_Engagement().run();
}