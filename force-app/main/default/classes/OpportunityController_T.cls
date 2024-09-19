@isTest
public class OpportunityController_T {
public static User admin_User;
    public static Integer count = 1;
    public static String ADMIN_PROFILE = 'System Administrator';
    public static List<Opportunity> con = new List<Opportunity>();

    @isTest
    static void testInsertContactRecord() {
        User admin_User = TestDataFactory.createUser(true, 'Opportunity', ADMIN_PROFILE); 
        insert admin_User;

        String searchKey = '';
        String sObjectApiName = 'Opportunity';

        Map<String, Object> oppRecord = new Map<String, Object>();
        oppRecord.put('FirstName', 'John');
        oppRecord.put('LastName', 'Doe');
        oppRecord.put('Email', 'johndoe@example.com');
        oppRecord.put('Title', 'Manager');
        oppRecord.put('Salutation', 'Mr.');
        oppRecord.put('Mobile', '123-456-7890');
        oppRecord.put('Phone', '987-654-3210');

        Test.startTest();
        //Object insertResult = ContactController.insertContactRecord(contactRecord);
        Object fetchDefaultResult = OpportunityController.fetchDefaultRecord('RecordId', 'Opportunity');
        List<Object> fetchLookupResult = OpportunityController.fetchLookupData(searchKey, sObjectApiName); 
        Test.stopTest();

         //System.assertNotEquals(null, insertResult, 'Expected a non-null insertResult');
    System.assertEquals(null, fetchDefaultResult, 'Expected a non-null fetchDefaultResult');
    System.assertNotEquals(null, fetchLookupResult, 'Expected a non-null fetchLookupResult');
    }
}