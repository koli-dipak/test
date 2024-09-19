public class TH_Clearance extends BaseTriggerHandler {
	private List<Clearance__c> newClearanceList;
    private List<Clearance__c> oldClearanceList;
    private Map<ID, Clearance__c> newClearanceMap;
    private Map<ID, Clearance__c> oldClearanceMap;
    
    public TH_Clearance()
    {
        oldClearanceList = (List<Clearance__c>)Trigger.old;
        newClearanceList = (List<Clearance__c>)Trigger.new;
        newClearanceMap = (Map<Id, Clearance__c>)Trigger.newMap;
        oldClearanceMap = (Map<Id, Clearance__c>)Trigger.oldMap;
    }
    protected override void BeforeInsert(){
        if(Trigger_PAD.canRun('TH_ClearanceBeforeInsert')){
            proccesRecordBeforeClearance(newClearanceList,oldClearanceMap);
        }
    }
    protected override void BeforeUpdate(){
        if(Trigger_PAD.canRun('TH_ClearanceBeforeUpdate')){
            proccesRecordBeforeClearance(newClearanceList,oldClearanceMap);
        }
    }
    public static void proccesRecordBeforeClearance(List<Clearance__c> newClearanceList,Map<Id, Clearance__c> oldClearanceMap){
        Set<Id> oppIds = new Set<Id>();
        for(Clearance__c cr : newClearanceList){
            if(oldClearanceMap==null || (oldClearanceMap!=null && oldClearanceMap.get(cr.Id).RecordTypeId!=cr.RecordTypeId)){
                oppIds.add(cr.Opportunity__c);
            }
            
        }
        // Get Existing Data
        List<Clearance__c> allClearanceList = DAL_Clearance.getAllClearanceByOpp(oppIds);
        Map<Id,Set<String> > opportunitycrRecordTypeMap = new Map<Id,Set<String> >();
        for(Clearance__c cr : allClearanceList){
            if(!opportunitycrRecordTypeMap.containsKey(cr.Opportunity__c)){
                opportunitycrRecordTypeMap.put(cr.Opportunity__c,new Set<String>());
            }
            opportunitycrRecordTypeMap.get(cr.Opportunity__c).add(cr.RecordTypeId);
        }
        
        for(Clearance__c cr : newClearanceList){
            if(oldClearanceMap==null || (oldClearanceMap!=null && oldClearanceMap.get(cr.Id).RecordTypeId != cr.RecordTypeId)){
                if(!opportunitycrRecordTypeMap.containsKey(cr.Opportunity__c)){
                    opportunitycrRecordTypeMap.put(cr.Opportunity__c,new Set<String>());
                }
                if(opportunitycrRecordTypeMap.get(cr.Opportunity__c).contains(cr.RecordTypeId)){
                    cr.addError('Clearance Tracker record is already exist with same record type');
                }
                else{
                    opportunitycrRecordTypeMap.get(cr.Opportunity__c).add(cr.RecordTypeId);
                }
            }
        }
    }
}