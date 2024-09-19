@isTest
public class DAL_Case_T {

    public static User admin_User;
    public static Integer count =1;
    public static string SYSTEM_ADMINISTRATOR_PROFILE ='System Administrator';
    public static List<Account> acc = new List<Account>();
    public static List<Case> CaseList = new List<Case>();
    public static List<Contact> con = new List<Contact>();
    public static Id frontingInboxRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.Fronting_Inbox_Record_Type_Dev_Name).getRecordTypeId();
    public static Id InsuredRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Insured').getRecordTypeId();
    
    static void proccesRecordDataForCase(){
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
            ContactObj.put('LastName','Test Contact');
            ContactObj.put('AccountId',acc[0].Id);
            ContactObj.put('Email','test@gmail.com');
            for(Integer i = 0 ; i <count; i++)
            {
                con.add((Contact) TestDataFactory.operationOnObjectRec('insert', 'Contact', ContactObj));
            }
            
            Map<String,Object> caseObj = new Map<String,Object>();
            caseObj.put('Subject','Test Case');
            caseObj.put('SuppliedName','Test Case');
            caseObj.put('RecordTypeId',frontingInboxRecTypeId);
            caseObj.put('SuppliedEmail','test@gmail.com');
            caseObj.put('ContactId',con[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                CaseList.add((Case) TestDataFactory.operationOnObjectRec('insert', 'Case', caseObj));
            }
        }
    }
    
    static testMethod void testMethod1(){
        proccesRecordDataForCase();
        Test.startTest();
        DAL_Case.getCaseRecordsByIdSet(new Set<Id>{CaseList[0].Id});
        DAL_Case.getCaseRecordsByIdSet(new Set<Case>{CaseList[0]});
        DAL_Case.getCaseRecordsByIdList(new List<Case>{CaseList[0]});
        DAL_Case.getCaseRecordsBySetId(new Set<Id>{CaseList[0].Id});
        Test.stopTest();
    } 
}