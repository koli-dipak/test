public class PlatformEventController {
   
    @AuraEnabled
    public static List<EmailMessage> getRelatedEmailMessages(Id caseId) {
       	List<Case> listCase=[SELECT ID,Opportunity__c, AccountId,Topic__c FROM Case Where Id=:CaseId];
        if(listCase.size()>0){
            if(listCase[0].Topic__c!='Risk Engineering'){
            if(listCase[0].Opportunity__c==null){
               throw new AuraHandledException('Please link Opportunity to the case before sending email to box !');

            }}
            if(listCase[0].Topic__c=='Risk Engineering')
             {
                 if(listCase[0].AccountId==null)
                 {
                     throw new AuraHandledException('Please link Account to the case before sending email to box !');
                 }
             }
        }
        return [SELECT Id, ParentId, Subject, FromAddress, ToAddress,MessageDate,  isSync__c FROM EmailMessage WHERE ParentId = :caseId AND isSync__c = false Order By MessageDate desc];
    }
    @AuraEnabled
    public static String getRelatedEmailMessagesWithBox(String caseId) {
        Map<String,Object> returnMap=new Map<string,Object>();
        returnMap.put('defaultBox','');
       	List<Case> listCase=[SELECT ID,Opportunity__c,Box_Folder_Name__c,AccountId, Topic__c FROM Case Where Id=:CaseId];
        if(listCase.size()>0){
            if(listCase[0].Topic__c!='Risk Engineering'){
                if(listCase[0].Opportunity__c==null){
                throw new AuraHandledException('Please link Opportunity to the case before sending email to box !');

                }
            }
             if(listCase[0].Topic__c=='Risk Engineering')
             {
                 if(listCase[0].AccountId==null)
                 {
                     throw new AuraHandledException('Please link Account to the case before sending email to box !');
                 }
             }
            
            returnMap.put('defaultBox',listCase[0].Box_Folder_Name__c);
        }
        
        returnMap.put('BoxFolderList',picklistValues('Case','Box_Folder_Name__c'));
        returnMap.put('EmailMessage', [SELECT Id, ParentId, Subject, FromAddress, ToAddress,MessageDate,  isSync__c FROM EmailMessage WHERE ParentId = :caseId AND isSync__c = false Order By MessageDate desc]);
        return JSON.serialize(returnMap);
    }
    public static Map<String, String> picklistValues(String objectName, String fieldName) {
        Map<String, String> values = new Map<String, String>();
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectName});
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    values.put(entry.getValue(), entry.getLabel());
                }
            }
        }
        
        return values;
    }
    @AuraEnabled
    public static void createPlatformEvent(String recordId) {
        List<Case> listCase=[SELECT ID,Opportunity__c,AccountId,Topic__c FROM Case Where Id=:recordId];
if(listCase.size()>0){
    List<Email_To_Case__e> inkEvents = new List<Email_To_Case__e>();
    if(listCase[0].AccountId!=null && listCase[0].Topic__c=='Risk Engineering'){
        inkEvents.add(new Email_To_Case__e(CaseId__c=listCase[0].Id,  
                                           AccountId__c=listCase[0].AccountId));
    }
    
    // Call method to publish events
    List<Database.SaveResult> results = EventBus.publish(inkEvents);
  
}
    }
}