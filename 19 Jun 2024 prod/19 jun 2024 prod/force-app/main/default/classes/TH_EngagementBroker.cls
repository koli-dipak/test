public class TH_EngagementBroker extends BaseTriggerHandler {
    private List<Engagement_Broker__c> newEngagementBrokerList;
    private List<Engagement_Broker__c> oldEngagementBrokerList;
    private Map<ID, Engagement_Broker__c> newEngagementBrokerMap;
    private Map<ID, Engagement_Broker__c> oldEngagementBrokerMap;
    
    public TH_EngagementBroker()
    {
        oldEngagementBrokerList = (List<Engagement_Broker__c>)Trigger.old;
        newEngagementBrokerList = (List<Engagement_Broker__c>)Trigger.new;
        newEngagementBrokerMap = (Map<Id, Engagement_Broker__c>)Trigger.newMap;
        oldEngagementBrokerMap = (Map<Id, Engagement_Broker__c>)Trigger.oldMap;
    }
    
    protected override void beforeInsert() { 
        if(Trigger_PAD.canRun('TH_EngagementBrokerBeforeInsert')){
            processRecordBefore(newEngagementBrokerList, oldEngagementBrokerMap);
        }
    } 
    
    
    protected override void beforeUpdate()
    {
        if(Trigger_PAD.canRun('TH_EngagementBrokerBeforeUpdate'))
        {
            
        }
    }
    
    public static void processRecordBefore(List<Engagement_Broker__c> newEngagementBrokerList, Map<Id, Engagement_Broker__c> oldEngagementBrokerMap){
        System.debug('@@newEngagementBrokerList:::'+newEngagementBrokerList);
        Set<Id> engagementRecordIds = new Set<Id>();
        List<Engagement_Broker__c> ExistingRecords = new List<Engagement_Broker__c>();
        Map<Id, Set<Id>> ExistingBrokerWiseBrokerAccountsMap = new Map<Id, Set<Id>>();
        Map<Id, String> BrokerAccountIdWiseNameMap = new Map<Id, String>();
        Map<Id, List<String>> engagementIdWiseErrorNames = new Map<Id, List<String>>();
        Map<Id, List<Engagement_Broker__c>> engagementIdWiseErrorEngagementRecords = new Map<Id, List<Engagement_Broker__c>>();
        
        for (Engagement_Broker__c broker : newEngagementBrokerList) {
            engagementRecordIds.add(broker.Broker__c);
        }
        
        if(!engagementRecordIds.isEmpty()){
            ExistingRecords = DAL_EngagementBroker.getEngagementBrokerByEngagementIds(engagementRecordIds);
        }
        
        if(!ExistingRecords.isEmpty()){
            for (Engagement_Broker__c broker : ExistingRecords) {
                if(!ExistingBrokerWiseBrokerAccountsMap.containsKey(broker.Broker__c))
                    ExistingBrokerWiseBrokerAccountsMap.put(broker.Broker__c, new Set<Id>());
                ExistingBrokerWiseBrokerAccountsMap.get(broker.Broker__c).add(broker.Broker_Account__c);
                BrokerAccountIdWiseNameMap.put(broker.Broker_Account__c, broker.Broker_Account__r.Name);
            }
        }
        
        if(!ExistingBrokerWiseBrokerAccountsMap.isEmpty()){
            for (Engagement_Broker__c broker : newEngagementBrokerList) {
                if(ExistingBrokerWiseBrokerAccountsMap.containsKey(broker.Broker__c)){
                    for (Id brokerAccountId : ExistingBrokerWiseBrokerAccountsMap.get(broker.Broker__c)) {
                        if(broker.Broker_Account__c == brokerAccountId){
                            //broker.addError('The records you are trying to include already exists in the list: '+BrokerAccountIdWiseNameMap.get(broker.Broker_Account__c));
                            if(!engagementIdWiseErrorNames.containsKey(broker.Broker__c)){
                                engagementIdWiseErrorNames.put(broker.Broker__c, new List<String>());
                            }
                            engagementIdWiseErrorNames.get(broker.Broker__c).add(BrokerAccountIdWiseNameMap.get(broker.Broker_Account__c));
                            
                            if(!engagementIdWiseErrorEngagementRecords.containsKey(broker.Broker__c)){
                                engagementIdWiseErrorEngagementRecords.put(broker.Broker__c, new List<Engagement_Broker__c>());
                            }
                            engagementIdWiseErrorEngagementRecords.get(broker.Broker__c).add(broker);
                        }
                    }
                }
            }
            system.debug('@@engagementIdWiseErrorNames::'+engagementIdWiseErrorNames);
            system.debug('@@engagementIdWiseErrorEngagementRecords::'+engagementIdWiseErrorEngagementRecords);
            if(!engagementIdWiseErrorNames.isEmpty()){
                for(Id engagementId : engagementIdWiseErrorNames.keySet()){
                    for(Engagement_Broker__c broker : engagementIdWiseErrorEngagementRecords.get(engagementId)){
                        broker.addError(System.Label.Junction_object_record_already_exists_erorr + String.join(engagementIdWiseErrorNames.get(engagementId), ';'));
                    }
                }
            }
        }
    }
}