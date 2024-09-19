@isTest
private class TH_Account_T {
    
    public static User admin_User;
    public static Integer count =1;
    public static string ADMIN_PROFILE ='System Administrator';
    public static List<Account> acc = new List<Account>();
    public static List<Opportunity> Opp = new List<Opportunity>();
    
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
                Accountobj.put('Name','Hiteshm');
                Accountobj.put('Region__c','Southeast');
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
                
                Map<String,Object>  Accountobj2 = new Map<String,Object>();
                Accountobj2.put('RecordTypeId',accRecordTypeId);
                Accountobj2.put('Name','Hitesha');
                Accountobj2.put('Insured_External_Id__c','HITESHM-02');
                Accountobj2.put('Region__c','Southeast');
                acc.add((Account) TestDataFactory.operationOnObjectRec('', 'Account', Accountobj2));
                
            }
            
            Map<String,Object>  Opportunityobj = new Map<String,Object>();
            Opportunityobj.put('Name','test');
            Opportunityobj.put('CloseDate',System.today());
            Opportunityobj.put('StageName','Interest');
            Opportunityobj.put('Type','New');
            Opportunityobj.put('AccountId',acc[0].Id);
            Opportunityobj.put('Line_of_Business__c','Commercial Umbrella');
            for(Integer i = 0 ; i <count; i++)
            {
                Opp.add((Opportunity) TestDataFactory.operationOnObjectRec('insert', 'Opportunity', Opportunityobj));
            }
        }
    }
    
    static testMethod void AccountproccesRecordDataTest() 
    {
        proccesRecordData();
        Test.startTest();
        
        insert acc[1];
        update acc[1];
        Test.stopTest();
    }
}