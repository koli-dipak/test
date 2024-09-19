public class TH_EmailMessage extends BaseTriggerHandler {
    private List<EmailMessage> newEmailMessageList;
    private List<EmailMessage> oldEmailMessageList;
    private Map<ID, EmailMessage> newEmailMessageMap;
    private Map<ID, EmailMessage> oldEmailMessageMap;
    
    public TH_EmailMessage()
    {
        oldEmailMessageList = (List<EmailMessage>)Trigger.old;
        newEmailMessageList = (List<EmailMessage>)Trigger.new;
        newEmailMessageMap = (Map<Id, EmailMessage>)Trigger.newMap;
        oldEmailMessageMap = (Map<Id, EmailMessage>)Trigger.oldMap;
    }
    
    protected override void beforeInsert() { 
        if(Trigger_PAD.canRun('TH_EmailMessageBeforeInsert')){
            proccesRecordBeforeEmailMessage(newEmailMessageList,oldEmailMessageMap);
        }
    } 
    
    public static void proccesRecordBeforeEmailMessage(List<EmailMessage> newEmailMessageList, Map<Id, EmailMessage> oldEmailMessageMap){
        
        Integer checkDays = 0;
        Set<Id> CaseIds = new Set<Id>();
        Set<Id> CaseIdRiskEnginer = new Set<Id>();
        Set<Id> insertedCaseIds = new Set<Id>();
        Map<Id, Id> parentCaseIdWiseNewCaseId = new Map<Id, Id>();
        List<Case> caseRecordsToInsert = new List<Case>();
        List<Case> updateCaseRecords = new List<Case>();
        
        Id frontingInboxRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.Fronting_Inbox_Record_Type_Dev_Name).getRecordTypeId();
        List<Case_closed_Day__mdt> CaseClosedDaysMDT = Case_closed_Day__mdt.getAll().values();
        if (!CaseClosedDaysMDT.isEmpty() && CaseClosedDaysMDT[0].DeveloperName == 'Default') {
            checkDays = Integer.valueOf(CaseClosedDaysMDT[0].Days__c);
        }
        
        for(EmailMessage EM : newEmailMessageList){
            if(String.isNotBlank(EM.ParentId) && EM.ParentId.getSObjectType().getDescribe().getName() == 'Case' && EM.Incoming){
                CaseIds.add(EM.ParentId);
                
            }
            if(String.isNotBlank(EM.ParentId) && EM.ParentId.getSObjectType().getDescribe().getName() == 'Case' && !EM.Incoming){
                CaseIdRiskEnginer.add(EM.ParentId);
            }
        }
        Map<Id,Case> parentCaseMap = new Map<Id,Case>([SELECT Id, Topic__c, Origin, RecordTypeId FROM Case WHERE Id = :CaseIdRiskEnginer]);
         Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('N2G Internal Cases').getRecordTypeId();
       
                
        // Risk Enginner Validation
        for(EmailMessage EM : newEmailMessageList){
            if(String.isNotBlank(EM.ParentId) && EM.ParentId.getSObjectType().getDescribe().getName() == 'Case' && !EM.Incoming){
                CaseIdRiskEnginer.add(EM.ParentId);
            }
            if(String.isNotBlank(EM.ParentId) && EM.ParentId.getSObjectType().getDescribe().getName() == 'Case' && !EM.Incoming){
                if (parentCaseMap.containsKey(EM.ParentId) != null && parentCaseMap.get(EM.ParentId).Topic__c!=null && parentCaseMap.get(EM.ParentId).Topic__c == 'Risk Engineering' && parentCaseMap.get(EM.ParentId).RecordTypeId==caseRecordTypeId) {
                    // Run the code here
                    List<Case> newCaseList = new List<Case>();
                    Set<Id> riskEngineeringGroupUserIds = new Set<Id>();
                    List<GroupMember> riskEngineeringGroupMembers = [SELECT UserOrGroupId
                                                                     FROM GroupMember
                                                                     WHERE Group.DeveloperName = 'Risk_Engineering_Queue'];
                    for (GroupMember member : riskEngineeringGroupMembers) {
                        riskEngineeringGroupUserIds.add(member.UserOrGroupId);
                    }
                    Boolean isUserInRiskEngineeringGroup = riskEngineeringGroupUserIds.contains(UserInfo.getUserId());
                    if (!isUserInRiskEngineeringGroup) {
                        EM.addError('The risk engineering team is only permitted to send emails from the case');
                    }
                }
            }
            
        }
        
        
        if(!CaseIds.isEmpty()){
            List<Case> caseRecords = DAL_Case.getCaseRecordsByIdSet(CaseIds);
            for(Case caseRec : caseRecords){
                if(caseRec.IsClosed){
                    if(caseRec.Closed_Days__c >= checkDays){
                        Case newCase = new Case();
                        newCase.SuppliedEmail = caseRec.SuppliedEmail;
                        newCase.SuppliedName = caseRec.SuppliedName;
                        newCase.Status = 'New';
                        newCase.OwnerId = caseRec.OwnerId;
                        newCase.Origin = 'Email';
                        newCase.Subject = caseRec.Subject;
                        newCase.Description = caseRec.Description;
                        newCase.ParentId = caseRec.Id;
                        // newCase.SourceId = '02s7i000001mOEGAA2';
                        newCase.ContactId = caseRec.ContactId;
                        newCase.AccountId = caseRec.AccountId;
                        newCase.Requesting_Office__c = caseRec.Requesting_Office__c;
                        newCase.Opportunity__c = caseRec.Opportunity__c;
                        newCase.Box_Folder_Name__c = caseRec.Box_Folder_Name__c;
                        newCase.Client__c = caseRec.Client__c;
                        newCase.RecordTypeId = frontingInboxRecTypeId;
                        caseRecordsToInsert.add(newCase);
                    }else{
                        caseRec.Status = 'New';
                        updateCaseRecords.add(caseRec);
                    }
                }
            }
            system.debug('@@caseRecordsToInsert:::'+caseRecordsToInsert);
            If(!caseRecordsToInsert.isEmpty()){
                List<Database.SaveResult> results = Database.insert(caseRecordsToInsert, false);
                for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully INSERTED CASE. CASE ID: ' + sr.getId());
                        insertedCaseIds.add(sr.getId());
                    }
                    else {               
                        for(Database.Error err : sr.getErrors()) {                  
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Case fields that affected this error: ' + err.getFields());
                        }
                    }
                }
                
                if(!insertedCaseIds.isEmpty()){
                    List<Case> newCaseRecords = DAL_Case.getCaseRecordsByIdSet(insertedCaseIds);
                    Map<String, String> OrgWideEmailAddressIdMap = new Map<String, String>();
                    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                    List<OrgWideEmailAddress> OrgWideEmailAddressRecs = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName =: System.Label.FI_Custom_Case_Auto_Response_Rule_Sender_Email_Address];
                    List<EmailTemplate> emailTemplateRec = [SELECT Id,DeveloperName, Name, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName =:System.Label.FI_Custom_Case_Auto_Response_Rule_Email_Template_Name];
                    Contact contactRec = [SELECT Id FROM Contact WHERE LastName = 'DND PSADEV Global Contact for Case'];
                    if(!OrgWideEmailAddressRecs.isEmpty()){
                        for(OrgWideEmailAddress email : OrgWideEmailAddressRecs){
                            if(email.DisplayName == System.Label.FI_Custom_Case_Auto_Response_Rule_Sender_Email_Address){
                                OrgWideEmailAddressIdMap.put(email.DisplayName, email.Id);
                            }
                        }  
                    }
                    
                    for(Case caseRec : newCaseRecords){
                        parentCaseIdWiseNewCaseId.put(caseRec.ParentId, caseRec.Id);
                        
                        If(!OrgWideEmailAddressIdMap.isEmpty() && OrgWideEmailAddressIdMap.containsKey(System.Label.FI_Custom_Case_Auto_Response_Rule_Sender_Email_Address) && !emailTemplateRec.isEmpty()){
                            
                            // send auto response email to case 
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            List<String> toAddresses = new List<String> {caseRec.SuppliedEmail};
                                mail.setToAddresses(toAddresses);
                            mail.setReplyTo(OrgWideEmailAddressIdMap.get(System.Label.Set_reply_to_FI_Case_org_wide_email_address));
                            mail.setWhatId(caseRec.Id);
                            system.debug('@@caseRec.ownerId::'+caseRec.ownerId);
                            mail.setTargetObjectId(contactRec.Id);
                            mail.setTreatTargetObjectAsRecipient(false);
                            mail.setOrgWideEmailAddressId(OrgWideEmailAddressIdMap.get(System.Label.FI_Custom_Case_Auto_Response_Rule_Sender_Email_Address));
                            mail.setTemplateID(emailTemplateRec[0].Id);
                            emailList.add(mail);
                        }
                    }
                    
                    if(!emailList.isEmpty()){
                        Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailList);
                        if (emailResults[0].success) {
                            System.debug('The email was sent successfully.');
                        } else {
                            System.debug('The email failed to send: ' + emailResults[0].errors[0].message);
                        }
                    }
                }
                
                for(EmailMessage EM : newEmailMessageList){
                    if(String.isNotBlank(EM.ParentId) && EM.ParentId.getSObjectType().getDescribe().getName() == 'Case'
                       && EM.Incoming && parentCaseIdWiseNewCaseId.containsKey(EM.ParentId)){
                           EM.ParentId = parentCaseIdWiseNewCaseId.get(EM.ParentId);
                       }
                }
            }
            
            if(!updateCaseRecords.isEmpty()){
                update updateCaseRecords;
            }
        }
    }
}