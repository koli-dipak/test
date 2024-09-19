@isTest
public with sharing class DAL_Utility_T {
    public static User admin_User;
    public static Integer count =1;
    public static string SYSTEM_ADMINISTRATOR_PROFILE ='System Administrator';
    
    @isTest
    static void testMethod1()
    {
        admin_User = TestDataFactory.createUser(true,'LOB_Management__c',SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        System.runAs(admin_User)
        {
            Map<String,Object>  emailTemplateMap = new Map<String,Object>();
            emailTemplateMap.put('isActive',true);
            emailTemplateMap.put('Name','Test Email Template');
            emailTemplateMap.put('DeveloperName','Test_Email_Template_1234567890');
            emailTemplateMap.put('TemplateType','custom');
            emailTemplateMap.put('FolderId',admin_User.Id);
            emailTemplateMap.put('HtmlValue','<html><head><title></title></head><body style="height: auto; min-height: auto;"><p>Dear&nbsp;{{Name}}&nbsp;{{Email}}&nbsp;{{TestField}}</p><p>{Please do not change anything here we will replace the link here}<br /><br /><br />&nbsp;Kind regards&nbsp;</p></body></html>');
            EmailTemplate EmailTemplateRec = (EmailTemplate) TestDataFactory.operationOnObjectRec('insert', 'EmailTemplate', emailTemplateMap);

            DAL_Utility.getEmailTemplateRecByDeveloperName(EmailTemplateRec.DeveloperName);
        }
    }
    @isTest
    static void testMethod2()
    {
        Map<String,Object> ChecklistRecords = new Map<String,Object>();
        ChecklistRecords.put('Name','COMMON POLICY DECLARATIONS');
        ChecklistRecords.put('States__c','AL');
        ChecklistRecords.put('TYPE__c','Checklist');
        Broker_Checklist__c rec = (Broker_Checklist__c) TestDataFactory.operationOnObjectRec('insert','Broker_Checklist__c',ChecklistRecords);
        
        //Create Document
        Map<String, Object> createDocument = new Map<String,Object>();
        createDocument.put('Title','Test Document');
        createDocument.put('PathOnClient','TestDocument.pdf');
        createDocument.put('VersionData', Blob.valueOf('Test Content'));
        createDocument.put('IsMajorVersion',true);
        ContentVersion cv = (ContentVersion) TestDataFactory.operationOnObjectRec('insert','ContentVersion',createDocument);
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        Map<String,Object> FormWiseRec = new Map<String,Object>();
        FormWiseRec.put('LinkedEntityId', rec.Id);
        FormWiseRec.put('ContentDocumentId', conDocId);
        FormWiseRec.put('shareType', 'V');
        ContentDocumentLink FormContentDocumentId = (ContentDocumentLink) TestDataFactory.operationOnObjectRec('insert','ContentDocumentLink',FormWiseRec);
    	
        DAL_Utility.getContentDocumentLinkIds(new List<String>{rec.Id});
        DAL_Utility.getContentVersionIds(new List<ContentDocumentLink>{FormContentDocumentId});
    	DAL_Utility.getListOfPeriod();
    }
    
    static testMethod void testMethod3(){
        Test.startTest();
       	DAL_Utility.getListOfPeriod();
        DAL_Utility.getListOfEditablePolicyNo();
        DAL_Utility.getOrgWideEmailAddress();
        DAL_Utility.getPriorityWiseBusinessDaysList();
        DAL_Utility.getBusinessHours();
        DAL_Utility.getEmailTemplateByDeveloperName();
        DAL_Utility.getOrgWideEmailAddressByDisplayName();
        DAL_Utility.getRecordTypeByName('');
        DAL_Utility.getGroupMemberByDevName('');
        DAL_Utility.getCaseTeamRoleByName('');
        DAL_Utility.getProfileByName('N2G - Users');
        DAL_Utility.getCustomNotificationByName('LOB_Task_Completion');
        DAL_Utility.getCaseTeamMemberByCaseIds(new Set<Id>{null});
        Test.stopTest();
    } 
}