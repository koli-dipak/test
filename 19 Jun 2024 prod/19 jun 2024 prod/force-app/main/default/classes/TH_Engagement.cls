public class TH_Engagement extends BaseTriggerHandler{
private List<Engagement__c> newEngagementList;
    private List<Engagement__c> oldEngagementList;
    private Map<ID, Engagement__c> newEngagementMap;
    private Map<ID, Engagement__c> oldEngagementMap;
    
    public TH_Engagement()
    {
        oldEngagementList = (List<Engagement__c>)Trigger.old;
        newEngagementList = (List<Engagement__c>)Trigger.new;
        newEngagementMap = (Map<Id, Engagement__c>)Trigger.newMap;
        oldEngagementMap = (Map<Id, Engagement__c>)Trigger.oldMap;
    }
    
    protected override void beforeInsert() { 
        if(Trigger_PAD.canRun('TH_EngagementBeforeInsert')){
            proccesRecordBeforeEngagement(newEngagementList,oldEngagementMap);
        }
    } 
    
    protected override void beforeUpdate() { 
        if(Trigger_PAD.canRun('TH_EngagementBeforeUpdate')){
            proccesRecordBeforeEngagement(newEngagementList,oldEngagementMap);
        }
    }
     
    public static void proccesRecordBeforeEngagement(List<Engagement__c> newEngagementList, Map<Id, Engagement__c> oldEngagementMap){
        updateEndDate(newEngagementList, oldEngagementMap);
    }
    
    public static void updateEndDate(List<Engagement__c> newEngagementList, Map<Id, Engagement__c> oldEngagementMap){
        System.debug('@@newEngagementList::'+newEngagementList);
        
        for(Engagement__c engagement : newEngagementList){
            if(String.isNotBlank(String.valueOf(engagement.Start_Date_Time__c))){
                if(Trigger.isInsert 
                   || (Trigger.isUpdate && engagement.Start_Date_Time__c != oldEngagementMap.get(engagement.Id).Start_Date_Time__c)){
                    engagement.End_Date_Time__c = engagement.Start_Date_Time__c.addHours(1);
                }
            }
        }
    }
}