public class TH_EngagementExternalAttendees extends BaseTriggerHandler {
    private List<Engagement_External_Attendee__c> newEngagementExternalAttendeesList;
    private List<Engagement_External_Attendee__c> oldEngagementExternalAttendeesList;
    private Map<ID, Engagement_External_Attendee__c> newEngagementExternalAttendeesMap;
    private Map<ID, Engagement_External_Attendee__c> oldEngagementExternalAttendeesMap;
    
    public TH_EngagementExternalAttendees()
    {
        oldEngagementExternalAttendeesList = (List<Engagement_External_Attendee__c>)Trigger.old;
        newEngagementExternalAttendeesList = (List<Engagement_External_Attendee__c>)Trigger.new;
        newEngagementExternalAttendeesMap = (Map<Id, Engagement_External_Attendee__c>)Trigger.newMap;
        oldEngagementExternalAttendeesMap = (Map<Id, Engagement_External_Attendee__c>)Trigger.oldMap;
    }
    
    protected override void beforeInsert() { 
        if(Trigger_PAD.canRun('TH_EngagementExternalAttendeesBeforeInsert')){
            processRecordBefore(newEngagementExternalAttendeesList, oldEngagementExternalAttendeesMap);
        }
    } 
    
    
    protected override void beforeUpdate()
    {
        if(Trigger_PAD.canRun('TH_EngagementExternalAttendeesBeforeUpdate'))
        {
            
        }
    }

    public static void processRecordBefore(List<Engagement_External_Attendee__c> newEngagementExternalAttendeesList, Map<Id, Engagement_External_Attendee__c> oldEngagementExternalAttendeesMap){
        System.debug('@@newEngagementExternalAttendeesList:::'+newEngagementExternalAttendeesList);
        Set<Id> engagementRecordIds = new Set<Id>();
        List<Engagement_External_Attendee__c> ExistingRecords = new List<Engagement_External_Attendee__c>();
        Map<Id, Set<Id>> ExistingEngagementWiseExternalAttendeesMap = new Map<Id, Set<Id>>();
        Map<Id, String> ExternalAttendeesIdWiseNameMap = new Map<Id, String>();
        Map<Id, List<String>> engagementIdWiseErrorNames = new Map<Id, List<String>>();
        Map<Id, List<Engagement_External_Attendee__c>> engagementIdWiseErrorExternalAttendeesRecords = new Map<Id, List<Engagement_External_Attendee__c>>();

        for (Engagement_External_Attendee__c ExternalAttendees : newEngagementExternalAttendeesList) {
            engagementRecordIds.add(ExternalAttendees.Engagement__c);
        }

        if(!engagementRecordIds.isEmpty()){
            ExistingRecords = DAL_EngagementExternalAttendees.getEngagementExternalAttendeesByEngagementIds(engagementRecordIds);
        }

        if(!ExistingRecords.isEmpty()){
            for (Engagement_External_Attendee__c ExternalAttendees : ExistingRecords) {
                if(!ExistingEngagementWiseExternalAttendeesMap.containsKey(ExternalAttendees.Engagement__c))
                    ExistingEngagementWiseExternalAttendeesMap.put(ExternalAttendees.Engagement__c, new Set<Id>());
                ExistingEngagementWiseExternalAttendeesMap.get(ExternalAttendees.Engagement__c).add(ExternalAttendees.External_Attendee__c);
                ExternalAttendeesIdWiseNameMap.put(ExternalAttendees.External_Attendee__c, ExternalAttendees.External_Attendee__r.Name);
            }
        }

        if(!ExistingEngagementWiseExternalAttendeesMap.isEmpty()){
            for (Engagement_External_Attendee__c ExternalAttendees : newEngagementExternalAttendeesList) {
                 if(ExistingEngagementWiseExternalAttendeesMap.containsKey(ExternalAttendees.Engagement__c)){
                    for (Id ExternalAttendeesId : ExistingEngagementWiseExternalAttendeesMap.get(ExternalAttendees.Engagement__c)) {
                        if(ExternalAttendees.External_Attendee__c == ExternalAttendeesId){
                            //ExternalAttendees.addError('The records you are trying to include already exists in the list: '+ExternalAttendeesIdWiseNameMap.get(ExternalAttendees.External_Attendee__c));
                            if(!engagementIdWiseErrorNames.containsKey(ExternalAttendees.Engagement__c)){
                                engagementIdWiseErrorNames.put(ExternalAttendees.Engagement__c, new List<String>());
                            }
                            engagementIdWiseErrorNames.get(ExternalAttendees.Engagement__c).add(ExternalAttendeesIdWiseNameMap.get(ExternalAttendees.External_Attendee__c));
                            
                            if(!engagementIdWiseErrorExternalAttendeesRecords.containsKey(ExternalAttendees.Engagement__c)){
                                engagementIdWiseErrorExternalAttendeesRecords.put(ExternalAttendees.Engagement__c, new List<Engagement_External_Attendee__c>());
                            }
                            engagementIdWiseErrorExternalAttendeesRecords.get(ExternalAttendees.Engagement__c).add(ExternalAttendees);
                        }
                    }
                 }
            }
            system.debug('@@engagementIdWiseErrorNames::'+engagementIdWiseErrorNames);
            system.debug('@@engagementIdWiseErrorExternalAttendeesRecords::'+engagementIdWiseErrorExternalAttendeesRecords);
            if(!engagementIdWiseErrorNames.isEmpty()){
                for(Id engagementId : engagementIdWiseErrorNames.keySet()){
                    for(Engagement_External_Attendee__c ExternalAttendees : engagementIdWiseErrorExternalAttendeesRecords.get(engagementId)){
                        ExternalAttendees.addError(System.Label.Junction_object_record_already_exists_erorr + String.join(engagementIdWiseErrorNames.get(engagementId), ';'));
                    }
                }
            }
        }
    }
}