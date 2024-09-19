@isTest
public class TH_IntegrationLog_T {
    
    public static Integer count =1;
    public static List<Integration_Log__c> logs = new List<Integration_Log__c>();
    public static List<Account> acc = new List<Account>();
    public static List<Contact> con = new List<Contact>();
    public static List<Opportunity> Opp = new List<Opportunity>();
    public static List<LOB_Management__c> LOB = new List<LOB_Management__c>();
    public static List<Quote> quote = new List<Quote>();
    
    @isTest
    public static void Test1(){
        
        Map<String,Object>  Accountobj = new Map<String,Object>();
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
        Accountobj.put('RecordTypeId',RecordTypeId);
        Accountobj.put('Name','NewAccount');
        Accountobj.put('Box_Folder_Name__c','test');
        for(Integer i = 0 ; i <count; i++)
        {
            acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
        }
        
        
        Map <String,Object> logMap = new Map <String,Object>();  
        logMap.put('RecordId__c', acc[0].Id); 
        logMap.put('Status__c', 'Error');
        for(Integer i = 0 ; i <count; i++)
        {
            logs.add((Integration_Log__c) TestDataFactory.operationOnObjectRec('insert', 'Integration_Log__c', logMap));
        }
        Test.startTest();
        TH_IntegrationLog logHandler = new TH_IntegrationLog();
        logHandler.newIntegrationLogs = logs;
        logHandler.processRecords();
        Test.stopTest();
    }
    
    @isTest
    public static void Test2(){
        
        Map<String,Object>  Accountobj = new Map<String,Object>();
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
        Accountobj.put('RecordTypeId',RecordTypeId);
        Accountobj.put('Name','NewAccount');
        Accountobj.put('Box_Folder_Name__c','test');
        for(Integer i = 0 ; i <count; i++)
        {
            acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
        }
        
        Map<String,Object>  Opportunityobj = new Map<String,Object>();
        Opportunityobj.put('Name','test');
        Opportunityobj.put('CloseDate',System.today());
        Opportunityobj.put('StageName','Unqualified');
        Opportunityobj.put('AccountId',acc[0].Id);
        Opportunityobj.put('Line_of_Business__c','Commercial Umbrella;Ocean Marine');
        for(Integer i = 0 ; i <count; i++)
        {
            Opp.add((Opportunity) TestDataFactory.operationOnObjectRec('insert', 'Opportunity', Opportunityobj));
        }
        
        Id LOBRecordTypeId = Schema.SObjectType.LOB_Management__c.getRecordTypeInfosByName().get('Builders Risk').getRecordTypeId();
        Map<String,Object>  LOBObj = new Map<String,Object>();
        LOBObj.put('LOB_Effective_Date__c',date.today());
        LOBObj.put('LOB_Stage__c','Interest');
        LOBObj.put('Submission_Source__c','Broker');
        LOBObj.put('Type__c','Renewal');
        LOBObj.put('Opportunity_Related__c',Opp[0].Id);
        for(Integer i = 0 ; i <count; i++)
        {
            LOB.add((LOB_Management__c) TestDataFactory.operationOnObjectRec('insert', 'LOB_Management__c', LOBObj));
        }
        
        Map <String,Object> logMap = new Map <String,Object>();  
        logMap.put('RecordId__c', LOB[0].Id); 
        logMap.put('Status__c', 'Error');
        for(Integer i = 0 ; i <count; i++)
        {
            logs.add((Integration_Log__c) TestDataFactory.operationOnObjectRec('insert', 'Integration_Log__c', logMap));
        }
        Test.startTest();
        TH_IntegrationLog logHandler = new TH_IntegrationLog();
        logHandler.newIntegrationLogs = logs;
        logHandler.processRecords();
        Test.stopTest();
    }
    
    @isTest
    public static void Test3(){
        
        Map<String,Object>  Accountobj = new Map<String,Object>();
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
        Accountobj.put('RecordTypeId',RecordTypeId);
        Accountobj.put('Name','NewAccount');
        Accountobj.put('Box_Folder_Name__c','test');
        for(Integer i = 0 ; i <count; i++)
        {
            acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
        }
        
        Map<String,Object>  ContactObj = new Map<String,Object>();
        Id ContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        ContactObj.put('RecordTypeId',ContactRecordTypeId);
        ContactObj.put('LastName','NewContact');
        ContactObj.put('AccountId',acc[0].Id);
        for(Integer i = 0 ; i <count; i++)
        {
            con.add((Contact) TestDataFactory.operationOnObjectRec('insert', 'Contact', ContactObj));
        }
        
        Map <String,Object> logMap = new Map <String,Object>();  
        logMap.put('RecordId__c', con[0].Id); 
        logMap.put('Status__c', 'Error');
        for(Integer i = 0 ; i <count; i++)
        {
            logs.add((Integration_Log__c) TestDataFactory.operationOnObjectRec('insert', 'Integration_Log__c', logMap));
        }
        Test.startTest();
        TH_IntegrationLog logHandler = new TH_IntegrationLog();
        logHandler.newIntegrationLogs = logs;
        logHandler.processRecords();
        Test.stopTest();
    }
    
    @isTest
    public static void Test4(){
        
        Map<String,Object>  Accountobj = new Map<String,Object>();
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
        Accountobj.put('RecordTypeId',RecordTypeId);
        Accountobj.put('Name','NewAccount');
        Accountobj.put('Box_Folder_Name__c','test');
        for(Integer i = 0 ; i <count; i++)
        {
            acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
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
        
        Map<String,Object> quoteObj = new Map<String,Object>();
        quoteObj.put('Name','test Quote');
        quoteObj.put('ExpirationDate', Date.today().addDays(30));
        quoteObj.put('Status','Interest');
        quoteObj.put('OpportunityId', Opp[0].Id);
        quoteObj.put('Pricebook2Id', Test.getStandardPricebookId());
        for(Integer i = 0 ; i <count; i++)
        {
            quote.add((Quote) TestDataFactory.operationOnObjectRec('insert', 'Quote', quoteObj));
        }
        
        Map <String,Object> logMap = new Map <String,Object>();  
        logMap.put('RecordId__c', quote[0].Id); 
        logMap.put('Status__c', 'Error');
        for(Integer i = 0 ; i <count; i++)
        {
            logs.add((Integration_Log__c) TestDataFactory.operationOnObjectRec('insert', 'Integration_Log__c', logMap));
        }
        Test.startTest();
        TH_IntegrationLog logHandler = new TH_IntegrationLog();
        logHandler.newIntegrationLogs = logs;
        logHandler.processRecords();
        Test.stopTest();
    }
}