trigger EngagementInternalAttendeesTrigger on Engagement_Internal_Attendee__c (before insert, before update) {
	new TH_EngagementInternalAttendees().run();
}