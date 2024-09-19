@isTest
public class MultiselectLOBPremiumHelper_T {
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
            
            MultiselectLOBPremiumHelper.getLOBRecords(Opp[0].Id); 
            lobManagement = DAL_LOB_Management.getAllLOBManagementByOpp(new Set<Id>{Opp[0].Id});
            MultiselectLOBPremiumHelper.updateLOBRecords(new Map<String, Decimal>{String.valueOf(lobManagement[0].Id)=>1.00},new Map<String, Decimal>{String.valueOf(lobManagement[0].Id)=>1.00});  
            MultiselectLOBPremiumHelper.updateLOBEffectiveDateRecords(new Map<String, Date>{lobManagement[0].Id=>Date.today()});  
            MultiselectLOBPremiumHelper.updateLOBUnderWriterRecords(new Map<String, String>{lobManagement[0].Id=>admin_User.Id}, Opp[0].Id, new Map<String, String>{lobManagement[0].Id=>'Test Task'});
            MultiselectLOBPremiumHelper.fetchLookupData('test','User');
            MultiselectLOBPremiumHelper.fetchDefaultRecord('test','User');
            LOB_Management__c LOB = [SELECT Id, Estimated_LOB_Premium__c, LOB_Effective_Date__c,Referred_by__c,Underwriter__c FROM LOB_Management__c WHERE Id = :lobManagement[0].Id];
            List<Task> taskRec = [SELECT Id FROM Task WHERE WhatId = :Opp[0].Id];
            system.debug('@@LOB:::'+LOB);
            system.assertEquals(1.00, LOB.Estimated_LOB_Premium__c);
            system.assertEquals(Date.today(), LOB.LOB_Effective_Date__c);
            system.assertEquals(admin_User.Id, LOB.Underwriter__c);
            system.assertEquals(1, taskRec.size());
        }
    
    }
        static testMethod void taskTest() 
    {
        proccesRecordDataForLOB();
    }
}