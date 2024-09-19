@isTest
public class TH_EngagementInternalAttendees_T {
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

                Map<String,Object>  engagementInternalAttendeeObj = new Map<String,Object>();
                engagementInternalAttendeeObj.put('Engagement__c', engagementRecord.Id);
                engagementInternalAttendeeObj.put('Internal_Attendee__c',admin_User.Id);
                Engagement_Internal_Attendee__c engagementInternalRecord = (Engagement_Internal_Attendee__c) TestDataFactory.operationOnObjectRec('insert', 'Engagement_Internal_Attendee__c', engagementInternalAttendeeObj);

                Map<String,Object>  engagementInternalAttendeeObj2 = new Map<String,Object>();
                engagementInternalAttendeeObj2.put('Engagement__c', engagementRecord.Id);
                engagementInternalAttendeeObj2.put('Internal_Attendee__c',admin_User.Id);
                Engagement_Internal_Attendee__c engagementInternalAttenceRecord2 = (Engagement_Internal_Attendee__c) TestDataFactory.operationOnObjectRec('insert', 'Engagement_Internal_Attendee__c', engagementInternalAttendeeObj2);
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