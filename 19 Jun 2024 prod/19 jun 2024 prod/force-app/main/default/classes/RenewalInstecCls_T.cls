@isTest
public class RenewalInstecCls_T {
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
            Opportunityobj.put('StageName','Interest');
            Opportunityobj.put('AccountId',acc[0].Id);
            Opportunityobj.put('Line_of_Business__c','Commercial Umbrella;Ocean Marine');
            for(Integer i = 0 ; i <count; i++)
            {
                Opp.add((Opportunity) TestDataFactory.operationOnObjectRec('insert', 'Opportunity', Opportunityobj));
            }
            
            System.debug('Opp@@@'+ Opp);

            //LOB_Management__c 
            Id Commercial_Auto_RT = Schema.SObjectType.LOB_Management__c.getRecordTypeInfosByDeveloperName().get('Commercial_Auto').getRecordTypeId();
            Map<String,Object>  LOBobj = new Map<String,Object>();
            LOBobj.put('LOB_Stage__c','Bound');
            LOBobj.put('LOB_Effective_Date__c', Date.today().addDays(5));
            LOBobj.put('Estimated_LOB_Premium__c',1050);
            LOBobj.put('Submission_Source__c','Other');
            LOBobj.put('Opportunity_Related__c', Opp[0].Id);
            //LOBobj.put('Case__c', CaseList[0].Id);
            LOBobj.put('Type__c','New');
            LOBobj.put('RecordTypeId', Commercial_Auto_RT);
            for(Integer i = 0 ; i <count; i++)
            {
                LobList.add((LOB_Management__c) TestDataFactory.operationOnObjectRec('insert', 'LOB_Management__c', LOBobj));
            }
          

        }
    }
    
    static testMethod void testGetRenewalLob() {

        // Call the getRenewalLob method
        Test.startTest();
        testMethod1();
        List<Policy_Number_Holder__c> policies = RenewalInstecCls.getRenewalLob(LobList[LobList.size()-1].Id);
        Test.stopTest();

        System.assertEquals(0, policies.size());
    }

    static testMethod void testGetPoliciesAndInstecDetailsFromLob() {

        // Call the getPoliciesAndInstecDetailsFromLob method
        Test.startTest();
        testMethod1();
        List<Policy_Number_Holder__c> policies = RenewalInstecCls.getPoliciesAndInstecDetilsFromLob(LobList[LobList.size()-1].Id, new RenewalInstecCls());
        Test.stopTest();
		
        System.assertEquals(0, policies.size());
    }

    static testMethod void testSendToInstec() {
        // Create test data for PolicyAndInstecDetails
        List<Policy_Number_Holder__c> policies = new List<Policy_Number_Holder__c>();
        Policy_Number_Holder__c policy = new Policy_Number_Holder__c();
        // Initialize policy fields here
        policies.add(policy);

        // Create test data for renewalInstecObj
        RenewalInstecCls renewalInstecObj = new RenewalInstecCls();
        // Initialize renewalInstecObj fields here

        // Call the sendToInstec method
        Test.startTest();
        RenewalInstecCls.sendToInstec(policies, renewalInstecObj);
        Test.stopTest();
    }
}