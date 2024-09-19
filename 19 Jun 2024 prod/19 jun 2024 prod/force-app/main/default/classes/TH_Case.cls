/**
* Apex class for handling Case triggers.
*/
public class TH_Case extends BaseTriggerHandler {
    
    private List < Case > newCaseList;
    private List < Case > oldCaseList;
    private Map < ID, Case > newCaseMap;
    private Map < ID, Case > oldCaseMap;
    
    /**
* Constructor to initialize trigger context variables.
*/
    public TH_Case() {
        oldCaseList = (List < Case > ) Trigger.old;
        newCaseList = (List < Case > ) Trigger.new;
        newCaseMap = (Map < Id, Case > ) Trigger.newMap;
        oldCaseMap = (Map < Id, Case > ) Trigger.oldMap;
    }
    
    /**
* Trigger handler method invoked before Case records are inserted.
*/
    protected override void beforeInsert() {
        if (Trigger_PAD.canRun('TH_CaseBeforeInsert')) {
            proccesRecordBefore(newCaseList, oldCaseMap);
            BuildSubjectField(newCaseList, oldCaseMap);
            setDueDateBaseOnPrority(newCaseList, oldCaseMap);
            userBasedDepartmentOnReqDept(newCaseList, oldCaseMap);
        }
    }
    
    /**
* Trigger handler method invoked before Case records are updated.
*/
    protected override void beforeUpdate() {
        if (Trigger_PAD.canRun('TH_CaseBeforeUpdate')) {
            throwEditException(newCaseList,oldCaseMap);
            proccesRecordBefore(newCaseList, oldCaseMap);
            assignCasesToQueuess(newCaseList,oldCaseMap);
            setDueDateBaseOnPrority(newCaseList, oldCaseMap);
        }
    }
    
    /**
* Trigger handler method invoked after Case records are inserted.
*/
    protected override void afterInsert() {
        if (Trigger_PAD.canRun('TH_CaseAfterInsert')) {
            system.debug('@@ After Insert Trigger Called');
            SendEmailForNewCase(newCaseList, oldCaseMap);
            CaseStatusChangeTriggerHandler.OnAfterInsert(newCaseList);
            
        }
    }
    
    /**
* Trigger handler method invoked after Case records are updated.
*/
    protected override void afterUpdate() {
        if (Trigger_PAD.canRun('TH_CaseAfterUpdate')) {
            system.debug('@@ After Update Trigger Called');
            ChangeOwnerShipWhenAssignedtoQueue(newCaseList, oldCaseMap);
            SendEmailForQueueMembers(newCaseList, oldCaseMap);
            System.debug('22newCaseList@@'+ newCaseList);
            CaseStatusChangeTriggerHandler.OnAfterUpdate(newCaseList, oldCaseMap);
        }
    }
    
    /**
* Method to process Case records before insert/update.
*/
    public static void proccesRecordBefore(List < Case > newCaseList, Map < ID, Case > oldCaseMap) {
        updateCaseRequestingOffice(newCaseList, oldCaseMap);
        updateCaseClientFromOpportunity(newCaseList, oldCaseMap);
    }
    
    
    //Methods for TH_CASE
    public static void BuildSubjectField(List < Case > newCaseList, Map < ID, Case > oldCaseMap) {
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('N2G Internal Cases').getRecordTypeId();
        Id recTypeId = caseRecordTypeId;
        
        List < Id > accountIds = new List < Id > ();
        for (Case c: newCaseList) {
            accountIds.add(c.AccountId);
        }
        
        List < Account > accountList = DAL_Account.getAccountList(accountIds);
        
        Map < Id, String > clientMap = new Map < Id, String > ();
        for (Account a: accountList) {
            clientMap.put(a.Id, a.Name);
        }
        for (Case newCase: newCaseList) {
            if (newCase.RecordTypeId == recTypeId && newCase.Origin==null) {
                DateTime now = DateTime.now();
                String formattedDateTime = now.format('MM/dd/yyyy hh:mm:ss a');
                String clientName = '';
                if (clientMap.containsKey(newCase.AccountId)) {
                    clientName = clientMap.get(newCase.AccountId);
                }
                String subject = 'Risk Engineering Request' + ' | ' + clientName + ' | ' + formattedDateTime;
                newCase.Subject = subject;
            }
            if (newCase.RecordTypeId == recTypeId && newCase.Origin=='Email') {
                newCase.Topic__c='Risk Engineering';
            }
            if(newCase.SuppliedEmail!=null)            {
                newCase.Case_Created_By_Email_ID__c=newCase.SuppliedEmail;
            }
        }
        
    }
    
    // Method to change ownership when a case is assigned to a specific queue
    public static void ChangeOwnerShipWhenAssignedtoQueue(List < Case > newCaseList, Map < ID, Case > oldCaseMap) {
        // List to hold CaseTeamMember records to be updated
        List < CaseTeamMember > caseTeamList = new List < CaseTeamMember > ();
        // Get the risk engineering queue group
        List<Group> riskEngineeringQueue = DAL_Group.getriskEngineeringQueue();
        
        // Set to hold case IDs that meet the criteria
        Set < ID > caseIds = new Set < ID > ();
        for (Case c: newCaseList) {
            // Check if the case owner has changed to the risk engineering queue
            if (c.OwnerId == riskEngineeringQueue[0].Id && oldCaseMap.get(c.Id).OwnerId != riskEngineeringQueue[0].Id)
            {
                caseIds.add(c.Id);
            }
        }
        
        // Get the specific CaseTeamRole by name
        List < CaseTeamRole > role = DAL_Utility.getCaseTeamRoleByName('N2G Internal Cases Read Only');
        // Get CaseTeamMember records for the cases identified
        List < CaseTeamMember > teamMembers = DAL_Utility.getCaseTeamMemberByCaseIds(caseIds); 
        caseTeamList.addAll(teamMembers);
        
        // Update the TeamRoleId for the CaseTeamMember records
        if (caseTeamList != null && role != null) {
            for (CaseTeamMember caseteam: caseTeamList) {
                caseteam.TeamRoleId = role[0].Id;
            }
        }
        // Update CaseTeamMember records
        update caseTeamList;
    }
    
    // Method to send email notifications for new cases
    public static void SendEmailForNewCase(List<Case> newCaseList, Map<ID, Case> oldCaseMap) {
        // Get email templates for notifications
        EmailTemplate et = DAL_EmailTemplate.getEmailTemplateByName('New N2G Internal Case Email Notification');
        EmailTemplate et1= DAL_EmailTemplate.getEmailTemplateByName('RE Queue Notification Email2Case');
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('N2G Internal Cases').getRecordTypeId();
        List<User> queueUser = DAL_User.getUsersOfREQueue();
        List<String> emailAddresses = new List<String>();
        if (caseRecordTypeId != null) {
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SingleEmailMessage> emailList1 = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail;
            Messaging.SingleEmailMessage mail1;
            Set<Id> ownerIds = new Set<Id>();
            Set<Id> accountIds = new Set<Id>();
            
            // Collect OwnerId and AccountId values from the newCaseList
            for (Case newCase : newCaseList) {
                if (newCase.RecordTypeId == caseRecordTypeId && !String.isEmpty(newCase.Subject)) {
                    ownerIds.add(newCase.OwnerId);
                    accountIds.add(newCase.AccountId);
                    
                }
            }
            List < Account > accountList = DAL_Account.getAccountListByUniquieIds(accountIds);
            Map < Id, String > clientMap = new Map < Id, String > ();
            for (Account a: accountList) {
                clientMap.put(a.Id, a.Name);
            }
            
            // Query User records and Account records
            Map<Id, User> userMap = new Map<Id, User>(DAL_User.getUsersByOwnerId(ownerIds));
            Map<Id, Account> accountMap = new Map<Id, Account>(DAL_Account.getAccountListByUniquieIds(accountIds));
            for (Case newCase : newCaseList) {
                System.debug('Orgin:::1'+newCase.Origin);
                if (newCase.RecordTypeId == caseRecordTypeId && !String.isEmpty(newCase.Subject) && newCase.Origin==null){
                    User u = userMap.get(newCase.OwnerId);
                    Account acc = accountMap.get(newCase.AccountId);
                    if (u != null && acc != null) {
                        // Prepare email notification for non-email originated cases
                        OrgWideEmailAddress[] owea = DAL_Utility.getOrgWideEmailAddress();
                        Map<String, Object> emailMap = new Map<String, Object>();
                        String s = String.valueOf(newCase.CreatedDate);
                        Datetime datetimeValue = Datetime.valueOf(s);
                        String dateString = datetimeValue.format('MM/dd/yyyy');
                        String orgDomain = URL.getOrgDomainUrl().getHost();
                        emailMap.put('Subject', newCase.Subject);
                        emailMap.put('OwnerName', u.Name);
                        emailMap.put('CreatedDate', dateString);
                        emailMap.put('ClientName', acc.Name);
                        emailMap.put('CaseLink', 'https://' + orgDomain + '/' + newCase.Id);
                        mail = new Messaging.SingleEmailMessage();
                        if (u.Email != null) {
                            mail.setToAddresses(new List<String>{u.Email});
                        }
                        if ( owea.size() > 0 ) {
                            mail.setOrgWideEmailAddressId(owea.get(0).Id); 
                        }
                        mail.setSubject(newCase.Subject);
                        if (et.HtmlValue != null) {
                            mail.setHtmlBody(replaceDynamicContent(emailMap, et.HtmlValue));
                        }
                        emailList.add(mail);
                    }
                }
                else if(newCase.RecordTypeId == caseRecordTypeId && !String.isEmpty(newCase.Subject) && newCase.Origin=='Email'){
                    // Prepare email notification for email originated cases
                    String clientName = '';
                    if (clientMap.containsKey(newCase.AccountId)) {
                        clientName = clientMap.get(newCase.AccountId);
                    }
                    Map<String, Object> emailMap1 = new Map<String, Object>();
                    String orgDomain = URL.getOrgDomainUrl().getHost();
                    String subject;
                    if(clientName=='')
                    {
                        subject = 'Risk Engineering Request' + ' | ' + newCase.Subject;
                    }
                    else
                    {
                        subject = 'Risk Engineering Request' + ' | ' + clientName +  ' | ' + newCase.Subject;
                    }
                    emailMap1.put('CaseLink', 'https://' + orgDomain + '/' + newCase.Id);
                    emailMap1.put('EmailID',newCase.SuppliedEmail);
                    if(newCase.Description!=null){
                        emailMap1.put('CaseDescription', newCase.Description);
                    }else{
                        emailMap1.put('CaseDescription','');
                    }
                    OrgWideEmailAddress[] owea = DAL_Utility.getOrgWideEmailAddress();
                    mail1 = new Messaging.SingleEmailMessage();
                    for (User u : queueUser) {
                        if (u.Email != null) {
                            emailAddresses.add(u.Email);
                        }
                    }
                    if ( owea.size() > 0 ) {
                        mail1.setOrgWideEmailAddressId(owea.get(0).Id); 
                    }
                    if (!emailAddresses.isEmpty()) {
                        mail1.setToAddresses(emailAddresses);
                        
                    }
                    if (et1.HtmlValue != null) {
                        mail1.setHtmlBody(replaceDynamicContent(emailMap1, et1.HtmlValue));
                        mail1.setSubject(subject);
                    }
                    emailList1.add(mail1);
                }
                
            }
            if (!emailList.isEmpty()) {
                Messaging.sendEmail(emailList);
            }
            if (!emailList1.isEmpty()) {
                Messaging.sendEmail(emailList1);
            }
        }
    }
    
    // Method to assign cases to specific queues based on criteria
    public static void assignCasesToQueuess(List<Case> newCaseList, Map<ID, Case> oldCaseMap) {
        
        Id parentCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('N2G Internal Cases').getRecordTypeId();
        Id bpqQueueID;
        Id reQueueID;
        
        // Get the groups for BPO Priority Rating Queue and Risk Engineering Queue
        List<Group> groupRecords = DAL_Group.getGroupRecordsByName('BPO - Priority Rating Queue');
        List<Group> groupRecords1 = DAL_Group.getGroupRecordsByName('Risk Engineering Queue');
        if (!groupRecords.isEmpty()) {
            bpqQueueID = groupRecords[0].Id;
        } 
        if (!groupRecords1.isEmpty()) {
            reQueueID = groupRecords1[0].Id;
        }     
        
        // Assign cases to the appropriate queues based on status and other criteria
        if (parentCaseRecordTypeId != null && bpqQueueID != null) {
            List<Case> casesToUpdate = new List<Case>();
            for (Case newCase : newCaseList) {
                if (newCase.RecordTypeId == parentCaseRecordTypeId &&
                    newCase.Topic__c == 'Risk Engineering' &&
                    newCase.Status == 'Assigned to BPO') {
                        newCase.OwnerId = bpqQueueID;
                    }
                else if (newCase.RecordTypeId == parentCaseRecordTypeId &&
                         newCase.Topic__c == 'Risk Engineering' &&
                         (newCase.Status == 'Internal RE' || newCase.Status == 'Closed')) {
                             newCase.OwnerId = reQueueID;
                             
                         }
                else if (newCase.RecordTypeId == parentCaseRecordTypeId &&
                         newCase.Topic__c == 'Risk Engineering' &&
                         (newCase.Status == 'New')) {
                             newCase.OwnerId =newCase.CreatedById ;
                         }
            }
        }
    }
    
    public static void SendEmailForQueueMembers(List<Case> newCaseList, Map<ID, Case> oldCaseMap) {
        // Fetch email templates for different email notifications
        EmailTemplate et = DAL_EmailTemplate.getEmailTemplateByName('Email Template Send Mail To RE team');
        EmailTemplate et2 = DAL_EmailTemplate.getEmailTemplateByName('RE Case Completed Email Notification');
        EmailTemplate et3 = DAL_EmailTemplate.getEmailTemplateByName('Case status changed then send email case owner');
        
        // Fetch record types for cases
        List<RecordType> rt = DAL_Utility.getRecordTypeByName('N2G Internal Cases'); 
        List<RecordType> rt1 = DAL_Utility.getRecordTypeByName('Child Case'); 
        
        // Fetch cases from the database by ID list
        List <Case> mCaseList = DAL_Case.getCaseRecordsByIdList(newCaseList);
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('N2G Internal Cases').getRecordTypeId();
        
        // Fetch users of the RE queue
        List<User> queueUser = DAL_User.getUsersOfREQueue();
        
        // Map to store new cases with their IDs as keys
        Map<String,Case> newCaseMap = New Map<String,Case>();
        for(Case c: mCaseList){
            newCaseMap.put(c.Id, c);
        }
        
        // List to store email addresses
        List<String> emailAddresses = new List<String>();
        
        // Fetch RE queue ID
        String REQId = DAL_Group.getREQueueId();
        {
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail;
            // Loop through new cases to handle email sending logic
            for (Case newCase : newCaseList) {
                // Send email notifications for each case in the email list
                if (!emailList.isEmpty()) {
                    Messaging.sendEmail(emailList);
                    
                }
                
            }
        }
        
        // If case record type is valid, proceed with further processing
        if (caseRecordTypeId != null) {
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail;
            Set<Id> ownerIds = new Set<Id>();
            Set<Id> accountIds = new Set<Id>();
            Set<Id> createdByIds = new Set<Id>();
            
            // Collect OwnerId, AccountId, and CreatedById from new cases
            for (Case newCase : newCaseList) {
                if (newCase.RecordTypeId == caseRecordTypeId) {
                    ownerIds.add(newCase.OwnerId );
                    accountIds.add(newCase.AccountId);
                    createdByIds.add(newCase.CreatedById);
                }
            }
            
            // Fetch relevant records from the database
            Map<Id, Group> ownerMap = new Map<Id, Group>(DAL_Group.getGroupByOwnerId(ownerIds));
            Map<Id, User> createdByMap = new Map<Id, User>(DAL_User.getUsersByOwnerId(createdByIds));
            Map<Id, Account> accountMap = new Map<Id, Account>(DAL_Account.getAccountListByUniquieIds(accountIds));
            
            // Loop through new cases to prepare email notifications
            for (Case newCase : newCaseList) {
                if(newCase.ownerId==REQId){
                    User createdByUser = createdByMap.get(newCase.CreatedById );
                    Account acc = accountMap.get(newCase.AccountId);
                    Group ownerData = ownerMap.get(newCase.OwnerId);
                    
                    // If the case status is not closed, and it belongs to the RE queue, prepare email content
                    if (newCase.Status!='Closed' && newCase.RecordTypeId == caseRecordTypeId && newCase.Origin==null && ownerData.Name=='Risk Engineering Queue' && oldCaseMap.get(newCase.Id).OwnerId!=ownerData.Id){
                        Map<String, Object> emailMap = new Map<String, Object>();
                        OrgWideEmailAddress[] owea = DAL_Utility.getOrgWideEmailAddress(); 
                        if (createdByUser != null && acc != null) {
                            String orgDomain = URL.getOrgDomainUrl().getHost();
                            emailMap.put('AccountName', acc.name);
                            emailMap.put('CreatedByName', createdByUser.name );
                            emailMap.put('Topic', newCase.Topic__c);
                            if(newCase.Reason_for_Request__c!=null){
                                emailMap.put('ReasonForRequest', newCase.Reason_for_Request__c);
                            }else{
                                emailMap.put('ReasonForRequest','');
                            }
                            if(newCase.Survey_Type__c!=null){
                                emailMap.put('SurveyType', newCase.Survey_Type__c);
                            }else{
                                emailMap.put('SurveyType', '');
                            }
                            if(newCase.Quote__c!=null){
                                emailMap.put('Quote', newCase.Quote__c);
                            }else{
                                emailMap.put('Quote', '');
                            }
                            if(newCase.Visit_Type__c!=null){
                                emailMap.put('VisitType', newCase.Visit_Type__c);
                            }else{
                                emailMap.put('VisitType', '');
                            }
                            emailMap.put('RushRequest', newCase.Rush_request__c);
                            emailMap.put('CaseLink', 'https://' + orgDomain + '/' + newCase.Id);
                            mail = new Messaging.SingleEmailMessage();
                            for (User u : queueUser) {
                                if (u.Email != null) {
                                    emailAddresses.add(u.Email);
                                }
                            }
                            if (!emailAddresses.isEmpty()) {
                                mail.setToAddresses(emailAddresses);
                                
                            }
                            if ( owea.size() > 0 ) {
                                mail.setOrgWideEmailAddressId(owea.get(0).Id); 
                            }
                            mail.setSubject('Risk Engineering Request | '+acc.name + (newCase.Visit_Type__c!=null?(' | '+newCase.Visit_Type__c):''));
                            if (et.HtmlValue != null) {
                                mail.setHtmlBody(replaceDynamicContent(emailMap, et.HtmlValue));
                            }
                            emailList.add(mail);
                        }
                    }
                    
                }
                
                // If the case is closed, send a completion notification
                if (newCase.Status=='Closed' && newCase.RecordTypeId == caseRecordTypeId && newCase.Topic__c=='Risk Engineering'){
                    Map<String, Object> emailMap = new Map<String, Object>();
                    OrgWideEmailAddress[] owea = DAL_Utility.getOrgWideEmailAddress();
                    String orgDomain = URL.getOrgDomainUrl().getHost();
                    emailMap.put('CaseLink', 'https://' + orgDomain + '/' + newCase.Id);
                    mail = new Messaging.SingleEmailMessage();
                    for (User u : queueUser) {
                        if (u.Email != null) {
                            emailAddresses.add(u.Email);
                        }
                    }
                    if ( owea.size() > 0 ) {
                        mail.setOrgWideEmailAddressId(owea.get(0).Id); 
                    }
                    if (!emailAddresses.isEmpty()) {
                        mail.setToAddresses(emailAddresses);
                    }
                    mail.setSubject('BPO Risk Engineering Request Complete For '+newCase.CaseNumber);
                    if (et2.HtmlValue != null) {
                        mail.setHtmlBody(replaceDynamicContent(emailMap, et2.HtmlValue));
                    }
                    emailList.add(mail);
                }
                
                // If the case status changes to 'New', notify the case owner
                if ((oldCaseMap.containsKey(newCase.Id) && oldCaseMap.get(newCase.Id).Status != 'New' && newCase.RecordTypeId == caseRecordTypeId && newCase.Topic__c=='Risk Engineering')&& (newCase.Status == 'New' && newCase.RecordTypeId == caseRecordTypeId && newCase.Topic__c=='Risk Engineering')){
                    Map<String, Object> emailMap = new Map<String, Object>();
                    User createdByUser = DAL_User.getCreatedByUser(newCase.CreatedById);
                    String orgDomain = URL.getOrgDomainUrl().getHost();
                    emailMap.put('CaseLink', 'https://' + orgDomain + '/' + newCase.Id);
                    emailMap.put('Subject', newCase.Subject);
                    emailMap.put('CaseOwner', createdByUser.Name);
                    mail = new Messaging.SingleEmailMessage();
                    for (User user : queueUser) {
                        if (user.Email != null) {
                            emailAddresses.add(user.Email);
                        }
                        
                    }
                    if (createdByUser.Email != null) {
                        mail.setToAddresses(new List<String>{createdByUser.Email});
                    }
                    mail.setSubject('Your Risk Engineering Request ' + newCase.Subject);
                    if (et3.HtmlValue != null) {
                        mail.setHtmlBody(replaceDynamicContent(emailMap, et3.HtmlValue));
                    }
                    emailList.add(mail);
                    
                } 
            }
            if (!emailList.isEmpty()) {
                Messaging.sendEmail(emailList);
                
            }
        }
    }
    
    // Method to throw an exception if the edit permissions are not valid
    public static void throwEditException(List<Case> newCaseList, Map<Id,Case> oldCaseMap) {
        
        Set<Id> caseIds = new Set<Id>();
        for (Case updatedCase : newCaseList) {
            caseIds.add(updatedCase.Id);
        }
        Map<Id, Case> caseMap = new Map<Id, Case>(newCaseList);
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('N2G Internal Cases').getRecordTypeId();  
        Set<Id> riskEngineeringGroupUserIds = new Set<Id>();
        Set<Id> bpoqueueGroupUserIds = new Set<Id>();
        
        // Fetch group members of Risk Engineering Queue and BPO Priority Rating Queue
        List<GroupMember> riskEngineeringGroupMembers = DAL_Utility.getGroupMemberByDevName('Risk_Engineering_Queue'); 
        List<GroupMember> bpoPriorityRatingQueueMemebrs= DAL_Utility.getGroupMemberByDevName('Priority_Rating_Queue');                 
        
        for (GroupMember member : riskEngineeringGroupMembers) {
            riskEngineeringGroupUserIds.add(member.UserOrGroupId);
        }
        for (GroupMember member : bpoPriorityRatingQueueMemebrs) {
            bpoqueueGroupUserIds.add(member.UserOrGroupId);
        } 
        String n2gAdminID=Label.N2G_AdminID;
        if (n2gAdminID != null) {
            riskEngineeringGroupUserIds.add(n2gAdminID);
        }
        List<String> allowedFields = new List<String>{'status','vlocity_ins__indicatorimagename__c','vlocity_ins__statusimagename__c','case_closed_reasons__c'};
            Map<String,Schema.SObjectField> caseFieldsMap = ((SObject)Type.forName('Schema','Case').newInstance()).getSObjectType().getDescribe().fields.getMap();
        boolean thisiserror = false;
        
        // Check for permission errors in case updates
        for (Case caseObj : caseMap.values()) {
            Case oldRecord = oldCaseMap.get(caseObj.Id);        
            if (oldRecord.Status != 'New' && caseObj.Topic__c=='Risk Engineering' && caseObj.RecordTypeId==caseRecordTypeId) {
                Boolean isOwner = caseObj.OwnerId == UserInfo.getUserId();
                Boolean isREteamMember = isUserInREteam(caseObj.TeamMembers, UserInfo.getUserId());
                Boolean isUserInRiskEngineeringGroup = riskEngineeringGroupUserIds.contains(UserInfo.getUserId());
                Boolean isUserInBPOQueueGroup = bpoqueueGroupUserIds.contains(UserInfo.getUserId());
                
                // Check if user has valid edit permissions
                if (!(isOwner || isREteamMember || isUserInRiskEngineeringGroup)) {
                    if(oldRecord.get('Status') == 'Assigned to BPO')
                    {
                        if(isUserInBPOQueueGroup)
                        {
                            thisiserror = false;
                            for (String field : caseFieldsMap.keyset()) {
                                if (caseObj.get(field) != oldRecord.get(field) && !allowedFields.contains(field)) {
                                    thisiserror = true;
                                }
                            }  
                        }
                        else
                        {
                            thisiserror = true;
                        }
                    }
                    else
                    {
                        thisiserror = true;
                    }
                }
                
            }
            
        }
        
        // Add error message if permissions are invalid
        for (Case caseObj : newCaseList) {
            if (thisiserror ){
                caseObj.addError('Edit permission can only be granted to the Owner, REteam members, or users in the Risk Engineering group.');
            }
        }
    }
    
    // Helper method to check if a user is in the RE team
    public static Boolean isUserInREteam(List<CaseTeamMember> teamMembers, Id userId) {
        Set<Id> memberIds = new Set<Id>();
        for (CaseTeamMember member : teamMembers) {
            memberIds.add(member.MemberId);
        }
        return memberIds.contains(userId);
    }
    
    // Method to replace dynamic content in email templates
    public static string replaceDynamicContent(Map<String,Object> inputMap,String textToReplace){
        
        Pattern pattrn = Pattern.compile('\\{\\{[iI][fF]\\([a-zA-Z0-9\', .\\-]*\\)\\}\\}');
        Matcher matcher = pattrn.matcher(textToReplace);
        while(matcher.find()) {
            String conditionalVariable=matcher.group(0).replaceAll('\\{\\{[iI][fF]\\(','').replaceAll('\\)\\}\\}','');
            List<String> ConditionList=conditionalVariable.split(',\''); 
            String dynamicData='';
            if(ConditionList.size()>2){
                if(inputMap.get(ConditionList[0])!=null && Boolean.valueOf(inputMap.get(ConditionList[0]))){
                    dynamicData=ConditionList[1];
                }else{
                    dynamicData=ConditionList[2];
                }
            }
            if(dynamicData.length()>1 && dynamicData.substring(dynamicData.length()-1)=='\''){
                dynamicData=dynamicData.substring(0,dynamicData.length()-1);  
            }else{
                dynamicData='';
            }
            textToReplace=textToReplace.replaceAll('\\{\\{[iI][fF]\\('+conditionalVariable+'\\)\\}\\}', dynamicData);
            
        }        
        pattrn = Pattern.compile('\\{\\{[a-zA-Z0-9]*\\}\\}');
        matcher = pattrn.matcher(textToReplace);
        while(matcher.find()) {
            String variableName=matcher.group(0).replaceAll('\\{\\{','').replaceAll('\\}\\}','');
            if(string.valueOf(inputMap.get(variableName))!=null){
                // to remove $ issues for reason for request N2G-702
                String finalText=(string.valueOf(inputMap.get(variableName)).replaceAll('\\$','\\\\\\$'));
                textToReplace=textToReplace.replaceAll('\\{\\{'+variableName+'\\}\\}',finalText );
            }
        }        
        return textToReplace;
    }
    
    public static void updateCaseRequestingOffice(List < Case > newCaseList, Map < ID, Case > oldCaseMap) {
        // Set to store Contact IDs for lookup
        Set < Id > contactIds = new Set < Id > ();
        // Map to store mapping of Contact ID to Account ID
        Map < String, Id > contactIdWiseAccountId = new Map < String, Id > ();
        // Get the Record Type ID for 'Fronting Inbox'
        Id frontingInboxRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.Fronting_Inbox_Record_Type_Dev_Name).getRecordTypeId();
        
        // Loop through new cases to identify relevant contacts
        for (Case caseRec: newCaseList) {
            // Check if the case is of the 'Fronting Inbox' record type and is either a new insert or a contact update
            if (caseRec.RecordTypeId == frontingInboxRecTypeId &&
                (Trigger.isInsert || (Trigger.isUpdate && caseRec.ContactId != oldCaseMap.get(caseRec.Id).ContactId))) {
                    if (String.isNotBlank(caseRec.ContactId)) {
                        // Add Contact ID to set for lookup
                        contactIds.add(caseRec.ContactId);
                    } else {
                        // Clear the Requesting Office if Contact ID is blank
                        caseRec.Requesting_Office__c = null;
                    }
                }
        }
        
        // If there are contact IDs to process
        if (!contactIds.isEmpty()) {
            // Fetch Contact records by IDs
            List < Contact > conList = DAL_Contact.getContactByIdSet(contactIds);
            if (!conList.isEmpty()) {
                // Populate the map with Contact ID to Account ID
                for (Contact con: conList) {
                    contactIdWiseAccountId.put(con.Id, con.AccountId);
                }
                
                // Update the Requesting Office field in cases
                if (!contactIdWiseAccountId.isEmpty()) {
                    for (Case caseRec: newCaseList) {
                        if (caseRec.RecordTypeId == frontingInboxRecTypeId &&
                            (Trigger.isInsert || (Trigger.isUpdate && caseRec.ContactId != oldCaseMap.get(caseRec.Id).ContactId))) {
                                if (String.isNotBlank(caseRec.ContactId) && contactIdWiseAccountId.containsKey(caseRec.ContactId)) {
                                    caseRec.Requesting_Office__c = contactIdWiseAccountId.get(caseRec.ContactId);
                                }
                            }
                    }
                }
            }
        }
    }
    
    public static void updateCaseClientFromOpportunity(List < Case > newCaseList, Map < ID, Case > oldCaseMap) {
        // Set to store Opportunity IDs for lookup
        Set < Id > oppIds = new Set < Id > ();
        // Map to store mapping of Opportunity ID to Account ID
        Map < String, Id > oppIdWiseAccountId = new Map < String, Id > ();
        // Get the Record Type ID for 'Fronting Inbox'
        Id frontingInboxRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.Fronting_Inbox_Record_Type_Dev_Name).getRecordTypeId();
        
        // Loop through new cases to identify relevant opportunities
        for (Case caseRec: newCaseList) {
            // Check if the case is of the 'Fronting Inbox' record type and is either a new insert or an opportunity update
            if (caseRec.RecordTypeId == frontingInboxRecTypeId &&
                (Trigger.isInsert || (Trigger.isUpdate && caseRec.Opportunity__c != oldCaseMap.get(caseRec.Id).Opportunity__c))) {
                    if (String.isNotBlank(caseRec.Opportunity__c)) {
                        // Add Opportunity ID to set for lookup
                        oppIds.add(caseRec.Opportunity__c);
                    } else {
                        // Clear the Client field if Opportunity ID is blank
                        caseRec.Client__c = null;
                    }
                }
        }
        
        // If there are opportunity IDs to process
        if (!oppIds.isEmpty()) {
            // Fetch Opportunity records by IDs
            List < Opportunity > oppList = DAL_Opportunity.getAllOpportunityById(oppIds);
            if (!oppList.isEmpty()) {
                // Populate the map with Opportunity ID to Account ID
                for (Opportunity opp: oppList) {
                    oppIdWiseAccountId.put(opp.Id, opp.AccountId);
                }
                
                // Update the Client field in cases
                if (!oppIdWiseAccountId.isEmpty()) {
                    for (Case caseRec: newCaseList) {
                        if (caseRec.RecordTypeId == frontingInboxRecTypeId &&
                            (Trigger.isInsert || (Trigger.isUpdate && caseRec.Opportunity__c != oldCaseMap.get(caseRec.Id).Opportunity__c))) {
                                if (String.isNotBlank(caseRec.Opportunity__c) && oppIdWiseAccountId.containsKey(caseRec.Opportunity__c)) {
                                    caseRec.Client__c = oppIdWiseAccountId.get(caseRec.Opportunity__c);
                                }
                            }
                    }
                }
            }
        }
    }
    
    public static void setDueDateBaseOnPrority(List<Case> CaseList, Map<ID, Case> oldCaseMap){
        // Fetch the list of priority-wise business days from custom metadata
        List<Priority_Wise_Business_Days_For_Case__mdt> PriorityWiseBusinessDaysList = DAL_Utility.getPriorityWiseBusinessDaysList();
        
        // Map to store priority-wise business days
        Map<String, Decimal> PriorityWiseBusinessDaysMap = new Map<String, Decimal>();
        List<Case> UpdatedCaseList = new List<Case>();
        for(Priority_Wise_Business_Days_For_Case__mdt PriorityWiseBusinessDays : PriorityWiseBusinessDaysList){
            PriorityWiseBusinessDaysMap.put(PriorityWiseBusinessDays.DeveloperName, PriorityWiseBusinessDays.Business_Days__c);
        }
        System.debug('PriorityWiseBusinessDaysMap '+PriorityWiseBusinessDaysMap);
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IT Help Desk').getRecordTypeId();
        for(Case CaseRec : CaseList){
            if (CaseRec.RecordTypeId == caseRecordTypeId && Trigger.isInsert) {
                if (CaseRec.Priority == 'Low') {
                    CaseRec.Due_Date__c = DueDateBaseOnPriority(DateTime.newInstance(Date.today(), Time.newInstance(12, 0, 0, 0)), (Integer)PriorityWiseBusinessDaysMap.get(CaseRec.Priority));
                }
            }
            
            if (CaseRec.RecordTypeId == caseRecordTypeId && (Trigger.isUpdate && CaseRec.Priority != oldCaseMap.get(CaseRec.Id).Priority)){
                CaseRec.Due_Date__c = DueDateBaseOnPriority(CaseRec.LastModifiedDate, (Integer)PriorityWiseBusinessDaysMap.get(CaseRec.Priority)); 
            }
        }
        
    }
    
    public static Date DueDateBaseOnPriority(DateTime createdDates, Integer BusinessDaysBaseOnPriority) {
        // Get the business hours settings
        BusinessHours bh = DAL_Utility.getBusinessHours();
        
        // Initialize variables
        DateTime createdDate = createdDates;
        Integer BusinessDays = BusinessDaysBaseOnPriority;
        System.debug('BusinessDays '+BusinessDays);
        
        // Calculate the due date based on business days
        DateTime dueDate = BusinessHours.add(bh.Id, createdDate, BusinessDays * 24 * 60 * 60 * 1000);
        System.debug('dueDate '+dueDate);
        
        // Adjust due date to exclude holidays and non-business hours
        while (!BusinessHours.isWithin(bh.Id, dueDate)) {
            dueDate = dueDate.addDays(1);
        }
        //Date formatedDueDate = Date.valueOf(dueDate.format('yyyy-MM-dd'));
        return Date.valueOf(dueDate.format('yyyy-MM-dd'));
    }
    
    // Method for updating the Requester’s Department for IT Help Desk cases
    public static void userBasedDepartmentOnReqDept(List < Case > newCaseList, Map < ID, Case > oldCaseMap){
        // Get the Record Type ID for 'IT Help Desk'
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IT Help Desk').getRecordTypeId();
        
        // List to store supplied emails from new cases
        List<String> userEmail = new List<String>();
        
        // Map to store user email to department mapping
        Map<String,String> mapUserWiseDept = new Map<String,String>();
        
        // Loop through new cases to collect emails
        for(Case caseRecord : newCaseList){
            system.debug('caseRecord #@'+caseRecord);
            // Check if the case is a new insert, has a supplied email, and is of the 'IT Help Desk' record type
            if(Trigger.isInsert && !String.isBlank(caseRecord.SuppliedEmail) && caseRecord.RecordTypeId == caseRecordTypeId){
                userEmail.add(caseRecord.SuppliedEmail);
            }
        }
        
        // If there are emails to process
        if(!userEmail.isEmpty()){
            // Fetch users by email and populate the map with user email to department mapping
            for(User usr : DAL_User.getUsersByName(userEmail)){
                mapUserWiseDept.put(usr.Email,usr.Department);
            }
        }
        system.debug('mapUserWiseDept '+mapUserWiseDept);
        // Loop through new cases to update the Requester's Department field
        for(Case caseRecord : newCaseList){
            if(mapUserWiseDept.containsKey(caseRecord.SuppliedEmail)){
                caseRecord.Requester_s_Department__c = mapUserWiseDept.get(caseRecord.SuppliedEmail);
                
            }
        }
        
    }
    
}