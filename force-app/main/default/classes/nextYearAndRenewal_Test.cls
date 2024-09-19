@isTest
public class nextYearAndRenewal_Test {
    
   	public static User admin_User;
    public static Integer count =1;
    public static string SYSTEM_ADMINISTRATOR_PROFILE ='System Administrator';
    public static List<LOB_Management__c> lobManagement = new List<LOB_Management__c>();
    public static List<Account> acc = new List<Account>();
    public static List<Opportunity> Opp = new List<Opportunity>();
    
	@isTest
    static void processNextYearAndRenewalT() 
    {
        admin_User = TestDataFactory.createUser(true,'LOB_Management__c',SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        System.runAs(admin_User)
        {
            Map<String,Object>  Accountobj = new Map<String,Object>();
            Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
            Accountobj.put('RecordTypeId',RecordTypeId);
            Accountobj.put('Name','NewAcco');
            Accountobj.put('Box_Folder_Name__c','test');
            for(Integer i = 0 ; i <count; i++)
            {
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
            }
            
            Map<String,Object>  Opportunityobj = new Map<String,Object>();
            Opportunityobj.put('Name','test');
            Opportunityobj.put('CloseDate',System.today());
            Opportunityobj.put('StageName','Unqualified');
            Opportunityobj.put('AccountId',acc[0].Id);
            Opportunityobj.put('Line_of_Business__c','Commercial Umbrella;Ocean Marine');
            for(Integer i = 0 ; i <count; i++)
            {
                Opp.add((Opportunity) TestDataFactory.operationOnObjectRec('insert', 'Opportunity', Opportunityobj));
            }
            
            Map<String,Object>  LOBObj = new Map<String,Object>();
            LOBObj.put('LOB_Effective_Date__c',date.today());
            LOBObj.put('LOB_Stage__c','Bound');
            LOBObj.put('Submission_Source__c','Broker');
            LOBObj.put('Type__c','Renewal');
            LOBObj.put('Opportunity_Related__c',Opp[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                lobManagement.add((LOB_Management__c) TestDataFactory.operationOnObjectRec('insert', 'LOB_Management__c', LOBObj));
            }
            
            Test.startTest();
            nextYearAndRenewal.processNextYearAndRenewal(Opp[0].Id);
            Test.stopTest();
            
        }
        
    }
}