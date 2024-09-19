@isTest
public class CTRL_CloneOpportunityWithQuote_T {
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
        CTRL_CloneOpportunityWithQuote.cloneWithProducts(Opp[0].Id);
        Test.stopTest();
    }
}