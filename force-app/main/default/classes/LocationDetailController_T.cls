@isTest
public class LocationDetailController_T {
    public static User admin_User;
    public static Integer count = 1;
    public static String SYSTEM_ADMINISTRATOR_PROFILE = 'System Administrator';
    public static List<Case> CaseList = new List<Case>();
    public static List<Schema.Location> loc = new List<Schema.Location>();
    public static List<CaseAndLocaiton__c> CaseJuncList = new List<CaseAndLocaiton__c>();
    //public static List<CaseAndLocaiton__c> caseLocation = new List<CaseAndLocaiton__c>();
    public static List<Location_And_Contact__c> LocationContact = new List<Location_And_Contact__c>();
    public static List<Location_And_Line_Of_Business__c> LocationLOB = new List<Location_And_Line_Of_Business__c>();
    public static List<LOB_Management__c> lobManagement = new List<LOB_Management__c>();
    public static List<Opportunity> Opp = new List<Opportunity>();
    public static List<Account> acc = new List<Account>();
    public static List<Contact> con = new List<Contact>();
    
    @isTest
    static void proccesRecordData() {
        admin_User = TestDataFactory.createUser(true, 'Location', SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        
        System.runAs(admin_User) {
            for (Integer i = 0; i < count; i++) {
                Map<String, Object> Locationobj = new Map<String, Object>();
                Locationobj.put('Name', 'SLOC-100519');
                Locationobj.put('Address_Details__c', '123 Main St');
                loc.add((Schema.Location)TestDataFactory.operationOnObjectRec('insert', 'Location', Locationobj));
                
                Map<String, Object> Locationobj1 = new Map<String, Object>();
                Locationobj1.put('Name', 'SLOC-100519');
                Locationobj1.put('Address_Details__c', '456 Elm St');
                loc.add((Schema.Location)TestDataFactory.operationOnObjectRec('insert', 'Location', Locationobj1));
            }
            
            Map<String, Object> caseObj = new Map<String, Object>();
            caseObj.put('Subject', 'Test Case');
            caseObj.put('SuppliedName', 'Test Case');
            caseObj.put('SuppliedEmail', 'test@gmail.com');
            caseObj.put('Box_Folder_Name__c', 'Locals');
            for (Integer i = 0; i < count; i++) {
                CaseList.add((Case)TestDataFactory.operationOnObjectRec('insert', 'Case', caseObj));
            }
            
            Map<String, Object> caseAndLocation = new Map<String, Object>();
            caseAndLocation.put('Case__c', CaseList[0].Id);
            caseAndLocation.put('Location__c', loc[0].Id);
            for (Integer i = 0; i < count; i++) {
                CaseJuncList.add((CaseAndLocaiton__c)TestDataFactory.operationOnObjectRec('insert', 'CaseAndLocaiton__c', caseAndLocation));
            }
        }
    }
    
    @isTest
    static void getLocationCaseTest() {
        
 		User admin_User = TestDataFactory.createUser(true,'Case',SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        System.runAs(admin_User){
            
            //Account
            Id InsuredRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Insured').getRecordTypeId();
            Map<String,Object>  Accountobj = new Map<String,Object>();
            Accountobj.put('RecordTypeId',InsuredRecordTypeId);
            Accountobj.put('Name','NewAcco');
            for(Integer i = 0 ; i <count; i++)
            {
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
            }
            
            //Contact
            Map<String,Object> ContactObj = new Map<String,Object>();
            ContactObj.put('LastName','Test Contact');
            ContactObj.put('AccountId',acc[0].Id);
            ContactObj.put('Email','test@gmail.com');
            for(Integer i = 0 ; i <count; i++)
            {
                con.add((Contact) TestDataFactory.operationOnObjectRec('insert', 'Contact', ContactObj));
            }
            
            //Opportunity
            Id N2GRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('N2G Internal Cases').getRecordTypeId();
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
            
            //Case
            Map<String,Object> caseObj = new Map<String,Object>();
            caseObj.put('Subject','Test Case');
            caseObj.put('SuppliedName','Test Case');
            caseObj.put('RecordTypeId',N2GRecordTypeId);
            caseObj.put('SuppliedEmail','test@gmail.com');
            caseObj.put('ContactId',con[0].Id);
            caseObj.put('Box_Folder_Name__c','Locals');
            caseObj.put('Opportunity__c',Opp[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                CaseList.add((Case) TestDataFactory.operationOnObjectRec('insert', 'Case', caseObj));
            }
            
            //LOB
            Id Commercial_Auto_RT = Schema.SObjectType.LOB_Management__c.getRecordTypeInfosByDeveloperName().get('Commercial_Auto').getRecordTypeId();
            Map<String,Object>  LOBobj = new Map<String,Object>();
            LOBobj.put('LOB_Stage__c','Submission');
            LOBobj.put('LOB_Effective_Date__c', Date.today().addDays(5));
            LOBobj.put('Estimated_LOB_Premium__c',1050);
            LOBobj.put('Submission_Source__c','Other');
            //LOBobj.put('Line_of_Business__c','Commercial Auto');
            LOBobj.put('Opportunity_Related__c', Opp[0].Id);
            LOBobj.put('Case__c', CaseList[0].Id);
            LOBobj.put('Type__c','New');
            LOBobj.put('RecordTypeId', Commercial_Auto_RT);
            for(Integer i = 0 ; i <count; i++)
            {
                lobManagement.add((LOB_Management__c) TestDataFactory.operationOnObjectRec('insert', 'LOB_Management__c', LOBobj));
            }
            
            //Location
            Map<String, Object> Locationobj = new Map<String, Object>();
            Locationobj.put('Name', 'Test');
            Locationobj.put('Address_Details__c', '123 Main St');
            for(Integer i = 0 ; i <count; i++)
            {
                loc.add((Schema.Location) TestDataFactory.operationOnObjectRec('insert', 'Location', Locationobj));
            }
            
            //CaseAndLocaiton__c
            Map<String, Object> caseLocationObj = new Map<String, Object>();
            caseLocationObj.put('Location__c', loc[0].Id);
            caseLocationObj.put('Case__c', CaseList[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                CaseJuncList.add((CaseAndLocaiton__c) TestDataFactory.operationOnObjectRec('insert', 'CaseAndLocaiton__c', caseLocationObj));
            }
    }
        
        Test.startTest();
List<CaseAndLocaiton__c> result = LocationDetailController.getLocationCase(CaseList[0].Id, new List<String>{loc[0].Id});
Test.stopTest();

System.debug('Expected Location Name: ' + loc[0].Name);
if (result.size() > 0) {
System.debug('Actual Location Name from Result: ' + result[0].Location__r.Name);
} else {
System.debug('No results found.');
}

/*System.assertEquals(1, result.size());
System.assertEquals(loc[0].Name, result[0].Location__r.Name);*/
}
    
    @isTest
    static void getLocationTest() {
        
 		 admin_User = TestDataFactory.createUser(true, 'Location', SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        System.runAs(admin_User) {
            for (Integer i = 0; i < count; i++) {
                Map<String, Object> Locationobj = new Map<String, Object>();
                Locationobj.put('Name', 'Test');
                Locationobj.put('Address_Details__c', '123 Main St');
                loc.add((Schema.Location) TestDataFactory.operationOnObjectRec('insert', 'Location', Locationobj));
            }
        }
        
        Map<String, Object> caseObj = new Map<String, Object>();
            caseObj.put('Subject', 'Test Case');
            caseObj.put('SuppliedName', 'Test Case');
            caseObj.put('SuppliedEmail', 'test@gmail.com');
            caseObj.put('Box_Folder_Name__c', 'Locals');
            for (Integer i = 0; i < count; i++) {
                CaseList.add((Case)TestDataFactory.operationOnObjectRec('insert', 'Case', caseObj));
            }

        Test.startTest();
        String result = LocationDetailController.getLocation(new List<String>{loc[0].Id}, CaseList[CaseList.size()-1].Id);
        Test.stopTest();

}
    
    @isTest
    static void getCjrValueTest(){
        proccesRecordData();
        Test.startTest();
        List<CaseAndLocaiton__c> result = LocationDetailController.getCjrValue(CaseList[0].Id);
        Test.stopTest();
        System.debug('Expected cjr Id : ' + result);
        System.assertEquals(1, result.size());
    }
    
    @isTest
    static void deleteLocationCaseTest() {
        proccesRecordData();
        CaseAndLocaiton__c junctionRecord = CaseJuncList[0];
        
        Test.startTest();
        LocationDetailController.deleteLocationCase(junctionRecord.Id);
        Test.stopTest();
        
        List<CaseAndLocaiton__c> deletedRecords = [SELECT Id FROM CaseAndLocaiton__c WHERE Id = :junctionRecord.Id];
        System.assertEquals(0, deletedRecords.size());
    }
    
    @isTest
    static void getLocationCountryCodeTest() {
        Test.startTest();
        Map<String, String> countryCodes = LocationDetailController.getLocationCountryCode();
        Test.stopTest();
        
        System.assertNotEquals(0, countryCodes.size());
    }
    
    @isTest
    static void getLocationStateCodeTest() {
        Test.startTest();
        Map<String, String> countryCodes = LocationDetailController.getLocationStateCode();
        Test.stopTest();
        
        System.assertNotEquals(0, countryCodes.size());
    }
    
    @isTest
    static void insertLocationRecordTest() {
        // Create a Case record
        Case testCase = new Case(
            Subject = 'Test Case',
            SuppliedName = 'Test Case',
            SuppliedEmail = 'test@gmail.com',
            Box_Folder_Name__c = 'Locals'
        );
        //case testCaseRecord = (case)TestDataFactory.operationOnObjectRec('insert', 'Case', testCase);
        insert testCase;
        
        Map<String, Object> LocationRecord = new Map<String, Object>();
        LocationRecord.put('Case__c', testCase.Id);
        LocationRecord.put('Currency_Code__c', 'USD');
        LocationRecord.put('Building_Property_Name__c', 'Building1');
        LocationRecord.put('Address__Street__s', '123 Main St');
        LocationRecord.put('Address__City__s', 'City1');
        LocationRecord.put('Address__PostalCode__s', '12345');
        LocationRecord.put('Address__StateCode__s', 'CA');
        LocationRecord.put('Name', 'SLOC-0038');
        LocationRecord.put('Location_ID__c', 'SLOC-0038');
        LocationRecord.put('Address__CountryCode__s', 'US');
        
        List<Schema.Location> LocationLists = new List<Schema.Location>();
        Test.startTest();
        try
        {
            LocationLists = LocationDetailController.insertLocationRecord(LocationRecord);
        }
        catch(exception e)
        {
        }
        
        Test.stopTest();
        System.assertEquals(1, LocationLists.size());
       // System.assertNotEquals(null, LocationLists[0].Id);
        
    }
    
    @isTest
	static void proccesRecordBeforeTest() {
   
  // Create a Location record with matching data
    Schema.Location testLocation = new Schema.Location(
        Address__City__s = 'City1',
        Address__PostalCode__s = '12345',
        Address__Street__s = '123 Main St',
        Building_Property_Name__c = 'Building1',
        Address__StateCode__s = 'CA',
        Name='SLOC-0038',
        Address__CountryCode__s = 'US'
    );
    insert testLocation;

    // Create a LocationRecord Map with similar data
    Map<String, Object> LocationRecord = new Map<String, Object>();
    LocationRecord.put('Address__City__s', 'City1');
    LocationRecord.put('Address__PostalCode__s', '12345');
    LocationRecord.put('Address__Street__s', '123 Main St');
    LocationRecord.put('Building_Property_Name__c', 'Building1');
    LocationRecord.put('Address__StateCode__s', 'CA');
    LocationRecord.put('Address__CountryCode__s', 'US');

    Test.startTest();
    List<Schema.Location> result = LocationDetailController.proccesRecordBefore(LocationRecord);
    Test.stopTest();
    
}
    
    @isTest
	static void insertLocationRecordIntoCaseAndLocationObjectTest() {
        admin_User = TestDataFactory.createUser(true, 'Case', SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        System.runAs(admin_User) {
            Id casRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('N2G_Internal_Cases').getRecordTypeId();
                
                for (Integer i = 0; i < count; i++) {
                    Map<String, Object> caseobj = new Map<String, Object>();
                    caseobj.put('RecordTypeId', casRecordTypeId);
                    caseobj.put('Subject', 'Test Case ' + i);
                    CaseList.add((Case) TestDataFactory.operationOnObjectRec('insert', 'Case', caseobj));
                }
                
                Map<String, Object> locationObj = new Map<String, Object>();
                locationObj.put('Name', 'New Location');
                Schema.Location locationRecord = (Schema.Location) TestDataFactory.operationOnObjectRec('insert', 'Location', locationObj);
                loc.add(locationRecord);
                
                Map<String, Object> caseLocationObj = new Map<String, Object>();
                caseLocationObj.put('Location__c', locationRecord.Id);
                caseLocationObj.put('Case__c', CaseList[0].Id);
                CaseAndLocaiton__c locationRecord1 = (CaseAndLocaiton__c) TestDataFactory.operationOnObjectRec('insert', 'CaseAndLocaiton__c', caseLocationObj);
                
            	Test.startTest();
            		try {
                		CaseAndLocaiton__c result = LocationDetailController.insertLocationRecordIntoCaseAndLocationObject(loc[0].Id, CaseList[0].Id);
            		} catch (Exception e) {
                		/*Boolean expectedExceptionThrown = e.getMessage().contains('Duplicate Record Found') ? true : false;
               			System.AssertEquals(expectedExceptionThrown, true);*/
                		//System.assert(e.getMessage().contains('Duplicate Record Found'));
            		}	
            	Test.stopTest();
            
        }
  }
    
   /* @isTest
    static void associateLocationRecordTest(){
         User admin_User = TestDataFactory.createUser(true,'Case',SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        String caseId = '';
        String locId = '';
        System.runAs(admin_User){
            
            //Account
            Id InsuredRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Insured').getRecordTypeId();
            Map<String,Object>  Accountobj = new Map<String,Object>();
            Accountobj.put('RecordTypeId',InsuredRecordTypeId);
            Accountobj.put('Name','NewAcco');
            for(Integer i = 0 ; i <count; i++)
            {
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
            }
            
            //Contact
            Map<String,Object> ContactObj = new Map<String,Object>();
            ContactObj.put('LastName','Test Contact');
            ContactObj.put('AccountId',acc[0].Id);
            contactobj.put('email','test@gmail.com');
            for(Integer i = 0 ; i <count; i++)
            {
                con.add((Contact) TestDataFactory.operationOnObjectRec('insert', 'Contact', ContactObj));
            }
            
            //Opportunity
            Id N2GRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('N2G Internal Cases').getRecordTypeId();
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
            
            //Case
            Map<String,Object> caseObj = new Map<String,Object>();
            caseObj.put('Subject','Test Case');
            caseObj.put('SuppliedName','Test Case');
            caseObj.put('RecordTypeId',N2GRecordTypeId);
          	caseobj.put('suppliedemail','test@gmail.com');
            caseObj.put('ContactId',con[0].Id);
            caseObj.put('Box_Folder_Name__c','Locals');
            caseObj.put('Opportunity__c',Opp[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                CaseList.add((Case) TestDataFactory.operationOnObjectRec('insert', 'Case', caseObj));
            }
            
            //LOB
            Id Commercial_Auto_RT = Schema.SObjectType.LOB_Management__c.getRecordTypeInfosByDeveloperName().get('Commercial_Auto').getRecordTypeId();
            Map<String,Object>  LOBobj = new Map<String,Object>();
            LOBobj.put('LOB_Stage__c','Submission');
            LOBobj.put('LOB_Effective_Date__c', Date.today().addDays(5));
            LOBobj.put('Estimated_LOB_Premium__c',1050);
            LOBobj.put('Submission_Source__c','Other');
            //LOBobj.put('Line_of_Business__c','Commercial Auto');
            LOBobj.put('Opportunity_Related__c', Opp[0].Id);
            LOBobj.put('Case__c', CaseList[0].Id);
            LOBobj.put('Type__c','New');
            LOBobj.put('RecordTypeId', Commercial_Auto_RT);
            for(Integer i = 0 ; i <count; i++)
            {
                lobManagement.add((LOB_Management__c) TestDataFactory.operationOnObjectRec('insert', 'LOB_Management__c', LOBobj));
            }

              //Location
            Map<String, Object> Locationobj = new Map<String, Object>();
            Locationobj.put('Name', 'Test');
            Locationobj.put('Address_Details__c', '123 Main St');
            for(Integer i = 0 ; i <count; i++)
            {
                loc.add((Schema.Location) TestDataFactory.operationOnObjectRec('insert', 'Location', Locationobj));
            }
            
            //Location_And_Line_Of_Business__c
            
			String selectedLobRecordsJson = '{"Line_of_Business__c": ["' + lobManagement[0].Id + '"],"Case__c": ["' + CaseList[0].Id + '"],"Location__c": ["' + loc[0].Id + '"]}';

			Map<String, Object> selectedLobRecordsMap = (Map<String, Object>) JSON.deserializeUntyped(selectedLobRecordsJson);
            
        //Location_And_Contact__c
            Map<String,Object>  LocationContactobj = new Map<String,Object>();
            LocationContactobj.put('Contact__c',con[0].Id);
            LocationContactobj.put('Case__c',CaseList[0].Id);
            LocationContactobj.put('Location__c', loc[0].Id);
            //LocationContactobj.put(loc[0].Id, new List<String>{con[0].Id});
            for(Integer i = 0 ; i <count; i++)
            {
                LocationContact.add((Location_And_Contact__c) TestDataFactory.operationOnObjectRec('insert', 'Location_And_Contact__c',  LocationContactobj));
            }
            
			Test.startTest();
			LocationDetailController.associateLocationRecord(selectedLobRecordsMap, loc[0].Id, CaseList[0].Id);
			Test.stopTest();
            
    }
    }*/
    
    @isTest
    static void associateLocationRecordTest(){

		User admin_User = TestDataFactory.createUser(true,'Location',SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        System.runAs(admin_User){
            
            //Account
            Id InsuredRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Insured').getRecordTypeId();
            Map<String,Object>  Accountobj = new Map<String,Object>();
            Accountobj.put('RecordTypeId',InsuredRecordTypeId);
            Accountobj.put('Name','NewAcco');
            for(Integer i = 0 ; i <count; i++)
            {
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
            }
            
            //Contact
            Map<String,Object> ContactObj = new Map<String,Object>();
            ContactObj.put('LastName','Test Contact');
            ContactObj.put('AccountId',acc[0].Id);
            ContactObj.put('Email','test@gmail.com');
            for(Integer i = 0 ; i <count; i++)
            {
                con.add((Contact) TestDataFactory.operationOnObjectRec('insert', 'Contact', ContactObj));
            }
            
            //Opportunity
            Id N2GRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('N2G Internal Cases').getRecordTypeId();
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
            
            //Case
            Map<String,Object> caseObj = new Map<String,Object>();
            caseObj.put('Subject','Test Case');
            caseObj.put('SuppliedName','Test Case');
            caseObj.put('RecordTypeId',N2GRecordTypeId);
            caseObj.put('SuppliedEmail','test@gmail.com');
            caseObj.put('ContactId',con[0].Id);
            caseObj.put('Box_Folder_Name__c','Locals');
            caseObj.put('Opportunity__c',Opp[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                CaseList.add((Case) TestDataFactory.operationOnObjectRec('insert', 'Case', caseObj));
            }
        
             //LOB
            Id Commercial_Auto_RT = Schema.SObjectType.LOB_Management__c.getRecordTypeInfosByDeveloperName().get('Commercial_Auto').getRecordTypeId();
            Map<String,Object>  LOBobj = new Map<String,Object>();
            LOBobj.put('LOB_Stage__c','Submission');
            LOBobj.put('LOB_Effective_Date__c', Date.today().addDays(5));
            LOBobj.put('Estimated_LOB_Premium__c',1050);
            LOBobj.put('Submission_Source__c','Other');
            //LOBobj.put('Line_of_Business__c','Commercial Auto');
            LOBobj.put('Opportunity_Related__c', Opp[0].Id);
            LOBobj.put('Case__c', CaseList[0].Id);
            LOBobj.put('Type__c','New');
            LOBobj.put('RecordTypeId', Commercial_Auto_RT);
            for(Integer i = 0 ; i <count; i++)
            {
                lobManagement.add((LOB_Management__c) TestDataFactory.operationOnObjectRec('insert', 'LOB_Management__c', LOBobj));
            }
            
        //Location
            Map<String, Object> Locationobj = new Map<String, Object>();
            Locationobj.put('Name', 'Test');
            Locationobj.put('Address_Details__c', '123 Main St');
            for(Integer i = 0 ; i <count; i++)
            {
                loc.add((Schema.Location) TestDataFactory.operationOnObjectRec('insert', 'Location', Locationobj));
            }
            
            //Location_And_Line_Of_Business__c
            
			String selectedLobRecordsJson = '{"'+loc[0].Id+'": ["' + lobManagement[0].Id + '"]}';

			Map<String, Object> selectedLobRecordsMap = (Map<String, Object>) JSON.deserializeUntyped(selectedLobRecordsJson);
            
            //Location_And_Contact__c
            
			String selectedLocationContactJson = '{"'+loc[0].Id+'": ["' + con[0].Id + '"]}';

			Map<String, Object>selectedLocationContactRecordsMap = (Map<String, Object>) JSON.deserializeUntyped(selectedLocationContactJson);
            
            
			List<Location_And_Contact__c> removeListOfLocationAndContact = new List<Location_And_Contact__c>();
            Map<String, Object> LACTEst = new Map<String, Object>();
            LACTEst.put('Location__c', loc[0].Id);
            LACTEst.put('Contact__c', con[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                removeListOfLocationAndContact.add((Location_And_Contact__c) TestDataFactory.operationOnObjectRec('insert', 'Location_And_Contact__c', LACTEst));
            }
            List<String> tempTEstData = new List<String>();
            tempTEstData.add(removeListOfLocationAndContact[0].Id);
			            
            Test.startTest();
			LocationDetailController.associateLocationRecord(selectedLobRecordsMap, selectedLocationContactRecordsMap, CaseList[0].Id, tempTEstData);
			Test.stopTest();
    }
    }
}