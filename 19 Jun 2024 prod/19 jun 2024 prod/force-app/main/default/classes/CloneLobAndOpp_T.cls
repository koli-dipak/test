@isTest
public class CloneLobAndOpp_T {
    
    public static User admin_User;
    public static Integer count =1;
    public static string SYSTEM_ADMINISTRATOR_PROFILE ='System Administrator';
    public static List<Opportunity> Opp = new List<Opportunity>();
    public static List<Account> acc = new List<Account>();
    public static List<Contact> ContactList = new List<Contact>();
    public static List<LOB_Management__c > LobList = new List<LOB_Management__c >();
    
    @isTest
    public static void testMethod1(){
        admin_User = TestDataFactory.createUser(true,'User',SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        System.runAs(admin_User){
            
            //Account
            Map<String,Object>  Accountobj = new Map<String,Object>();
            Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
            Accountobj.put('RecordTypeId',RecordTypeId);
            Accountobj.put('Name','NewAcco');
            Accountobj.put('Box_Folder_Name__c','test');
            for(Integer i = 0 ; i <count; i++)
            {
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
            }
            
            
            //Opportunity
            Map<String,Object>  Opportunityobj = new Map<String,Object>();
            Opportunityobj.put('Name','test');
            Opportunityobj.put('CloseDate',System.today());
            //Opportunityobj.put('StageName','Interest');
            Opportunityobj.put('StageName','Bound');
            Opportunityobj.put('AccountId',acc[0].Id);
            Opportunityobj.put('Line_of_Business__c','Commercial Umbrella;Ocean Marine');
            //Opportunityobj.put('Line_of_Business__c','Commercial Auto');
            for(Integer i = 0 ; i <count; i++)
            {
                Opp.add((Opportunity) TestDataFactory.operationOnObjectRec('insert', 'Opportunity', Opportunityobj));
            }
            
            //Opportunity2
            Map<String,Object>  Opportunityobj2 = new Map<String,Object>();
            Opportunityobj2.put('Name','test');
            Opportunityobj2.put('CloseDate',System.today());
            //Opportunityobj.put('StageName','Interest');
            Opportunityobj2.put('StageName','Bound');
            Opportunityobj2.put('AccountId',acc[0].Id);
            Opportunityobj2.put('Line_of_Business__c','Ocean Marine');
            Opportunityobj2.put('Prospect_Opportunity__c',Opp[Opp.size()-1].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                Opp.add((Opportunity) TestDataFactory.operationOnObjectRec('insert', 'Opportunity', Opportunityobj2));
            }
            
            System.debug('Opp@@@'+ Opp);
            
            //LOB_Management__c 
            Id Commercial_Auto_RT = Schema.SObjectType.LOB_Management__c.getRecordTypeInfosByDeveloperName().get('Commercial_Auto').getRecordTypeId();
            Map<String,Object>  LOBobj = new Map<String,Object>();
            LOBobj.put('LOB_Stage__c','Bound');
            LOBobj.put('LOB_Effective_Date__c', Date.today().addDays(6));
            //LOBobj.put('Lob_Expiry_Date__c', Date.valueOf('2023-08-11'));
            LOBobj.put('Lob_Expiry_Date__c', Date.today().addDays(-180));
            LOBobj.put('Estimated_LOB_Premium__c',1043);
            LOBobj.put('Submission_Source__c','Other');
            LOBobj.put('Opportunity_Related__c', Opp[0].Id);
            //LOBobj.put('Case__c', CaseList[0].Id);
            LOBobj.put('Type__c','New');
            LOBobj.put('RecordTypeId', Commercial_Auto_RT);
            LOBobj.put('Cloned__c', false);
            for(Integer i = 0 ; i <count; i++)
            {
                LobList.add((LOB_Management__c) TestDataFactory.operationOnObjectRec('insert', 'LOB_Management__c', LOBobj));
            }
            
            //LOB_Management__c2
            Id Commercial_UMB_RT = Schema.SObjectType.LOB_Management__c.getRecordTypeInfosByDeveloperName().get('Commercial_Umbrella').getRecordTypeId();
            Map<String,Object>  LOBobj2 = new Map<String,Object>();
            LOBobj2.put('LOB_Stage__c','Bound');
            LOBobj2.put('LOB_Effective_Date__c', Date.today().addDays(8));
            //LOBobj2.put('Lob_Expiry_Date__c', Date.valueOf('2023-08-11'));
            LOBobj2.put('Lob_Expiry_Date__c', Date.today().addDays(-180));
            LOBobj2.put('Estimated_LOB_Premium__c',103);
            LOBobj2.put('Submission_Source__c','Other');
            LOBobj2.put('Opportunity_Related__c', Opp[1].Id);
            LOBobj2.put('Type__c','New');
            LOBobj2.put('RecordTypeId', Commercial_UMB_RT);
            LOBobj2.put('Cloned__c', false);
            for(Integer i = 0 ; i <count; i++)
            {
                LobList.add((LOB_Management__c) TestDataFactory.operationOnObjectRec('insert', 'LOB_Management__c', LOBobj2));
            }
            
        }
    
    // Test the cloneLobAndOpps method
    Test.startTest();
    String result = CloneLobAndOpp.cloneLobAndOpps(LobList);
    Test.stopTest();
    
    // Perform assertions if needed
    //System.assertEquals(Opp[0].Id, result, 'The cloned opportunity ID should match');
}
}