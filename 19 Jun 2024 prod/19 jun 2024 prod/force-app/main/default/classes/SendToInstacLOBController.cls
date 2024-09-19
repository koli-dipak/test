public class SendToInstacLOBController {
	@AuraEnabled
    public static string sendToInstec(String recordId){
        String ErrorMessage='';
        List<LOB_Management__c> LOBList=DAL_LOB_Management.getLOBManagementByIds(recordId);
        if(LOBList.size()==0){
            ErrorMessage='Line of Business Record Not Found';
        }else{
            if(LOBList[0].Opportunity_Related__r.Account.BillingState!=null && LOBList[0].Opportunity_Related__r.Account.BillingState.length()>2 ){
                ErrorMessage=Label.sendToLOBInvalidStateError;
            }else if(LOBList[0].Opportunity_Related__r.Box_Folder_Id__c==null){
                ErrorMessage=Label.OpportunityBoxInvalidError; 
            }else{
                List<Instec__e> instecList = new List<Instec__e>();
                
                Instec__e box = new Instec__e();
                box.LOBID__c = LOBList[0].Id;
                instecList.add(box);
                
                LOB_Management__c lob = new LOB_Management__c();
                lob.id = LOBList[0].Id;
                lob.SendtoInstecForRating__c  = true;
                
                BaseTriggerHandler.bypass('TH_LOBMANAGEMENT');
                update lob;
                BaseTriggerHandler.clearBypass('TH_LOBMANAGEMEN');
                System.debug('instecList: ' + instecList);
                
                if(instecList.size()>0){
                    EventBus.publish(instecList);
                }
            }
        }
        return ErrorMessage;
    }
}