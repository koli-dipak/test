trigger EngagementExternalAttendeesTrigger on Engagement_External_Attendee__c (before insert, before update) {
	new TH_EngagementExternalAttendees().run();
}