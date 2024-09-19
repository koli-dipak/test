@isTest
public class BoxCreationTest {
    /*Static testMethod void createAccountBox(){ 
        
        List<Account> accounts = new List<Account>{};
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
        Account testAccount = new Account();
        testAccount.Name='Test Company Name123';
        testAccount.RecordTypeId = accRecordTypeId;
        accounts.add(testAccount);
        insert accounts;
        
        List<box__FRUP__c> boxFrups = new List<box__FRUP__c>();
		box__FRUP__c testboxFrups = new box__FRUP__c();
        testboxFrups.box__Retry_Count__c = 1.00;
        boxFrups.add(testboxFrups);
        insert boxFrups;
        
        ApexPages.StandardController scAcc = new ApexPages.StandardController(testAccount);
        BoxCreation testAccBoxCreation = new BoxCreation(scAcc);
        testAccBoxCreation.createAccountBox();
        
        Opportunity opp = new Opportunity();
        
        Map<String,Object>  Opportunityobj = new Map<String,Object>();
        Opportunityobj.put('StageName','Interest');
        Opportunityobj.put('Line_of_Business__c','Builders Risk');
        opp = (Opportunity) TestDataFactory.operationOnObjectRecord('insert', 'Opportunity', Opportunityobj);  
        opp.AccountId = testAccount.Id;
        update opp;
        
        ApexPages.StandardController scOpp = new ApexPages.StandardController(opp);
        BoxCreation testOppBoxCreation = new BoxCreation(scOpp);
        testOppBoxCreation.createOpportunityBox();
        
		LOB_Management__c lob = new LOB_Management__c();
        lob.Opportunity_Related__c = opp.Id;
        insert lob;
        
        ApexPages.StandardController scLob = new ApexPages.StandardController(lob);
        BoxCreation testLobBoxCreation = new BoxCreation(scLob);
        testLobBoxCreation.createLOBBox();
        
        
        Clearance__c cler = new Clearance__c();
        insert cler;
        
        ApexPages.StandardController sccler = new ApexPages.StandardController(cler);
        BoxCreation testscclerBoxCreation = new BoxCreation(sccler);
        testscclerBoxCreation.createClearanceBox();
    }*/
    
    
    public static User admin_User;
    public static Integer count =1;
    public static string ADMIN_PROFILE ='System Administrator';
    public static List<Account> acc = new List<Account>();
    public static List<box__FRUP__c> frup = new List<box__FRUP__c>();
    public static List<Opportunity> Opp = new List<Opportunity>();
    public static List<Clearance__c> Clearance = new List<Clearance__c>();
    public static List<LOB_Management__c> lobManagement = new List<LOB_Management__c>();

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
                Accountobj.put('Name','Newtes'+i);
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
            }
            
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
            
            Map<String,Object>  Clearanceobj = new Map<String,Object>();
            Clearanceobj.put('Opportunity__c',opp[0].id);
            for(Integer i = 0 ; i <count; i++)
            {
                Clearance.add((Clearance__c) TestDataFactory.operationOnObjectRec('insert', 'Clearance__c', Clearanceobj));
            }
            
            Set<Id> oppIds = new Set<Id>{Opp[0].Id};
            lobManagement = DAL_LOB_Management.getAllLOBManagementByOpp(oppIds);
        }
    }
    
    static testMethod void AccountproccesRecordDataTest() 
    {
        proccesRecordData();
        Test.startTest();
        
        ApexPages.StandardController scAcc = new ApexPages.StandardController(acc[0]);
        BoxCreation testAccBoxCreation = new BoxCreation(scAcc);
        testAccBoxCreation.createAccountBox();
        
        ApexPages.StandardController scOpp = new ApexPages.StandardController(opp[0]);
        BoxCreation testOppBoxCreation = new BoxCreation(scOpp);
        testOppBoxCreation.createOpportunityBox();
        
        ApexPages.StandardController scLob = new ApexPages.StandardController(lobManagement[0]);
        BoxCreation testLobBoxCreation = new BoxCreation(scLob);
        testLobBoxCreation.createLOBBox();
        
        ApexPages.StandardController sccler = new ApexPages.StandardController(Clearance[0]);
        BoxCreation testscclerBoxCreation = new BoxCreation(sccler);
        testscclerBoxCreation.createClearanceBox();
        
        Test.stopTest();
    }
}