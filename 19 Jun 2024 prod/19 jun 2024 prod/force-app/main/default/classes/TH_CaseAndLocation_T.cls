@isTest
public class TH_CaseAndLocation_T {
    public static User admin_User;
    public static Integer count = 1;
    public static String ADMIN_PROFILE = 'System Administrator';
    public static List<Case> cas = new List<Case>();
    
    static void proccesRecordData() {
        admin_User = TestDataFactory.createUser(true, 'Case', ADMIN_PROFILE);
        insert admin_User;
        System.runAs(admin_User) {
            try {
                Id casRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('N2G_Internal_Cases').getRecordTypeId();
                
                for (Integer i = 0; i < count; i++) {
                    Map<String, Object> caseobj = new Map<String, Object>();
                    caseobj.put('RecordTypeId', casRecordTypeId);
                    caseobj.put('Subject', 'Test Case ' + i);
                    cas.add((Case) TestDataFactory.operationOnObjectRec('insert', 'Case', caseobj));
                }
                
                Map<String, Object> locationObj = new Map<String, Object>();
                locationObj.put('Name', 'New Location');
                Schema.Location locationRecord = (Schema.Location) TestDataFactory.operationOnObjectRec('insert', 'Location', locationObj);
                
                Map<String, Object> caseLocationObj = new Map<String, Object>();
                caseLocationObj.put('Location__c', locationRecord.Id);
                caseLocationObj.put('Case__c', cas[0].Id);
                CaseAndLocaiton__c locationRecord1 = (CaseAndLocaiton__c) TestDataFactory.operationOnObjectRec('insert', 'CaseAndLocaiton__c', caseLocationObj);
                
                Map<String, Object> caseLocationObj2 = new Map<String, Object>();
                caseLocationObj2.put('Location__c', locationRecord.Id);
                caseLocationObj2.put('Case__c', cas[0].Id);
                CaseAndLocaiton__c locationRecord2 = (CaseAndLocaiton__c) TestDataFactory.operationOnObjectRec('insert', 'CaseAndLocaiton__c', caseLocationObj2);
            } catch (Exception e) {
                Boolean expectedExceptionThrown = e.getMessage().contains('Duplicate Record Found') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
        }
    }
    
    @isTest
    static void AccountproccesRecordDataTest() {
        proccesRecordData();
    }
}