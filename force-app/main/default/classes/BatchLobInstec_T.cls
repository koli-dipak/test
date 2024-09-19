@isTest
public class BatchLobInstec_T {
	public static User admin_User;
    public static Integer count =1;
    public static string SYSTEM_ADMINISTRATOR_PROFILE ='System Administrator';
    public static List<Opportunity> Opp = new List<Opportunity>();
    public static List<Account> acc = new List<Account>();
    public static List<Contact> ContactList = new List<Contact>();
    public static List<LOB_Management__c > LobList = new List<LOB_Management__c >();
    public static List<InsurancePolicy> Ipol = new List<InsurancePolicy>();
    public static List<Policy_Number_Holder__c> policyHolders = new List<Policy_Number_Holder__c>();
    public static Map<Id, Lob_Management__c> uniqueLobManagementMap = new Map<Id, Lob_Management__c>();

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
            
            //System.debug('Opp@@@'+ Opp);

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

            //create insurance policy record
            Map<String,Object>  InsurancePolicyobj = new Map<String,Object>();
            InsurancePolicyobj.put('NameInsuredId',acc[0].Id);
            //InsurancePolicyobj.put('ParentPolicyId',Ipol[0].Id);
            InsurancePolicyobj.put('Name','Newtes');
            InsurancePolicyobj.put('StorageID__c','a1234b');
            Ipol.add((InsurancePolicy) TestDataFactory.operationOnObjectRec('insert', 'InsurancePolicy',  InsurancePolicyobj));
            
            
            // Create Policy_Number_Holder__c records with Policy_Number__c set to 'Newtes'
            Map<String, Object> policyHolderObj = new Map<String, Object>();
            policyHolderObj.put('Line_of_Business__c', LobList[0].Id);
            //policyHolderObj.put('Instec_Storage_ID__c', acc[0].Id);
            //policyHolderObj.put('Instec_Expiration__c', Date.today().addYears(1));
            policyHolderObj.put('Effective_Date__c', Date.today());
            policyHolderObj.put('Policy_Number__c', 'Newtes');
            policyHolderObj.put('Insurance_Policy__c', Ipol[0].Id);
            policyHolders.add((Policy_Number_Holder__c)TestDataFactory.operationOnObjectRec('insert', 'Policy_Number_Holder__c', policyHolderObj));
			System.debug('## ' + policyHolderObj);
			
        }
    }
    
    @isTest
    static void testBatchLobInstec() {
        Test.startTest();
        testMethod1();
        BatchLobInstec batch = new BatchLobInstec();
        Database.executeBatch(batch);
        Test.stopTest();
        
        List<Lob_Management__c> updatedLobManagementRecords = [SELECT Id, Lob_Expiry_Date__c, is_Instec_Lob__c FROM Lob_Management__c WHERE Id IN :uniqueLobManagementMap.keySet()];

        for (Lob_Management__c lob : updatedLobManagementRecords) {
            System.assertEquals(true, lob.is_Instec_Lob__c, 'is_Instec_Lob__c should be true.');
        } 
    }
}