@isTest
private class DAL_Account_T {
    
    public static User admin_User;
    public static Integer count =1;
    public static string ADMIN_PROFILE ='System Administrator';
    public static List<Account> acc = new List<Account>();
    
    static void proccesRecordData()
    {
        admin_User = TestDataFactory.createUser(true,'Account',ADMIN_PROFILE);
        insert admin_User;
        System.runAs(admin_User)
        {
            Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
            
            for(Integer i = 0 ; i <count; i++)
            {
                Map<String,Object>  Accountobj = new Map<String,Object>();
                Accountobj.put('RecordTypeId',accRecordTypeId);
                Accountobj.put('Name','Hiteshm');
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
                
                Map<String,Object>  Accountobj2 = new Map<String,Object>();
                Accountobj2.put('RecordTypeId',accRecordTypeId);
                Accountobj2.put('Name','Hitesha');
                Accountobj2.put('Insured_External_Id__c','HITESHM-02');
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj2));
            }
        }
    }
    
    static testMethod void AccountproccesRecordDataTest() 
    {
        proccesRecordData();
        Test.startTest();
        
        Set<String> prefixSet1 = new Set<String>();
        prefixSet1.add(acc[1].Insured_External_Id__c);
        
        
        Set<String> prefixSet = new Set<String>();
        String newFolderName=acc[0].Name.replaceAll('[\\.\\*\\s\\?<>()&#@/,\'"%20:\\\\]', '');
        if(newFolderName.length()>7){
            newFolderName=newFolderName.substring(0,7);
        }else{
            newFolderName=newFolderName.rightPad(7, '0');
        }
        newFolderName = newFolderName.toUpperCase();
        prefixSet.add(newFolderName);
        
        Set<Id> accIds = new Set<Id>();
        accIds.add(acc[0].Id);
        DAL_Account.getAccountBoxFolderName(prefixSet1);
        DAL_Account.getAccountBoxFolderNamePrefixList(prefixSet);
        DAL_Account.getAccountById(acc[0].Id);
        DAL_Account.getAccountMap(accIds);
        DAL_Account.getAccountList(new List<Id>{acc[0].Id});
        DAL_Account.getAccountListByUniquieIds(accIds);
        DAL_Account.getChildAccountsMap(accIds);
        Test.stopTest();
    }
}