@isTest
public class TH_Clearance_T {
    
    public static User admin_User;
    public static Integer count =2;
    public static Integer countClearance =1;
    public static string SYSTEM_ADMINISTRATOR_PROFILE ='System Administrator';
    public static List<Clearance__c> Clearance = new List<Clearance__c>();
    public static List<Account> acc = new List<Account>();
    public static List<Opportunity> Opp = new List<Opportunity>();
    static void proccesRecordDataForClearance(){
        admin_User = TestDataFactory.createUser(true,'Opportunity',SYSTEM_ADMINISTRATOR_PROFILE);
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
            Opportunityobj.put('Line_of_Business__c','Commercial Umbrella;Ocean Marine');
            Opportunityobj.put('AccountId',acc[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                Opp.add((Opportunity) TestDataFactory.operationOnObjectRec('insert', 'Opportunity', Opportunityobj));
            }
            
            Map<String,Object>  Clearanceobj = new Map<String,Object>();
            Clearanceobj.put('Opportunity__c',opp[0].id);
            for(Integer i = 0 ; i <countClearance; i++)
            {
                Clearance.add((Clearance__c) TestDataFactory.operationOnObjectRec('insert', 'Clearance__c', Clearanceobj));
            }
            
            Map<String,Object>  ClearanceobjNew = new Map<String,Object>();
            Id cleRecordTypeId = Schema.SObjectType.Clearance__c.getRecordTypeInfosByName().get('Sanctions Clearance').getRecordTypeId();
            ClearanceobjNew.put('RecordTypeId',cleRecordTypeId);
            ClearanceobjNew.put('Opportunity__c',opp[0].id);
            for(Integer i = 0 ; i <countClearance; i++)
            {
                Clearance.add((Clearance__c) TestDataFactory.operationOnObjectRec('insert', 'Clearance__c', ClearanceobjNew));
            }
        }
    }
    
    static testMethod void ApprovedStatesOnPolicyFormTest() 
    {
        proccesRecordDataForClearance();
        Test.startTest();
        update Clearance;
        Test.stopTest();
    }
}