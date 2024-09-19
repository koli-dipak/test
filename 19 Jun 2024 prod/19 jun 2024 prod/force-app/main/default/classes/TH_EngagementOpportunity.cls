public class TH_EngagementOpportunity extends BaseTriggerHandler {
    private List<Engagement_Opportunity__c> newEngagementOpportunityList;
    private List<Engagement_Opportunity__c> oldEngagementOpportunityList;
    private Map<ID, Engagement_Opportunity__c> newEngagementOpportunityMap;
    private Map<ID, Engagement_Opportunity__c> oldEngagementOpportunityMap;
    
    public TH_EngagementOpportunity()
    {
        oldEngagementOpportunityList = (List<Engagement_Opportunity__c>)Trigger.old;
        newEngagementOpportunityList = (List<Engagement_Opportunity__c>)Trigger.new;
        newEngagementOpportunityMap = (Map<Id, Engagement_Opportunity__c>)Trigger.newMap;
        oldEngagementOpportunityMap = (Map<Id, Engagement_Opportunity__c>)Trigger.oldMap;
    }
    
    protected override void beforeInsert() { 
        if(Trigger_PAD.canRun('TH_EngagementOpportunityBeforeInsert')){
            processRecordBefore(newEngagementOpportunityList, oldEngagementOpportunityMap);
        }
    } 
    
    
    protected override void beforeUpdate()
    {
        if(Trigger_PAD.canRun('TH_EngagementOpportunityBeforeUpdate'))
        {
            
        }
    }

    public static void processRecordBefore(List<Engagement_Opportunity__c> newEngagementOpportunityList, Map<Id, Engagement_Opportunity__c> oldEngagementOpportunityMap){
        System.debug('@@newEngagementOpportunityList:::'+newEngagementOpportunityList);
        Set<Id> engagementRecordIds = new Set<Id>();
        List<Engagement_Opportunity__c> ExistingRecords = new List<Engagement_Opportunity__c>();
        Map<Id, Set<Id>> ExistingEngagementWiseOpportunityMap = new Map<Id, Set<Id>>();
        Map<Id, String> OpportunityIdWiseNameMap = new Map<Id, String>();
        Map<Id, List<String>> engagementIdWiseErrorNames = new Map<Id, List<String>>();
        Map<Id, List<Engagement_Opportunity__c>> engagementIdWiseErrorOpportunityRecords = new Map<Id, List<Engagement_Opportunity__c>>();

        for (Engagement_Opportunity__c engagementOpportunity : newEngagementOpportunityList) {
            engagementRecordIds.add(engagementOpportunity.Engagement__c);
        }

        if(!engagementRecordIds.isEmpty()){
            ExistingRecords = DAL_EngagementOpportunity.getEngagementOpportunityByEngagementIds(engagementRecordIds);
        }

        if(!ExistingRecords.isEmpty()){
            for (Engagement_Opportunity__c engagementOpportunity : ExistingRecords) {
                if(!ExistingEngagementWiseOpportunityMap.containsKey(engagementOpportunity.Engagement__c))
                    ExistingEngagementWiseOpportunityMap.put(engagementOpportunity.Engagement__c, new Set<Id>());
                ExistingEngagementWiseOpportunityMap.get(engagementOpportunity.Engagement__c).add(engagementOpportunity.Opportunity__c);
                OpportunityIdWiseNameMap.put(engagementOpportunity.Opportunity__c, engagementOpportunity.Opportunity__r.Name);
            }
        }

        if(!ExistingEngagementWiseOpportunityMap.isEmpty()){
            for (Engagement_Opportunity__c engagementOpportunity : newEngagementOpportunityList) {
                 if(ExistingEngagementWiseOpportunityMap.containsKey(engagementOpportunity.Engagement__c)){
                    for (Id engagementOpportunityId : ExistingEngagementWiseOpportunityMap.get(engagementOpportunity.Engagement__c)) {
                        if(engagementOpportunity.Opportunity__c == engagementOpportunityId){
                            // engagementOpportunity.addError('The records you are trying to include already exists in the list: '+OpportunityIdWiseNameMap.get(engagementOpportunity.Opportunity__c));
                            if(!engagementIdWiseErrorNames.containsKey(engagementOpportunity.Engagement__c)){
                                engagementIdWiseErrorNames.put(engagementOpportunity.Engagement__c, new List<String>());
                            }
                            engagementIdWiseErrorNames.get(engagementOpportunity.Engagement__c).add(OpportunityIdWiseNameMap.get(engagementOpportunity.Opportunity__c));
                            
                            if(!engagementIdWiseErrorOpportunityRecords.containsKey(engagementOpportunity.Engagement__c)){
                                engagementIdWiseErrorOpportunityRecords.put(engagementOpportunity.Engagement__c, new List<Engagement_Opportunity__c>());
                            }
                            engagementIdWiseErrorOpportunityRecords.get(engagementOpportunity.Engagement__c).add(engagementOpportunity);
                        }
                    }
                 }
            }
            system.debug('@@engagementIdWiseErrorNames::'+engagementIdWiseErrorNames);
            system.debug('@@engagementIdWiseErrorOpportunityRecords::'+engagementIdWiseErrorOpportunityRecords);
            if(!engagementIdWiseErrorNames.isEmpty()){
                for(Id engagementId : engagementIdWiseErrorNames.keySet()){
                    for(Engagement_Opportunity__c engagementOpportunity : engagementIdWiseErrorOpportunityRecords.get(engagementId)){
                        engagementOpportunity.addError(System.Label.Junction_object_record_already_exists_erorr + String.join(engagementIdWiseErrorNames.get(engagementId), ';'));
                    }
                }
            }
        }
    }
}