public class TH_Account extends BaseTriggerHandler {
    
    private List<Account> newAccountList;
    private List<Account> oldAccountList;
    private Map<ID, Account> newAccountMap;
    private Map<ID, Account> oldAccountMap;
    
    public TH_Account()
    {
        oldAccountList = (List<Account>)Trigger.old;
        newAccountList = (List<Account>)Trigger.new;
        newAccountMap = (Map<Id, Account>)Trigger.newMap;
        oldAccountMap = (Map<Id, Account>)Trigger.oldMap;
    }
    
    protected override void beforeInsert() { 
        if(Trigger_PAD.canRun('TH_AccountBeforeInsert')){
            proccesRecordBeforeInsertAccount(newAccountList);
        }
    } 
    
    
    protected override void beforeUpdate()
    {
        if(Trigger_PAD.canRun('TH_AccountBeforeUpdate'))
        {
            proccesRecordBeforeUpdate(newAccountList,oldAccountMap);
        }
    }
    
    protected override void afterUpdate()
    {
        if(Trigger_PAD.canRun('TH_AccountAfterUpdate'))
        {
            proccesRecordAfterUpdate(newAccountList,oldAccountMap);
        }
    }
    
    
    public static void proccesRecordBeforeInsertAccount(List<Account> newAccountList)
    {
        Id InsuredRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Insured').getRecordTypeId();
        Id AgencyBrokerageRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('AgencyBrokerage').getRecordTypeId();
        Id BrokerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Broker').getRecordTypeId();
  	    Set<String> prefixSet = new Set<String>();
        Set<String> InsuredPrefixSet = new Set<String>();
        for(Account acc:newAccountList){
            String newFolderName=acc.Name.replaceAll('[;\\[\\]\\{\\}\\.\\*\\s\\?<>()&#@$\\^\\!/,\'"%20:\\\\]', '');
            if(newFolderName.length()>7){
                newFolderName=newFolderName.substring(0,7);
            }else{
                newFolderName=newFolderName.rightPad(7, '0');
            }
            newFolderName = newFolderName.toUpperCase();
            prefixSet.add(newFolderName);
            if( null != acc.Insured_External_Id__c)
            InsuredPrefixSet.add((acc.Insured_External_Id__c).toUpperCase());
        }
        
        Map<String, Account> existingInsuredAccount = new  Map<String, Account>();
        if(!InsuredPrefixSet.isEmpty())
        {
            system.debug('InsuredPrefixSet:::'+InsuredPrefixSet);
            List<Account> exitingAccountWithInsured = DAL_Account.getAccountBoxFolderName(InsuredPrefixSet);
            system.debug('exitingAccountWithInsured:::'+exitingAccountWithInsured.size());
            for(Account acc:exitingAccountWithInsured){
                 existingInsuredAccount.put(acc.Box_Folder_Name__c,acc);
             }
        }
            
        system.debug('prefixSet:::'+prefixSet);
        List<Account> boxFolderNamePrefixList = DAL_Account.getAccountBoxFolderNamePrefixList(prefixSet);
        Map<String, Integer> boxFolderNameCountMap = new Map<String, Integer>();
        system.debug('boxFolderNamePrefixList:::'+boxFolderNamePrefixList);
        for(Account acc:boxFolderNamePrefixList){
            if(acc.Box_Folder_Name__c !=null && acc.Box_Folder_Name__c.indexOf('-')>=0){
                String folderName=acc.Box_Folder_Name__c.substring(0,acc.Box_Folder_Name__c.indexOf('-')).toUpperCase();
                Integer maxCount=Integer.valueOf(acc.Box_Folder_Name__c.substring(acc.Box_Folder_Name__c.indexOf('-')+1));
                if(!boxFolderNameCountMap.containsKey(folderName)){
                    boxFolderNameCountMap.put(folderName,maxCount);
                }else{
                    if(maxCount<boxFolderNameCountMap.get(folderName)){
                        maxCount= boxFolderNameCountMap.get(folderName);
                    }
                }
                
                boxFolderNameCountMap.put(folderName,maxCount);  
            }
            
        }
        
        
        for(Account acc : newAccountList){
            
              system.debug('acc::Insured_External_Id__c:'+acc.Insured_External_Id__c);
            if(null != acc.Insured_External_Id__c)
            {
                String insuredExternalKey = acc.Insured_External_Id__c.toUpperCase();
                system.debug('insuredExternalKey:'+insuredExternalKey);
                system.debug('existingInsuredAccount:'+existingInsuredAccount.get(insuredExternalKey) );
                if(existingInsuredAccount.get(insuredExternalKey) != null)
                {
                    acc.addError('Cannot Create a new Insured Account. Account already exist with the same Insured Id');
                    continue;
                }
            }
            
            
            
            system.debug('acc:::'+acc);
            String newFolderName=acc.Name.replaceAll('[;\\[\\]\\{\\}\\.\\*\\s\\?<>()&#@$\\^\\!/,\'"%20:\\\\]', '');
            if(newFolderName.length()>7){
                newFolderName=newFolderName.substring(0,7);
            }else{
                newFolderName=newFolderName.rightPad(7, '0');
            }
            newFolderName = newFolderName.toUpperCase();
            if(!boxFolderNameCountMap.containsKey(newFolderName)){
                boxFolderNameCountMap.put(newFolderName,0);
            }
            
            Integer currentCnt=boxFolderNameCountMap.get(newFolderName) + 1;
            boxFolderNameCountMap.put(newFolderName,currentCnt);
            
            acc.Box_Folder_Name__c = newFolderName+'-'+(currentCnt<10?'0'+currentCnt:''+currentCnt);
             system.debug(' acc.Box_Folder_Name__c:::'+ acc.Box_Folder_Name__c);
            
            if(acc.Insured_External_Id__c !=null)
            {
               acc.Box_Folder_Name__c =acc.Insured_External_Id__c;
            }
            // Added To Update External Id if record created in SF
			if( acc.Insured_External_Id__c==null && acc.recordTypeId == InsuredRecordTypeId){
                acc.Insured_External_Id__c=acc.Box_Folder_Name__c;
            }else if( acc.Broker_External_Id__c==null && ( acc.recordTypeId == AgencyBrokerageRecordTypeId || acc.recordTypeId == BrokerRecordTypeId)){
                 acc.Broker_External_Id__c=acc.Box_Folder_Name__c;
            }
           system.debug('accaccaccacc::::'+acc.Box_Folder_Name__c);  
           system.debug('accaccaccacc::::'+acc);    
        }
    }
    
    public static void proccesRecordBeforeUpdate(List<Account > accountLists,Map<ID, Account> oldAgencyRepMap)
    {
        
        /*for(Account acc: accountLists)
        {
            
        }*/
    }
    //N2G927 29-12-2022
    public static void proccesRecordAfterUpdate(List<Account> newAccountList,Map<ID, Account> oldAccountMap)
    {
        updateOpportunityRegion(newAccountList, oldAccountMap);      
    }
    
    public static void updateOpportunityRegion(List<Account> newAccountList,Map<ID, Account> oldAccountMap){
        
        set<Id> accIdSet = new Set<Id>();
        Map<ID, String> accIdWiseRegionMap = new Map<ID, String>();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        
        for(Account acc : newAccountList){
            if(String.isNotBlank(acc.Region__c)){
                accIdSet.add(acc.id);
                accIdWiseRegionMap.put(acc.id, acc.Region__c);
            }
        }
        
        if(!accIdSet.isEmpty()){
            List<Opportunity> oppRecords = DAL_Opportunity.getOppByAccountIds(accIdSet);
            
            for(Opportunity opp : oppRecords){
                If(opp.vlocity_ins__AgencyBrokerageId__c != null && accIdWiseRegionMap.containsKey(opp.vlocity_ins__AgencyBrokerageId__c) && String.isNotBlank(accIdWiseRegionMap.get(opp.vlocity_ins__AgencyBrokerageId__c))){
                    opp.Region__c = accIdWiseRegionMap.get(opp.vlocity_ins__AgencyBrokerageId__c);
                    opportunitiesToUpdate.add(opp);
                }
            }
            
            if(!opportunitiesToUpdate.isEmpty()){
                List<Database.SaveResult> results = Database.update(opportunitiesToUpdate, false);
            }
        } 
    }
}