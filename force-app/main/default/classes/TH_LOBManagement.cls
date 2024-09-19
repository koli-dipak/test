public class TH_LOBManagement extends BaseTriggerHandler{
    private List<LOB_Management__c> newLOBManagementList;
    private List<LOB_Management__c> oldLOBManagementList;
    private Map<ID, LOB_Management__c> newLOBManagementMap;
    private Map<ID, LOB_Management__c> oldLOBManagementMap;
    
    public TH_LOBManagement()
    {
        oldLOBManagementList = (List<LOB_Management__c>)Trigger.old;
        newLOBManagementList = (List<LOB_Management__c>)Trigger.new;
        newLOBManagementMap = (Map<Id, LOB_Management__c>)Trigger.newMap;
        oldLOBManagementMap = (Map<Id, LOB_Management__c>)Trigger.oldMap;
    }
    protected override void BeforeInsert(){
        if(Trigger_PAD.canRun('TH_LOBManagementBeforeInsert')){
            processIncrementGerRaterProgramID(newLOBManagementList);
            proccesRecordBeforeInsertLOBManagement(newLOBManagementList,oldLOBManagementMap);
        }
    }
    protected override void BeforeUpdate(){
        if(Trigger_PAD.canRun('TH_LOBManagementBeforeUpdate')){
            proccesRecordBeforeLOBManagement(newLOBManagementList,oldLOBManagementMap);
        }
    }
    protected override void AfterInsert() { 
        if(Trigger_PAD.canRun('TH_LOBManagementAfterInsert')){
            proccesRecordAfterLOBManagement(newLOBManagementList,oldLOBManagementMap);
        }
    } 
    protected override void AfterUpdate() { 
        if(Trigger_PAD.canRun('TH_LOBManagementAfterUpdate')){
            proccesRecordAfterLOBManagement(newLOBManagementList,oldLOBManagementMap);
        }
    }
    protected Override void beforeDelete() {
        if(Trigger_PAD.canRun('TH_LOBManagementBeforeDelete')){
            //proccesRecordBeforeDeleteLOBManagement(oldLOBManagementList);
        }
    }
    protected Override void afterDelete() {
        
        if(Trigger_PAD.canRun('TH_LOBManagementAfterDelete')){
            
            proccesRecordAfterLOBManagement(oldLOBManagementList,null);
        }
    }
    
      public static void processIncrementGerRaterProgramID(List<LOB_Management__c> newLOBManagementList) {
        Integer maxProgramID = 0;
        List<LOB_Management__c> existingLOBs = DAL_LOB_Management.incGerRaterProgramId();
        if (!existingLOBs.isEmpty()) {
            system.debug('existingLOBs' + existingLOBs);
            String lastProgramID = existingLOBs[0].GerRater_Program_ID__c;
            system.debug('getn   @@@@     lastProgramID' + lastProgramID);
            if (lastProgramID != null && lastProgramID.length() > 0 && lastProgramID.isNumeric()) {
                maxProgramID = Integer.valueOf(lastProgramID);
                system.debug('   in getting max prog   maxProgramID' + maxProgramID);
            }
        }
        system.debug('beforemaxProgramID' + maxProgramID);
        if (maxProgramID < 10000) {
            maxProgramID = 9999;
        }
        
        // Increment the value by one for each new record
        Integer nextProgramID = maxProgramID + 1; // Incrementing by one
        system.debug('after incere' + nextProgramID);
        // Iterate over the new records and set the GerRater_Program_ID__c field
        for(LOB_Management__c lob : newLOBManagementList) {
            lob.GerRater_Program_ID__c = String.valueOf(nextProgramID++);
        }
    }
    public static void proccesRecordBeforeInsertLOBManagement(List<LOB_Management__c> newLOBManagementList,
                                                        Map<Id, LOB_Management__c> oldLOBManagementMap){
        Set<Id> oppIds = new Set<Id>();
         List<Probability_Default_Percentage__mdt> defaultPercent = DAL_LOB_Management.getAllProbabilityDefaultPerMdt();
         Map<string,Decimal> percentMap = new Map<string,Decimal>(); 
           for(Probability_Default_Percentage__mdt lobpercent : defaultPercent){
             percentMap.put(lobpercent.MasterLabel,lobpercent.Percentage__c);  
           }                                                 
        for(LOB_Management__c lob : newLOBManagementList){ 
            if(percentMap.containsKey(lob.LOB_Stage__c)){
                lob.Probability__c = percentMap.get(lob.LOB_Stage__c);
            }
            if(oldLOBManagementMap == null 
               || (oldLOBManagementMap !=null 
                   && oldLOBManagementMap.get(lob.Id).RecordTypeId != lob.RecordTypeId))
            {
                oppIds.add(lob.Opportunity_Related__c);
            }
            if(oldLOBManagementMap!=null
               && oldLOBManagementMap.get(lob.Id).LOB_Stage__c != lob.LOB_Stage__c
               && oldLOBManagementMap.get(lob.Id).LOB_Stage__c == 'Declined' )
            {
                lob.Declined_Reason_Code__c = null;
            }
           //N2g-54 rollup Forecasting 
            if(oldLOBManagementMap == null 
               || (oldLOBManagementMap!=null && (oldLOBManagementMap.get(lob.Id).Estimated_LOB_Premium__c != lob.Estimated_LOB_Premium__c || oldLOBManagementMap.get(lob.Id).Probability__c != lob.Probability__c)))
            {
                lob.Forecasting_Premium__c = (lob.Estimated_LOB_Premium__c == null || lob.Probability__c == null) ?0:(lob.Estimated_LOB_Premium__c * (lob.Probability__c/100));
            }
            
            //N2G-1108
            if(lob.LOB_Stage__c != null && lob.LOB_Effective_Date__c != null && lob.LOB_Stage__c.equalsIgnoreCase('Bound')){
                lob.Lob_Expiry_Date__c = lob.LOB_Effective_Date__c.addYears(1);
            }
            
        }
                                                            
            /*Map<Id,Opportunity> relatedOppMap = DAL_Opportunity.getAllOpportunityMapById(oppIds);
            for(LOB_Management__c lob: newLOBManagementList)
            {
			    if( null != relatedOppMap.get(lob.Opportunity_Related__c)) 
                {
                    //lob.LOB_Stage__c  = relatedOppMap.get(lob.Opportunity_Related__c).StageName ;
                    lob.Submission_Source__c = relatedOppMap.get(lob.Opportunity_Related__c).leadsource; 
                    lob.Type__c = relatedOppMap.get(lob.Opportunity_Related__c).Type ;
                }
        }*/
        
        List<LOB_Management__c> allLOBManagementList = DAL_LOB_Management.getAllLOBManagementByOpp(oppIds);
        
        Map<Id,Set<String> > opportunityLOBRecordTypeMap = new Map<Id,Set<String> >();
        for(LOB_Management__c lob : allLOBManagementList){
            if(!opportunityLOBRecordTypeMap.containsKey(lob.Opportunity_Related__c)){
                opportunityLOBRecordTypeMap.put(lob.Opportunity_Related__c,new Set<String>());
            }
            opportunityLOBRecordTypeMap.get(lob.Opportunity_Related__c).add(lob.RecordTypeId);
        }

        for(LOB_Management__c lob : newLOBManagementList){
            if(oldLOBManagementMap==null
               || (oldLOBManagementMap!=null 
                   && oldLOBManagementMap.get(lob.Id).RecordTypeId!=lob.RecordTypeId))
            {
                
                if(!opportunityLOBRecordTypeMap.containsKey(lob.Opportunity_Related__c)){
                    opportunityLOBRecordTypeMap.put(lob.Opportunity_Related__c,new Set<String>());
                }
                if(opportunityLOBRecordTypeMap.get(lob.Opportunity_Related__c).contains(lob.RecordTypeId)){
                    lob.addError('LOB Management record is already exist with same record type');
                }
                else{
                    opportunityLOBRecordTypeMap.get(lob.Opportunity_Related__c).add(lob.RecordTypeId);
                }
            }
        }
                                                            
    }
    
    
    
    
    public static void proccesRecordBeforeLOBManagement(List<LOB_Management__c> newLOBManagementList,
                                                        Map<Id, LOB_Management__c> oldLOBManagementMap){

        Set<Id> oppIds = new Set<Id>();
        List<Probability_Default_Percentage__mdt> defPercent = DAL_LOB_Management.getAllProbabilityDefaultPerMdt();        
         Map<string,Decimal> PerMap = new Map<string,Decimal>(); 
           for(Probability_Default_Percentage__mdt lobpercent : defPercent){
             PerMap.put(lobpercent.MasterLabel,lobpercent.Percentage__c);  
           }  
           
           List<Lob_Stage_Picklist__mdt > mdtLobStage = DAL_LOB_Management.getLobStageMdt();        
           Map<string,String> PerMap2 = new Map<string,String>(); 
             for(Lob_Stage_Picklist__mdt  lobStage : mdtLobStage){
                PerMap2.put(lobStage.Label,lobStage.DeveloperName);  
             }     
                                                          
        for(LOB_Management__c lob : newLOBManagementList){
            if(oldLOBManagementMap.get(lob.Id).LOB_Stage__c != lob.LOB_Stage__c){
                if(PerMap.containsKey(lob.LOB_Stage__c)){
                lob.Probability__c = PerMap.get(lob.LOB_Stage__c);
            }
            }
           
            if(oldLOBManagementMap == null 
               || (oldLOBManagementMap !=null 
                   && oldLOBManagementMap.get(lob.Id).RecordTypeId != lob.RecordTypeId))
            {
                oppIds.add(lob.Opportunity_Related__c);
            }
            if(oldLOBManagementMap!=null
               && oldLOBManagementMap.get(lob.Id).LOB_Stage__c != lob.LOB_Stage__c
               && oldLOBManagementMap.get(lob.Id).LOB_Stage__c == 'Declined' )
            {
                lob.Declined_Reason_Code__c = null;
            }
            if(oldLOBManagementMap!=null
               && oldLOBManagementMap.get(lob.Id).LOB_Stage__c != lob.LOB_Stage__c )
            {
                lob.Previous_LOB_Stage__c=oldLOBManagementMap.get(lob.Id).LOB_Stage__c;
            }
       		//N2g-54 rollup Forecasting 
           if(oldLOBManagementMap!=null
               && (oldLOBManagementMap.get(lob.Id).Estimated_LOB_Premium__c != lob.Estimated_LOB_Premium__c
               || oldLOBManagementMap.get(lob.Id).Probability__c != lob.Probability__c))
            {
                lob.Forecasting_Premium__c = (lob.Estimated_LOB_Premium__c == null || lob.Probability__c == null)?0:(lob.Estimated_LOB_Premium__c * (lob.Probability__c/100));
            }
            
            //N2G-1108
             if(oldLOBManagementMap!=null && oldLOBManagementMap.get(lob.Id).LOB_Stage__c != lob.LOB_Stage__c && lob.LOB_Stage__c.equalsIgnoreCase('Bound')){
                lob.Lob_Expiry_Date__c  = oldLOBManagementMap.get(lob.Id).LOB_Effective_Date__c.addYears(1);
            }
            if(oldLOBManagementMap!=null && oldLOBManagementMap.get(lob.Id).LOB_Effective_Date__c != lob.LOB_Effective_Date__c ){
                lob.Lob_Expiry_Date__c  = lob.LOB_Effective_Date__c.addYears(1);
            }
        }
        
        List<LOB_Management__c> allLOBManagementList = DAL_LOB_Management.getAllLOBManagementByOpp(oppIds);
        
        Map<Id,Set<String> > opportunityLOBRecordTypeMap = new Map<Id,Set<String> >();
        for(LOB_Management__c lob : allLOBManagementList){
            if(!opportunityLOBRecordTypeMap.containsKey(lob.Opportunity_Related__c)){
                opportunityLOBRecordTypeMap.put(lob.Opportunity_Related__c,new Set<String>());
            }
            opportunityLOBRecordTypeMap.get(lob.Opportunity_Related__c).add(lob.RecordTypeId);
        }

        for(LOB_Management__c lob : newLOBManagementList){
            if(oldLOBManagementMap==null
               || (oldLOBManagementMap!=null 
                   && oldLOBManagementMap.get(lob.Id).RecordTypeId!=lob.RecordTypeId))
            {
                
                if(!opportunityLOBRecordTypeMap.containsKey(lob.Opportunity_Related__c)){
                    opportunityLOBRecordTypeMap.put(lob.Opportunity_Related__c,new Set<String>());
                }
                if(opportunityLOBRecordTypeMap.get(lob.Opportunity_Related__c).contains(lob.RecordTypeId)){
                    lob.addError('LOB Management record is already exist with same record type');
                }
                else{
                    opportunityLOBRecordTypeMap.get(lob.Opportunity_Related__c).add(lob.RecordTypeId);
                }
            }
        }

        for(LOB_Management__c lob : newLOBManagementList){
            if(oldLOBManagementMap.get(lob.Id).LOB_Stage__c != lob.LOB_Stage__c){
                if(lob.LOB_Stage__c == PerMap2.get('Lost') || lob.LOB_Stage__c == PerMap2.get('Declined')){
                    lob.Loss_Reason__c = lob.Loss_Reason__c;
                    lob.Lost_Reason__c = lob.Lost_Reason__c;
                }
                else {
                    lob.Loss_Reason__c = '';
                    lob.Lost_Reason__c = '';
                }
            }
        }
    }
    
    public static void proccesRecordAfterLOBManagement(List<LOB_Management__c> newLOBManagementList,Map<Id, LOB_Management__c> oldLOBManagementMap){
        //-------------------- N2G-333 Start Here --------------------- 
        List<LOB_Management__c> lobToConsider = new List<LOB_Management__c>();
        
        List<User> queueUser = [SELECT Id, Name, Email
                                FROM User
                                WHERE Id IN (SELECT UserOrGroupId
                                             FROM GroupMember
                                             WHERE Group.Name = 'Risk Engineering Queue')];
        
        List<String> toAddress = new List<String>();
        for (User u : queueUser) {
            if (u.Email != null) {
                toAddress.add(u.Email);
            }
        }
        
        for(LOB_Management__c lobManagement : newLOBManagementList) {
            
            if(lobManagement.Case__c != null && (lobManagement.LOB_Stage__c == 'Not Submitted' || lobManagement.LOB_Stage__c == 'Declined' || lobManagement.LOB_Stage__c == 'Lost')){
               
                Case mCase = [select Id, CaseNumber, RecordType.Name, RecordTypeId, Owner.Name, Owner.Email, Subject,Status from Case where id = :lobManagement.Case__c LIMIT 1];
                if(mCase.RecordType.Name == 'N2G Internal Cases' && mCase.Status != 'Closed'){
                   
                    String orgDomain = URL.getOrgDomainUrl().getHost();
                    String caseLink = 'https://' + orgDomain + '/' + mCase.Id;
                    System.debug('@@@Case Link ::: ' + caseLink);
                    String subjectLine = 'Risk Engineering Case | Closure of Related LoBs for Case: ' + mCase.Subject;
                    System.debug('@@@Email Sbject ::: ' + subjectLine);
                    String emailBody = '<p>Dear Risk Engineering Team,</p><p></p><p>This automated notification is to inform you that the following case ' + mCase.CaseNumber + ', linked to opportunity ' + caseLink + ', has experienced a change in the associated LoB stages. These stages are now marked as either \'Not Submitted,\' \'Declined,\' or \'Lost.\'</p><p>Kindly liaise with the Underwriting (UW) team to verify that the LoB stages have not been closed erroneously. If this is confirmed, you may proceed to close the risk engineering survey request, citing the closure reason as \'No longer required.\'</p><p></p><p>Best regards, Your Salesforce Reminder Assistant</p>';
                    
                    List<Messaging.SingleEmailMessage> mailList =  new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    OrgWideEmailAddress[] owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'donotreply@n2g.com' LIMIT 1];
                    mail.setSubject(subjectLine);
                    mail.setHtmlBody(emailBody);
                    
                    if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id); 
            }
                    
                    mailList.add(mail);
                    if (!toAddress.isEmpty()) {
                        mail.setToAddresses(toAddress);   
                    }
                    
                    // Send the email if the list is not empty
                    if (!toAddress.isEmpty()) {
                        System.debug('@@@Sending email...');
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);
                        if (results[0].success){
                            System.debug('@@@Email sent successfully.');
                        }
                        else {
                            System.debug('@@@The email failed to send: ' + results[0].errors[0].message);
                        }
                        
                    }
                    
                }
            }
        }
        //-------------------- N2G-333 Ends Here --------------------- 
        
        
        
        
        
        // Get list of opportunity ids to update stage
        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> opportunityTypeChangeIds = new Set<Id>();
        for(LOB_Management__c lobManagement : newLOBManagementList){
            if(lobManagement.LOB_Stage__c != null && (oldLOBManagementMap == null || (oldLOBManagementMap != null && lobManagement.LOB_Stage__c != oldLOBManagementMap.get(lobManagement.Id).LOB_Stage__c))){
                opportunityIds.add(lobManagement.Opportunity_Related__c);
            }
            if(lobManagement.Type__c != null && (oldLOBManagementMap == null || (oldLOBManagementMap != null && lobManagement.Type__c != oldLOBManagementMap.get(lobManagement.Id).Type__c))){
                opportunityIds.add(lobManagement.Opportunity_Related__c);
            }
            
        }
        system.debug('@@'+opportunityIds);
        // get list of LOB related to opportunity
        List<LOB_Management__c> allLOBManagementList = DAL_LOB_Management.getAllLOBManagementByOpp(opportunityIds);
        Map<Id,Set<String> > opportunityLOBRecordTypeMap = new Map<Id,Set<String> >();
        Map<Id,List<LOB_Management__c> > oppWiseLOBAfterSubmissionMap = new Map<Id,List<LOB_Management__c> >();
        Set<String> renewalTypeOpportunity = new Set<String>();
        Map<Id,Set<String> > oppWiseExistingLOB = new Map<Id,Set<String> >();
        Map<Id, Integer> oppWiseTotallobs = new Map<Id, Integer>();
        Map<Id, Integer> oppWiseNotSubmittelobs = new Map<Id, Integer>();
        
        // Iterate over LOB and get opp wise list of lob
        for(LOB_Management__c lob : allLOBManagementList){
            if(!opportunityLOBRecordTypeMap.containsKey(lob.Opportunity_Related__c)){
                opportunityLOBRecordTypeMap.put(lob.Opportunity_Related__c,new Set<String>());
                oppWiseTotallobs.put(lob.Opportunity_Related__c, 0);
                oppWiseNotSubmittelobs.put(lob.Opportunity_Related__c, 0);
            }
            opportunityLOBRecordTypeMap.get(lob.Opportunity_Related__c).add(lob.RecordType.Name);
            oppWiseTotallobs.put(lob.Opportunity_Related__c, oppWiseTotallobs.get(lob.Opportunity_Related__c) + 1);
            
            if(lob.LOB_Stage__c != 'Not Interested' && lob.LOB_Stage__c != 'Unqualified'){
                 if(!oppWiseLOBAfterSubmissionMap.containsKey(lob.Opportunity_Related__c)){
                    oppWiseLOBAfterSubmissionMap.put(lob.Opportunity_Related__c,new List<LOB_Management__c>());
                }
                oppWiseLOBAfterSubmissionMap.get(lob.Opportunity_Related__c).add(lob); 
            }
            
            if(!oppWiseExistingLOB.containsKey(lob.Opportunity_Related__c) && lob.Opportunity_Related__r.Line_of_Business__c!=null){
                 oppWiseExistingLOB.put(lob.Opportunity_Related__c,new set<String>(lob.Opportunity_Related__r.Line_of_Business__c.split(';')));
            }
           
            if(lob.Type__c=='Renewal'){
                renewalTypeOpportunity.add(lob.Opportunity_Related__c);
            }
        }
        system.debug('@@renewalTypeOpportunity :: '+JSON.serialize(renewalTypeOpportunity));
        
        Set<String> skipOppStage = new Set<String>{'Declined', 'Lost', 'Bound','Not Submitted'};
        
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();//(DAL_Opportunity.getAllOpportunityById(opportunityIds));
        Opportunity opp;
        // Opp wise Highest stage update from the lob stage value
        // And also updates the loss and lost reason with lob loss reason values. Updated at 01-05-2022.
        for(LOB_Management__c lobManagement : allLOBManagementList){
            if(lobManagement.LOB_Stage__c != null ){
                
               // if(!skipOppStage.contains(lobManagement.LOB_Stage__c)){
                    if(!opportunityMap.containsKey(lobManagement.Opportunity_Related__c)){
                        opportunityMap.put(lobManagement.Opportunity_Related__c,new Opportunity(Id=lobManagement.Opportunity_Related__c,Name=lobManagement.Opportunity_Related__r.Name));
                    }   
                    opp=opportunityMap.get(lobManagement.Opportunity_Related__c);
                    if(lobManagement.LOB_Stage__c == 'Quote'){
                        opp.StageName = 'Quote';
                        opp.Loss_Reason__c = '';
                        opp.Lost_Reason__c = '';
                    }else if(lobManagement.LOB_Stage__c == 'Submission' && opp.StageName != 'Submission'  && opp.StageName  != 'Quote'){
                        opp.StageName = 'Submission';
                        opp.Loss_Reason__c = '';
                        opp.Lost_Reason__c = '';
                    }
                    else if(lobManagement.LOB_Stage__c == 'Interest' && opp.StageName != 'Interest' && opp.StageName != 'Submission'  && opp.StageName  != 'Quote'){
                        opp.StageName = 'Interest';
                        opp.Loss_Reason__c = '';
                        opp.Lost_Reason__c = '';
                    }
                    else if(lobManagement.LOB_Stage__c == 'Unqualified' && opp.StageName != 'Unqualified'  && opp.StageName != 'Interest' && opp.StageName != 'Submission'  && opp.StageName  != 'Quote'){
                        opp.StageName = 'Unqualified';
                        opp.Loss_Reason__c = '';
                        opp.Lost_Reason__c = '';
                    }
                    else if(lobManagement.LOB_Stage__c == 'Lost' && opp.StageName != 'Lost' && opp.StageName != 'Unqualified'  && opp.StageName != 'Interest' && opp.StageName != 'Submission'  && opp.StageName  != 'Quote'){
                        opp.StageName = 'Lost';
                        opp.Loss_Reason__c = lobManagement.Loss_Reason__c;
                        opp.Lost_Reason__c = String.isNotBlank(lobManagement.Lost_Reason__c) ? lobManagement.Lost_Reason__c : '';
                    }
                    else if(lobManagement.LOB_Stage__c == 'Declined' && opp.StageName != 'Declined' && opp.StageName != 'Lost' && opp.StageName != 'Unqualified'  && opp.StageName != 'Interest' && opp.StageName != 'Submission'  && opp.StageName  != 'Quote'){
                        opp.StageName = 'Declined';
                        opp.Loss_Reason__c = lobManagement.Loss_Reason__c;
                        opp.Lost_Reason__c = String.isNotBlank(lobManagement.Lost_Reason__c) ? lobManagement.Lost_Reason__c : '';
                    }
                    else if(lobManagement.LOB_Stage__c == 'Not Submitted' && opp.StageName != 'Not Submitted' && opp.StageName != 'Declined' && opp.StageName != 'Lost' && opp.StageName != 'Unqualified'  && opp.StageName != 'Interest' && opp.StageName != 'Submission'  && opp.StageName  != 'Quote'){
                        opp.StageName = 'Not Submitted';
                        opp.Loss_Reason__c = lobManagement.Loss_Reason__c;
                        opp.Lost_Reason__c = String.isNotBlank(lobManagement.Lost_Reason__c) ? lobManagement.Lost_Reason__c : '';
                    }
                    else if(lobManagement.LOB_Stage__c == 'Not Interested' && opp.StageName != 'Not Interested' && opp.StageName != 'Not Submitted' && opp.StageName != 'Declined' && opp.StageName != 'Lost' && opp.StageName != 'Unqualified'  && opp.StageName != 'Interest' && opp.StageName != 'Submission'  && opp.StageName  != 'Quote'){
                        opp.StageName = 'Not Interested';
                        opp.Loss_Reason__c = lobManagement.Loss_Reason__c;
                        opp.Lost_Reason__c = String.isNotBlank(lobManagement.Lost_Reason__c) ? lobManagement.Lost_Reason__c : '';
                    }
                    
                    System.debug(lobManagement.LOB_Stage__c + ' :: ' + opp.StageName);
                    System.debug(lobManagement.Loss_Reason__c + ' :: ' + opp.Loss_Reason__c);
                    System.debug(lobManagement.Lost_Reason__c + ' :: ' + opp.Lost_Reason__c);
              //  }
            }
            if(lobManagement.Type__c!=null){
                if(!opportunityMap.containsKey(lobManagement.Opportunity_Related__c)){
                    opportunityMap.put(lobManagement.Opportunity_Related__c,new Opportunity(Id=lobManagement.Opportunity_Related__c,Name=lobManagement.Opportunity_Related__r.Name));
                }   
                opp=opportunityMap.get(lobManagement.Opportunity_Related__c);
                Opp.Type='New';
               	if(renewalTypeOpportunity.contains(lobManagement.Opportunity_Related__c)){
                    Opp.Type='Renewal';
                }
                String name = Datetime.newInstance(lobManagement.Opportunity_Related__r.CloseDate.year(), lobManagement.Opportunity_Related__r.CloseDate.month(),lobManagement.Opportunity_Related__r.CloseDate.day()).format('yyyy-MM-dd');
                //opp.Name = lobManagement.Opportunity_Related__r.Account.Name +' - '+ lobManagement.Opportunity_Related__r.Submission_Type__c +' - ' + opp.Type +' - Effective - '+name;
                String accName='';
                if(lobManagement.Opportunity_Related__r.Account.Name.length() >= 70)
                {
                    accName = lobManagement.Opportunity_Related__r.Account.Name.substring(0, 69);
                }
                else
                {
                    accName =lobManagement.Opportunity_Related__r.Account.Name;
                }
                
                opp.Name = accName +' - '+ lobManagement.Opportunity_Related__r.Submission_Type__c +' - ' + opp.Type +' - '+name;
  
            }
        }

        List<Product_category__mdt> allProductCategoryMdt = DAL_Opportunity.getAllProductCategoryMdt();
        System.debug('@@allProductCategoryMdt ::'+allProductCategoryMdt);
        
        Map<String,String> productCategoryMap = new Map<String,String>();
        for(Product_category__mdt pc : allProductCategoryMdt){
            if(!productCategoryMap.containsKey(pc.MasterLabel))
                productCategoryMap.put(pc.MasterLabel,pc.Category__c);
        }
        Set<String> mainCategorySet = new Set<String>{'Domestic', 'Foreign'};
        
        // update LOB field on Opportunity
        boolean updateflag=false;
        List<Opportunity> opportunityToUpdate = new List<Opportunity>();
        for(Id oppId : opportunityLOBRecordTypeMap.keySet()){
            updateflag=false;
            Opp=new Opportunity();
            Opp.Id=oppId;
            Set<String> oppWiseExistingLOBRecTypes = oppWiseExistingLOB.get(oppId);
            Set<String> oppWiseNewLOBRecTypes = opportunityLOBRecordTypeMap.get(oppId);
           // Null pointer handling should be done here which is missing 
            if(oppWiseExistingLOBRecTypes!=null && (!oppWiseExistingLOBRecTypes.containsAll(oppWiseNewLOBRecTypes) || oppWiseExistingLOBRecTypes.size() > oppWiseNewLOBRecTypes.size())){
                Opp.Line_of_Business__c=string.join(new list<String>(opportunityLOBRecordTypeMap.get(oppId)),';');
                    
                    Boolean domesticVal = false;
                    Boolean foreignVal = false;
                    if(oppWiseLOBAfterSubmissionMap.containsKey(oppId)){

                        for(LOB_Management__c lineOfBusiness : oppWiseLOBAfterSubmissionMap.get(oppId))
                        //for(String val :opp.Line_of_Business__c.split(';'))
                        {
                            String val=lineOfBusiness.RecordType.Name;
                            if(productCategoryMap.get(val) == 'Domestic'){
                                domesticVal = true;
                            }else if(productCategoryMap.get(val) == 'Foreign'){
                                foreignVal = true;
                            }
                        }
                        System.debug('@@domesticVal ::'+domesticVal);
                        System.debug('@@foreignVal ::'+foreignVal);
                        if(domesticVal && foreignVal){
                            opp.Submission_Type__c = 'Global';
                            System.debug('@@opp.Name ::'+opportunityMap.get(oppId).Name);
                            if(opportunityMap.get(oppId).Name.contains('Domestic')){
                                opp.Name = opportunityMap.get(oppId).Name.replace('Domestic','Global');
                            }else if(opportunityMap.get(oppId).Name.contains('Foreign')){
                                opp.Name = opportunityMap.get(oppId).Name.replace('Foreign','Global');
                            }
                        }else if(domesticVal && !foreignVal){
                            opp.Submission_Type__c = 'Domestic';
                        }else if(foreignVal && !domesticVal){
                            opp.Submission_Type__c = 'Foreign';
                        }
                    }
                updateflag=true;
            }
            if(opportunityMap.containsKey(oppId) && opportunityMap.get(oppId).Type!=null){
                Opp.Type=opportunityMap.get(oppId).Type;
                opp.Name=opportunityMap.get(oppId).Name;
               updateflag=true;
            } 
            if(opportunityMap.containsKey(oppId) && opportunityMap.get(oppId).StageName!=null){
                
                Opp.StageName=opportunityMap.get(oppId).StageName;
                // If Opp stage changes to Not Interested, Not Submitted, Lost Or Declined, It will update the reason also mapped with LOB, Updated at 01-05-2022.
                If(opportunityMap.get(oppId).Loss_Reason__c != null)
                    Opp.Loss_Reason__c=opportunityMap.get(oppId).Loss_Reason__c;
                If(opportunityMap.get(oppId).Lost_Reason__c != null)
                    Opp.Lost_Reason__c=opportunityMap.get(oppId).Lost_Reason__c;
                
                Boolean domesticVal = false;
                Boolean foreignVal = false;
                if(oppWiseLOBAfterSubmissionMap.containsKey(oppId)){
                    for(LOB_Management__c lineOfBusiness : oppWiseLOBAfterSubmissionMap.get(oppId))
                    //for(String val :opp.Line_of_Business__c.split(';'))
                    {
                        String val=lineOfBusiness.RecordType.Name;
                        if(productCategoryMap.get(val) == 'Domestic'){
                            domesticVal = true;
                        }else if(productCategoryMap.get(val) == 'Foreign'){
                            foreignVal = true;
                        }
                    }
                    System.debug('@@domesticVal ::'+domesticVal);
                    System.debug('@@foreignVal ::'+foreignVal);
                    if(domesticVal && foreignVal){
                        opp.Submission_Type__c = 'Global';
                        System.debug('@@opp.Name ::'+opportunityMap.get(oppId).Name);
                        if(opportunityMap.get(oppId).Name.contains('Domestic')){
                            opp.Name = opportunityMap.get(oppId).Name.replace('Domestic','Global');
                        }else if(opportunityMap.get(oppId).Name.contains('Foreign')){
                            opp.Name = opportunityMap.get(oppId).Name.replace('Foreign','Global');
                        }
                    }else if(domesticVal && !foreignVal){
                        opp.Submission_Type__c = 'Domestic';
                    }else if(foreignVal && !domesticVal){
                        opp.Submission_Type__c = 'Foreign';
                    }
                }
                updateflag=true;
            } 
            
            if(updateflag==true){
                system.debug('@@Opp:: '+Opp);
                opportunityToUpdate.add(Opp);
            }
        }
        
        if(opportunityToUpdate.size()>0){
            Trigger_PAD.deactivateTrigger('TH_OpportunityBeforeUpdate');
            Trigger_PAD.deactivateTrigger('TH_OpportunityAfterUpdate');
            update opportunityToUpdate;
            Trigger_PAD.activateTrigger('TH_OpportunityBeforeUpdate');
            Trigger_PAD.activateTrigger('TH_OpportunityAfterUpdate');
        }
    }
   
    public static void proccesRecordBeforeDeleteLOBManagement(List<LOB_Management__c> oldLOBManagementList){
        
       //String profileName = [select Name from profile where id = :UserInfo.getProfileId()].Name;
        
       // for(LOB_Management__c lob : oldLOBManagementList){
            //if(profileName != 'System Administrator'){
          //      lob.addError('You can\'t delete LOB Management');
            //}
       // }
    }
}