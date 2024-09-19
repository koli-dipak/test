public class TH_EngagementInternalAttendees extends BaseTriggerHandler {
    private List<Engagement_Internal_Attendee__c> newEngagementInternalAttendeesList;
    private List<Engagement_Internal_Attendee__c> oldEngagementInternalAttendeesList;
    private Map<ID, Engagement_Internal_Attendee__c> newEngagementInternalAttendeesMap;
    private Map<ID, Engagement_Internal_Attendee__c> oldEngagementInternalAttendeesMap;
    
    public TH_EngagementInternalAttendees()
    {
        oldEngagementInternalAttendeesList = (List<Engagement_Internal_Attendee__c>)Trigger.old;
        newEngagementInternalAttendeesList = (List<Engagement_Internal_Attendee__c>)Trigger.new;
        newEngagementInternalAttendeesMap = (Map<Id, Engagement_Internal_Attendee__c>)Trigger.newMap;
        oldEngagementInternalAttendeesMap = (Map<Id, Engagement_Internal_Attendee__c>)Trigger.oldMap;
    }
    
    protected override void beforeInsert() { 
        if(Trigger_PAD.canRun('TH_EngagementInternalAttendeesBeforeInsert')){
            processRecordBefore(newEngagementInternalAttendeesList, oldEngagementInternalAttendeesMap);
        }
    } 
    
    
    protected override void beforeUpdate()
    {
        if(Trigger_PAD.canRun('TH_EngagementInternalAttendeesBeforeUpdate'))
        {
            
        }
    }

    public static void processRecordBefore(List<Engagement_Internal_Attendee__c> newEngagementInternalAttendeesList, Map<Id, Engagement_Internal_Attendee__c> oldEngagementInternalAttendeesMap){
        System.debug('@@newEngagementInternalAttendeesList:::'+newEngagementInternalAttendeesList);
        Set<Id> engagementRecordIds = new Set<Id>();
        List<Engagement_Internal_Attendee__c> ExistingRecords = new List<Engagement_Internal_Attendee__c>();
        Map<Id, Set<Id>> ExistingEngagementWiseInternalAttendeesMap = new Map<Id, Set<Id>>();
        Map<Id, String> InternalAttendeesIdWiseNameMap = new Map<Id, String>();
        Map<Id, List<String>> engagementIdWiseErrorNames = new Map<Id, List<String>>();
        Map<Id, List<Engagement_Internal_Attendee__c>> engagementIdWiseErrorInternalAttendeesRecords = new Map<Id, List<Engagement_Internal_Attendee__c>>();

        for (Engagement_Internal_Attendee__c InternalAttendees : newEngagementInternalAttendeesList) {
            engagementRecordIds.add(InternalAttendees.Engagement__c);
        }

        if(!engagementRecordIds.isEmpty()){
            ExistingRecords = DAL_EngagementInternalAttendees.getEngagementInternalAttendeesByEngagementIds(engagementRecordIds);
        }

        if(!ExistingRecords.isEmpty()){
            for (Engagement_Internal_Attendee__c InternalAttendees : ExistingRecords) {
                if(!ExistingEngagementWiseInternalAttendeesMap.containsKey(InternalAttendees.Engagement__c))
                    ExistingEngagementWiseInternalAttendeesMap.put(InternalAttendees.Engagement__c, new Set<Id>());
                ExistingEngagementWiseInternalAttendeesMap.get(InternalAttendees.Engagement__c).add(InternalAttendees.Internal_Attendee__c);
                InternalAttendeesIdWiseNameMap.put(InternalAttendees.Internal_Attendee__c, InternalAttendees.Internal_Attendee__r.Name);
            }
        }

        if(!ExistingEngagementWiseInternalAttendeesMap.isEmpty()){
            for (Engagement_Internal_Attendee__c InternalAttendees : newEngagementInternalAttendeesList) {
                 if(ExistingEngagementWiseInternalAttendeesMap.containsKey(InternalAttendees.Engagement__c)){
                    for (Id InternalAttendeesId : ExistingEngagementWiseInternalAttendeesMap.get(InternalAttendees.Engagement__c)) {
                        if(InternalAttendees.Internal_Attendee__c == InternalAttendeesId){
                            //InternalAttendees.addError('The records you are trying to include already exists in the list: '+InternalAttendeesIdWiseNameMap.get(InternalAttendees.Internal_Attendee__c));
                            if(!engagementIdWiseErrorNames.containsKey(InternalAttendees.Engagement__c)){
                                engagementIdWiseErrorNames.put(InternalAttendees.Engagement__c, new List<String>());
                            }
                            engagementIdWiseErrorNames.get(InternalAttendees.Engagement__c).add(InternalAttendeesIdWiseNameMap.get(InternalAttendees.Internal_Attendee__c));
                            
                            if(!engagementIdWiseErrorInternalAttendeesRecords.containsKey(InternalAttendees.Engagement__c)){
                                engagementIdWiseErrorInternalAttendeesRecords.put(InternalAttendees.Engagement__c, new List<Engagement_Internal_Attendee__c>());
                            }
                            engagementIdWiseErrorInternalAttendeesRecords.get(InternalAttendees.Engagement__c).add(InternalAttendees);
                        }
                    }
                 }
            }
            system.debug('@@engagementIdWiseErrorNames::'+engagementIdWiseErrorNames);
            system.debug('@@engagementIdWiseErrorInternalAttendeesRecords::'+engagementIdWiseErrorInternalAttendeesRecords);
            if(!engagementIdWiseErrorNames.isEmpty()){
                for(Id engagementId : engagementIdWiseErrorNames.keySet()){
                    for(Engagement_Internal_Attendee__c InternalAttendees : engagementIdWiseErrorInternalAttendeesRecords.get(engagementId)){
                        InternalAttendees.addError(System.Label.Junction_object_record_already_exists_erorr + String.join(engagementIdWiseErrorNames.get(engagementId), ';'));
                    }
                }
            }
        }
    }
}