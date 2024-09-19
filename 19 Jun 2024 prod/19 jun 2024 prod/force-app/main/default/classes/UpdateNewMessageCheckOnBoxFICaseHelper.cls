public class UpdateNewMessageCheckOnBoxFICaseHelper {
    @AuraEnabled
    public static Case getCaseRecord(String caseId){
        return [SELECT Id, New_Message__c FROM Case WHERE Id =:caseId];
    }
    
    @AuraEnabled
    public static String updateCaseRecord(String caseId){
        if(caseId != null){
            Case caseRec = new Case();
            caseRec.Id = caseId;
            caseRec.New_Message__c = false;
            Database.SaveResult result = Database.update(caseRec, false);
            if (result.isSuccess()) {
                return 'SUCCESS';
            }
            else {               
                for(Database.Error err : result.getErrors()) {
                    return 'ERROR: '+ err.getMessage();
                }
            }
        }
        return 'ERROR: Id is null';
    }
}