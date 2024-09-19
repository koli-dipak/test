@isTest
public class DAL_LOB_Management_T {
    public static User admin_User;
    public static Integer count =1;
    public static string SYSTEM_ADMINISTRATOR_PROFILE ='System Administrator';
    
    @isTest
    static void testMethod1()
    {
        admin_User = TestDataFactory.createUser(true,'LOB_Management__c',SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        System.runAs(admin_User)
        {
            Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
            Map<String,Object>  Accountobj = new Map<String,Object>();
            Accountobj.put('RecordTypeId',RecordTypeId);
            Accountobj.put('Name','NewAcco');
            Accountobj.put('Box_Folder_Name__c','test');
            Account accountRec = (Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj);

            Map<String,Object>  Opportunityobj = new Map<String,Object>();
            Opportunityobj.put('Name','test');
            Opportunityobj.put('CloseDate',System.today());
            Opportunityobj.put('StageName','Unqualified');
            Opportunityobj.put('AccountId',accountRec.Id);
            Opportunityobj.put('Line_of_Business__c','Commercial Umbrella;Ocean Marine');
            Opportunity OpportunityRec = (Opportunity) TestDataFactory.operationOnObjectRec('insert', 'Opportunity', Opportunityobj);
            
            /*Id Foreign_Casualty_CMP_RT = Schema.SObjectType.LOB_Management__c.getRecordTypeInfosByDeveloperName().get('Foreign_Casualty_CMP').getRecordTypeId();
            Map<String,Object>  LOBobj = new Map<String,Object>();
            LOBobj.put('LOB_Stage__c','Submission');
            LOBobj.put('LOB_Effective_Date__c', Date.today().addDays(5));
            LOBobj.put('Submission_Source__c','Other');
            LOBobj.put('Opportunity_Related__c', OpportunityRec.Id);
            LOBobj.put('Type__c','New');
            LOBobj.put('RecordTypeId', Foreign_Casualty_CMP_RT);
            LOB_Management__c lobForeignCasualtyCMPRec = (LOB_Management__c) TestDataFactory.operationOnObjectRec('insert', 'LOB_Management__c', LOBobj);*/
            
            List<LOB_Management__c> lobManagementRecords = DAL_LOB_Management.getAllLOBManagementByOpp(new Set<Id>{OpportunityRec.Id});
            system.assertEquals(2, lobManagementRecords.size());

            DAL_LOB_Management.getAllLOBManagementRecordType();

            DAL_LOB_Management.getLOBManagementById(lobManagementRecords[0].Id);

            List<LOB_Management__c> lobManagementRecords3 = DAL_LOB_Management.getLOBManagementByIds(lobManagementRecords[0].Id);
            system.assertEquals(1, lobManagementRecords3.size());
            
            List<LOB_Management__c> lobManagementRecordsGetListOfLob = DAL_LOB_Management.getListOfLob(lobManagementRecords[0].Id);
            system.assertEquals(1, lobManagementRecordsGetListOfLob.size());
            
            List<LOB_Management__c> lobManagementRecordsgetOrginalLob = DAL_LOB_Management.getOrginalLob(new List<Id>{lobManagementRecords[0].Id});
            system.assertEquals(1, lobManagementRecordsgetOrginalLob.size());

            List<LOB_Management__c> lobManagementRecords4 = DAL_LOB_Management.getLOBRecordsByOppId(OpportunityRec.Id);
            system.assertEquals(2, lobManagementRecords4.size());
            
            List<Probability_Default_Percentage__mdt> ProbDefaPer = DAL_LOB_Management.getAllProbabilityDefaultPerMdt();
            system.assertEquals(ProbDefaPer.size()>0,true);
            
            List<Lob_Stage_Picklist__mdt > LobStgMdt = DAL_LOB_Management.getLobStageMdt();
            system.assertEquals(LobStgMdt.size()>0,true);
        }
    }
}