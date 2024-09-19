@isTest
public class DAL_Contact_T {
    public static User admin_User;
    public static Integer count =1;
    public static string SYSTEM_ADMINISTRATOR_PROFILE ='System Administrator';
    public static List<Account> acc = new List<Account>();
    public static List<Contact> con = new List<Contact>();
    public static Id InsuredRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Insured').getRecordTypeId();
    
    static void proccesRecordDataForContact(){
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
        }
    }
    
    static testMethod void testMethod1(){
        proccesRecordDataForContact();
        Test.startTest();
        DAL_Contact.getContactByAcc(acc[0].Id);
        DAL_Contact.getContactById(con[0].Id);
        DAL_Contact.getContactByEmail(new Set<String>{'test@gmail.com'});
        DAL_Contact.getContactByIdSet(new Set<Id>{con[0].Id});
        Test.stopTest();
    } 
}