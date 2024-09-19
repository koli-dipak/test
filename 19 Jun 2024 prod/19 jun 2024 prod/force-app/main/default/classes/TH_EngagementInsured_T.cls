@isTest
public class TH_EngagementInsured_T {

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
                Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Insured').getRecordTypeId();
                
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

                Map<String,Object>  engagementInsuredObj = new Map<String,Object>();
                engagementInsuredObj.put('Engagement__c', engagementRecord.Id);
                engagementInsuredObj.put('Insured__c',acc[0].Id);
                Engagement_Insured__c engagementBrokerRecord = (Engagement_Insured__c) TestDataFactory.operationOnObjectRec('insert', 'Engagement_Insured__c', engagementInsuredObj);

                Map<String,Object>  engagementInsuredObj2 = new Map<String,Object>();
                engagementInsuredObj2.put('Engagement__c', engagementRecord.Id);
                engagementInsuredObj2.put('Insured__c',acc[0].Id);
                Engagement_Insured__c engagementBrokerRecord2 = (Engagement_Insured__c) TestDataFactory.operationOnObjectRec('insert', 'Engagement_Insured__c', engagementInsuredObj2);
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('The records you are trying to include already exists in the list') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
            }
        }
    }
    
    static testMethod void AccountproccesRecordDataTest() 
    {
        proccesRecordData();
    }

    
}