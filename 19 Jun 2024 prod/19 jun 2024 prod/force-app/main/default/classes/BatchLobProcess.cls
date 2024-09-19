global class BatchLobProcess implements  Database.Batchable<sObject>,Database.Stateful,Schedulable{
    /*private Date targetDate;
    global BatchLobProcess(){
        // Calculate the targetDate here
        targetDate = Date.today().addDays(180);
    }*/

    global Database.QueryLocator start(Database.BatchableContext ctx){
        Map<String, Integer> MapPeriod = new Map<String, Integer>();
        //List<Renewal_Configurable_Period__mdt> periodList = [select DeveloperName, Period__c from Renewal_Configurable_Period__mdt];
        List<Renewal_Configurable_Period__mdt> periodList = DAL_Utility.getListOfPeriod();
        if(periodList.size()>0){
            for(Renewal_Configurable_Period__mdt rec : periodList){
                 MapPeriod.put(rec.DeveloperName, (Integer)rec.Period__c);
            }
        }
        Integer period = MapPeriod.get('X180_days_before_the_expiry_date');
        System.debug('period@@ '+ period);
        //String query = 'SELECT Id, LOB_Effective_Date__c, LOB_Stage__c, Opportunity_Related__c,Opportunity_Related__r.Prospect_Opportunity__c FROM LOB_Management__c WHERE LOB_Stage__c = \'Bound\' AND LOB_Effective_Date__c = NEXT_N_DAYS:180';
        //String query = 'SELECT Id, LOB_Effective_Date__c, LOB_Stage__c, Opportunity_Related__c, Opportunity_Related__r.Prospect_Opportunity__c FROM LOB_Management__c WHERE LOB_Stage__c = \'Bound\' AND LOB_Effective_Date__c = :targetDate AND RecordType.Name != \'Builders Risk\' AND Cloned__c != true';
        //Date targetDate = Date.today().addDays(-180);
        Date targetDate = Date.today().addDays(period);
        String query = 'SELECT Id, LOB_Effective_Date__c, LOB_Stage__c, Opportunity_Related__c, Opportunity_Related__r.Prospect_Opportunity__c FROM LOB_Management__c WHERE LOB_Stage__c = \'Bound\' AND Original_is_Cloned__c!=true AND RecordType.Name != \'Builders Risk\' AND Lob_Expiry_Date__c = :targetDate';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext ctx, List<LOB_Management__c> scope) {
        
        set<id> lobId = new set<id>();
        Map<String, String> ParentAndChildOpportunityId = new Map<String, String>();
        Map<String, String> ParentAndChildLobId = new Map<String, String>();
        set<id> oppid = new set<id>();
        
        for (LOB_Management__c lob : scope) {
            lobId.add(lob.Id);
            if(lob.Opportunity_Related__r.Prospect_Opportunity__c == null){
                oppid.add(lob.Opportunity_Related__c);
            }else{
                ParentAndChildOpportunityId.put(lob.Opportunity_Related__c, lob.Opportunity_Related__r.Prospect_Opportunity__c);
            }
            ParentAndChildLobId.put(lob.Id, lob.Opportunity_Related__c);
        }
        if(oppid.size() > 0){
            List<Opportunity> cloneOpportunityRecords = cloneOpportunityRecord(oppid);
            
            for(Opportunity cloneOppRec : cloneOpportunityRecords){
                ParentAndChildOpportunityId.put(cloneOppRec.Renewed_Opportunity__c, cloneOppRec.Id);
            }
            
            //List<Opportunity> PropectOpp = [select Id, Renewed_Opportunity__c, Prospect_Opportunity__c  from Opportunity where Id = :ParentAndChildOpportunityId.keySet()];
            List<Opportunity> PropectOpp = DAL_Opportunity.getListOfOpp(ParentAndChildOpportunityId);
            
            for(Opportunity PropectOppRec : PropectOpp){
                if(ParentAndChildOpportunityId.containsKey(PropectOppRec.Id) && PropectOppRec.Prospect_Opportunity__c == null){
                    PropectOppRec.Prospect_Opportunity__c = ParentAndChildOpportunityId.get(PropectOppRec.Id);
                }
            }
            
            update PropectOpp;
        }
        
        
        List<LOB_Management__c> cloneLobRecords = cloneLobRecord(lobId, ParentAndChildLobId, ParentAndChildOpportunityId);
                
    }
    
    public List<Opportunity> cloneOpportunityRecord(set<id> oppid){
        System.debug('@@oppid '+oppid);
        String ObjName = 'Opportunity';
        SObjectType objToken = Schema.getGlobalDescribe().get(ObjName);
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap();
        List<String> fieldslist = new List<String>();
        String relationshipField = 'Renewed_Opportunity__c';
        //List<String> Skipfieldslist = new List<String>{'applied_epic_key__c', 'line_of_business__c'};
        Set<String> Skipfieldslist = new Set<String>();
        Map<String, Set<String>> SkipList = DAL_ObjectCloneSkippedField.getChildSkipListByParentName(ObjName);
        System.debug('@@SkipField'+ JSON.Serialize(SkipList));
        if(SkipList!=null && SkipList.containsKey(ObjName)) {
            Skipfieldslist = toLowerSet(SkipList.get(ObjName));
            Skipfieldslist.add('line_of_business__c');
        }
        
        //String recordTypeId = [select Id, Name, DeveloperName, NamespacePrefix, Description, BusinessProcessId, SobjectType, IsActive, IsPersonType, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, SystemModstamp from RecordType where SobjectType = 'Opportunity' And DeveloperName = 'Prospect_Opportunity' Limit 1].Id;
        for(String fieldName : fields.keySet()) {
            System.debug('--fieldname--'+ fieldName);
            if(fields.containsKey(fieldName) && fields.get(fieldName).getDescribe().isCreateable() && !Skipfieldslist.contains(fieldName)){
                fieldslist.add(fieldName);
            }
        }
        fieldslist.add('Account.Name');
        String query;
        if(oppid.size() > 0){
            query   = 'SELECT ' + String.join(fieldslist, ',') + ' FROM Opportunity WHERE Id IN : oppid';
        }
        System.debug('query ===['+JSON.Serialize(query));
        List<Opportunity> sObjList = new List<Opportunity>();
        if(fieldslist.size() > 0 && (query != null || query != '')){
            sObjList = Database.query(query); 
        }
        
        List<SObject> clonedObjList = new List<SObject>();
        
        
        for(Opportunity obj : sObjList){
            System.debug('@@obj ' + JSON.Serialize(obj));
            SObject clonedSobj;
            clonedSobj  = obj.clone(false, false, false, false);
            
            if(clonedSobj!=null){
                // update relationshipField with parentRecordId
                if(String.isNotBlank(relationshipField)){
                    clonedSobj.put(relationshipField,obj.Id);
                    //clonedSobj.put('recordtypeid',recordTypeId);
                    clonedSobj.put('is_prospect_opportunity__c',true);
                    clonedSobj.put('cloned__c',true);
                    clonedSobj.put('isClonedFromBatch__c',true);
                    clonedSobj.put('StageName','Interest');
                    clonedSobj.put('Type','Renewal');
                    Date originalCloseDate = (Date)obj.get('CloseDate');
                    Integer yearsToAdd = 1;
                    Date newCloseDate = originalCloseDate.addYears(yearsToAdd);
                    
                    // update oppName
                    String accName=obj.Account.Name;
                    if(accName.length() >= 70)
                    {
                        accName = accName.substring(0, 69);
                    }
                     
                    String opportunityName = accName +' - '+ (String)obj.get('Submission_Type__c') +' - Renewal - '+Datetime.newInstance(newCloseDate.year(), newCloseDate.month(),newCloseDate.day()).format('yyyy-MM-dd');
                    if(opportunityName.length() >= 120)
                    {
                        opportunityName = opportunityName.substring(0, 119);
                    }
                    clonedSobj.put('Name',opportunityName);
                    clonedSobj.put('closedate',newCloseDate);
                }
            }
            clonedObjList.add(clonedSobj);
        }
        System.debug('@@clonedObjList'+clonedObjList);
        if(clonedObjList.size() > 0){
            BaseTriggerHandler.bypass('TH_OPPORTUNITY');
            System.debug('@@@clonedObjListRec : '+clonedObjList);
            insert clonedObjList;
            System.debug('@@@clonedObjListRec : '+clonedObjList);
            BaseTriggerHandler.clearbypass('TH_OPPORTUNITY');
            return clonedObjList;
        }
        return null;
    }
    
    public List<LOB_Management__c> cloneLobRecord(set<id> lobId, Map<String, String> ParentAndChildLobId, Map<String, String> ParentAndChildOpportunityId){
        String ObjName = 'LOB_Management__c';
        SObjectType objToken = Schema.getGlobalDescribe().get(ObjName);
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap();
        List<String> fieldslist = new List<String>();
        String relationshipField = 'Renewed_Line_of_Business__c';
        //List<String> Skipfieldslist = new List<String>{'applied_epic_key__c', 'line_of_business__c'};
        Set<String> Skipfieldslist = new Set<String>();
        Map<String, Set<String>> SkipList = DAL_ObjectCloneSkippedField.getChildSkipListByParentName('Opportunity');
        System.debug('@@SkipField'+ JSON.Serialize(SkipList));
        if(SkipList!=null && SkipList.containsKey(ObjName)) {
            Skipfieldslist = toLowerSet(SkipList.get(ObjName));
        }
        
        //String recordTypeId = [select Id, Name, DeveloperName, NamespacePrefix, Description, BusinessProcessId, SobjectType, IsActive, IsPersonType, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, SystemModstamp from RecordType where SobjectType = 'Opportunity' And DeveloperName = 'Prospect_Opportunity' Limit 1].Id;
        for(String fieldName : fields.keySet()) {
            System.debug('--fieldname--'+ fieldName);
            if(fields.containsKey(fieldName) && fields.get(fieldName).getDescribe().isCreateable() && !Skipfieldslist.contains(fieldName)){
                fieldslist.add(fieldName);
            }
        }
        
        String query;
        if(lobId.size() > 0){
            query   = 'SELECT ' + String.join(fieldslist, ',') + ' FROM LOB_Management__c WHERE Id IN : lobId';
        }
        System.debug('query ===['+JSON.Serialize(query));
        List<SObject> sObjList = new List<SObject>();
        if(fieldslist.size() > 0 && (query != null || query != '')){
            sObjList = Database.query(query); 
        }
        
        List<SObject> clonedObjList = new List<SObject>();
        Map<String, Object> childDataMaping = new Map<String, Object>();
        childDataMaping.put('Unqualified', 'Unqualified');
        childDataMaping.put('Interest', 'Interest');
        childDataMaping.put('Submission', 'Interest');
        childDataMaping.put('Declined', 'Interest');
        childDataMaping.put('Quote', 'Interest');
        childDataMaping.put('Lost', 'Interest');
        childDataMaping.put('Bound', 'Interest');
        childDataMaping.put('Not Submitted', 'Interest');
        childDataMaping.put('Not Interested', 'Interest');
        
        for(Sobject obj : sObjList){
            SObject clonedSobj;
            clonedSobj  = obj.clone(false, false, false, false);
            
            if(clonedSobj!=null){
                // update relationshipField with parentRecordId
                if(String.isNotBlank(relationshipField)){
                    clonedSobj.put(relationshipField,obj.Id);
                    clonedSobj.put('cloned__c',true);
                    clonedSobj.put('type__c', 'Renewal');
                    System.debug('clonedSobj.get : '+clonedSobj.get('Renewed_Line_of_Business__c'));
                    String RenewedLobId = (String)clonedSobj.get('Renewed_Line_of_Business__c');
                    //by ms 16/01/2024
                    System.debug('clonedSobj.get LOB_Effective_Date__c : '+clonedSobj.get('LOB_Effective_Date__c'));
                    Date effectiveDate = Date.valueOf(clonedSobj.get('LOB_Effective_Date__c'));
                    effectiveDate = effectiveDate.addYears(1);
                    clonedSobj.put('LOB_Effective_Date__c', effectiveDate);
                    clonedSobj.put('LOB_Stage__c', childDataMaping.get(String.valueOf(clonedSobj.get('LOB_Stage__c'))));
                    
                    // Access Renewed_Line_of_Business__c field using clonedSobj
                    String newLobId;
                    String newId;
                    
                    // Check if the key exists in ParentAndChildLobId map
                    if (ParentAndChildLobId != null && ParentAndChildLobId.containsKey(RenewedLobId)) {
                        newLobId = ParentAndChildLobId.get(RenewedLobId);
                    }
                    
                    // Check if the key exists in ParentAndChildOpportunityId map
                    if (ParentAndChildOpportunityId != null && ParentAndChildOpportunityId.containsKey(newLobId)) {
                        newId = ParentAndChildOpportunityId.get(newLobId);
                    }
                    
                    System.debug('@@@newId ' + newId);
                    clonedSobj.put('Opportunity_Related__c', newId);
                    
                }
            }
            clonedObjList.add(clonedSobj);
        }
        
        
        System.debug('@@clonedObjList'+clonedObjList);
        if(clonedObjList.size() > 0){
            BaseTriggerHandler.bypass('TH_OPPORTUNITY');
            BaseTriggerHandler.bypass('TH_LOBMANAGEMENT');
            insert clonedObjList;
            BaseTriggerHandler.clearbypass('TH_LOBMANAGEMENT');
            BaseTriggerHandler.clearbypass('TH_OPPORTUNITY');
            return clonedObjList;
        }
        return null;
        
    }
    
    private static Set<String> toLowerSet(Set<String> setString) {
        Set<String> lowerStringSet = new Set<String>();
        for(String str: setString) {
            lowerStringSet.add(str.toLowerCase());   
        }
        return lowerStringSet;
    }
    
    global void finish(Database.BatchableContext ctx) {
        System.debug('Batch Process Completed Successfully');
     
    }
    
    public void execute(SchedulableContext context) {
        BatchLobProcess batch = new BatchLobProcess();
        Database.executeBatch(batch,50);
    }
    
}