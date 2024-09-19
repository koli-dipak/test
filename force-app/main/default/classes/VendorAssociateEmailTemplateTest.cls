@isTest
public class VendorAssociateEmailTemplateTest { 
    public static User admin_User;
    public static Integer count = 1;
    public static String ADMIN_PROFILE = 'System Administrator';
    public static List<Account> acc = new List<Account>();
    public static List<Case> CaseList = new List<Case>();
    public static List<Opportunity> Opp = new List<Opportunity>();
    public static List<Contact> con = new List<Contact>();
    public static List<LOB_Management__c> lobManagement = new List<LOB_Management__c>();
    public static List<Schema.Location> loc = new List<Schema.Location>();
    public static List<CaseAndLocaiton__c> caseLocation = new List<CaseAndLocaiton__c>();
    public static List<InsurancePolicy> Ipol = new List<InsurancePolicy>();
    public static List<Location_And_Contact__c> LocationContact = new List<Location_And_Contact__c>();
    public static List<Location_And_Line_Of_Business__c> LocationLOB = new List<Location_And_Line_Of_Business__c>();
    
    @IsTest
    static void testMethod1() {
        
        User admin_User = TestDataFactory.createUser(true,'Case',ADMIN_PROFILE);
        insert admin_User;
        System.runAs(admin_User){
            
            //Account
            Id InsuredRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Insured').getRecordTypeId();
            Map<String,Object>  Accountobj = new Map<String,Object>();
            Accountobj.put('RecordTypeId',InsuredRecordTypeId);
            Accountobj.put('Name','NewAcco');
            for(Integer i = 0 ; i <count; i++)
            {
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
            }
            
            //Contact
            Map<String,Object> ContactObj = new Map<String,Object>();
            ContactObj.put('LastName','Test Contact');
            ContactObj.put('AccountId',acc[0].Id);
            ContactObj.put('Email','test@gmail.com');
            for(Integer i = 0 ; i <count; i++)
            {
                con.add((Contact) TestDataFactory.operationOnObjectRec('insert', 'Contact', ContactObj));
            }
            
            //Opportunity
            Id N2GRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('N2G Internal Cases').getRecordTypeId();
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
            
            //Case
            Map<String,Object> caseObj = new Map<String,Object>();
            caseObj.put('Subject','Test Case');
            caseObj.put('SuppliedName','Test Case');
            caseObj.put('RecordTypeId',N2GRecordTypeId);
            caseObj.put('SuppliedEmail','test@gmail.com');
            caseObj.put('Visit_Type__c','On-site');
            caseObj.put('ContactId',con[0].Id);
            caseObj.put('Box_Folder_Name__c','Locals');
            caseObj.put('Opportunity__c',Opp[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                CaseList.add((Case) TestDataFactory.operationOnObjectRec('insert', 'Case', caseObj));
            }
            
            //LOB
            Id Commercial_Auto_RT = Schema.SObjectType.LOB_Management__c.getRecordTypeInfosByDeveloperName().get('Commercial_Auto').getRecordTypeId();
            Map<String,Object>  LOBobj = new Map<String,Object>();
            LOBobj.put('LOB_Stage__c','Submission');
            LOBobj.put('LOB_Effective_Date__c', Date.today().addDays(5));
            LOBobj.put('Estimated_LOB_Premium__c',1050);
            LOBobj.put('Submission_Source__c','Other');
            //LOBobj.put('Line_of_Business__c','Commercial Auto');
            LOBobj.put('Opportunity_Related__c', Opp[0].Id);
            LOBobj.put('Case__c', CaseList[0].Id);
            LOBobj.put('Type__c','New');
            LOBobj.put('RecordTypeId', Commercial_Auto_RT);
            for(Integer i = 0 ; i <count; i++)
            {
                lobManagement.add((LOB_Management__c) TestDataFactory.operationOnObjectRec('insert', 'LOB_Management__c', LOBobj));
            }
            
            //Location
            Map<String, Object> Locationobj = new Map<String, Object>();
            Locationobj.put('Name', 'Test');
            Locationobj.put('Address_Details__c', '123 Main St');
            for(Integer i = 0 ; i <count; i++)
            {
                loc.add((Schema.Location) TestDataFactory.operationOnObjectRec('insert', 'Location', Locationobj));
            }
            
            //CaseAndLocaiton__c
            Map<String, Object> caseLocationObj = new Map<String, Object>();
            caseLocationObj.put('Location__c', loc[0].Id);
            caseLocationObj.put('Case__c', CaseList[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                caseLocation.add((CaseAndLocaiton__c) TestDataFactory.operationOnObjectRec('insert', 'CaseAndLocaiton__c', caseLocationObj));
            }
            
            //InsurancePolicy
            Map<String,Object>  InsurancePolicyobj = new Map<String,Object>();
            InsurancePolicyobj.put('NameInsuredId',acc[0].Id);
            InsurancePolicyobj.put('Name','Newtest');
            InsurancePolicyobj.put('Case__c',CaseList[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                Ipol.add((InsurancePolicy) TestDataFactory.operationOnObjectRec('insert', 'InsurancePolicy',  InsurancePolicyobj));
            }
            
            //Location_And_Contact__c
            Map<String,Object>  LocationContactobj = new Map<String,Object>();
            LocationContactobj.put('Contact__c',con[0].Id);
            LocationContactobj.put('Case__c',CaseList[0].Id);
            LocationContactobj.put('Location__c',loc[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                LocationContact.add((Location_And_Contact__c) TestDataFactory.operationOnObjectRec('insert', 'Location_And_Contact__c',  LocationContactobj));
            }
            
            //Location_And_Line_Of_Business__c
            Map<String,Object>  LocationLOBobj = new Map<String,Object>();
            LocationLOBobj.put('Line_of_Business__c',lobManagement[0].Id);
            LocationLOBobj.put('Case__c',CaseList[0].Id);
            LocationLOBobj.put('Location__c',loc[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                LocationLOB.add((Location_And_Line_Of_Business__c) TestDataFactory.operationOnObjectRec('insert', 'Location_And_Line_Of_Business__c',  LocationLOBobj));
            }
            
            
            List< VendorAssociateEmailTemplate.Request> reList = new List< VendorAssociateEmailTemplate.Request>();
            VendorAssociateEmailTemplate.Request req=new VendorAssociateEmailTemplate.Request();
            req.locationList=[Select id,Location_Adress__c,Name,Case__c,Location__c,Location_Name__c from CaseAndLocaiton__c];
            req.CaseId=CaseList[0].Id;
            reList.add(req);
            
            Test.StartTest();
            List<VendorAssociateEmailTemplate.Response> responseList=VendorAssociateEmailTemplate.sendEmailtoVendor(reList);
            Test.StopTest();
            
            //System.debug([Select id,Location_Adress__c,Name,Case__c,Location__c,Location_Name__c from CaseAndLocaiton__c LIMIT 1]);
        }
    }
    
}