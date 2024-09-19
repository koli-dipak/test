public class AccountBoxController {
    public String folderName{get;set;}
    public AccountBoxController(ApexPages.StandardController stdController) {
        Account acct = (Account)stdController.getRecord();
    	folderName=[select id,Box_Folder_Id__c from account where id=:acct.Id limit 1].Box_Folder_Id__c;
    }
    
    
}