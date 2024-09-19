@isTest
public class CustomLookupLwcController_T {
    
    public static User admin_User;
    public static Integer count =2;
    public static string ADMIN_PROFILE ='System Administrator';
    public static List<Account> acc = new List<Account>();
    
    static void proccesRecordData()
    {
        admin_User = TestDataFactory.createUser(true,'Account',ADMIN_PROFILE);
        insert admin_User;
        System.runAs(admin_User)
        {
            Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
            
            for(Integer i = 0 ; i <count; i++)
            {
                Map<String,Object>  Accountobj = new Map<String,Object>();
                Accountobj.put('RecordTypeId',accRecordTypeId);
                Accountobj.put('Name','Newtes'+i);
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
            }
        }
    }
    
    static testMethod void AccountproccesRecordDataTest() 
    {
        proccesRecordData();
        Test.startTest();
        CustomLookupLwcController.fetchLookupData('N' , 'Account','Createddate','Id',acc[0].Id);
        CustomLookupLwcController.fetchDefaultRecord(acc[0].Id , 'Account','Createddate','Id',acc[0].Id);
        Test.stopTest();
    }
}