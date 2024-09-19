@isTest
public class TH_EngagementExternalAttendees_T {
    
    public static User admin_User;
    public static Integer count =1;
    public static string ADMIN_PROFILE ='System Administrator';
    public static List<Contact> Con = new List<Contact>();
    
    static void proccesRecordData()
    {
        admin_User = TestDataFactory.createUser(true,'Account',ADMIN_PROFILE);
        insert admin_User;
        System.runAs(admin_User)
        {
            try{
                Id ConRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Broker').getRecordTypeId();
                
                for(Integer i = 0 ; i <count; i++)
                {
                    Map<String,Object>  Contactobj = new Map<String,Object>();
                    Contactobj.put('RecordTypeId',ConRecordTypeId);
                    Contactobj.put('LastName','Test Contact '+i);
                    Con.add((Contact) TestDataFactory.operationOnObjectRec('insert', 'Contact', Contactobj));
                }
                
                Map<String,Object>  engagementObj = new Map<String,Object>();
                engagementObj.put('Name','New Engagement');
                engagementObj.put('Start_Date_Time__c', DateTime.now());
                Engagement__c engagementRecord = (Engagement__c) TestDataFactory.operationOnObjectRec('insert', 'Engagement__c', engagementObj);
                
                Map<String,Object>  engagementExternalAttendeeObj = new Map<String,Object>();
                engagementExternalAttendeeObj.put('Engagement__c', engagementRecord.Id);
                engagementExternalAttendeeObj.put('External_Attendee__c',Con[0].Id);
                Engagement_External_Attendee__c engagementExternalRecord = (Engagement_External_Attendee__c) TestDataFactory.operationOnObjectRec('insert', 'Engagement_External_Attendee__c', engagementExternalAttendeeObj);
                
                Map<String,Object>  engagementExternalAttendeeObj2 = new Map<String,Object>();
                engagementExternalAttendeeObj2.put('Engagement__c', engagementRecord.Id);
                engagementExternalAttendeeObj2.put('External_Attendee__c',Con[0].Id);
                Engagement_External_Attendee__c engagementExternalRecord2 = (Engagement_External_Attendee__c) TestDataFactory.operationOnObjectRec('insert', 'Engagement_External_Attendee__c', engagementExternalAttendeeObj2);
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