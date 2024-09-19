@isTest
public class TH_LOBManagement_T {
    
    public static User admin_User;
    public static Integer count =1;
    public static string SYSTEM_ADMINISTRATOR_PROFILE ='System Administrator';
    public static List<LOB_Management__c> lobManagement = new List<LOB_Management__c>();
    public static List<Account> acc = new List<Account>();
    public static List<Opportunity> Opp = new List<Opportunity>();
    
    static void proccesRecordDataForLOB()
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
            Set<Id> oppIds = new Set<Id>{Opp[0].Id};
                lobManagement = DAL_LOB_Management.getAllLOBManagementByOpp(oppIds);
            List<RecordType> lobReocrdTypes = DAL_LOB_Management.getAllLOBManagementRecordType();
            RecordType lobOceanMarineRT = new RecordType();
            for(RecordType rt : lobReocrdTypes){
                if(rt.Name == 'Ocean Marine')
                    lobOceanMarineRT = rt;
            }
            
        }
    }
    
    static testMethod void csetLOBManagementTest() 
    {
        proccesRecordDataForLOB();
        Test.startTest();
        update lobManagement;
        update opp;
        try{
            delete lobManagement;
        }catch(Exception e){
            
        }
        Test.stopTest();     
    }
    
    static testMethod void csetLOBManagementTest1() 
    {
        proccesRecordDataForLOB();
        Test.startTest();
        lobManagement[0].Type__c = 'New';
        lobManagement[0].LOB_Stage__c = 'Declined';
        update lobManagement;
        lobManagement[0].Type__c = 'Renewal';
        lobManagement[0].LOB_Stage__c = 'Quote';
        update lobManagement;
        lobManagement[0].LOB_Stage__c = 'Submission';
        update lobManagement;
        lobManagement[0].LOB_Stage__c = 'Interest';
        update lobManagement;
        lobManagement[0].LOB_Stage__c = 'Bound';
        update lobManagement;
        lobManagement[0].LOB_Stage__c = 'Lost';
        update lobManagement;
        Test.stopTest();     
    }
    
    static testMethod void csetLOBManagementTest3(){
        proccesRecordDataForLOB();
        Test.startTest();
        lobManagement[0].LOB_Stage__c = 'Not Submitted';
        update lobManagement;
        lobManagement[0].LOB_Stage__c = 'Not Interested';
        update lobManagement;
        Test.stopTest();
    }
    
    static testMethod void newLOBManagementTest1() 
    {
        proccesRecordDataForLOB();
        Test.startTest();
        Opp[0].Line_of_Business__c += ';Foreign Casualty CMP';
        update Opp;
        
        Id BuildersRiskRT = Schema.SObjectType.LOB_Management__c.getRecordTypeInfosByDeveloperName().get('Builders_Risk').getRecordTypeId();
        List<LOB_Management__c> newLobRecords = new List<LOB_Management__c>();
        Map<String,Object>  LOBobj = new Map<String,Object>();
        LOBobj.put('LOB_Stage__c','Submission');
        LOBobj.put('LOB_Effective_Date__c', Date.today().addDays(5));
        LOBobj.put('Submission_Source__c','Other');
        LOBobj.put('Opportunity_Related__c', Opp[0].Id);
        LOBobj.put('Type__c','New');
        LOBobj.put('RecordTypeId', BuildersRiskRT);
        newLobRecords.add((LOB_Management__c) TestDataFactory.operationOnObjectRec('', 'LOB_Management__c', LOBobj));
        Insert newLobRecords;
        Test.stopTest();     
    }
    
    static testMethod void newLOBManagementTest2() 
    {
        proccesRecordDataForLOB();
        Test.startTest();
        Id Foreign_Casualty_CMP_RT = Schema.SObjectType.LOB_Management__c.getRecordTypeInfosByDeveloperName().get('Foreign_Casualty_CMP').getRecordTypeId();
        Map<String,Object>  LOBobj = new Map<String,Object>();
        LOBobj.put('LOB_Stage__c','Submission');
        LOBobj.put('LOB_Effective_Date__c', Date.today().addDays(5));
        LOBobj.put('Submission_Source__c','Other');
        LOBobj.put('Opportunity_Related__c', Opp[0].Id);
        LOBobj.put('Type__c','New');
        LOBobj.put('RecordTypeId', Foreign_Casualty_CMP_RT);
        
        LOB_Management__c lobForeignCasualtyCMPRec = (LOB_Management__c) TestDataFactory.operationOnObjectRec('', 'LOB_Management__c', LOBobj);
        Insert lobForeignCasualtyCMPRec;
        
        Id Builders_Risk_RT = Schema.SObjectType.LOB_Management__c.getRecordTypeInfosByDeveloperName().get('Builders_Risk').getRecordTypeId();
        LOBobj.put('RecordTypeId', Builders_Risk_RT);
        LOB_Management__c lobBuildersRiskRec = (LOB_Management__c) TestDataFactory.operationOnObjectRec('', 'LOB_Management__c', LOBobj);
        Insert lobBuildersRiskRec;
        Test.stopTest();     
    }
    
    static testMethod void csetLOBManagementTest2() 
    {
        proccesRecordDataForLOB();
        Test.startTest();
        Id Builders_Risk_RT = Schema.SObjectType.LOB_Management__c.getRecordTypeInfosByDeveloperName().get('Builders_Risk').getRecordTypeId();
        lobManagement[0].RecordTypeId = Builders_Risk_RT;
        update lobManagement;
        Test.stopTest();     
    }
    
   

}