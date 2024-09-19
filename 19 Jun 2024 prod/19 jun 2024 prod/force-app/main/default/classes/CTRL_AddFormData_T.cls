@isTest
public class CTRL_AddFormData_T {
    
    public static Integer count = 1;
    public static List<vlocity_ins__Application__c> app = new List<vlocity_ins__Application__c>();
    public static List<FC_Casualty_Premium__c> fcasprem = new List<FC_Casualty_Premium__c>();
    public static List<LOB_Management__c> lobManagement = new List<LOB_Management__c>();
    public static List<Account> acc = new List<Account>();
    public static List<Opportunity> Opp = new List<Opportunity>();
    public static List<	FC_Coverage__c> fcoverage = new List<FC_Coverage__c>();
    public static List<	FC_Form__c> fcovgform = new List<FC_Form__c>();
    public static List<	FC_Reference_Form__c> fcrefform = new List<FC_Reference_Form__c>();
    
	@isTest
    public static void getFormsDetTest(){
        User admin_User = TestDataFactory.createUser(true, '','System Administrator');
        System.runAs(admin_User){
            
            Test.startTest();
            
            Map<String,Object> FCFormRecords = new Map<String,Object>();
            FCFormRecords.put('Form_Name__c','COMMON POLICY DECLARATIONS');
            FCFormRecords.put('Order__c',1);
            //FCFormRecords.put('Form_Name_ID__c','OP-D-1100CT-N2G0621');
            FCFormRecords.put('LOB_CODE__c','Common');
            FCFormRecords.put('Default__c',true);
            FC_Reference_Form__c FormNameRec = (FC_Reference_Form__c) TestDataFactory.operationOnObjectRec('insert','FC_Reference_Form__c',FCFormRecords);
            
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
            FormWiseRec.put('LinkedEntityId', FormNameRec.Id);
            FormWiseRec.put('ContentDocumentId', conDocId);
            FormWiseRec.put('shareType', 'V');
            ContentDocumentLink FormContentDocumentId = (ContentDocumentLink) TestDataFactory.operationOnObjectRec('insert','ContentDocumentLink',FormWiseRec);
			System.debug(FormContentDocumentId);
            
            //-------------
            
             Map<String,Object>  Accountobj = new Map<String,Object>();
            Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
            Accountobj.put('RecordTypeId',RecordTypeId);
            Accountobj.put('Name','NewAcco');
            Accountobj.put('Box_Folder_Name__c','test');
            for(Integer i = 0 ; i <count; i++)
            {
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
            }
            
            Map<String,Object>  Opportunityobj = new Map<String,Object>();
            Opportunityobj.put('Name','test');
            Opportunityobj.put('CloseDate',System.today());
            Opportunityobj.put('StageName','Unqualified');
            Opportunityobj.put('AccountId',acc[0].Id);
            Opportunityobj.put('Line_of_Business__c','Commercial Umbrella;Ocean Marine');
            for(Integer i = 0 ; i <count; i++)
            {
                Opp.add((Opportunity) TestDataFactory.operationOnObjectRec('insert', 'Opportunity', Opportunityobj));
            }
            
            lobManagement = [SELECT Id FROM LOB_Management__c];
            
            Map<String,Object> engagement = new Map<String,Object>();
            engagement.put('Assign_To__c',admin_User.Id);
            Engagement__c engagementRec = (Engagement__c) TestDataFactory.operationOnObjectRec('insert','Engagement__c',engagement);

            Map<String,Object> broker = new Map<String,Object>();
            broker.put('Broker__c',engagementRec.Id);
            broker.put('Broker_Account__c',acc[0].Id);
            Engagement_Broker__c brokerRec = (Engagement_Broker__c) TestDataFactory.operationOnObjectRec('insert','Engagement_Broker__c',broker);
            
            Map<String,Object>  ApplicationObj = new Map<String,Object>();
          	ApplicationObj.put('Name','NewApp');
            ApplicationObj.put('LineofBusiness__c',lobManagement[0].Id);
            ApplicationObj.put('Program_Id__c','644');
            ApplicationObj.put('Version__c','1');
            for(Integer i = 0 ; i <count; i++)
            {
                app.add((vlocity_ins__Application__c) TestDataFactory.operationOnObjectRec('insert', 'vlocity_ins__Application__c', ApplicationObj));
            }
            
            Map<String,Object> casualtyPremium = new Map<String,Object>();
            casualtyPremium.put('Application__c',app[0].Id);
            casualtyPremium.put('Broker__c',brokerRec.Id);
            casualtyPremium.put('Insured_Name__c',acc[0].Id);
            casualtyPremium.put('Line_of_Business__c',lobManagement[0].Id);
            
            for(Integer i = 0 ; i <count; i++)
            {
               fcasprem.add((FC_Casualty_Premium__c) TestDataFactory.operationOnObjectRec('insert', 'FC_Casualty_Premium__c', casualtyPremium)); 
            }
            
             Map<String,Object> fccoverage = new Map<String,Object>();
            fccoverage.put('Casualty_Premium__c',fcasprem[0].Id);
            for(Integer i = 0 ; i <count; i++)
            {
               fcoverage.add((FC_Coverage__c) TestDataFactory.operationOnObjectRec('insert', 'FC_Coverage__c', fccoverage)); 
            }
            
            Map<String,Object> referenceform = new Map<String,Object>();
            referenceform.put('Form_Name__c','test');
            referenceform.put('Order__c',1);
            for(Integer i = 0 ; i <count; i++)
            {
               fcrefform.add((FC_Reference_Form__c) TestDataFactory.operationOnObjectRec('insert', 'FC_Reference_Form__c', referenceform)); 
            }
            
             Map<String,Object> fcform = new Map<String,Object>();
            fcform.put('FC_Coverage__c',fcoverage[0].Id);
            fcform.put('FC_Reference_Form__c',fcrefform[0].Id);
            fcform.put('Application__c',app[0].Id);
            
            for(Integer i = 0 ; i <count; i++)
            {
               fcovgform.add((FC_Form__c) TestDataFactory.operationOnObjectRec('insert', 'FC_Form__c', fcform)); 
            }
            
            Map<String,Object> FormWiseRec2 = new Map<String,Object>();
            FormWiseRec2.put('LinkedEntityId', fcrefform[0].Id);
            FormWiseRec2.put('ContentDocumentId', conDocId);
            FormWiseRec2.put('shareType', 'V');
            ContentDocumentLink FormContentDocumentId2 = (ContentDocumentLink) TestDataFactory.operationOnObjectRec('insert','ContentDocumentLink',FormWiseRec2);
            
            Map<String, Object> inputmap = new Map<String, Object>();
            inputmap.put('CurrentLob','Common');
            
            Map<String, Object> inputmap2 = new Map<String, Object>();
            inputmap2.put('ApplicationID',app[0].Id);
            
            Boolean value=New CTRL_AddFormData().invokeMethod('getFormsDet', inputmap, new Map<String, Object>(), new Map<String, Object>());
            System.assertEquals(value, true);
             value=New CTRL_AddFormData().invokeMethod('getDefaultForms', new Map<String, Object>(), new Map<String, Object>(), new Map<String, Object>());
            System.assertEquals(value, true);
             value=New CTRL_AddFormData().invokeMethod('dltPrevForms', new Map<String, Object>(), new Map<String, Object>(), new Map<String, Object>());
            System.assertEquals(value, true);
            value=New CTRL_AddFormData().invokeMethod('getContentDocumentLinks', inputmap2, new Map<String, Object>(), new Map<String, Object>());
            System.assertEquals(value, true);
            value=New CTRL_AddFormData().invokeMethod('dltPrevExtensions', inputmap2, new Map<String, Object>(), new Map<String, Object>());
            System.assertEquals(value, true);
            
            Test.stopTest();
        }
    }
}