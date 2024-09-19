@isTest
public class DAL_Opportunity_T {
    public static User admin_User;
    public static Integer count =1;
    public static string ADMIN_PROFILE ='System Administrator';
    public static List<Opportunity> Opp = new List<Opportunity>();
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
            
            Map<String,Object>  Opportunityobj = new Map<String,Object>();
            Opportunityobj.put('Name','test');
            Opportunityobj.put('CloseDate',System.today());
            Opportunityobj.put('StageName','Interest');
            Opportunityobj.put('Type','New');
            Opportunityobj.put('AccountId',acc[0].Id);
            Opportunityobj.put('Line_of_Business__c','Commercial Umbrella');
            for(Integer i = 0 ; i <count; i++)
            {
                Opp.add((Opportunity) TestDataFactory.operationOnObjectRec('insert', 'Opportunity', Opportunityobj));
            }
        }
    }
    
    static testMethod void proccesRecordDataTest() 
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
        
        Set<Id> oppIds = new Set<Id>();
        oppIds.add(opp[0].Id);
        DAL_Opportunity.getAllOpportunityById(oppIds);
        DAL_Opportunity.getAllOpportunityMapById(oppIds);
        DAL_Opportunity.getOpportunityById(opp[0].Id);
        DAL_Opportunity.getAllProductCategoryMdt();
        DAL_Opportunity.getUserByCurrentUserId(new Set<Id>{admin_User.Id});
        DAL_Opportunity.getOpportunityAppliedEpicKeyPrefixList(prefixSet);
        DAL_Opportunity.getQueue();
        DAL_Opportunity.getOppByAccountIds(new Set<Id>{acc[0].Id});
        Test.stopTest();
    }
}