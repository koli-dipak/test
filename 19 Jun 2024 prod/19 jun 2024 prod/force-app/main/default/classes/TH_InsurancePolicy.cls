public class TH_InsurancePolicy extends BaseTriggerHandler { 
    
    private List<InsurancePolicy> newInsurancePolicyList;
    private List<InsurancePolicy> oldInsurancePolicyList;
    private Map<ID, InsurancePolicy> newInsurancePolicyMap;
    private Map<ID, InsurancePolicy> oldInsurancePolicyMap;
    
    public TH_InsurancePolicy()
    {
        oldInsurancePolicyList = (List<InsurancePolicy>)Trigger.old;
        newInsurancePolicyList = (List<InsurancePolicy>)Trigger.new;
        newInsurancePolicyMap = (Map<Id, InsurancePolicy>)Trigger.newMap;
        oldInsurancePolicyMap = (Map<Id, InsurancePolicy>)Trigger.oldMap;
    }
    
    protected override void beforeInsert() { 
        if(Trigger_PAD.canRun('TH_InsurancePolicyBeforeInsert')){
            proccesRecordBeforeInsertInsurancePolicy(newInsurancePolicyList);
        }
    } 
    
    
    protected override void beforeUpdate()
    {
        if(Trigger_PAD.canRun('TH_InsurancePolicyBeforeUpdate'))
        {
            proccesRecordBeforeUpdate(newInsurancePolicyList,oldInsurancePolicyMap);
        }
    }
    protected override void afterUpdate()
    {
        if(Trigger_PAD.canRun('TH_InsurancePolicyafterUpdate'))
        {
            proccesRecordAfterUpdate(newInsurancePolicyList,oldInsurancePolicyMap);
        }
    }
    protected override void afterDelete()
    {
        if(Trigger_PAD.canRun('TH_InsurancePolicyAfterDelete'))
        {
            proccesRecordAfterDelete(oldInsurancePolicyList);
        }
    }
    // after insert logic 
    protected override void afterInsert()
    {
        if(Trigger_PAD.canRun('TH_InsurancePolicyAfterInsert'))
        {
            processRecordAfterInsert(newInsurancePolicyList);
        }
    }
    
    public static void proccesRecordBeforeInsertInsurancePolicy(List<InsurancePolicy> newInsurancePolicyList)
    {
       
    }
    
    public static void proccesRecordBeforeUpdate(List<InsurancePolicy > newInsurancePolicyList,Map<ID, InsurancePolicy> oldInsurancePolicyMap)
    {
        for(InsurancePolicy policy : newInsurancePolicyList){
            if(policy.Rollup_Premium__c!=oldInsurancePolicyMap.get(policy.Id).Rollup_Premium__c)
            {
                policy.PremiumAmount=policy.Rollup_Premium__c;
                
            }          
        }
       
    }
    public static void proccesRecordAfterUpdate(List<InsurancePolicy > newInsurancePolicyList,Map<ID, InsurancePolicy> oldInsurancePolicyMap)
    {
        List<String> listParentPolicyIds=new List<String>();
        Set<String> policyNumbersIds = new Set<String>();
        
        for(InsurancePolicy policy : newInsurancePolicyList){
            if(policy.PremiumAmount!=oldInsurancePolicyMap.get(policy.Id).PremiumAmount)
            {
                if(policy.ParentPolicyId!=null){
                    listParentPolicyIds.add(policy.ParentPolicyId);
                }
            }
            
            if((policy.StorageID__c != oldInsurancePolicyMap.get(policy.Id).StorageID__c) || (policy.ExpirationDate != oldInsurancePolicyMap.get(policy.Id).ExpirationDate)) {
                policyNumbersIds.add(policy.Name);
            }
        }
        CalculatePolicyPremium(listParentPolicyIds);
        if(policyNumbersIds.size() > 0){
            updatePolicyNoHolder(newInsurancePolicyList, policyNumbersIds);
        }
        
        
    }
    public static void proccesRecordAfterDelete(List<InsurancePolicy > newInsurancePolicyList)
    {
        List<String> listParentPolicyIds=new List<String>();
        for(InsurancePolicy policy : newInsurancePolicyList){
            
            if(policy.ParentPolicyId!=null){
                listParentPolicyIds.add(policy.ParentPolicyId);
            } 
        }
      	CalculatePolicyPremium(listParentPolicyIds);
       
    }
    
    public static void CalculatePolicyPremium(List<String> listPolicyIds){
        List<InsurancePolicy> listParentPolicyToUpdate=new List<InsurancePolicy>();
        List<AggregateResult> listParentPolicy = [SELECT ParentPolicyId,sum(PremiumAmount) TotalPremiumAmount FROM InsurancePolicy Where ParentPolicyId=:listPolicyIds group by ParentPolicyId];
        
        for (AggregateResult ar : listParentPolicy) {
           	InsurancePolicy policy =new InsurancePolicy();
            policy.id=(String)ar.get('ParentPolicyId');
            policy.PremiumAmount=(Decimal)ar.get('TotalPremiumAmount');
            listParentPolicyToUpdate.add(policy);
        }  
        
        Trigger_PAD.deactivateTrigger('TH_InsurancePolicyBeforeUpdate');
        Trigger_PAD.deactivateTrigger('TH_InsurancePolicyAfterUpdate');
        update listParentPolicyToUpdate;
        Trigger_PAD.activateTrigger('TH_InsurancePolicyBeforeUpdate');
        Trigger_PAD.activateTrigger('TH_InsurancePolicyAfterUpdate');
    }
    
    public static void processRecordAfterInsert(List<InsurancePolicy> newInsurancePolicyList)
    {
      Set<String> newPolicyNumbers = new Set<String>();
        for (InsurancePolicy policy : newInsurancePolicyList)
        {
            newPolicyNumbers.add(policy.Name);
        }
        
        List<Policy_Number_Holder__c> policyHoldersToUpdate = [SELECT Id, Insurance_Policy__c, Policy_Number__c FROM Policy_Number_Holder__c WHERE Policy_Number__c IN :newPolicyNumbers];
        
        for (Policy_Number_Holder__c holder : policyHoldersToUpdate)
        {
            for (InsurancePolicy policy : newInsurancePolicyList)
            {
                if (policy.Name == holder.Policy_Number__c)
                {
                    holder.Insurance_Policy__c = policy.Id;
                }
            }
        }
        
        update policyHoldersToUpdate;
    }
    
    public static void updatePolicyNoHolder(List<InsurancePolicy> newInsurancePolicyList, Set<String> newPolicyNumbers){
        List<Policy_Number_Holder__c> policyHoldersToUpdate = [SELECT Id, Insurance_Policy__c, Policy_Number__c FROM Policy_Number_Holder__c WHERE Policy_Number__c IN :newPolicyNumbers];
        
        for (Policy_Number_Holder__c holder : policyHoldersToUpdate)
        {
            for (InsurancePolicy policy : newInsurancePolicyList)
            {
                if (policy.Name == holder.Policy_Number__c)
                {
                    holder.Insurance_Policy__c = policy.Id;
                }
            }
        }
        
        update policyHoldersToUpdate;
    }
}