@isTest
public class TH_Task_T {
    public static User admin_User;
    public static Integer count =1;
    public static string SYSTEM_ADMINISTRATOR_PROFILE ='System Administrator';
    public static List<Task> taskList = new List<Task>();
    public static List<Opportunity> oppList = new List<Opportunity>();
    public static List<Contact> ContactList = new List<Contact>();
    public static List<Account> acc = new List<Account>();
    static void proccesRecordDataForTask()
    {
        
        admin_User = TestDataFactory.createUser(true,'Opportunity',SYSTEM_ADMINISTRATOR_PROFILE);
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
            
            Id RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
            Map<String,Object> ContactObj = new Map<String,Object>();
            ContactObj.put('LastName','Test Contact');
            ContactObj.put('AccountId',acc[0].Id);
            ContactObj.put('RecordTypeId',RecordTypeId);
            for(Integer i = 0 ; i <count; i++)
            {
                ContactList.add((Contact) TestDataFactory.operationOnObjectRec('insert', 'Contact', ContactObj));
            }
            Map<String,Object>  Opportunityobj = new Map<String,Object>();
            Opportunityobj.put('Name','test');
            Opportunityobj.put('CloseDate',System.today());
            Opportunityobj.put('StageName','Interest');
            Opportunityobj.put('Line_of_Business__c','Commercial Umbrella;Ocean Marine');
            Opportunityobj.put('AccountId',acc[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                oppList.add((Opportunity) TestDataFactory.operationOnObjectRec('insert', 'Opportunity', Opportunityobj));
            }
            Group ratingqueuegroup=[SELECT Id, Name, DeveloperName, Email, Type FROM Group where Type='Queue' AND DeveloperName ='Rating_Queue'];
            List<LOB_Management__c> lobi=[select Id,Name from LOB_Management__c Limit 1];
            Map<String,Object>  taskobj = new Map<String,Object>();
            // taskobj.put('WhoId',ContactList[0].Id);
            taskObj.put('WhatId',oppList[0].Id);
            taskObj.put('Status','Completed');
            taskObj.put('Subject','Send Letter');
            taskObj.put('Priority','Normal');
            taskObj.put('Line_of_Business__c',lobi[0].id);
            taskObj.put('OwnerId',ratingqueuegroup.Id);
            taskObj.put('TaskSubtype','Email');
            for(Integer i = 0 ; i <count; i++)
            {
                taskList.add((Task) TestDataFactory.operationOnObjectRec('insert', 'Task', taskobj));
            }
            taskobj = new Map<String,Object>();
            taskObj.put('Status','Completed');
            taskObj.put('Id',taskList[0].id);
            taskObj.put('OwnerId',ratingqueuegroup.Id);
            TestDataFactory.operationOnObjectRec('update', 'Task',taskObj);
        }
        
    }
    static void proccesRecordDataForTask1()
    {
        
        admin_User = TestDataFactory.createUser(true,'Opportunity',SYSTEM_ADMINISTRATOR_PROFILE);
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
            
            Id RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
            Map<String,Object> ContactObj = new Map<String,Object>();
            ContactObj.put('LastName','Test Contact');
            ContactObj.put('AccountId',acc[0].Id);
            ContactObj.put('RecordTypeId',RecordTypeId);
            for(Integer i = 0 ; i <count; i++)
            {
                ContactList.add((Contact) TestDataFactory.operationOnObjectRec('insert', 'Contact', ContactObj));
            }
            Map<String,Object>  Opportunityobj = new Map<String,Object>();
            Opportunityobj.put('Name','test');
            Opportunityobj.put('CloseDate',System.today());
            Opportunityobj.put('StageName','Interest');
            Opportunityobj.put('Line_of_Business__c','Commercial Umbrella;Ocean Marine');
            Opportunityobj.put('AccountId',acc[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                oppList.add((Opportunity) TestDataFactory.operationOnObjectRec('insert', 'Opportunity', Opportunityobj));
            }
            Group n2gdomestic=[SELECT Id, Name, DeveloperName, Email, Type FROM Group where Type='Queue' AND DeveloperName ='N2G_Domestic_Operations'];
            List<LOB_Management__c> lobi=[select Id,Name, Underwriter__c from LOB_Management__c where Underwriter__c!=null Limit 1];
            Map<String,Object>  taskobj = new Map<String,Object>();
            // taskobj.put('WhoId',ContactList[0].Id);
            taskObj.put('WhatId',oppList[0].Id);
            taskObj.put('Status','Completed');
            taskObj.put('Subject','Send Letter');
            taskObj.put('Priority','Normal');
            taskObj.put('Line_of_Business__c',lobi[0].id);
            taskObj.put('OwnerId',n2gdomestic.Id);
            taskObj.put('TaskSubtype','Email');
            for(Integer i = 0 ; i <count; i++)
            {
                taskList.add((Task) TestDataFactory.operationOnObjectRec('insert', 'Task', taskobj));
            }
            taskobj = new Map<String,Object>();
            taskObj.put('Status','Completed');
            taskObj.put('Id',taskList[0].id);
            taskObj.put('OwnerId',n2gdomestic.Id);
            TestDataFactory.operationOnObjectRec('update', 'Task',taskObj);
        }
        
    }
    static void newTaskCreate()
    {
        Test.startTest();
        Account acc=new Account();
        acc.AccountNumber='123456789987';
        acc.Name='21ST CENTURY ONCOLOGY HOLDINGS INC';
        acc.BillingCity='ADI';
        acc.RecordTypeId=Schema.sObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
        insert acc;
        Opportunity opp=new Opportunity(Name='Testttt', CloseDate=Date.today(),StageName='Prospecting',  accountid=acc.Id);
        insert opp;
        System.debug('OPP Lookup Account ID===>'+opp.AccountId+'OPP ID =====>'+opp.Id+'Account ID======>'+acc.id);
        LOB_Management__c lob=new LOB_Management__c();
        lob.Opportunity_Related__c=opp.id;
        insert lob;
        Group ratingqueuegroup=[SELECT Id, Name, DeveloperName, Email, Type FROM Group where Type='Queue' AND DeveloperName ='Rating_Queue'];
        Task t=new Task();
        t.Subject='Other';
        t.Status='Open';
        t.Line_of_Business__c=lob.Id;
        insert t;
        System.debug('New Task Id========>'+t.Id);
        t.OwnerId=ratingqueuegroup.id;
        t.Status='Completed';
        update t;
        System.debug('New Task Id========>'+t.Status);
        System.debug(t.Status);
        Task t1 = [select id,Status,OwnerId,Line_of_Business__c from Task ];
        
        System.assertEquals('Open',t1.Status);
        System.assertNotEquals('',t1.OwnerId);
        System.debug('Owner ID====>'+t1.OwnerId);
        System.assertNotEquals('',t1.Line_of_Business__c);
        
        
        Test.stopTest();
    }
    public static void proccesRecordDataForQLI(String PROFILE)
    {
        User admin_User;
        Integer count = 1;
        string SYSTEM_ADMINISTRATOR_PROFILE = 'System Administrator';
        List<Opportunity> Opp = new List<Opportunity>();
        List<Quote> quote = new List<Quote>();
        List<QuoteLineItem> quoteLineItem = new List<QuoteLineItem>();
        List<QuoteLineItem_Reference__c> quotelinereference = new List<QuoteLineItem_Reference__c>();
        List<DocumentChecklistItem> documentChecklistItem = new List<DocumentChecklistItem>();
        List<LOB_Management__c> lobList = new List<LOB_Management__c>();
        List<Task> taskList = new List<Task>();
        List<Product2> product = new List<Product2>();
        List<Account> acc = new List<Account>();
        admin_User = TestDataFactory.createUser(true,'Opportunity',PROFILE);
        insert admin_User;
        System.debug('-->'+admin_User.ProfileId);
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
            Opportunityobj.put('StageName','Interest');
            Opportunityobj.put('AccountId',acc[0].Id);
            Opportunityobj.put('Line_of_Business__c','Commercial Umbrella;Ocean Marine');
            for(Integer i = 0 ; i <count; i++)
            {
                Opp.add((Opportunity) TestDataFactory.operationOnObjectRec('insert', 'Opportunity', Opportunityobj));
            }
            
            Map<String, Object> lobObj = new Map<String, Object>();
            lobObj.put('Underwriter__c', admin_User.Id);
            lobObj.put('Opportunity_Related__c', Opp[0].Id);
            
            //lobObj.put('RecordType', 'Commercial Auto');
            
            for (Integer i = 0; i < count; i++) {
                lobList.add((LOB_Management__c) TestDataFactory.operationOnObjectRec('insert', 'LOB_Management__c', lobObj));
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
            
            Map<String,Object> productObj = new Map<String,Object>();
            productObj.put('Name','test Product');
            for(Integer i = 0 ; i <count; i++)
            {
                product.add((Product2) TestDataFactory.operationOnObjectRec('insert', 'Product2', productObj));
            }
            
            Map<String,Object> priceBookEntryObj = new Map<String,Object>();
            priceBookEntryObj.put('Pricebook2Id', Test.getStandardPricebookId());
            priceBookEntryObj.put('Product2Id', product[0].Id);
            priceBookEntryObj.put('IsActive', true);
            priceBookEntryObj.put('UnitPrice', 150);
            PricebookEntry pbeRec = (PricebookEntry) TestDataFactory.operationOnObjectRec('insert', 'PricebookEntry', priceBookEntryObj);
            
            Map<String,Object> quoteLineObj = new Map<String,Object>();
            quoteLineObj.put('PricebookEntryId', pbeRec.Id);
            quoteLineObj.put('UnitPrice', 150);
            quoteLineObj.put('Quantity', 1);
            quoteLineObj.put('QuoteId', quote[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                quoteLineItem.add((QuoteLineItem) TestDataFactory.operationOnObjectRec('insert', 'QuoteLineItem', quoteLineObj));
            }
            
            
            Map<String,Object> quotelinereferenceObj = new Map<String,Object>();
            
            quotelinereferenceObj.put('Quote_Line_Item__c', quoteLineItem[0].Id);
            
            for(Integer i = 0 ; i <count; i++)
            {
                quotelinereference.add((QuoteLineItem_Reference__c) TestDataFactory.operationOnObjectRec('insert', 'QuoteLineItem_Reference__c', quotelinereferenceObj));
            }
            
            Map<String,Object> documentChecklistItemObj = new Map<String,Object>();
            
            documentChecklistItemObj.put('Quote_Line_Item__c', quote[0].Id);
            documentChecklistItemObj.put('ParentRecordId', quotelinereference[0].Id);
            documentChecklistItemObj.put('Generate_Quote_and_Binder__c', quote[0].Id);
            documentChecklistItemObj.put('Quote_Line_Item__c', quoteLineItem[0].Id);
            documentChecklistItemObj.put('IsRequired', false);
            documentChecklistItemObj.put('Name', 'Workers Compensation | ALL | Insured risk engineering');
            documentChecklistItemObj.put('Status', 'Pending Collection');
            for(Integer i = 0 ; i <count; i++)
            {
                documentChecklistItem.add((DocumentChecklistItem) TestDataFactory.operationOnObjectRec('insert', 'DocumentChecklistItem', documentChecklistItemObj));
            }
            
            Map<String,Object>  taskobj = new Map<String,Object>();
            // taskobj.put('WhoId',ContactList[0].Id);
            taskObj.put('WhatId',quote[0].Id);
            taskObj.put('Status','Open');
            taskObj.put('Subject','Binding Checklist Task');
            taskObj.put('Priority','Normal');
            
            for(Integer i = 0 ; i <count; i++)
            {
                taskList.add((Task) TestDataFactory.operationOnObjectRec('insert', 'Task', taskobj));
            }
            Test.startTest();
            TH_Task.sendTaskNotificationEmail(taskList[0]);
           
            documentChecklistItemObj = new Map<String,Object>();
            documentChecklistItemObj.put('Status', 'Complete');
            documentChecklistItemObj.put('Id',documentChecklistItem[0].id);
            TestDataFactory.operationOnObjectRec('update', 'DocumentChecklistItem',documentChecklistItemObj);
           
            
           
            documentChecklistItem[0].Name = 'true';
            documentChecklistItem[0].IsRequired = true;
            Update documentChecklistItem;
            
        
            // System.assertEquals('Edit permission is exclusively reserved for administrators.', documentChecklistItem[0].getErrors()[0].getMessage(), 'Error message should match');
            
          
            delete documentChecklistItem[0];
            Test.stopTest();
            //  System.assertEquals('Delete permission is exclusively reserved for administrators.', documentChecklistItem[0].getErrors()[0].getMessage(), 'Error message should match');
        }
    }
    
    static testMethod void taskTest() 
    {
        proccesRecordDataForTask();
    }
    static testMethod void taskTest2() 
    {
        newTaskCreate();
        // proccesRecordDataForTask();
    }
    static testMethod void taskTest3() 
    {
        // newTaskCreate();
        proccesRecordDataForTask1();
    }
    
    static void updateDocumentCheckListOtherThanStatus() 
    {
        string PROFILE = 'N2G - Users';
        proccesRecordDataForQLI(PROFILE);
        
        
    }
}