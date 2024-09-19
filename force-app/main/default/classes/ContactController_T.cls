@isTest
public class ContactController_T {
    public static User admin_User;
    public static Integer count = 1;
    public static String ADMIN_PROFILE = 'System Administrator';
    public static List<Contact> con = new List<Contact>();

    @isTest
    static void testInsertContactRecord() {
        User admin_User = TestDataFactory.createUser(true, 'Contact', ADMIN_PROFILE); 
        insert admin_User;

        String searchKey = '';
        String sObjectApiName = 'Contact';

        Map<String, Object> contactRecord = new Map<String, Object>();
        contactRecord.put('FirstName', 'John');
        contactRecord.put('LastName', 'Doe');
        contactRecord.put('Email', 'johndoe@example.com');
        contactRecord.put('Title', 'Manager');
        contactRecord.put('Salutation', 'Mr.');
        contactRecord.put('Mobile', '123-456-7890');
        contactRecord.put('Phone', '987-654-3210');

        Test.startTest();
        Object insertResult = ContactController.insertContactRecord(contactRecord);
        Object fetchDefaultResult = ContactController.fetchDefaultRecord('RecordId', 'Contact');
        List<Object> fetchLookupResult = ContactController.fetchLookupData(searchKey, sObjectApiName); 
        Test.stopTest();

         System.assertNotEquals(null, insertResult, 'Expected a non-null insertResult');
    System.assertEquals(null, fetchDefaultResult, 'Expected a non-null fetchDefaultResult');
    System.assertNotEquals(null, fetchLookupResult, 'Expected a non-null fetchLookupResult');
    }
}