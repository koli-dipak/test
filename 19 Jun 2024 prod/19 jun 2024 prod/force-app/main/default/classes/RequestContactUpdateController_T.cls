@isTest
public class RequestContactUpdateController_T {
    
    public static User admin_User;
    public static Integer count =1; 
    public static string ADMIN_PROFILE ='System Administrator';
    public static List<Account> acc = new List<Account>();
    public static List<Contact> con = new List<Contact>();
    
    static void proccesRecordData()
    {
        admin_User = TestDataFactory.createUser(true,'Account',ADMIN_PROFILE);
        insert admin_User;
        System.runAs(admin_User)
        {
            Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
            Id brokerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
            
            for(Integer i = 0 ; i <count; i++)
            {
                Map<String,Object>  Accountobj = new Map<String,Object>();
                Accountobj.put('RecordTypeId',accRecordTypeId);
                Accountobj.put('Name','Newtes'+i);
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
                
                Map<String,Object>  Contactobj = new Map<String,Object>();
                Contactobj.put('RecordTypeId',brokerRecordTypeId);
                Contactobj.put('Salutation','Mr.');
                Contactobj.put('FirstName','NewtesRecord Information FirstName'+i);
                Contactobj.put('LastName','NewtesRecord Information LastName'+i);
                Contactobj.put('Email','Newtes@mail.com');
                Contactobj.put('AccountId',acc[0].Id);
                con.add((Contact) TestDataFactory.operationOnObjectRec('insert', 'Contact', Contactobj));
            }
        }
    }
    
    static testMethod void AccountproccesRecordDataTest() 
    {
        proccesRecordData();
        Test.startTest();
        RequestContactUpdateController.getContactRecords(acc[0].Id);
        RequestContactUpdateController.sendEmail(acc[0].Id,con[0].Id,'test');
        List<Agent_Contact__c> listAC=[SELECT Id,Status__c,Encrypted_Id__c,Head_of_Office__c FROM Agent_Contact__c order by createddate desc];
        RequestContactUpdateController.getAgentContactData(listAC[0].Encrypted_Id__c);
        RequestContactUpdateController.getAgentContactDetail(listAC[0].Encrypted_Id__c);
        RequestContactUpdateController.getContactDetails('New');
        RequestContactUpdateController.updateAgentContact(JSON.serialize(listAC[0]),'{"LastName":"test","FirstName":"test","Salutation":"Mr.","isSaved":"true"}','[{"Event_Name__c":"test"}]','[{"Event_Name__c":"test","Manager__c":{"LastName":"test","FirstName":"test","Salutation":"Mr.","isSaved":"true"}}]','[{"Event_Name__c":"test"}]','[{"Event_Name__c":"test","Manager__c":{"LastName":"test","FirstName":"test","Salutation":"Mr.","isSaved":"true"}}]');
        listAC=[SELECT Id,Status__c,Encrypted_Id__c,Head_of_Office__c FROM Agent_Contact__c order by createddate desc];
        listAC[0].Status__c='Approved';
        update listAC[0];
        RequestContactUpdateController.updateReleatedObject(listAC[0].Encrypted_Id__c);
        
        
        /*List<BrokerContact__c> BroConlist = [Select Id, ObjectType__c,Type__c from BrokerContact__c order by createddate desc];
        RequestContactUpdateController.getAgentContactData(BroConlist[0].Id);
        RequestContactUpdateController.getAgentContactDetail(BroConlist[0].Id);
        RequestContactUpdateController.getContactDetails('New');
        RequestContactUpdateController.updateAgentContact(JSON.serialize(BroConlist[0]),'{"LastName":"test","isSaved":"true"}','[{"Event_Name__c":"test"}]','[{"Event_Name__c":"test","Manager__c":{"LastName":"test","isSaved":"true"}}]','[{"Event_Name__c":"test"}]','[{"Event_Name__c":"test","Manager__c":{"LastName":"test","isSaved":"true"}}]'); 
        BroConlist= [Select Id, ObjectType__c,Type__c from BrokerContact__c order by createddate desc];
        BroConlist[0].ObjectType__c='Contact';
        BroConlist[0].Type__c='Broker';
        update BroConlist[0];
        RequestContactUpdateController.updateReleatedObject(BroConlist[0].Id);*/
        
        
        Test.stopTest();
        
    }
    
}