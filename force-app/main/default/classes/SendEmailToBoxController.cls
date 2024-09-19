public class SendEmailToBoxController {
    @AuraEnabled
    public static List<EmailMessage> getRelatedEmailMessages(Id caseId) {
       	List<Case> listCase=[SELECT ID,Opportunity__c, AccountId,Topic__c,RecordType.Name FROM Case Where Id=:CaseId];
         //Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('N2G Internal Cases').getRecordTypeId();
       
        if(listCase.size()>0){
           
            if(listCase[0].Topic__c=='Risk Engineering' && listCase[0].RecordType.Name=='N2G Internal Cases')
             {
                 if(listCase[0].AccountId==null)
                 {
                     throw new AuraHandledException('Please link Account to the case before sending email to box !');
                 }
             }
            else
            {
             if(listCase[0].Opportunity__c==null){
               throw new AuraHandledException('Please link Opportunity to the case before sending email to box !');

            }   
            }
        }
        return [SELECT Id, ParentId, Subject, FromAddress, ToAddress,MessageDate,  isSync__c FROM EmailMessage WHERE ParentId = :caseId AND isSync__c = false Order By MessageDate desc];
    } 
    @AuraEnabled
    public static String getRelatedEmailMessagesWithBox(Id caseId) {
        Map<String,Object> returnMap=new Map<string,Object>();
        returnMap.put('defaultBox','');
        List<Case> listCase=[SELECT ID,Opportunity__c,Box_Folder_Name__c,AccountId, RecordType.Name, Topic__c FROM Case Where Id=:CaseId];
      //   Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('N2G Internal Cases').getRecordTypeId();
       
        if(listCase.size()>0){
            returnMap.put('defaultBox',listCase[0].Box_Folder_Name__c);
            
            if(listCase[0].Topic__c=='Risk Engineering' && listCase[0].RecordType.Name=='N2G Internal Cases')
            {
                if(listCase[0].AccountId==null)
                {
                    throw new AuraHandledException('Please link Account to the case before sending email to box !');
                }else{
                    returnMap.put('isForAccount',true);
                    returnMap.put('defaultBox','Risk Engineering');
                }
            }
            else
                {
                if(listCase[0].Opportunity__c==null){
                    throw new AuraHandledException('Please link Opportunity to the case before sending email to box !');
                    
                }
            }
            
            
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
    public static void sendEmailToBox(List<Id> emailIds,Id caseId,String boxFolderName) {
        System.debug('emailIds'+emailIds);
        List<Case> listCase=[SELECT ID,Opportunity__c,AccountId,Topic__c, RecordType.Name  FROM Case Where Id=:CaseId];
        if(listCase.size()>0){
            listCase[0].Box_Folder_Name__c=boxFolderName;
            update listCase[0];
            List<Email_To_Case__e> inkEvents = new List<Email_To_Case__e>();
            List<EmailMessage> emailMessages = [SELECT Id, isSync__c,parentId,activityId FROM EmailMessage WHERE Id IN :emailIds];
            for (EmailMessage email : emailMessages) {
                email.isSync__c = true;
                if(listCase[0].AccountId!=null && listCase[0].Topic__c=='Risk Engineering' && listCase[0].RecordType.Name=='N2G Internal Cases'){
                    inkEvents.add(new Email_To_Case__e(CaseId__c=email.Id,  
                                               AccountId__c=listCase[0].AccountId));
                }else{
                    inkEvents.add(new Email_To_Case__e(CaseId__c=email.Id,  
                                               OpportunityId__c=listCase[0].Opportunity__c));
                }
                
                
            }
            
           // Call method to publish events
            List<Database.SaveResult> results = EventBus.publish(inkEvents);
            update emailMessages;
            
        }
    }
}