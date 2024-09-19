public class DAL_EngagementExternalAttendees {
    public static List<Engagement_External_Attendee__c> getEngagementExternalAttendeesByEngagementIds(Set<Id> engagementRecordIds){
        return [SELECT Id, Engagement__c, External_Attendee__c, External_Attendee__r.Name
                FROM Engagement_External_Attendee__c
                WHERE Engagement__c IN :engagementRecordIds];
    }
}