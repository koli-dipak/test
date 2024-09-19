@isTest
public class AddRelatedRecordController_T {
    public static User admin_User;
    public static Integer count =1;
    public static string ADMIN_PROFILE ='System Administrator';
    public static Account accountRecord;
    public static Account accountRecord2;
    public static Engagement__c engagementRecord;
    
    public static void processRecords()
    {
        admin_User = TestDataFactory.createUser(true,'Account',ADMIN_PROFILE);
        insert admin_User;
        System.runAs(admin_User)
        {
            Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
            
            Map<String,Object>  Accountobj = new Map<String,Object>();
            Accountobj.put('RecordTypeId',accRecordTypeId);
            Accountobj.put('Name','Test Surag');
            Accountobj.put('OwnerId',admin_User.Id);
            accountRecord = (Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj);
            
            Map<String,Object>  Accountobj2 = new Map<String,Object>();
            Accountobj2.put('RecordTypeId',accRecordTypeId);
            Accountobj2.put('Name','Test Surag');
            Accountobj2.put('OwnerId',admin_User.Id);
            accountRecord2 = (Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj2);
            
            Map<String,Object>  engagementMap = new Map<String,Object>();
            engagementMap.put('Name','Test Surag');
            engagementMap.put('OwnerId',admin_User.Id);
            engagementRecord = (Engagement__c) TestDataFactory.operationOnObjectRec('insert', 'Engagement__c', engagementMap);
        }
    }
    
    @isTest
    public static void TestMethod1(){
        processRecords();
        AddRelatedRecordController.fetchDefaultRecord(accountRecord.Id, 'Account');
        AddRelatedRecordController.fetchLookupData('Test', engagementRecord.Id, 'Account', 'Account_Engagement_Junction_Object', false, 5, '["'+accountRecord2.Id+'"]', 'Insured', 'Account_Engagement_Junction_Object','Name','OwnerId=OwnerId');
        
        Map<String, String> inputMap = new Map<String, String>();
        inputMap.put('sObjectApiNameOfJunctionObject','Engagement_Broker__c');
        inputMap.put('sObjectApiNameToSearch','Account');
        inputMap.put('currentSObjectName','Engagement__c');
        inputMap.put('fieldAPINameOfCurrentObject','Broker__c');
        inputMap.put('fieldAPINameOfSelectedObject','Broker_Account__c');
        inputMap.put('allSelectedRecordIds', '["'+accountRecord.Id+'"]');
        inputMap.put('currentRecordId',engagementRecord.Id);
        
        AddRelatedRecordController.createJunctionObjectRecord(inputMap);
        AddRelatedRecordController.getRecordTypes('Account');
        AddRelatedRecordController.getForm('Account', 'Account_Engagement_Junction_Object');
        
    }
}