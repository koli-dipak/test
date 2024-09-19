public class TH_PolicyForRiskEngineering  extends BaseTriggerHandler {
    private List<Case_and_InsurancePolicy__c> newCaseAndPolicyList;
    private List<Case_and_InsurancePolicy__c> oldCaseAndPolicyList;
    private Map<ID, Case_and_InsurancePolicy__c> newCaseAndPolicyMap;
    private Map<ID, Case_and_InsurancePolicy__c> oldCaseAndPolicyMap;
    
    public TH_PolicyForRiskEngineering()
    {
        oldCaseAndPolicyList = (List<Case_and_InsurancePolicy__c>)Trigger.old;
        newCaseAndPolicyList = (List<Case_and_InsurancePolicy__c>)Trigger.new;
        newCaseAndPolicyMap = (Map<Id, Case_and_InsurancePolicy__c>)Trigger.newMap;
        oldCaseAndPolicyMap = (Map<Id, Case_and_InsurancePolicy__c>)Trigger.oldMap;
    }
    
    protected override void beforeInsert() { 
        if(Trigger_PAD.canRun('TH_PolicyForRiskEngineeringBeforeInsert')){
            processRecordBefore(newCaseAndPolicyList, oldCaseAndPolicyMap);
        }
    } 
    
    public static void processRecordBefore(List<Case_and_InsurancePolicy__c> newCaseAndPolicyList, Map<Id, Case_and_InsurancePolicy__c> oldCaseAndPolicyMap){
        System.debug('@@newCaseAndPolicyList:::'+newCaseAndPolicyList);
        Set<Id> caseRecordIds = new Set<Id>();
        List<Case_and_InsurancePolicy__c> ExistingRecords = new List<Case_and_InsurancePolicy__c>();
        Map<Id, Set<Id>> ExistingCaseWisePolicyMap = new Map<Id, Set<Id>>();
        Map<Id, String> PolicyIdWisePolicyName = new Map<Id, String>();
        Map<Id, List<String>> caseIdWiseErrorNames = new Map<Id, List<String>>();
        Map<Id, List<Case_and_InsurancePolicy__c>> caseIdWiseErrorCasePolicyRecords = new Map<Id, List<Case_and_InsurancePolicy__c>>();
        
        for (Case_and_InsurancePolicy__c casePolicy : newCaseAndPolicyList) {
            caseRecordIds.add(casePolicy.Case__c);
        }
        
        if(!caseRecordIds.isEmpty()){
            ExistingRecords = DAL_PolicyForRiskEngineering.getCasePolicyRecordsByCaseIds(caseRecordIds);
        }
        
        if(!ExistingRecords.isEmpty()){
            for (Case_and_InsurancePolicy__c casePolicy : ExistingRecords) {
                if(!ExistingCaseWisePolicyMap.containsKey(casePolicy.Case__c))
                    ExistingCaseWisePolicyMap.put(casePolicy.Case__c, new Set<Id>());
                ExistingCaseWisePolicyMap.get(casePolicy.Case__c).add(casePolicy.Insurance_Policy__c);
                PolicyIdWisePolicyName.put(casePolicy.Insurance_Policy__c, casePolicy.Insurance_Policy__r.Name);
            }
        }
        
        if(!ExistingCaseWisePolicyMap.isEmpty()){
            for (Case_and_InsurancePolicy__c casePolicy : newCaseAndPolicyList) {
                if(ExistingCaseWisePolicyMap.containsKey(casePolicy.Case__c)){
                    for (Id brokerAccountId : ExistingCaseWisePolicyMap.get(casePolicy.Case__c)) {
                        if(casePolicy.Insurance_Policy__c == brokerAccountId){
                            if(!caseIdWiseErrorNames.containsKey(casePolicy.Case__c)){
                                caseIdWiseErrorNames.put(casePolicy.Case__c, new List<String>());
                            }
                            caseIdWiseErrorNames.get(casePolicy.Case__c).add(PolicyIdWisePolicyName.get(casePolicy.Insurance_Policy__c));
                            
                            if(!caseIdWiseErrorCasePolicyRecords.containsKey(casePolicy.Case__c)){
                                caseIdWiseErrorCasePolicyRecords.put(casePolicy.Case__c, new List<Case_and_InsurancePolicy__c>());
                            }
                            caseIdWiseErrorCasePolicyRecords.get(casePolicy.Case__c).add(casePolicy);
                        }
                    }
                }
            }
            system.debug('@@caseIdWiseErrorNames::'+caseIdWiseErrorNames);
            system.debug('@@caseIdWiseErrorCasePolicyRecords::'+caseIdWiseErrorCasePolicyRecords);
            if(!caseIdWiseErrorNames.isEmpty()){
                for(Id caseId : caseIdWiseErrorNames.keySet()){
                    for(Case_and_InsurancePolicy__c casePolicy : caseIdWiseErrorCasePolicyRecords.get(caseId)){
                        casePolicy.addError(System.Label.Junction_object_record_already_exists_erorr + String.join(caseIdWiseErrorNames.get(caseId), ';'));
                    }
                }
            }
        }
    }
}