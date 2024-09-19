@isTest
public class HLPR_CloneWithChildRecords_T {
    public static User admin_User;
    public static Integer count = 1;
    public static string SYSTEM_ADMINISTRATOR_PROFILE = 'System Administrator';
    public static List<Opportunity> Opp = new List<Opportunity>();
    public static List<Quote> quote = new List<Quote>();
    public static List<QuoteLineItem> quoteLineItem = new List<QuoteLineItem>();
    public static List<Product2> product = new List<Product2>();
    public static List<Account> acc = new List<Account>();
    
    static void proccesRecordDataForCloneWithChildRecord()
    {
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
            Opportunityobj.put('StageName','Interest');
            Opportunityobj.put('AccountId',acc[0].Id);
            Opportunityobj.put('Line_of_Business__c','Commercial Umbrella;Ocean Marine');
            for(Integer i = 0 ; i <count; i++)
            {
                Opp.add((Opportunity) TestDataFactory.operationOnObjectRec('insert', 'Opportunity', Opportunityobj));
            }
        }
    }
    
    @isTest
    static void cloneWithChildTestMethod1() 
    {
        proccesRecordDataForCloneWithChildRecord();
        
        Test.startTest();
        Set<String> setSTRChildObjectsToBeConverted = new Set<String>();
        setSTRChildObjectsToBeConverted.add('LOB_Management__c');
        
        Map<String, Object> newRecordFieldsValue = new Map<String, Object>();
        newRecordFieldsValue.put('Name', 'test');
        newRecordFieldsValue.put('CloseDate', Date.today().addDays(10));
        newRecordFieldsValue.put('Quote_due_date__c', null);
        newRecordFieldsValue.put('Box_Folder_Name__c', null);
        newRecordFieldsValue.put('Box_Folder_Id__c', null);
        newRecordFieldsValue.put('StageName', 'Unqualified');
        newRecordFieldsValue.put('Applied_Epic_key__c', null);
        
        Map<String, Object> childDataMaping = new Map<String, Object>();
        childDataMaping.put('Unqualified', 'Unqualified');
        childDataMaping.put('Interest', 'Interest');
        childDataMaping.put('Submission', 'Interest');
        childDataMaping.put('Declined', 'Interest');
        childDataMaping.put('Quote', 'Interest');
        childDataMaping.put('Lost', 'Interest');
        childDataMaping.put('Bound', 'Interest');
        childDataMaping.put('Not Submitted', 'Interest');
        
        Map<String, Object> cloneChildNewFieldValues = new Map<String, Object>();
        cloneChildNewFieldValues.put('Loss_Reason__c', null);
        
         Map<String, Object> filterValueMap = new Map<String, Object>();
        filterValueMap.put('Aggregate_Limit__c	', 'Aggregate Limit');
        
        String parentId = Opp[0].Id;
        
        HLPR_CloneWithChildRecords cloneProductObj = new HLPR_CloneWithChildRecords(Opp[0].Id, setSTRChildObjectsToBeConverted);
        cloneProductObj.cloneWithChildren(newRecordFieldsValue, 'TH_OPPORTUNITY', childDataMaping, cloneChildNewFieldValues);
        
        HLPR_CloneWithChildRecords cloneProductObjCoverage = new HLPR_CloneWithChildRecords(Opp[0].Id, new Set<String>{'FC_Coverage__c'});
    	cloneProductObjCoverage.cloneOnlyChildren(newRecordFieldsValue, 'TH_OPPORTUNITY', childDataMaping, cloneChildNewFieldValues, filterValueMap, parentId);

        cloneProductObj = new HLPR_CloneWithChildRecords(Opp[0].Id);
        cloneProductObjCoverage = new HLPR_CloneWithChildRecords(Opp[0].Id);
        Test.stopTest();
    }
    /* @isTest
    static void cloneWithChildTestMethod2() 
    {
        proccesRecordDataForCloneWithChildRecord();
        
        Test.startTest();
        Set<String> setSTRChildObjectsToBeConverted = new Set<String>();
        setSTRChildObjectsToBeConverted.add('FC_Coverage__c');
        
        Map<String, Object> newRecordFieldsValue = new Map<String, Object>();
        newRecordFieldsValue.put('Name', 'test');
        newRecordFieldsValue.put('CloseDate', Date.today().addDays(10));
        newRecordFieldsValue.put('Quote_due_date__c', null);
        newRecordFieldsValue.put('Box_Folder_Name__c', null);
        newRecordFieldsValue.put('Box_Folder_Id__c', null);
        newRecordFieldsValue.put('StageName', 'Unqualified');
        newRecordFieldsValue.put('Applied_Epic_key__c', null);
        
        Map<String, Object> childDataMaping = new Map<String, Object>();
        childDataMaping.put('Unqualified', 'Unqualified');
        childDataMaping.put('Interest', 'Interest');
        childDataMaping.put('Submission', 'Submission');
        childDataMaping.put('Declined', 'Declined');
        childDataMaping.put('Quote', 'Quote');
        childDataMaping.put('Lost', 'Lost');
        childDataMaping.put('Bound', 'Bound');
        childDataMaping.put('Not Submitted', 'Not Submitted');
        
        Map<String, Object> cloneChildNewFieldValues = new Map<String, Object>();
        cloneChildNewFieldValues.put('Employee_Benefits_Liability__c', 'Occurrence');
        
        Map<String, Object> filterValueMap = new Map<String, Object>();
        filterValueMap.put('Aggregate_Limit__c	', 'Aggregate Limit');
        
        String parentId = Opp[0].Id;
        
        HLPR_CloneWithChildRecords cloneProductObj = new HLPR_CloneWithChildRecords(Opp[0].Id, setSTRChildObjectsToBeConverted);
        cloneProductObj.cloneOnlyChildren(newRecordFieldsValue, 'TH_OPPORTUNITY', childDataMaping, cloneChildNewFieldValues, filterValueMap, parentId);
        
        cloneProductObj = new HLPR_CloneWithChildRecords(Opp[0].Id);
        Test.stopTest();
    }*/

}