public class SendToInstec {
    
    public sObject obj { get; set; }
    
    //constructor to get the sObject record
    public SendToInstec(ApexPages.StandardController controller) {
        obj =  (sObject) controller.getRecord();
    }
    
     public PageReference sendToInstecLOB(){        
        List<Instec__e> instecList = new List<Instec__e>();
        
        Instec__e box = new Instec__e();
        box.LOBID__c = obj.Id;
        instecList.add(box);
        
         LOB_Management__c lob = new LOB_Management__c();
         lob.id = obj.Id;
         lob.SendtoInstecForRating__c  = true;
         
         BaseTriggerHandler.bypass('TH_LOBMANAGEMENT');
         update lob;
         BaseTriggerHandler.clearBypass('TH_LOBMANAGEMEN');
        System.debug('instecList: ' + instecList);
        
        if(instecList.size()>0){
            EventBus.publish(instecList);
        }
        
        PageReference pageRef = new PageReference('/'+obj.Id);
        pageRef.setRedirect(true);
        return pageRef; 
    }
}