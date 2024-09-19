@isTest
public class DependentPicklistPopulation_T {
    public static User admin_User;
    public static Integer count =1;
    public static string SYSTEM_ADMINISTRATOR_PROFILE ='System Administrator';
    public static List<LOB_Management__c> lobManagement = new List<LOB_Management__c>();
    public static List<Account> acc = new List<Account>();
    public static List<Opportunity> Opp = new List<Opportunity>();

    @isTest
    public static void TestDependentPicklistPopulation() {
        User admin_User = TestDataFactory.createUser(true, '','System Administrator');
        System.runAs(admin_User){
            Test.startTest();

            // Create Account Record 
            Map<String,Object>  accRecord = new Map<String,Object>();
            Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
            accRecord.put('RecordTypeId',RecordTypeId);
            accRecord.put('Name','NewAcco');
            accRecord.put('Box_Folder_Name__c','test');
            for(Integer i = 0 ; i <count; i++)
            {
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', accRecord));
            }
            
            Map<String,Object>  oppRecord = new Map<String,Object>();
            oppRecord.put('Name','test');
            oppRecord.put('CloseDate',System.today());
            oppRecord.put('StageName','Unqualified');
            oppRecord.put('AccountId',acc[0].Id);
            oppRecord.put('Line_of_Business__c','Commercial Umbrella;Ocean Marine');
            for(Integer i = 0 ; i <count; i++)
            {
                Opp.add((Opportunity) TestDataFactory.operationOnObjectRec('insert', 'Opportunity', oppRecord));
            }

            // Create a LOB Management record
            Map<String,Object> lobRecord = new Map<String,Object>();
            lobRecord.put('LOB_Stage__c','Not Submitted');
            lobRecord.put('Loss_Reason__c','Other');
            lobRecord.put('Opportunity_Related__c', Opp[0].Id);
            LOB_Management__c lobNameRec = (LOB_Management__c) TestDataFactory.operationOnObjectRec('insert','LOB_Management__c',lobRecord);
            
            // Call the getDependentPicklistValues method
            Map<String, Object> inputMap = new Map<String, Object>();
            Map<String, Object> outMap = new Map<String, Object>();
            inputMap.put('lob', lobNameRec.Id);
            DependentPicklistPopulation.getDependentPicklistValues(inputMap, outMap);
        
            // Assert the output
            System.assertEquals(1, outMap.size());
            // List<Object> dependentPicklistValues = (List<Object>) JSON.deserializeUntyped((String) outMap.get('dependentPicklistValues'));
            // System.assertEquals(1, dependentPicklistValues.size());
            // Map<String, Object> stageValues = (Map<String, Object>) dependentPicklistValues[0];
            // System.assertEquals(1, stageValues.size());
            // List<Object> reasoncodeValues = (List<Object>) stageValues.get('Test Stage');
            // System.assertEquals(1, reasoncodeValues.size());
            // Map<String, Object> reasoncodeValue = (Map<String, Object>) reasoncodeValues[0];
            // System.assertEquals('Test Loss Reason', reasoncodeValue.get('label'));
            // System.assertEquals('Test Loss Reason', reasoncodeValue.get('value'));
    		
            Boolean value=New DependentPicklistPopulation().invokeMethod('getDependentPicklistValues', inputmap, new Map<String, Object>(), new Map<String, Object>());
            System.assertEquals(value, true);
            
            Test.stopTest();
        }
    }
}