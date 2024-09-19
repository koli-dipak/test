@isTest
public class TH_EngagementBroker_T {
    public static User admin_User;
    public static Integer count =1;
    public static string ADMIN_PROFILE ='System Administrator';
    public static List<Account> acc = new List<Account>();
    
    static void proccesRecordData()
    {
        admin_User = TestDataFactory.createUser(true,'Account',ADMIN_PROFILE);
        insert admin_User;
        System.runAs(admin_User)
        {
            try{
                Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('AgencyBrokerage').getRecordTypeId();
                
                for(Integer i = 0 ; i <count; i++)
                {
                    Map<String,Object>  Accountobj = new Map<String,Object>();
                    Accountobj.put('RecordTypeId',accRecordTypeId);
                    Accountobj.put('Name','Test Account '+i);
                    acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
                }

                Map<String,Object>  engagementObj = new Map<String,Object>();
                engagementObj.put('Name','New Engagement');
                engagementObj.put('Start_Date_Time__c', DateTime.now());
                Engagement__c engagementRecord = (Engagement__c) TestDataFactory.operationOnObjectRec('insert', 'Engagement__c', engagementObj);

                Map<String,Object>  engagementBrokerObj = new Map<String,Object>();
                engagementBrokerObj.put('Broker__c', engagementRecord.Id);
                engagementBrokerObj.put('Broker_Account__c',acc[0].Id);
                Engagement_Broker__c engagementBrokerRecord = (Engagement_Broker__c) TestDataFactory.operationOnObjectRec('insert', 'Engagement_Broker__c', engagementBrokerObj);

                Map<String,Object>  engagementBrokerObj2 = new Map<String,Object>();
                engagementBrokerObj2.put('Broker__c', engagementRecord.Id);
                engagementBrokerObj2.put('Broker_Account__c',acc[0].Id);
                Engagement_Broker__c engagementBrokerRecord2 = (Engagement_Broker__c) TestDataFactory.operationOnObjectRec('insert', 'Engagement_Broker__c', engagementBrokerObj2);
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