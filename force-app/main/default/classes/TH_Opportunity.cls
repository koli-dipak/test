public class TH_Opportunity extends BaseTriggerHandler{
    private List<Opportunity> newOpportunityList;
    private List<Opportunity> oldOpportunityList;
    private Map<ID, Opportunity> newOpportunityMap;
    private Map<ID, Opportunity> oldOpportunityMap;
    
    public Static boolean skipOpportunity = true; 
    public TH_Opportunity()
    {
        oldOpportunityList = (List<Opportunity>)Trigger.old;
        newOpportunityList = (List<Opportunity>)Trigger.new;
        newOpportunityMap = (Map<Id, Opportunity>)Trigger.newMap;
        oldOpportunityMap = (Map<Id, Opportunity>)Trigger.oldMap;
    }
    
    protected override void beforeInsert() { 
        if(Trigger_PAD.canRun('TH_OpportunityBeforeInsert')){
            proccesRecordBeforeOpportunity(newOpportunityList,oldOpportunityMap);
        }
    } 
    protected override void AfterInsert() { 
        if(Trigger_PAD.canRun('TH_OpportunityAfterInsert')){
            proccesRecordAfterOpportunity(newOpportunityList,oldOpportunityMap);
        }
    } 
    protected override void AfterUpdate() { 
        if(Trigger_PAD.canRun('TH_OpportunityAfterUpdate')){
            proccesRecordAfterOpportunity(newOpportunityList,oldOpportunityMap);
        }
    } 
    
    protected override void beforeUpdate() { 
        if(Trigger_PAD.canRun('TH_OpportunityBeforeUpdate')){
            proccesRecordBeforeOpportunity(newOpportunityList,oldOpportunityMap);
        }
    }
     
    public static void proccesRecordBeforeOpportunity(List<Opportunity> newOpportunityList, Map<Id, Opportunity> oldOpportunityMap){
        // set account Ids
        Boolean OppStageChange=false;
        Set<Id> accIds = new Set<Id>();
        Set<Id> accAgencyBrokerageIds = new Set<Id>();
        set<Id> oppIds =  new set<Id>();
        set<Id> userIds =  new set<Id>();

        for(Opportunity opp:newOpportunityList){
            accIds.add(opp.AccountId);
            accAgencyBrokerageIds.add(opp.vlocity_ins__AgencyBrokerageId__c);
            oppIds.add(opp.Id);
            userIds.add(opp.Assign_To__c);
            userIds.add(opp.OwnerId);
            if(oldOpportunityMap != null && opp.StageName != oldOpportunityMap.get(opp.Id).StageName
               && opp.StageName=='Bound')
            {
                Opp.CloseDate=oldOpportunityMap.get(opp.Id).CloseDate;
            }
        }
        
        List<User> userList = DAL_Opportunity.getUserByCurrentUserId(userIds);
        Map<String,User> OppWiseUserMap = new Map<String,User>();
        for(User user : userList){
            if(!OppWiseUserMap.containsKey(user.Id))
                OppWiseUserMap.put(user.Id,user);
        }
        
        Map<Id,Account> accMap = DAL_Account.getAccountMap(accIds);
        Map<Id,Account> BrokerAgencyAccMap = DAL_Account.getAccountMap(accAgencyBrokerageIds);
        Map<Id, List<Account>> childAccountMap = DAL_Account.getChildAccountsMap(accIds);
        
        Set<String> appliedEpickey = new Set<String>();
        for(Opportunity opp : newOpportunityList){
            if(oldOpportunityMap == null && opp.AccountId != null && accMap.get(opp.AccountId) != null){
                String effectiveDate = Datetime.newInstance(opp.CloseDate.year(), opp.CloseDate.month(),opp.CloseDate.day()).format('yyyy-MM-dd');
                String tempEpicKey = accMap.get(opp.AccountId).Box_Folder_Name__c + '-' + opp.LeadSource + '-' + effectiveDate;
                appliedEpickey.add(tempEpicKey); 
              
                
                if(childAccountMap.containsKey(opp.AccountId) && !Trigger_PAD.isBypassValidation)
                {
                    opp.addError('Invalid Operation on Parent Account. Parent accounts are for group holding and reporting only. To make a new submission, use a child account. For a specific entity, create it as a child account under the appropriate parent. For help or errors, contact support.');
                }
            }
            
           
            if(Trigger.isInsert){
                 if(opp.vlocity_ins__AgencyBrokerageId__c != null && BrokerAgencyAccMap.containsKey(opp.vlocity_ins__AgencyBrokerageId__c) && String.isNotBlank(BrokerAgencyAccMap.get(opp.vlocity_ins__AgencyBrokerageId__c).Region__c)){
                    opp.Region__c = BrokerAgencyAccMap.get(opp.vlocity_ins__AgencyBrokerageId__c).Region__c;
                }
            }
            
            
        }
        
        List<Opportunity> appliedEpickeyPrefixList = DAL_Opportunity.getOpportunityAppliedEpicKeyPrefixList(appliedEpickey);
        Map<String, Integer> appliedEpickeyCountMap = new Map<String, Integer>();
        for(Opportunity opp : appliedEpickeyPrefixList){
            if(oldOpportunityMap == null && opp.Applied_Epic_key__c !=null && opp.Applied_Epic_key__c.lastindexOf('-')>=0){
                String appliedEpickeyName = opp.Applied_Epic_key__c.substring(0,opp.Applied_Epic_key__c.lastindexOf('-'));
                if(!appliedEpickeyCountMap.containsKey(appliedEpickeyName)){
                    appliedEpickeyCountMap.put(appliedEpickeyName,0);
                }
                appliedEpickeyCountMap.put(appliedEpickeyName,appliedEpickeyCountMap.get(appliedEpickeyName)+1);  
            }
        }
        
        List<LOB_Management__c> oldLOBManagementList = DAL_LOB_Management.getAllLOBManagementByOpp(oppIds);
        system.debug('oldLOBManagementList>>>>'+oldLOBManagementList.size());
        Map<String,List<LOB_Management__c>> oppWiseLOBs = new Map<String,List<LOB_Management__c>>();
        Map<String,String> oppWiseLostLOBReason = new Map<String,String>();
        Map<String,String> oppWiseDeclineLOBReason = new Map<String,String>();
        for(LOB_Management__c lob :oldLOBManagementList){
            if(!oppWiseLOBs.containsKey(lob.Opportunity_Related__c)){
                oppWiseLOBs.put(lob.Opportunity_Related__c,new List<LOB_Management__c>());
            }
            oppWiseLOBs.get(lob.Opportunity_Related__c).add(lob);
            if(lob.LOB_Stage__c=='Declined'){oppWiseDeclineLOBReason.put(lob.Opportunity_Related__c,lob.Declined_Reason__c);}
            if(lob.LOB_Stage__c=='Lost'){oppWiseLostLOBReason.put(lob.Opportunity_Related__c,lob.Lost_Reason__c);}
        }

        List<Product_category__mdt> allProductCategoryMdt = DAL_Opportunity.getAllProductCategoryMdt();
        
        Map<String,String> productCategoryMap = new Map<String,String>();
        for(Product_category__mdt pc : allProductCategoryMdt){
            if(!productCategoryMap.containsKey(pc.MasterLabel))
                productCategoryMap.put(pc.MasterLabel,pc.Category__c);
        }
        Set<String> mainCategorySet = new Set<String>{'Domestic', 'Foreign'};
       // Map<Id,Account> accAgencyBrokerageMap = DAL_Account.getAccountMap(accAgencyBrokerageIds);
            for(Opportunity opp:newOpportunityList){
                
                Opportunity oldOpportunity;
                if(oldOpportunityMap!=null){
                    oldOpportunity = oldOpportunityMap.get(opp.Id);
                }
                
               /* if(accAgencyBrokerageMap.get(opp.vlocity_ins__AgencyBrokerageId__c) != null && (oldOpportunityMap==null || (oldOpportunityMap!=null && (oldOpportunity.vlocity_ins__AgencyBrokerageId__c != opp.vlocity_ins__AgencyBrokerageId__c)))){
                    Id recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency/Brokerage').getRecordTypeId();
                    if(accAgencyBrokerageMap.get(opp.vlocity_ins__AgencyBrokerageId__c).recordTypeId != recordtypeId){
                        opp.addError('Please select Account in Agency/Brokerage field which has Agency/Brokerage Record Type');
                    }
                }*/
                
                
                system.debug('oldOpportunityMap'+oldOpportunityMap);
                if(oldOpportunityMap==null){
                    String effectiveDate = Datetime.newInstance(opp.CloseDate.year(), opp.CloseDate.month(),opp.CloseDate.day()).format('yyyy-MM-dd');
                    String tempEpicKey = accMap.get(opp.AccountId).Box_Folder_Name__c + '-' + opp.LeadSource + '-' + effectiveDate;
                    
                    if(!appliedEpickeyCountMap.containsKey(tempEpicKey)){
                        appliedEpickeyCountMap.put(tempEpicKey,0);
                    }
                    Integer currentCnt=appliedEpickeyCountMap.get(tempEpicKey) + 1;
                    appliedEpickeyCountMap.put(tempEpicKey,currentCnt);
                    
                    opp.Applied_Epic_key__c = tempEpicKey+'-'+(currentCnt<10?'0'+currentCnt:''+currentCnt);
                    
                    if(opp.Assign_To__c != null){
                        opp.OwnerId = opp.Assign_To__c;
                    }   
                }
                
                //Removed line 158 from below to update zone on copy to next
                /*if(opp.OwnerId != null 
                        && (oldOpportunityMap==null || 
                            (oldOpportunityMap!=null && 
                             (oldOpportunityMap.get(opp.Id).OwnerId!=opp.OwnerId))) 
                        		&& OppWiseUserMap.containsKey(opp.OwnerId))
                    {
               			 opp.Zone__c = OppWiseUserMap.get(opp.OwnerId).Territory__c;
            		}*/
                
                //Change logic to look for ownwer id instead of Assignto id 
                //opp.Account_Manager__c = OppWiseUserMap.containsKey(opp.Assign_To__c) ? OppWiseUserMap.get(opp.Assign_To__c).Account_Manager__c : null;
                opp.Account_Manager__c = OppWiseUserMap.containsKey(opp.OwnerId) ? OppWiseUserMap.get(opp.OwnerId).Account_Manager__c : null;
                opp.Underwriting_Associate__c=OppWiseUserMap.containsKey(opp.OwnerId) ? OppWiseUserMap.get(opp.OwnerId).Underwriting_Associate__c : null;
                opp.Zone__c = OppWiseUserMap.get(opp.OwnerId).Territory__c;            
                
                if(opp.Line_of_Business__c != null && opp.Line_of_Business__c != '' 
                   && (oldOpportunityMap==null
                       || (oldOpportunityMap!=null
                           && (oldOpportunity.Line_of_Business__c!=opp.Line_of_Business__c))))
                {
                    Boolean domesticVal = false;
                    Boolean foreignVal = false;
                    for(String val :opp.Line_of_Business__c.split(';')){
                        if(productCategoryMap.get(val) == 'Domestic'){
                            domesticVal = true;
                        }else if(productCategoryMap.get(val) == 'Foreign'){
                            foreignVal = true;
                        }
                    }
                    System.debug('@@domesticVal ::'+domesticVal);
                    System.debug('@@foreignVal ::'+foreignVal);
                    if(domesticVal && foreignVal){
                        opp.Submission_Type__c = 'Global';
                    }else if(domesticVal && !foreignVal){
                        opp.Submission_Type__c = 'Domestic';
                    }else if(foreignVal && !domesticVal){
                        opp.Submission_Type__c = 'Foreign';
                    }
                }
                
                if(oldOpportunityMap!=null && opp.Max_LOB_Effective_Date__c!=null && oldOpportunity.Max_LOB_Effective_Date__c!=opp.Max_LOB_Effective_Date__c){
                    opp.CloseDate = opp.Max_LOB_Effective_Date__c;
                }
                
                if(accMap.get(opp.AccountId) != null && (oldOpportunityMap==null || (oldOpportunityMap!=null && (oldOpportunity.AccountId!=opp.AccountId || oldOpportunity.Name!=opp.Name 
                                                                                                                 || oldOpportunity.Submission_Type__c!=opp.Submission_Type__c || oldOpportunity.Type!=opp.Type || oldOpportunity.CloseDate!=opp.CloseDate ))))
                {
                    String name = Datetime.newInstance(opp.CloseDate.year(), opp.CloseDate.month(),opp.CloseDate.day()).format('yyyy-MM-dd');
                    //opp.Name = accMap.get(opp.AccountId).Name +' - '+ opp.Submission_Type__c +' - ' + opp.Type +' - Effective - '+name;
                    String accName='';
                    if(accMap.get(opp.AccountId).Name.length() >= 70)
                    {
                        accName = accMap.get(opp.AccountId).Name.substring(0, 69);
                    }
                    else
                    {
                        accName =accMap.get(opp.AccountId).Name;
                    }
                    
                    system.debug('accName>>>'+accName);
                    String opportunityName = accName +' - '+ opp.Submission_Type__c +' - ' + opp.Type +' - '+name;
                    system.debug('opportunityName>>>'+opportunityName);
                    system.debug('opportunityName.length() >>>'+opportunityName.length() );
                    if(opportunityName.length() >= 120)
                    {
                        opp.Name = opportunityName.substring(0, 119);
                    }
                    else
                    {
                        opp.Name = opportunityName;
                    }
                    
                }
                
                if(oldOpportunityMap!=null && (oldOpportunity.Count_Total_LOB__c!=opp.Count_Total_LOB__c
                                               || oldOpportunity.Count_LOB_with_Bound__c!=opp.Count_LOB_with_Bound__c
                                              || oldOpportunity.Count_LOB_with_Not_Submitted__c!=opp.Count_LOB_with_Not_Submitted__c) && opp.Count_Total_LOB__c == (opp.Count_LOB_with_Bound__c+ opp.Count_LOB_with_Not_Submitted__c))
                {
                    opp.StageName = 'Bound';
                    OppStageChange=true;
                }
                
                if(oldOpportunityMap!=null && (oldOpportunity.Count_Total_LOB__c!=opp.Count_Total_LOB__c
                                               || oldOpportunity.Count_LOB_with_Lost__c!=opp.Count_LOB_with_Lost__c
                                              || oldOpportunity.Count_LOB_with_Not_Submitted__c!=opp.Count_LOB_with_Not_Submitted__c) && opp.Count_Total_LOB__c == (opp.Count_LOB_with_Lost__c + opp.Count_LOB_with_Not_Submitted__c))
                { 
                    opp.StageName = 'Lost';
                    /*List<LOB_Management__c> lobList = oppWiseLOBs.get(opp.Id);

                    if(lobList != null && lobList.size() > 0){
                        opp.Lost_Reason__c = lobList[0].LOB_Stage__c == 'Lost' ? lobList[0].Lost_Reason__c : lobList[0].Declined_Reason__c; 
                    }*/
                    opp.Lost_Reason__c = oppWiseLostLOBReason.get(opp.Id) != ''? oppWiseLostLOBReason.get(opp.Id): opp.Lost_Reason__c;
                    OppStageChange=true;
                }
                
                
                if(oldOpportunityMap!=null && (oldOpportunity.Count_Total_LOB__c!=opp.Count_Total_LOB__c
                                               || oldOpportunity.Count_LOB_with_Declined__c!=opp.Count_LOB_with_Declined__c
                                              || oldOpportunity.Count_LOB_with_Not_Submitted__c!=opp.Count_LOB_with_Not_Submitted__c) && opp.Count_Total_LOB__c == (opp.Count_LOB_with_Declined__c + opp.Count_LOB_with_Not_Submitted__c))
                { 
                    opp.StageName = 'Declined';
                    /*List<LOB_Management__c> lobList = oppWiseLOBs.get(opp.Id);

                    if(lobList != null && lobList.size() > 0){
                        opp.Lost_Reason__c = lobList[0].LOB_Stage__c == 'Declined' ? lobList[0].Declined_Reason__c : lobList[0].Lost_Reason__c; 
                    }*/
                    if(oppWiseDeclineLOBReason.get(opp.Id) != null )
                    opp.Lost_Reason__c = oppWiseDeclineLOBReason.get(opp.Id) != ''?oppWiseLostLOBReason.get(opp.Id): opp.Lost_Reason__c;
                    OppStageChange=true;
                }
                if(oldOpportunityMap!=null && (oldOpportunity.Count_Total_LOB__c!=opp.Count_Total_LOB__c
                                               || oldOpportunity.Count_LOB_with_Declined__c!=opp.Count_LOB_with_Declined__c
                                              || oldOpportunity.Count_LOB_with_Lost__c!=opp.Count_LOB_with_Lost__c
                                              || oldOpportunity.Count_LOB_with_Not_Submitted__c!=opp.Count_LOB_with_Not_Submitted__c) && opp.Count_Total_LOB__c == (opp.Count_LOB_with_Declined__c+opp.Count_LOB_with_Lost__c+opp.Count_LOB_with_Not_Submitted__c) && opp.Count_LOB_with_Declined__c!=0 && opp.Count_LOB_with_Lost__c!=0)
                { 
                    opp.StageName = 'LOST';
                    /*List<LOB_Management__c> lobList = oppWiseLOBs.get(opp.Id);

                    if(lobList != null && lobList.size() > 0){
                        opp.Lost_Reason__c = lobList[0].LOB_Stage__c == 'Declined' ? lobList[0].Declined_Reason__c : lobList[0].Lost_Reason__c; 
                    }*/
                    //opp.Lost_Reason__c=oppWiseLostLOBReason.get(opp.Id);
                    if(oppWiseDeclineLOBReason.get(opp.Id) != null )
                    opp.Lost_Reason__c=oppWiseLostLOBReason.get(opp.Id) != ''?oppWiseLostLOBReason.get(opp.Id): opp.Lost_Reason__c;
                    OppStageChange=true;
                }
                
                // If bound+lost count same then mark it as bond
                if(oldOpportunityMap!=null && (oldOpportunity.Count_Total_LOB__c!=opp.Count_Total_LOB__c
                                               || oldOpportunity.Count_LOB_with_Bound__c!=opp.Count_LOB_with_Bound__c
                                               || oldOpportunity.Count_LOB_with_Lost_and_Declined__c!=opp.Count_LOB_with_Lost_and_Declined__c
                                              || oldOpportunity.Count_LOB_with_Not_Submitted__c!=opp.Count_LOB_with_Not_Submitted__c) && 
                   opp.Count_LOB_with_Bound__c>0 && opp.Count_Total_LOB__c == (opp.Count_LOB_with_Bound__c + opp.Count_LOB_with_Lost_and_Declined__c + opp.Count_LOB_with_Not_Submitted__c))
                {
                    opp.StageName = 'Bound';
                    OppStageChange=true;
                }
                
                // Not interested added on 05.10.2022 line number 246-257
               
                if(oldOpportunityMap!=null && (oldOpportunity.Count_Total_LOB__c != opp.Count_Total_LOB__c
                                               || oldOpportunity.Count_LOB_with_Bound__c != opp.Count_LOB_with_Bound__c
                                               || oldOpportunity.Count_LOB_with_Lost_and_Declined__c != opp.Count_LOB_with_Lost_and_Declined__c
                                               || oldOpportunity.Count_LOB_with_Not_Submitted__c!=opp.Count_LOB_with_Not_Submitted__c
                                               || oldOpportunity.Count_LOB_with_Not_Interested__c != opp.Count_LOB_with_Not_Interested__c ) && 
                   opp.Count_LOB_with_Bound__c>0 && opp.Count_Total_LOB__c == (opp.Count_LOB_with_Bound__c + opp.Count_LOB_with_Lost_and_Declined__c + opp.Count_LOB_with_Not_Submitted__c+ opp.Count_LOB_with_Not_Interested__c ))
                {
                    opp.StageName = 'Bound';
                    OppStageChange=true;
                }
                
                System.debug('@@opp.Lost_Reason__c ::'+opp.Lost_Reason__c);
                
                if(oldOpportunityMap!=null && (oldOpportunity.Count_Total_LOB__c!=opp.Count_Total_LOB__c 
                                               || oldOpportunity.Count_LOB_with_Not_Submitted__c!=opp.Count_LOB_with_Not_Submitted__c) && opp.Count_Total_LOB__c == opp.Count_LOB_with_Not_Submitted__c)
                {
                    opp.StageName = 'Not Submitted';
                    OppStageChange=true;
                }
                
                if(oldOpportunityMap!=null && opp.StageName!=oldOpportunity.StageName && !OppStageChange){
                    if(opp.StageName != 'Quote' && opp.Count_LOB_with_Quote__c > 0){
                        opp.addError(Label.Opportunity_Stage_Validation);
                    }else if(opp.StageName != 'Submission' && opp.Count_LOB_with_Submission__c > 0){
                        opp.addError(Label.Opportunity_Stage_Validation);
                    }else if(opp.StageName != 'Interest' && opp.Count_LOB_with_Interest__c > 0){
                        opp.addError(Label.Opportunity_Stage_Validation);
                    }else if(opp.StageName != 'Unqualified' && opp.Count_LOB_with_Unqualified__c > 0){
                        opp.addError(Label.Opportunity_Stage_Validation);
                    }else if((opp.StageName != 'Declined' || opp.StageName != 'Lost') && opp.Count_LOB_with_Lost_and_Declined__c == opp.Count_Total_LOB__c){
                        opp.addError(Label.Opportunity_Stage_Validation);
                    }else if(opp.StageName != 'Bound' && opp.Count_LOB_with_Bound__c == opp.Count_Total_LOB__c){
                        opp.addError(Label.Opportunity_Stage_Validation);
                    }
                }
            }
    }
       
    public static void proccesRecordAfterOpportunity(List<Opportunity> newOpportunityList,Map<Id, Opportunity> oldOpportunityMap){
        
        set<Id> oppIds =  new set<Id>();
        for(Opportunity opp :newOpportunityList){
            oppIds.add(opp.Id);
        }
        
        /*List<Opportunity> newOppList = DAL_Opportunity.getAllOpportunityById(oppIds);
        List<Task> taskList = new List<Task>();
        
        for(Opportunity opp : newOppList){
            HLPR_CalcBusinessDays calBusinessDays = new HLPR_CalcBusinessDays();
            Date localToday = Date.today().addDays(-2);
            Datetime local = Datetime.now().addDays(-2);
            Boolean isWorkingDay = False;
            Integer noOfDaysToAdd = 0;
            
            while(isWorkingDay == False){
                if(calBusinessDays.isWorkingDay(local.addDays(noOfDaysToAdd*1))){
                    isWorkingDay = True;
                }else{
                    noOfDaysToAdd++; 
                }
            }

            Group queue = DAL_Opportunity.getQueue();
            // Process Builder - Task to Account Manager to Update the D&B info
            if(opp.StageName == 'Submission' && opp.owner.Account_Manager__c != null){
                Task sanctionsTask = new Task();
                sanctionsTask.ActivityDate = localToday.addDays(noOfDaysToAdd);
                sanctionsTask.Status = 'Open';
                sanctionsTask.Priority = 'Normal';
                sanctionsTask.Subject = 'Sanctions Check for - ['+ opp.Name +']';
                sanctionsTask.WhatId =  opp.Id;
                sanctionsTask.OwnerId = opp.owner.Account_Manager__c;
                taskList.add(sanctionsTask);
                
                Task clearanceTask = new Task();
                clearanceTask.ActivityDate = localToday.addDays(noOfDaysToAdd);
                clearanceTask.Description  = opp.Instructions_to_BPO__c;
                clearanceTask.Status = 'Open';
                clearanceTask.Priority = 'Normal';
                clearanceTask.Subject = 'Clearance Check for - ['+ opp.Name +']';
                clearanceTask.WhatId =  opp.Id;
                clearanceTask.OwnerId = queue.Id;
                taskList.add(clearanceTask);
            }
            else if(opp.StageName == 'Submission'){
                Task task = new Task();
                task.ActivityDate = localToday.addDays(noOfDaysToAdd);
                task.Description  = opp.Instructions_to_BPO__c;
                task.Status = 'Open';
                task.Priority = 'Normal';
                task.Subject = 'New Submission - Clearance Check - No Account Manager [ '+ opp.Owner.FirstName + ' ' + opp.Owner.LastName + '] - [' + opp.vlocity_ins__AgencyBrokerageId__r.Name +' ]';
                task.WhatId =  opp.Id;
                task.OwnerId = queue.Id;
                taskList.add(task);
            }
        }*/
        
        List<LOB_Management__c> oldLOBManagementList = DAL_LOB_Management.getAllLOBManagementByOpp(oppIds);
        
        Map<String,Set<String> > oppWiseOLs = new Map<String,Set<String> >();
        for(LOB_Management__c lob :oldLOBManagementList){
            if(!oppWiseOLs.containsKey(lob.Opportunity_Related__c)){
                oppWiseOLs.put(lob.Opportunity_Related__c,new Set<String>());
            }
            oppWiseOLs.get(lob.Opportunity_Related__c).add(lob.RecordType.Name);
            
        }
        List<LOB_Management__c> newLOBManagementList = new List<LOB_Management__c>();
        List<RecordType> lobRecordTypeList = DAL_LOB_Management.getAllLOBManagementRecordType();
        Map<String,RecordType> recordTypeMap = new Map<String,RecordType>();
        for(RecordType rec : lobRecordTypeList){
           if(!recordTypeMap.containsKey(rec.Name)){
                recordTypeMap.put(rec.Name,rec);
            }
        }
            
        Set<Id> oppWithNewInstructionstoBPO = new Set<Id>();
        //create LOB Management
        for(Opportunity opp:newOpportunityList){
            if(opp.Line_of_Business__c!=null && (oldOpportunityMap==null || (oldOpportunityMap != null && opp.Line_of_Business__c != oldOpportunityMap.get(opp.Id).Line_of_Business__c))){
                for(String val :opp.Line_of_Business__c.split(';')){
                    if(recordTypeMap.containsKey(val)){
                        Id recordtypeId = recordTypeMap.get(val).Id;//Schema.SObjectType.LOB_Management__c.getRecordTypeInfosByName().get(val).getRecordTypeId();
                        if(oppWiseOLs.containsKey(opp.Id)){
                            if(!oppWiseOLs.get(opp.Id).contains(val)){
                                LOB_Management__c lob = new LOB_Management__c(Opportunity_Related__c=opp.Id,
                                                                              RecordTypeId=recordtypeId,
                                                                              //LOB_External_Id__c=opp.Applied_Epic_key__c + '-' + val,
                                                                              LOB_External_Id__c=opp.Id + '-' + val,
                                                                              LOB_Stage__c=opp.StageName!='Lost'?opp.StageName:'Submission',
                                                                              LOB_Effective_Date__c=opp.CloseDate,
                                                                              Type__c=opp.Type,
                                                                              Submission_Source__c =opp.leadsource,
                                                                              Priority_Rating__c  = opp.Priority_Rating__c,
																			  Underwriter__c = opp.OwnerId,
                                                                              Instructions_to_BPO__c = opp.Instructions_to_BPO__c,
                                                                              Loss_Reason__c  = opp.Loss_Reason__c,
                                                                              Lost_Reason__c = opp.Lost_Reason__c);
                                
                                newLOBManagementList.add(lob);
                                oppWiseOLs.get(opp.Id).add(val);
                            }
                        }else{
                            LOB_Management__c lob = new LOB_Management__c(Opportunity_Related__c=opp.Id,
                                                                          RecordTypeId=recordtypeId,
                                                                          //LOB_External_Id__c=opp.Applied_Epic_key__c + '-' + val,
                                                                          LOB_External_Id__c=opp.Id + '-' + val,
                                                                          LOB_Stage__c=opp.StageName!='Lost'?opp.StageName:'Submission',
                                                                          LOB_Effective_Date__c=opp.CloseDate,
                                                                          Type__c=opp.Type,
                                                                          Submission_Source__c =opp.leadsource,
                                                                          Priority_Rating__c  = opp.Priority_Rating__c,
																		  Underwriter__c = opp.OwnerId,
                                                                          Instructions_to_BPO__c = opp.Instructions_to_BPO__c,
                                                                          Loss_Reason__c  = opp.Loss_Reason__c,
                                                                          Lost_Reason__c = opp.Lost_Reason__c);
 
                            newLOBManagementList.add(lob);
                            if(!oppWiseOLs.containsKey(opp.Id)){
                                oppWiseOLs.put(opp.Id,new Set<String>());
                            }
                            oppWiseOLs.get(opp.Id).add(val);
                        } 
                    }
                } 
            }
            if(oldOpportunityMap != null && opp.Instructions_to_BPO__c != oldOpportunityMap.get(opp.Id).Instructions_to_BPO__c){
                oppWithNewInstructionstoBPO.add(opp.Id);
            }
        }
        system.debug('@@newLOBManagementList ::'+newLOBManagementList);
        if(newLOBManagementList.size()>0){
            insert newLOBManagementList;
        }

        if(!oppWithNewInstructionstoBPO.isEmpty()){
            Map<Id, Opportunity> newOpportunityMap = new Map<Id, Opportunity>(newOpportunityList);
            List<LOB_Management__c> lobToUpdate = DAL_LOB_Management.getAllLOBManagementByOpp(oppWithNewInstructionstoBPO);
            for(LOB_Management__c lobRec : lobToUpdate){
                Opportunity oppRec = newOpportunityMap.get(lobRec.Opportunity_Related__c);
                lobRec.Instructions_to_BPO__c = oppRec.Instructions_to_BPO__c;
            }
            
            if(!lobToUpdate.isEmpty()){
                BaseTriggerHandler.bypass('TH_LOBMANAGEMENT');
                Update lobToUpdate;
                BaseTriggerHandler.clearBypass('TH_LOBMANAGEMENT');
            }
        }
        /*system.debug('@@taskList ::'+taskList.size());
        if(taskList.size()>0){
            insert taskList;
        }*/
        /*//populate set of submissiontypes 
        Set<String> submissionTypes = new Set<String>();
        set<Id> oppIds =  new set<Id>();
        
        for(Opportunity opp :newOpportunityList){
            if(opp.Submission_Type__c !=null && (oldOpportunityMap==null || (oldOpportunityMap != null && opp.Submission_Type__c != oldOpportunityMap.get(opp.Id).Submission_Type__c))){
                submissionTypes.addAll(opp.Submission_Type__c.split(';'));
            }
            oppIds.add(opp.Id);
        }
        
        List<Product2> OldProductList = DAL_Product.getProductList(submissionTypes);//get products and its pricebookentry
        //map old products and pricebookentries
        Map<String,Id> oldProductMap = new Map<String,Id>();
        for(Product2 prod :OldProductList){
            oldProductMap.put(prod.ExternalId__c,prod.Id);
        }
        
        
        List<OpportunityLineItem> oldOppLineItemList = DAL_OpportunityLineItem.getAllOpportunityLineItem(oppIds);// get old opp lineitems 
        //map old opp lineitmes 
        Map<String,Set<String> > oppLineItemOppListMap = new Map<String,Set<String> >();
        Map<String,Set<String> > oppWiseOLs = new Map<String,Set<String> >();
        for(OpportunityLineItem lineItem :oldOppLineItemList){
            if(lineItem.Product2.ExternalId__c!=null){
                if(!oppWiseOLs.containsKey(lineItem.opportunityId)){
                    oppWiseOLs.put(lineItem.opportunityId,new Set<String>());
                }
                oppWiseOLs.get(lineItem.opportunityId).add(lineItem.Product2.ExternalId__c);
            }
        }
        //System.debug('Map:::'+oppLineItemOppListMap.get(oldOppLineItemList[0].Product2.Name));
        
        Pricebook2 priceBook = DAL_Pricebook.getStandardPricebook();// standard pricebook
        List<Product2> newproductList = new List<Product2>();// list for new products
        List<PricebookEntry> newPriceBookEnteyList  = new List<PricebookEntry>();//list for new pricebook entires
        List<OpportunityLineItem> newOppLineItemList = new List<OpportunityLineItem>();//list for new lineitmes
       
        //create prodcut and pricebookentry if not exist 
        for(String st :submissionTypes){
            if(!oldProductMap.containsKey(st)){
                Product2 prod = new Product2(Name=st,ExternalId__c=st);
                newproductList.add(prod);
                PricebookEntry pbEntry = new PricebookEntry(Product2=prod,Pricebook2Id=priceBook.Id,UnitPrice=0,IsActive=true);
                newPriceBookEnteyList.add(pbEntry);
            }
        }
        if(newproductList.size()>0){
            insert newproductList;
        }   
        if(newPriceBookEnteyList.size()>0){
            for(PricebookEntry P : newPriceBookEnteyList){
                P.product2Id=p.product2.Id;
                p.Product2=null;
            }
            insert newPriceBookEnteyList;
        }
        
        //map new created products and PB entires
        for(Product2 p : newproductList){
            oldProductMap.put(p.ExternalId__c,p.Id);
        }
        
        //create opportunity line item
        for(Opportunity opp:newOpportunityList){
            
            if(opp.Submission_Type__c!=null && (oldOpportunityMap==null || (oldOpportunityMap != null && opp.Submission_Type__c != oldOpportunityMap.get(opp.Id).Submission_Type__c))){
                for(String val :opp.Submission_Type__c.split(';')){
                    if(oppWiseOLs.containsKey(opp.Id)){
                        if(!oppWiseOLs.get(opp.Id).contains(val)){
                            OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId=opp.Id,Product2Id=oldProductMap.get(val),UnitPrice=0);
                            newOppLineItemList.add(oppLineItem);
                        }
                    }else{
                        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId=opp.Id,Product2Id=oldProductMap.get(val),UnitPrice=0);
                        newOppLineItemList.add(oppLineItem);
                    }
                    
                } 
            }
        }
        system.debug('@@'+newOppLineItemList);
        if(newOppLineItemList.size()>0){
            insert newOppLineItemList;
        }*/
    } 
}