public class BoxCreation {
    
    public sObject obj { get; set; }
    
    //constructor to get the sObject record
    public BoxCreation(ApexPages.StandardController controller) {
        obj =  (sObject) controller.getRecord();
    }
    
    public PageReference createAccountBox(){
        Account accRec = DAL_Account.getAccountById(obj.Id); //[SELECT Id,Name FROM Account Where id = : obj.Id];
        System.debug('The Account record: ' + accRec);

        List<box__FRUP__c> FRUP = DAL_FRUP.getFRUPByRecordIdAndObjectName(obj.Id,'Account');
        if(FRUP.size() > 0){
            delete FRUP;
        }
        
        List<Box_Sync__e> boxList = new List<Box_Sync__e>();
        
        Box_Sync__e box = new Box_Sync__e();
        box.AccountId__c = accRec.Id;
        box.FolderName__c = accRec.Box_Folder_Name__c;
        box.Object_Name__c = 'Account';
        box.TagName__c = accRec.Name;
        boxList.add(box);
        
        if(boxList.size()>0){
            EventBus.publish(boxList);
        }
        
        PageReference pageRef = new PageReference('/'+accRec.Id);
        pageRef.setRedirect(true);
        return pageRef; //Returns to the sObject page
    }
    
    public PageReference createOpportunityBox(){
        Opportunity oppRec = DAL_Opportunity.getOpportunityById(obj.Id);
        //[SELECT Id, AccountId, Line_of_Business__c, CloseDate, External_Key__c
        //FROM Opportunity Where id = : obj.Id];
        
        System.debug('The Opportunity record: ' + oppRec);
        
        List<box__FRUP__c> FRUP = DAL_FRUP.getFRUPByRecordIdAndObjectName(obj.Id,'Opportunity');
        if(FRUP.size() > 0){
            delete FRUP;
        }
        
        List<Box_Sync__e> boxList = new List<Box_Sync__e>();
        
        Box_Sync__e box = new Box_Sync__e();
        box.AccountId__c = oppRec.AccountId;
        box.FolderName__c = oppRec.CloseDate.YEAR() +'-'+ oppRec.External_Key__c;
        box.Line_of_Business__c = oppRec.Line_of_Business__c;
        box.Object_Name__c = 'Opportunity';
        box.OpportunityId__c = oppRec.Id;
        box.TagName__c = oppRec.Name;
        boxList.add(box);
        
        if(boxList.size()>0){
            EventBus.publish(boxList);
        }
        
        PageReference pageRef = new PageReference('/'+oppRec.Id);
        pageRef.setRedirect(true);
        return pageRef; //Returns to the sObject page
    }
    
    public PageReference createLOBBox(){
        LOB_Management__c LOBRec = DAL_LOB_Management.getLOBManagementById(obj.Id);
        //  [SELECT Id, Opportunity_Related__r.Id, recordType.Name FROM LOB_Management__c Where id = : obj.Id];
        System.debug('The LOB Management record: ' + LOBRec);
        
        List<box__FRUP__c> FRUP = DAL_FRUP.getFRUPByRecordIdAndObjectName(obj.Id,'LOB Management');
        if(FRUP.size() > 0){
            delete FRUP;
        }
        
        List<Box_Sync__e> boxList = new List<Box_Sync__e>();
        
        Box_Sync__e box = new Box_Sync__e();
        box.FolderName__c = LOBRec.recordType.Name;
        box.Object_Name__c = 'LOB Management';
        box.OpportunityId__c = LOBRec.Opportunity_Related__r.Id;
        boxList.add(box);
        
        System.debug('boxList: ' + boxList);
        
        if(boxList.size()>0){
            EventBus.publish(boxList);
        }
        
        PageReference pageRef = new PageReference('/'+LOBRec.Id);
        pageRef.setRedirect(true);
        return pageRef; //Returns to the sObject page
    }
    
    public PageReference createClearanceBox(){
        Clearance__c clearanceRec = DAL_Clearance.getClearanceById(obj.Id);
        //  [SELECT Id, Opportunity__r.Id, recordType.Name, External_Key__c FROM Clearance__c Where id = : obj.Id];
        System.debug('The clearanceRec record: ' + clearanceRec);
        
        List<box__FRUP__c> FRUP = DAL_FRUP.getFRUPByRecordIdAndObjectName(obj.Id,'Clearance__c');
        if(FRUP.size() > 0){
            delete FRUP;
        }
        
        List<Box_Sync__e> boxList = new List<Box_Sync__e>();
        
        Box_Sync__e box = new Box_Sync__e();
        box.ClearanceId__c = clearanceRec.Id;
        box.OpportunityId__c = clearanceRec.Opportunity__r.Id;
        box.FolderName__c = clearanceRec.recordType.Name +'-'+ clearanceRec.External_Key__c;
        box.Object_Name__c = 'Carrier Clearance';
        box.TagName__c = clearanceRec.Name;
        boxList.add(box);
        
        if(boxList.size()>0){
            EventBus.publish(boxList);
        }
        PageReference pageRef = new PageReference('/'+clearanceRec.Id);
        pageRef.setRedirect(true);
        return pageRef; //Returns to the sObject page
    }
}