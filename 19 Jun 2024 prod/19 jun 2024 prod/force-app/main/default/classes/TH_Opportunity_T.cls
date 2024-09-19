@isTest
public class TH_Opportunity_T {
    
    public static User admin_User;
    public static Integer count =1;
    public static string SYSTEM_ADMINISTRATOR_PROFILE ='System Administrator';
    public static List<Opportunity> Opp = new List<Opportunity>();
    public static List<Account> acc = new List<Account>();
    public static List<LOB_Management__c> LOBManagement = new List<LOB_Management__c>();
    
    static void proccesRecordDataForOpp()
    {
        
        admin_User = TestDataFactory.createUser(true,'Opportunity',SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        System.runAs(admin_User)
        {
            Map<String,Object>  Accountobj = new Map<String,Object>();
            Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
            Accountobj.put('RecordTypeId',RecordTypeId);
            //Accountobj.put('Name','TI Sparkle Americas, Inc., TI Sparkle S. Croix, TI Sparkle (GER Program - Telecom Italia');
            Accountobj.put('Name','Test Account');
            Accountobj.put('Box_Folder_Name__c','test');
            for(Integer i = 0 ; i <count; i++)
            {
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
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
    
    static testMethod void ApprovedStatesOnPolicyFormTest() 
    {
        proccesRecordDataForOpp();
        Test.startTest();
        update Opp;
        Test.stopTest();
    }
    Static testMethod void updatLineOfBusinessForeign(){
        proccesRecordDataForOpp();
        Test.startTest();
        Opp[0].Line_of_Business__c = 'Foreign Casualty CMP';
        update Opp;
        Test.stopTest();
    }
    Static testMethod void updatLineOfBusinessGlobal(){
        proccesRecordDataForOpp();
        Test.startTest();
        Opp[0].Line_of_Business__c = 'Commercial Umbrella;Foreign Casualty CMP';
        update Opp;
        Test.stopTest();
    }
    static testMethod void UpdateOppName(){
        proccesRecordDataForOpp();
        Test.startTest();
        Opp[0].Name = 'test';
        update Opp;
        Test.stopTest();
    }
    static testMethod void updateLOBStageToBound(){
        proccesRecordDataForOpp();
        Test.startTest();
        List<LOB_Management__c> lobList = [Select ID, LOB_Stage__c From LOB_Management__c where Opportunity_Related__c=:Opp[0].Id ];
        for(LOB_Management__c lob : lobList){
            lob.LOB_Stage__c = 'Bound';
        }
        update lobList;
        Test.stopTest();
    }
    
    static testMethod void updateLOBStageToLost(){
        proccesRecordDataForOpp();
        Test.startTest();
        List<LOB_Management__c> lobList = [Select ID, LOB_Stage__c From LOB_Management__c where Opportunity_Related__c=:Opp[0].Id ];
        for(LOB_Management__c lob : lobList){
            lob.LOB_Stage__c = 'Lost';
        }
        update lobList;
        Test.stopTest();
    }
    
    static testMethod void updateLOBStageToDeclined(){
        proccesRecordDataForOpp();
        Test.startTest();
        List<LOB_Management__c> lobList = [Select ID, LOB_Stage__c From LOB_Management__c where Opportunity_Related__c=:Opp[0].Id ];
        for(LOB_Management__c lob : lobList){
            lob.LOB_Stage__c = 'Declined';
        }
        update lobList;
        Test.stopTest();
    }
    
    static testMethod void updateLOBStageToNotSubmitted(){
        proccesRecordDataForOpp();
        Test.startTest();
        List<LOB_Management__c> lobList = [Select ID, LOB_Stage__c From LOB_Management__c where Opportunity_Related__c=:Opp[0].Id ];
        for(LOB_Management__c lob : lobList){
            lob.LOB_Stage__c = 'Not Submitted';
        }
        update lobList;
        Test.stopTest();
    }
    
    static testMethod void updateLOBStageToQuote(){
        proccesRecordDataForOpp();
        Test.startTest();
        Opp[0].Instructions_to_BPO__c = 'test';
        update Opp;
        Test.stopTest();
    }
    
    static testMethod void testOpportunityStageValidation() {
        proccesRecordDataForOpp();
        try {
            Test.startTest();
            Opp[0].StageName = 'Not Interested';
            //Opp[0].Count_LOB_with_Quote__c = 1;
            update Opp;
            Test.stopTest();
            
        } catch (Exception e) {
        }
        
    }
    
    
}