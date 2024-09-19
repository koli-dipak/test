public class DAL_Utility {
    public static EmailTemplate getEmailTemplateRecByDeveloperName(String emailTemplateDevName){
        return [SELECT Id, Body, HtmlValue, Subject, Name
                FROM EmailTemplate
                WHERE DeveloperName = :emailTemplateDevName LIMIT 1 ];
    }
    
    public static List<ContentDocumentLink> getContentDocumentLinkIds(List<String> BindingChecklistRecord){
        return [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId IN :BindingChecklistRecord];
    }
    
    public static List<ContentVersion> getContentVersionIds(List<ContentDocumentLink> linkList){
        Set<Id> contentDocumentIds = new Set<Id>();
        // Extract ContentDocumentId values from linkList
        for(ContentDocumentLink link : linkList) {
            contentDocumentIds.add(link.ContentDocumentId);
        }
        return [Select Id, FileType, Title, FileExtension, ContentDocumentId from ContentVersion where ContentDocumentId IN :contentDocumentIds];
    }
    
    public static List<Renewal_Configurable_Period__mdt> getListOfPeriod() {
        return [select DeveloperName, Period__c from Renewal_Configurable_Period__mdt];
    }
    
    @AuraEnabled
    public static List<Editable_Policy_No_On_Rating__mdt > getListOfEditablePolicyNo() {
        return [select Id, DeveloperName from Editable_Policy_No_On_Rating__mdt];
    }
    
    public static List<OrgWideEmailAddress> getOrgWideEmailAddress() {
        return [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'donotreply@n2g.com'];
    }
    
    public static List<RecordType> getRecordTypeByName(String rtName) {
        return [SELECT Id FROM RecordType WHERE Name =: rtName LIMIT 1];
    }
    
    public static List<GroupMember> getGroupMemberByDevName(String devName) {
        return [SELECT UserOrGroupId
                FROM GroupMember
                WHERE Group.DeveloperName =: devName];
    }
    
    public static List<Priority_Wise_Business_Days_For_Case__mdt> getPriorityWiseBusinessDaysList() {
        return [select DeveloperName, Business_Days__c from Priority_Wise_Business_Days_For_Case__mdt ];
    }
    
    public static BusinessHours getBusinessHours(){
        return [SELECT ID, Name FROM BusinessHours WHERE Name = 'Business Days According to Priority'];
    }
    
    public static List<CaseTeamRole> getCaseTeamRoleByName(String CaseTeamRoleName){
        return [SELECT Id, Name, AccessLevel, PreferencesVisibleInCSP, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp FROM CaseTeamRole WHERE Name =: CaseTeamRoleName];
    }
    
    public static List<CaseTeamMember> getCaseTeamMemberByCaseIds(Set<Id> caseIds){
        return [SELECT Id, ParentId, Parent.CaseNumber, MemberId, Member.Name, TeamTemplateMemberId, TeamRoleId, TeamRole.Name, TeamTemplateId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp FROM CaseTeamMember WHERE ParentId IN: caseIds];
    }
    
     public static Profile getProfileByName(String profileName){
        return [SELECT Id FROM Profile WHERE Name =: profileName LIMIT 1];
    }
    
    public static List<CustomNotificationType> getCustomNotificationByName(String developerName){
        return [
            SELECT Id, DeveloperName
            FROM CustomNotificationType
            WHERE DeveloperName = :developerName
        ];
    }
    
    public static List<OrgWideEmailAddress> getOrgWideEmailAddressByDisplayName(){
        return [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName =: System.Label.FI_Custom_Case_Auto_Response_Rule_Sender_Email_Address];
    }
    
    public static List<EmailTemplate> getEmailTemplateByDeveloperName(){
        return [SELECT Id,DeveloperName, Name, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName =:System.Label.FI_Custom_Case_Auto_Response_Rule_Email_Template_Name];
    }
    
}