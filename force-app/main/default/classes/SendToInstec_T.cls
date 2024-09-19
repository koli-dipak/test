@isTest
public class SendToInstec_T {
    public static Integer count = 1;
    public static List<Account> acc = new List<Account>();
    public static List<Opportunity> Opp = new List<Opportunity>();
    
    static testMethod void sendtoinstactest() 
    {
        Map<String,Object>  Accountobj = new Map<String,Object>();
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
        Id insuredItemSpecRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('InsuredItemSpec').getRecordTypeId();
        Id coverageSpecRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('CoverageSpec').getRecordTypeId();
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
        Opportunityobj.put('Line_of_Business__c','Commercial Umbrella;');
        for(Integer i = 0 ; i <count; i++)
        {
            Opp.add((Opportunity) TestDataFactory.operationOnObjectRec('insert', 'Opportunity', Opportunityobj));
        }
        
        Test.StartTest(); 
        
        ApexPages.StandardController sc = new ApexPages.StandardController([select id from LOB_Management__c limit 1]);
        SendToInstec  obj = new SendToInstec(sc);
        obj.sendToInstecLOB();
        
        
        Test.StopTest();
    }
}