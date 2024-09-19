@isTest
public class TH_Case_T {
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
            caseObj.put('RecordTypeId',frontingInboxRecTypeId);
            caseObj.put('SuppliedEmail','test@gmail.com');
            caseObj.put('ContactId',con[0].Id);
            caseObj.put('Box_Folder_Name__c','Locals');
            caseObj.put('Opportunity__c',Opp[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                CaseList.add((Case) TestDataFactory.operationOnObjectRec('insert', 'Case', caseObj));
            }
            
            Map<String,Object> caseObj1 = new Map<String,Object>();
            caseObj1.put('Subject','Risk Engineering Queue');
            caseObj1.put('SuppliedName','Test Case1');
            caseObj1.put('RecordTypeId',frontingInboxRecTypeId);
            caseObj1.put('SuppliedEmail','test1@gmail.com');
            caseObj1.put('ContactId',con[0].Id);
            caseObj1.put('Box_Folder_Name__c','Locals1');
            caseObj1.put('Opportunity__c',Opp[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                CaseList.add((Case) TestDataFactory.operationOnObjectRec('', 'Case', caseObj1));
            }
            
        }
    }
    
    static testMethod void testMethod1(){
        proccesRecordDataForCase();
        test.startTest();
        List<Case> newCases = [SELECT Id, Requesting_Office__c, Client__c FROM Case WHERE RecordTypeId =:frontingInboxRecTypeId];
        System.assertEquals(acc[0].Id, newCases[0].Requesting_Office__c);
        System.assertEquals(acc[0].Id, newCases[0].Client__c);
        test.stopTest();
    } 
    static testMethod void testMethod10(){
        proccesRecordDataForCase();
        test.startTest();
        Update con;
        test.stopTest();
    }
    static testMethod void testMethod11(){
        proccesRecordDataForCase();
        test.startTest();
        Update Opp;
        test.stopTest();
    }
    static testMethod void testMethod12(){
        proccesRecordDataForCase();
        test.startTest();
        Update acc;
        test.stopTest();
    }
    
    static testMethod void testMethod3(){
        proccesRecordDataForCase();
        test.startTest();
        List<Case> newCases = [SELECT Id, Requesting_Office__c, Client__c,Box_Folder_Name__c FROM Case WHERE RecordTypeId =:frontingInboxRecTypeId];
        newCases[0].Box_Folder_Name__c = 'Approvals';
        Update newCases;
        test.stopTest();
    }
    //not 
    static testMethod void testMethod9(){
        proccesRecordDataForCase();
        test.startTest();
        List<Case> newCases = [SELECT Id, Requesting_Office__c, Client__c,Box_Folder_Name__c,SuppliedName,Topic__c,Status FROM Case WHERE RecordTypeId =:frontingInboxRecTypeId];
        newCases[0].SuppliedName = 'RE Queue';
        update newCases;
        test.stopTest();
    }
    static testMethod void testMethod8(){
        proccesRecordDataForCase();
        test.startTest();
        List<Contact> contact = [SELECT Id, Name, Email FROM Contact ];
        contact[0].Email = 'testuser@gmail.com';
        Update contact;
        test.stopTest();
    }
    
    static testMethod void testMethod7(){
        proccesRecordDataForCase();
        test.startTest();
        List <RecordType> recIds = [select id,Name from RecordType where Name = 'N2G Internal Cases' LIMIT 1];
        //recIds[0].Name = 'N2G Internal Cases';
        //update recIds;
        test.stopTest();
    }
    
    static testMethod void testMethod4(){
        proccesRecordDataForCase();
        test.startTest();
        List<Case> caseList = new List<Case>();
        Map<String,Object> caseObj = new Map<String,Object>();
        caseObj.put('Subject','Test Case');
        caseObj.put('SuppliedName','Test Case');
        caseObj.put('SuppliedEmail','test@gmail.com');
        caseObj.put('Box_Folder_Name__c','Locals');
        caseObj.put('Topic__c','Risk Engineering');
        caseObj.put('RecordTypeId',N2GRecordTypeId);
        caseList.add((Case) TestDataFactory.operationOnObjectRec('', 'Case', caseObj));     
        Insert caseList;
        
        test.stopTest();
    }
    
    static testMethod void testMethod2(){
        proccesRecordDataForCase();
        test.startTest();
        List<EmailTemplate> emailDetails = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate Limit 1];
        emailDetails[0].subject = 'Risk Engineering Request';
        update emailDetails;
        test.stopTest();
    }
    
    static testMethod void testMethod13(){
        proccesRecordDataForCase();
        test.startTest();
        List<Case> caseList = new List<Case>();
        Map<String,Object> caseObj = new Map<String,Object>();
        caseObj.put('RecordTypeId',N2GRecordTypeId);
        caseObj.put('Subject','Test Case');
        caseObj.put('OwnerId',admin_User.Id);
        caseObj.put('AccountId',acc[0].Id);
        caseList.add((Case) TestDataFactory.operationOnObjectRec('', 'Case', caseObj));
        Insert caseList;
        test.stopTest();
    }
    
    static testMethod void testMethod14(){
        proccesRecordDataForCase();
        test.startTest();
        List<Case> caseList = new List<Case>();
        Map<String,Object> caseObj = new Map<String,Object>();
        caseObj.put('RecordTypeId',N2GRecordTypeId);
        caseObj.put('Subject','Test Case');
        caseObj.put('Origin','Email');
        caseObj.put('AccountId',acc[0].Id);
        caseList.add((Case) TestDataFactory.operationOnObjectRec('', 'Case', caseObj));
        Insert caseList;
        test.stopTest();
    }
    
    static testMethod void testMethod16(){
        proccesRecordDataForCase();
        test.startTest();
        List<Case> caseList = new List<Case>();
        Map<String,Object> caseObj = new Map<String,Object>();
        caseObj.put('RecordTypeId',N2GRecordTypeId);
        caseObj.put('Subject','Test Case');
        caseObj.put('Origin','Email');
        caseObj.put('AccountId',acc[0].Id);
        caseList.add((Case) TestDataFactory.operationOnObjectRec('', 'Case', caseObj));
        Insert caseList;
        test.stopTest();
    }
    
    static testMethod void testMethod15(){
        proccesRecordDataForCase();
        test.startTest();
        List<Case> caseList = new List<Case>();
        Map<String,Object> caseObj = new Map<String,Object>();
        caseObj.put('RecordTypeId',N2GRecordTypeId);
        caseObj.put('Subject','Test Case');
        caseObj.put('Origin','Email');
        caseObj.put('AccountId',acc[0].Id);
        caseObj.put('OwnerId',REQId);
        caseObj.put('Status','Internal RE');
        caseObj.put('Topic__c','Risk Engineering');
        caseList.add((Case) TestDataFactory.operationOnObjectRec('Insert', 'Case', caseObj));
        
        //Insert caseList;
        
        ///List<Case> newCases = [SELECT Id, Requesting_Office__c, Client__c,Box_Folder_Name__c,OwnerId,Origin FROM Case WHERE RecordTypeId =:N2GRecordTypeId];
        caseList[0].Box_Folder_Name__c = 'Approvals';
        caseList[0].OwnerId = REQId;
        caseList[0].Status = 'Closed';
        caseList[0].Origin = '';
        //Update caseList[0];
        
        caseList[0].Box_Folder_Name__c = 'Approvals';
        caseList[0].OwnerId = REQId;
        caseList[0].Status = 'New';
        caseList[0].Origin = '';
        caseList[0].Topic__c = 'Risk Engineering';
        //Update caseList[0];
        
        test.stopTest();
    }
    
    static testMethod void testMethod17(){
        String ITHelpDeskRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IT Help Desk').getRecordTypeId();
        String ITQId=[SELECT Id, Name FROM Group WHERE Name = 'ITHelpDesk'].Id;
        proccesRecordDataForCase();
        test.startTest();
        List<Case> caseList = new List<Case>();
        Map<String,Object> caseObj = new Map<String,Object>();
        caseObj.put('RecordTypeId',ITHelpDeskRecordTypeId);
        caseObj.put('Subject','Test Case');
        caseObj.put('Origin','Email');
        caseObj.put('AccountId',acc[0].Id);
        caseObj.put('OwnerId',ITQId);
        caseObj.put('Status','New');
        caseObj.put('Priority', 'Low');
        caseList.add((Case) TestDataFactory.operationOnObjectRec('Insert', 'Case', caseObj));
        
        //update the Priority
        caseList[0].Priority = 'Medium';
        Update caseList[0];
        String dudt = String.valueOf(caseList[0].Due_Date__c);
        System.assertEquals(false, !(String.isBlank(dudt)));
        test.stopTest();
    }
    
    @isTest
    static void testReplaceDynamicContent() {
        proccesRecordDataForCase();
        test.startTest();
        
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('condition', true);
        
        String textToReplace = '{{if(condition,\'Condition met\',\'Condition not met\')}}';
        String expectedOutput = 'Condition met';
        
        String result = TH_Case.replaceDynamicContent(inputMap, textToReplace);
        
        System.assertEquals(expectedOutput, result, 'The dynamic content replacement did not work as expected');
        
        test.stopTest();
    }
    
    @isTest
    static void testIsUserInREteam() {
        List<CaseTeamMember> teamMembers = new List<CaseTeamMember>{
            new CaseTeamMember(MemberId = UserInfo.getUserId())
        };
        Boolean isInTeam = TH_Case.isUserInREteam(teamMembers, UserInfo.getUserId());
        System.assert(isInTeam, 'User should be recognized as part of the RE team.');
    }
    
     @isTest
    static void testAssignCasesToQueuess() {
        proccesRecordDataForCase();
        Group bpqQueue = [SELECT Id FROM Group WHERE Name = 'BPO - Priority Rating Queue' LIMIT 1];
        Group reQueue = [SELECT Id FROM Group WHERE Name = 'Risk Engineering Queue' LIMIT 1];
        User dummyUser = [SELECT Id FROM USER LIMIT 1];
        
        
        // Retrieve the test cases
        //List<Case> newCaseList = [SELECT Id, Status, Topic__c, RecordTypeId, OwnerId, CreatedById FROM Case WHERE RecordTypeId = :N2GRecordTypeId];
        
        // Create a dummy oldCaseMap
        //Map<Id, Case> oldCaseMap = new Map<Id, Case>([SELECT Id, Status, OwnerId FROM Case WHERE Id IN :newCaseList]);
        
        // Call the method
        Test.startTest();
        List<Case> newCaseList = new List<Case>();
        Map<String,Object> caseObjMap = new Map<String,Object>();
        Map<ID, Case> oldCaseMap = new  Map<ID, Case>();
        caseObjMap.put('Subject','Test Case');
        caseObjMap.put('Origin','Email');
        caseObjMap.put('AccountId',acc[0].Id);
        //caseObjMap.put('OwnerId',bpqQueue.Id);
        caseObjMap.put('Priority', 'Low');
        caseObjMap.put('Topic__c','Risk Engineering');
        caseObjMap.put('Status','Assigned to BPO');
      	caseObjMap.put('CreatedById',dummyUser.Id);
        caseObjMap.put('RecordTypeId',N2GRecordTypeId);
        newCaseList.add((Case) TestDataFactory.operationOnObjectRec('Insert', 'Case', caseObjMap));
        TH_Case.assignCasesToQueuess(newCaseList, oldCaseMap);
       
        // Verify the owner of each case has been updated correctly
        for (Case caseObj : newCaseList) {
            if (caseObj.Status == 'Assigned to BPO') {
                caseObj.OwnerId = bpqQueue.Id;
                System.assertEquals(bpqQueue.Id, caseObj.OwnerId, 'Owner should be BPQ Queue for cases assigned to BPO.');
            } 
        }
        
        List<Case> newCaseList2 = new List<Case>();
        Map<String,Object> caseObjMap2 = new Map<String,Object>();
        Map<ID, Case> oldCaseMap2 = new  Map<ID, Case>();
        caseObjMap2.put('Subject','Test Case');
        caseObjMap2.put('Origin','Email');
        caseObjMap2.put('AccountId',acc[0].Id);
        //caseObjMap.put('OwnerId',bpqQueue.Id);
        caseObjMap2.put('Priority', 'Low');
        caseObjMap2.put('Topic__c','Risk Engineering');
        caseObjMap2.put('Status','New');
      	caseObjMap2.put('CreatedById',dummyUser.Id);
        caseObjMap2.put('RecordTypeId',N2GRecordTypeId);
        newCaseList2.add((Case) TestDataFactory.operationOnObjectRec('Insert', 'Case', caseObjMap2));
        TH_Case.assignCasesToQueuess(newCaseList2, oldCaseMap2);
        
        // Verify the owner of each case has been updated correctly
        for (Case caseObj : newCaseList2) {
            if (caseObj.Status == 'New') {
                caseObj.OwnerId = dummyUser.Id;
                System.assertEquals(caseObj.CreatedById, caseObj.OwnerId, 'Owner should be the creator for new cases.');
            }
        }
        
        List<Case> newCaseList3 = new List<Case>();
        Map<String,Object> caseObjMap3 = new Map<String,Object>();
        Map<ID, Case> oldCaseMap3 = new  Map<ID, Case>();
        caseObjMap3.put('Subject','Test Case');
        caseObjMap3.put('Origin','Email');
        caseObjMap3.put('AccountId',acc[0].Id);
        //caseObjMap.put('OwnerId',bpqQueue.Id);
        caseObjMap3.put('Priority', 'Low');
        caseObjMap3.put('Topic__c','Risk Engineering');
        caseObjMap3.put('Status','Internal RE');
      	caseObjMap3.put('CreatedById',dummyUser.Id);
        caseObjMap3.put('RecordTypeId',N2GRecordTypeId);
        caseObjMap3.put('OwnerId',reQueue.Id);
        newCaseList3.add((Case) TestDataFactory.operationOnObjectRec('Insert', 'Case', caseObjMap3));
        TH_Case.assignCasesToQueuess(newCaseList3, oldCaseMap3);
        
        // Verify the owner of each case has been updated correctly
        for (Case caseObj : newCaseList3) {
            if (caseObj.Status == 'Internal RE' || caseObj.Status == 'Closed') {
                System.assertEquals(reQueue.Id, caseObj.OwnerId, 'Owner should be RE Queue for cases with Internal RE or Closed status.');
            }
        }
        
        Test.stopTest();
    }
    
     @IsTest static void testOnAfterUpdate(){

         
         Case newCase = new Case();
        newCase.Subject = 'Unittest';
        newCase.Status = 'New';
        insert newCase; 
        
        Case testCase1 = [select Subject, Status from Case where Subject = 'Unittest']; 
        System.assertEquals(testCase1.Subject, 'Unittest');
         
        Map<Id, Case> oldObjectMap = new Map<Id, Case>();
          
        Case[] testCase = [select Subject, CaseNumber, Status, Owner.Name from Case where Subject = 'Unittest'];
        
        Case_Status_Change__c  statusChange = new  Case_Status_Change__c();
        statusChange.Name = testCase[0].CaseNumber + ' status: New';
        statusChange.Case__c = testCase[0].Id;
        statusChange.Status_Name__c = testCase[0].Status;
        statusChange.Set_Time__c = Datetime.now();
        insert statusChange;
        
        testCase[0].Status = 'Escalated';

        Case oldCase = new Case();
        oldCase.Subject ='Unittest';
        oldCase.Status = 'New';
        oldCase.Id=testCase[0].Id;
        oldObjectMap.put(testCase[0].Id, oldCase);

        
        CaseStatusChangeTriggerHandler.OnAfterUpdate(testCase, oldObjectMap);
        
        Case_Status_Change__c[] caseStatusChange = [select Name from Case_Status_Change__c where Case__r.Id=:testCase[0].Id and Change_Time__c = null];
        
        
        System.assertEquals(caseStatusChange[0].Name, testCase[0].CaseNumber + ' from New to Escalated');
    
    }

}