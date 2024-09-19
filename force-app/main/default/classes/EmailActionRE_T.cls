@isTest
private class EmailActionRE_T {
    public static User admin_User;
    public static Integer count =1;
    public static string SYSTEM_ADMINISTRATOR_PROFILE ='System Administrator';
    public static List<Account> acc = new List<Account>();
    public static List<Case> CaseList = new List<Case>();
    public static List<Opportunity> Opp = new List<Opportunity>();
    public static List<Contact> con = new List<Contact>();
    public static Id frontingInboxRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.Fronting_Inbox_Record_Type_Dev_Name).getRecordTypeId();
    public static Id InsuredRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Insured').getRecordTypeId();
    public static Id N2GRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('N2G Internal Cases').getRecordTypeId();
    public static String REQId=[SELECT Id, Name FROM Group WHERE Name = 'Risk Engineering Queue'].Id;
     
    @isTest
    static void proccesRecordDataForCase(){
        admin_User = TestDataFactory.createUser(true,'Case',SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        System.runAs(admin_User){
            Map<String,Object>  Accountobj = new Map<String,Object>();
            Accountobj.put('RecordTypeId',InsuredRecordTypeId);
            Accountobj.put('Name','NewAcco');
            for(Integer i = 0 ; i <count; i++)
            {
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
            }
            
            Map<String,Object> ContactObj = new Map<String,Object>();
            ContactObj.put('LastName','Test Contact');
            ContactObj.put('AccountId',acc[0].Id);
            ContactObj.put('Email','test@gmail.com');
            for(Integer i = 0 ; i <count; i++)
            {
                con.add((Contact) TestDataFactory.operationOnObjectRec('insert', 'Contact', ContactObj));
            }
            
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
            
            Map<String,Object> caseObj = new Map<String,Object>();
            caseObj.put('Subject','Test Case');
            caseObj.put('SuppliedName','Test Case');
            caseObj.put('RecordTypeId',N2GRecordTypeId);
            caseObj.put('SuppliedEmail','test@gmail.com');
            caseObj.put('ContactId',con[0].Id);
            caseObj.put('Box_Folder_Name__c','Locals');
            caseObj.put('Opportunity__c',Opp[0].Id);
            caseObj.put('Visit_Type__c','Foreign Casualty Desktop Review');
            for(Integer i = 0 ; i <count; i++)
            {
                CaseList.add((Case) TestDataFactory.operationOnObjectRec('insert', 'Case', caseObj));
            }
            
            Map<String,Object> caseObj1 = new Map<String,Object>();
            caseObj1.put('Subject','Risk Engineering Queue');
            caseObj1.put('SuppliedName','Test Case1');
            caseObj1.put('RecordTypeId',N2GRecordTypeId);
            caseObj1.put('SuppliedEmail','test1@gmail.com');
            caseObj1.put('ContactId',con[0].Id);
            caseObj1.put('Box_Folder_Name__c','Locals1');
            caseObj1.put('Visit_Type__c','Foreign Casualty Desktop Review');
            caseObj1.put('Opportunity__c',Opp[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                CaseList.add((Case) TestDataFactory.operationOnObjectRec('', 'Case', caseObj1));
            }
            
        }
    }
    
    @isTest
    static void testSendEmail() {
         proccesRecordDataForCase();

         EmailActionRE.Request testRequest = new EmailActionRE.Request();
        testRequest.matchedEmailAddress = 'test@example.com';
        testRequest.unmatchedEmailAddress = 'invalid@example.com';
        testRequest.EmailSubject = 'Test Subject';
        testRequest.CaseId = CaseList[0].id; // Provide a valid CaseId
        testRequest.EmailBody = '<p>Test Email Body</p>';
        
        List<EmailActionRE.FileData> testFileDataList = new List<EmailActionRE.FileData>();
        EmailActionRE.FileData testData = new EmailActionRE.FileData();
        testData.filename = 'TestFile.txt';
        //testData.versionId = '068XXXXXXXXXXXX'; // Provide a valid VersionId
        testFileDataList.add(testData);
        testRequest.fileData = JSON.serialize(testFileDataList);
        
        // Add test data to a list
        List<EmailActionRE.Request> testRequestList = new List<EmailActionRE.Request>();
        testRequestList.add(testRequest);
        

        Test.startTest();
        EmailActionRE.sendEmail(testRequestList);
        Test.stopTest();
      
    }
    
    // Add more test methods as needed
}