public class DAL_Account {

    Static public List<Account> getAccountBoxFolderNamePrefixList(Set<String> prefixSet){
       return [SELECT ID, Box_Folder_Name__c FROM Account WHERE Box_Folder_Name_Prefix__c IN :prefixSet];
    }
    
    Static public List<Account> getAccountBoxFolderName(Set<String> prefixSet){
       return [SELECT ID, Box_Folder_Name__c FROM Account WHERE Box_Folder_Name__c IN :prefixSet];
    }
    
    Static public Map<Id,Account> getAccountMap(Set<Id> accIds){
        return new Map<Id,Account>([Select Id, Name, ParentId, Box_Folder_Name__c, Region__c, recordTypeId From Account WHERE Id IN :accIds]);
    }
    
    Static public Map<Id, List<Account>> getChildAccountsMap(Set<Id> accIds){
        Map<Id, List<Account>> accountMap = new Map<Id, List<Account>>();
        for(Account accountRec : [Select Id, Name, ParentId, Box_Folder_Name__c, recordTypeId From Account WHERE ParentId != null AND ParentId IN :accIds]){
            if(accountMap.containsKey(accountRec.ParentId)){
                accountMap.get(accountRec.ParentId).add(accountRec);
            }
            else{
                accountMap.put(accountRec.ParentId, new List<Account>{accountRec});
            }
        }
        return accountMap;
    }
    
    Static public Account getAccountById(Id accId){
        return [SELECT Id, Box_Folder_Name__c, Name FROM Account Where Id = :accId];
    }
    
    Static public List<Account> getAccountList(List<Id> accountIds){
        return [SELECT Id, Name FROM Account WHERE Id IN: accountIds];
    }
    
     Static public List<Account> getAccountListByUniquieIds(Set<Id> accountIds){
        return [SELECT Id, Name FROM Account WHERE Id IN: accountIds];
    }
    
}