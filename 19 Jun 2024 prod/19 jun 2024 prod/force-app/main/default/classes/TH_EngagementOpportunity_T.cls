@isTest
public class TH_EngagementOpportunity_T {

    public static User admin_User;
    public static Integer count =1;
    public static string ADMIN_PROFILE ='System Administrator';
    public static List<Opportunity> Opp = new List<Opportunity>();
    public static List<Account> acc = new List<Account>();

    
    static void proccesRecordData()
    {
        admin_User = TestDataFactory.createUser(true,'Account',ADMIN_PROFILE);
        insert admin_User;
        System.runAs(admin_User)
        {
            try{
                Id OppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId();
                
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

                Map<String,Object>  engagementObj = new Map<String,Object>();
                engagementObj.put('Name','New Engagement');
                engagementObj.put('Start_Date_Time__c', DateTime.now());
                Engagement__c engagementRecord = (Engagement__c) TestDataFactory.operationOnObjectRec('insert', 'Engagement__c', engagementObj);

                Map<String,Object>  engagementOppObj = new Map<String,Object>();
                engagementOppObj.put('Engagement__c', engagementRecord.Id);
                engagementOppObj.put('Opportunity__c',Opp[0].Id);
                Engagement_Opportunity__c engagementOppRecord = (Engagement_Opportunity__c) TestDataFactory.operationOnObjectRec('insert', 'Engagement_Opportunity__c', engagementOppObj);

                Map<String,Object>  engagementOppObj2 = new Map<String,Object>();
                engagementOppObj2.put('Engagement__c', engagementRecord.Id);
                engagementOppObj2.put('Opportunity__c',Opp[0].Id);
                Engagement_Opportunity__c engagementOppRecord2 = (Engagement_Opportunity__c) TestDataFactory.operationOnObjectRec('insert', 'Engagement_Opportunity__c', engagementOppObj2);
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('The records you are trying to include already exists in the list') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
            }
        }
    }
    
     @isTest
    static void AccountproccesRecordDataTest() 
    {
        proccesRecordData();
    }

}