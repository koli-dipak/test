public class nextYearAndRenewal {
    @AuraEnabled
    public static String processNextYearAndRenewal(Id opportunityId) {
        //List<LOB_Management__c> lobsRecords = [SELECT Id, LOB_Effective_Date__c, LOB_Stage__c, Opportunity_Related__c, Opportunity_Related__r.Prospect_Opportunity__c FROM LOB_Management__c where Opportunity_Related__c =:opportunityId];
        //Opportunity oppRec = [SELECT Id, Name, CloseDate, StageName, Cloned__c FROM Opportunity WHERE Id = :opportunityId];
         Opportunity oppRec = DAL_Opportunity.getOpportunityById(opportunityId);
        Date closedDate = oppRec.CloseDate != null ? oppRec.CloseDate.addYears(1): Date.today().addYears(1);
        
        List<LOB_Management__c> lobsRecords = DAL_LOB_Management.getLOBRecordsByOppId(opportunityId);
        List<LOB_Management__c> boundLobIds = new List<LOB_Management__c>();
        for(LOB_Management__c records : lobsRecords){
            if(records.LOB_Stage__c == 'Bound'){
                boundLobIds.add(records);
            }
        }
        System.debug('boundLobIds ::: '+boundLobIds);
        String newOppId;
        if(boundLobIds.size()>0){
            newOppId = CloneLobAndOpp.cloneLobAndOpps(boundLobIds);
        	System.debug('@@newOppId:: '+newOppId);
        }
        	
        
        Set<String> setSTRChildObjectsToBeConverted = new Set<String>();
        setSTRChildObjectsToBeConverted.add('LOB_Management__c');
        
        Map<String, Object> newRecordFieldsValue = new Map<String, Object>();
        newRecordFieldsValue.put('Name', oppRec.Name);
        newRecordFieldsValue.put('CloseDate', closedDate);
        newRecordFieldsValue.put('Quote_due_date__c', null);
        newRecordFieldsValue.put('Box_Folder_Name__c', null);
        newRecordFieldsValue.put('Box_Folder_Id__c', null);
        newRecordFieldsValue.put('StageName', 'Unqualified');
        newRecordFieldsValue.put('Applied_Epic_key__c', null);
        newRecordFieldsValue.put('Cloned__c', true);
        newRecordFieldsValue.put('Renewed_Opportunity__c', opportunityId);  
        
        Map<String, Object> childDataMaping = new Map<String, Object>();
        childDataMaping.put('Unqualified', 'Unqualified');
        childDataMaping.put('Interest', 'Interest');
        childDataMaping.put('Submission', 'Interest');
        childDataMaping.put('Declined', 'Interest');
        childDataMaping.put('Quote', 'Interest');
        childDataMaping.put('Lost', 'Interest');
        childDataMaping.put('Bound', 'Interest');
        childDataMaping.put('Not Submitted', 'Interest');
        childDataMaping.put('Not Interested', 'Interest');
        
        Map<String, Object> cloneChildNewFieldValues = new Map<String, Object>();
        cloneChildNewFieldValues.put('Loss_Reason__c', null);
        cloneChildNewFieldValues.put('Cloned__c', true); 
        
        
        //HLPR_CloneWithChildRecords cloneProductObj = new HLPR_CloneWithChildRecords(newOppId, setSTRChildObjectsToBeConverted); 
        HLPR_CloneWithChildRecords cloneProductObj = new HLPR_CloneWithChildRecords(opportunityId, setSTRChildObjectsToBeConverted);        
        if(newOppId != null){
            cloneProductObj.cloneOnlyChildren(null, 'TH_OPPORTUNITY', childDataMaping, cloneChildNewFieldValues,null,newOppId);
            return newOppId;
        }else{ 
            return cloneProductObj.cloneWithChildren(newRecordFieldsValue, 'TH_OPPORTUNITY', childDataMaping, cloneChildNewFieldValues);
        }
    }
}