@isTest
public with sharing class EmailHelperClass_T {
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
            Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
            Map<String,Object>  Accountobj = new Map<String,Object>();
            Accountobj.put('RecordTypeId',RecordTypeId);
            Accountobj.put('Name','NewAcco');
            Accountobj.put('Box_Folder_Name__c','test');
            Account accountRec = (Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj);

            Map<String,Object>  contactMap = new Map<String,Object>();
            contactMap.put('LastName','Contact');
            contactMap.put('FirstName','Test');
            contactMap.put('Email','test@xyz.com.test');
            contactMap.put('AccountId',accountRec.Id);
            Contact ContactRec = (Contact) TestDataFactory.operationOnObjectRec('insert', 'Contact', contactMap);

            Map<String,Object>  emailTemplateMap = new Map<String,Object>();
            emailTemplateMap.put('isActive',true);
            emailTemplateMap.put('Name','Test Email Template');
            emailTemplateMap.put('DeveloperName','Test_Email_Template_1234567890');
            emailTemplateMap.put('TemplateType','custom');
            emailTemplateMap.put('FolderId',admin_User.Id);
            emailTemplateMap.put('HtmlValue','<html><head><title></title></head><body style="height: auto; min-height: auto;"><p>Dear&nbsp;{{Name}}&nbsp;{{Email}}&nbsp;{{TestField}}</p><p>{Please do not change anything here we will replace the link here}<br /><br /><br />&nbsp;Kind regards&nbsp;</p></body></html>');
            EmailTemplate EmailTemplateRec = (EmailTemplate) TestDataFactory.operationOnObjectRec('insert', 'EmailTemplate', emailTemplateMap);

            List<SObject> contactRecords = EmailHelperClass.search('Tes',accountRec.Id);
            // system.assertEquals(1, contactRecords.size());

            EmailHelperClass.EmailHelperWrapper emailWrapper = new EmailHelperClass.EmailHelperWrapper();
            emailWrapper.body = EmailTemplateRec.HtmlValue;
            emailWrapper.subject = 'Test Subject';
            emailWrapper.toAddress = new List<String>{ContactRec.Email};
            emailWrapper.ccAddress = new List<String>{'test@test.com'};

            EmailHelperClass.sendEmail(JSON.serialize(emailWrapper), ContactRec.Id);

            EmailHelperClass.sendEmailController(JSON.serialize(emailWrapper));

            SObject dynamicEmailTemplateRec = EmailHelperClass.getDynamicEmailTemplateRecord(ContactRec.Id);


        }
    }
}