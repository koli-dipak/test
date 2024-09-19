@isTest
public class TH_Engagement_T {

    public static User admin_User;
    public static Integer count =1;
    public static string SYSTEM_ADMINISTRATOR_PROFILE ='System Administrator';
    
    @isTest
    public static void testMethod1(){
        admin_User = TestDataFactory.createUser(true,'Opportunity',SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        System.runAs(admin_User)
        {
            Map<String,Object>  engagementObj = new Map<String,Object>();
        	engagementObj.put('Name','New Engagement');
        	engagementObj.put('Start_Date_Time__c', DateTime.now());
            Engagement__c engagementRecord = (Engagement__c) TestDataFactory.operationOnObjectRec('insert', 'Engagement__c', engagementObj);
            Engagement__c UpdatedEngagementRecord = [SELECT Id, Start_Date_Time__c, End_Date_Time__c FROM Engagement__c WHERE Id =:engagementRecord.Id];
            system.assertEquals(UpdatedEngagementRecord.Start_Date_Time__c.addHours(1), UpdatedEngagementRecord.End_Date_Time__c);
            UpdatedEngagementRecord.Start_Date_Time__c = UpdatedEngagementRecord.Start_Date_Time__c.addHours(10);
            update UpdatedEngagementRecord;
            Engagement__c UpdatedEngagementRecord2 = [SELECT Id, Start_Date_Time__c, End_Date_Time__c FROM Engagement__c WHERE Id =:engagementRecord.Id];
            system.assertEquals(UpdatedEngagementRecord2.Start_Date_Time__c.addHours(1), UpdatedEngagementRecord2.End_Date_Time__c);
        }
    }
}