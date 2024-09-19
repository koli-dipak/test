public class DAL_EngagementInternalAttendees {
    public static List<Engagement_Internal_Attendee__c> getEngagementInternalAttendeesByEngagementIds(Set<Id> engagementRecordIds){
        return [SELECT Id, Engagement__c, Internal_Attendee__c, Internal_Attendee__r.Name
                FROM Engagement_Internal_Attendee__c
                WHERE Engagement__c IN :engagementRecordIds];
    }
}