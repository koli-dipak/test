public class CTRL_CloneOpportunityWithQuote{
  @auraEnabled
  public static String cloneWithProducts(String recordId){
    Opportunity oppRec = [SELECT Id, Name, CloseDate, StageName, Cloned__c FROM Opportunity WHERE Id = :recordId];
    //Date closedDate = oppRec.CloseDate != null? oppRec.CloseDate.addDays(365): Date.today().addDays(365);
	Date closedDate = oppRec.CloseDate != null ? oppRec.CloseDate.addYears(1): Date.today().addYears(1);
      
    Set<String> setSTRChildObjectsToBeConverted = new Set<String>();
    setSTRChildObjectsToBeConverted.add('LOB_Management__c');

    // Handle leap year
   /* if (Date.isLeapYear(closedDate.year()) && closedDate.month() == 2 && closedDate.day() == 29) {
        closedDate = Date.newInstance(closedDate.year(), 2, 28);
    }*/
      
    System.debug(closedDate);
    Map<String, Object> newRecordFieldsValue = new Map<String, Object>();
    newRecordFieldsValue.put('Name', oppRec.Name);
    newRecordFieldsValue.put('CloseDate', closedDate);
    newRecordFieldsValue.put('Quote_due_date__c', null);
    newRecordFieldsValue.put('Box_Folder_Name__c', null);
    newRecordFieldsValue.put('Box_Folder_Id__c', null);
    newRecordFieldsValue.put('StageName', 'Unqualified');
    newRecordFieldsValue.put('Applied_Epic_key__c', null);
    newRecordFieldsValue.put('Cloned__c', true);
    newRecordFieldsValue.put('Renewed_Opportunity__c', recordId);  

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

    //Map<String, Map<String, Map<String, Object>>> objectWiseDataMapping = new Map<String, Map<String, Map<String, Object>>>();
    //childDataMaping.put('LOB_Management__c', new Map<String, Map<String,Object>>{'LOB_Stage__c' => childDataMaping});


    HLPR_CloneWithChildRecords cloneProductObj = new HLPR_CloneWithChildRecords(recordId, setSTRChildObjectsToBeConverted);
      
    return cloneProductObj.cloneWithChildren(newRecordFieldsValue, 'TH_OPPORTUNITY', childDataMaping, cloneChildNewFieldValues);
    
  }
}