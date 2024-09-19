@isTest
public class TH_EmailMessage_T {
    
    public static User admin_User;
    public static Integer count =1;
    public static string SYSTEM_ADMINISTRATOR_PROFILE ='System Administrator';
    public static List<Account> acc = new List<Account>();
    public static List<Case> CaseList = new List<Case>();
    public static List<Opportunity> Opp = new List<Opportunity>();
    public static List<Contact> con = new List<Contact>();
    public static List<EmailMessage> EmailMessageList = new List<EmailMessage>();
    public static Id frontingInboxRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.Fronting_Inbox_Record_Type_Dev_Name).getRecordTypeId();
    public static Id InsuredRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Insured').getRecordTypeId();
    
    static void proccesRecordDataForEmailMessage(){
        admin_User = TestDataFactory.createUser(true,'Case',SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        System.runAs(admin_User){
            Map<String,Object>  Accountobj = new Map<String,Object>();
            Accountobj.put('RecordTypeId',InsuredRecordTypeId);
            Accountobj.put('Name','NewAcco');
            for(Integer i = 0 ; i <count; i++)
            {
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
            }
            
            Map<String,Object> ContactObj = new Map<String,Object>();
            ContactObj.put('LastName','DND PSADEV Global Contact for Case');
            ContactObj.put('AccountId',acc[0].Id);
            ContactObj.put('Email','test@gmail.com');
            for(Integer i = 0 ; i <count; i++)
            {
                con.add((Contact) TestDataFactory.operationOnObjectRec('insert', 'Contact', ContactObj));
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
            
            Map<String,Object> caseObj = new Map<String,Object>();
            caseObj.put('Subject','Test Case');
            caseObj.put('SuppliedName','Test Case');
            caseObj.put('RecordTypeId',frontingInboxRecTypeId);
            caseObj.put('SuppliedEmail','test@gmail.com');
            caseObj.put('Status','Closed');
            caseObj.put('ContactId',con[0].Id);
            caseObj.put('Box_Folder_Name__c','Locals');
            caseObj.put('Opportunity__c',Opp[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                CaseList.add((Case) TestDataFactory.operationOnObjectRec('insert', 'Case', caseObj));
            }
            
            Map<String,Object>  emailMessageObj = new Map<String,Object>();
            emailMessageObj.put('Subject','Test Email');
            emailMessageObj.put('Incoming',true);
            emailMessageObj.put('ParentId',CaseList[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                EmailMessageList.add((EmailMessage) TestDataFactory.operationOnObjectRec('insert', 'EmailMessage', emailMessageObj));
            }
        }
    }
    
    static testMethod void testMethod1(){
        proccesRecordDataForEmailMessage();
        test.startTest();
        List<Case> updatedCases = [SELECT Id, Requesting_Office__c, Client__c, Status FROM Case WHERE RecordTypeId =:frontingInboxRecTypeId];
        List<Case_closed_Day__mdt> CaseClosedDaysMDT = Case_closed_Day__mdt.getAll().values();
        if (!CaseClosedDaysMDT.isEmpty() && CaseClosedDaysMDT[0].DeveloperName == 'Default') {
            if(Integer.valueOf(CaseClosedDaysMDT[0].Days__c) == 0){
                System.assertEquals(2, updatedCases.size());
            }else if(Integer.valueOf(CaseClosedDaysMDT[0].Days__c) > 0){
                System.assertEquals('New', updatedCases[0].Status);
            }
        }
        test.stopTest();
    } 
    
}