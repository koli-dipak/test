public class TH_EngagementInsured extends BaseTriggerHandler {
    private List<Engagement_Insured__c> newEngagementInsuredList;
    private List<Engagement_Insured__c> oldEngagementInsuredList;
    private Map<ID, Engagement_Insured__c> newEngagementInsuredMap;
    private Map<ID, Engagement_Insured__c> oldEngagementInsuredMap;
    
    public TH_EngagementInsured()
    {
        oldEngagementInsuredList = (List<Engagement_Insured__c>)Trigger.old;
        newEngagementInsuredList = (List<Engagement_Insured__c>)Trigger.new;
        newEngagementInsuredMap = (Map<Id, Engagement_Insured__c>)Trigger.newMap;
        oldEngagementInsuredMap = (Map<Id, Engagement_Insured__c>)Trigger.oldMap;
    }
    
    protected override void beforeInsert() { 
        if(Trigger_PAD.canRun('TH_EngagementInsuredBeforeInsert')){
            processRecordBefore(newEngagementInsuredList, oldEngagementInsuredMap);
        }
    } 
    
    
    protected override void beforeUpdate()
    {
        if(Trigger_PAD.canRun('TH_EngagementInsuredBeforeUpdate'))
        {
            
        }
    }

    public static void processRecordBefore(List<Engagement_Insured__c> newEngagementInsuredList, Map<Id, Engagement_Insured__c> oldEngagementInsuredMap){
        System.debug('@@newEngagementInsuredList:::'+newEngagementInsuredList);
        Set<Id> engagementRecordIds = new Set<Id>();
        List<Engagement_Insured__c> ExistingRecords = new List<Engagement_Insured__c>();
        Map<Id, Set<Id>> ExistingEngagementWiseInsuredAccountsMap = new Map<Id, Set<Id>>();
        Map<Id, String> InsuredAccountIdWiseNameMap = new Map<Id, String>();
        Map<Id, List<String>> engagementIdWiseErrorNames = new Map<Id, List<String>>();
        Map<Id, List<Engagement_Insured__c>> engagementIdWiseErrorInsuredRecords = new Map<Id, List<Engagement_Insured__c>>();

        for (Engagement_Insured__c Insured : newEngagementInsuredList) {
            engagementRecordIds.add(Insured.Engagement__c);
        }

        if(!engagementRecordIds.isEmpty()){
            ExistingRecords = DAL_EngagementInsured.getEngagementInsuredByEngagementIds(engagementRecordIds);
        }

        if(!ExistingRecords.isEmpty()){
            for (Engagement_Insured__c Insured : ExistingRecords) {
                if(!ExistingEngagementWiseInsuredAccountsMap.containsKey(Insured.Engagement__c))
                    ExistingEngagementWiseInsuredAccountsMap.put(Insured.Engagement__c, new Set<Id>());
                ExistingEngagementWiseInsuredAccountsMap.get(Insured.Engagement__c).add(Insured.Insured__c);
                InsuredAccountIdWiseNameMap.put(Insured.Insured__c, Insured.Insured__r.Name);
            }
        }

        if(!ExistingEngagementWiseInsuredAccountsMap.isEmpty()){
            for (Engagement_Insured__c Insured : newEngagementInsuredList) {
                 if(ExistingEngagementWiseInsuredAccountsMap.containsKey(Insured.Engagement__c)){
                    for (Id InsuredAccountId : ExistingEngagementWiseInsuredAccountsMap.get(Insured.Engagement__c)) {
                        if(Insured.Insured__c == InsuredAccountId){
                            //Insured.addError('The records you are trying to include already exists in the list: '+InsuredAccountIdWiseNameMap.get(Insured.Insured__c));
                            if(!engagementIdWiseErrorNames.containsKey(Insured.Engagement__c)){
                                engagementIdWiseErrorNames.put(Insured.Engagement__c, new List<String>());
                            }
                            engagementIdWiseErrorNames.get(Insured.Engagement__c).add(InsuredAccountIdWiseNameMap.get(Insured.Insured__c));
                            
                            if(!engagementIdWiseErrorInsuredRecords.containsKey(Insured.Engagement__c)){
                                engagementIdWiseErrorInsuredRecords.put(Insured.Engagement__c, new List<Engagement_Insured__c>());
                            }
                            engagementIdWiseErrorInsuredRecords.get(Insured.Engagement__c).add(Insured);
                        }
                    }
                 }
            }
            system.debug('@@engagementIdWiseErrorNames::'+engagementIdWiseErrorNames);
            system.debug('@@engagementIdWiseErrorInsuredRecords::'+engagementIdWiseErrorInsuredRecords);
            if(!engagementIdWiseErrorNames.isEmpty()){
                for(Id engagementId : engagementIdWiseErrorNames.keySet()){
                    for(Engagement_Insured__c Insured : engagementIdWiseErrorInsuredRecords.get(engagementId)){
                        Insured.addError(System.Label.Junction_object_record_already_exists_erorr + String.join(engagementIdWiseErrorNames.get(engagementId), ';'));
                    }
                }
            }
        }
    }
}