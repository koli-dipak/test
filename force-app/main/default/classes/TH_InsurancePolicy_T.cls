@isTest
public class TH_InsurancePolicy_T {
    public static User admin_User;
    public static Integer count =2;
    public static string ADMIN_PROFILE ='System Administrator';
    public static List<InsurancePolicy> Ipol = new List<InsurancePolicy>();
    public static List<Account> acc = new List<Account>();
    public static List<Policy_Number_Holder__c> policyHolders = new List<Policy_Number_Holder__c>();
    
    @isTest
    static void proccesRecordData()
    {
        admin_User = TestDataFactory.createUser(true,'InsurancePolicy',ADMIN_PROFILE);
        
        System.assertEquals('TestAdmin', admin_User.LastName);
        insert admin_User;
        
        System.runAs(admin_User)
        { 
            //Id accRecordTypeId = Schema.SObjectType.InsurancePolicy.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
            Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
            
            for(Integer i = 0 ; i <count; i++)
            {
                Map<String,Object>  Accountobj = new Map<String,Object>();
                Accountobj.put('RecordTypeId',accRecordTypeId);
                Accountobj.put('Name','Newtes'+i);
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
                
                System.assertEquals('Newtes0', acc[0].Name);
            }
            for(Integer i = 0 ; i <count; i++)
            {
                Map<String,Object>  InsurancePolicyobj = new Map<String,Object>();
                InsurancePolicyobj.put('NameInsuredId',acc[0].Id);
                InsurancePolicyobj.put('Name','Newtes'+i);
                Ipol.add((InsurancePolicy) TestDataFactory.operationOnObjectRec('insert', 'InsurancePolicy',  InsurancePolicyobj));
                
                System.assertEquals('Newtes'+i, Ipol[i].Name);
            }
            for(Integer i = 0 ; i <count; i++)
            {
                Map<String,Object>  InsurancePolicyobj = new Map<String,Object>();
                InsurancePolicyobj.put('NameInsuredId',acc[0].Id);
                InsurancePolicyobj.put('ParentPolicyId',Ipol[0].Id);
                InsurancePolicyobj.put('Name','Newtes'+i);
                Ipol.add((InsurancePolicy) TestDataFactory.operationOnObjectRec('insert', 'InsurancePolicy',  InsurancePolicyobj));
                
                System.assertEquals('Newtes'+i, Ipol[i].Name);
            }
            for (Integer i = 0; i < count; i++) {
                // Create Policy_Number_Holder__c records with Policy_Number__c set to 'Newtes'
                Map<String, Object> policyHolderObj = new Map<String, Object>();
                policyHolderObj.put('Policy_Number__c', 'Newtes' + i);
                policyHolderObj.put('Insurance_Policy__c', null);
                policyHolders.add((Policy_Number_Holder__c)TestDataFactory.operationOnObjectRec('insert', 'Policy_Number_Holder__c', policyHolderObj));
            }
        }
        
        
    }
    
    static testMethod void InsurancePolicyproccesRecordDataTest() 
        
    {
        
        Test.startTest();
        proccesRecordData();
        Ipol[Ipol.size()-1].PremiumAmount=200;
        Map<String,Object>  InsurancePolicyobj = new Map<String,Object>();
        
        InsurancePolicyobj.put('ParentPolicyId',Ipol[Ipol.size()-2].Id);
        InsurancePolicyobj.put('Name','Newtes');
        InsurancePolicyobj.put('Id',Ipol[Ipol.size()-1].Id);
        Ipol.add((InsurancePolicy) TestDataFactory.operationOnObjectRec('update','InsurancePolicy',InsurancePolicyobj));
        delete Ipol[Ipol.size()-1];
        
        Test.stopTest();
    }
    
    static testMethod void testProcessRecordAfterInsert() {
        Test.startTest();
        proccesRecordData();
        Map<String,Object>  InsurancePolicyobj = new Map<String,Object>();
        InsurancePolicyobj.put('ParentPolicyId',Ipol[Ipol.size()-2].Id);
        InsurancePolicyobj.put('Name','Newtes');
        InsurancePolicyobj.put('NameInsuredId',acc[0].Id);
        //InsurancePolicyobj.put('Id',Ipol[Ipol.size()-1].Id);
        TestDataFactory.operationOnObjectRec('insert','InsurancePolicy',InsurancePolicyobj);
        Test.stopTest();
    }

    
    static testMethod void testUpdatePolicyNoHolder() {
        Test.startTest();
        proccesRecordData();
        List<InsurancePolicy> newInsurancePolicyList = new List<InsurancePolicy>{Ipol[Ipol.size()-1]};
  		Set<String> newPolicyNumbers = new Set<String>{'Newtes1'};
        TH_InsurancePolicy.updatePolicyNoHolder(newInsurancePolicyList, newPolicyNumbers);
        List<Policy_Number_Holder__c> updatedHolders = [SELECT Id, Insurance_Policy__c FROM Policy_Number_Holder__c WHERE Policy_Number__c IN :newPolicyNumbers];
		System.assertEquals(1, updatedHolders.size());
    	System.assertNotEquals(null, updatedHolders[0].Insurance_Policy__c);
        Test.stopTest();
    }
    
    
    /*static testMethod void Test(){

InsurancePolicy listParentPolicyToUpdate1=new InsurancePolicy();
listParentPolicyToUpdate1.ParentPolicyId = '1231121';
insert listParentPolicyToUpdate1;
}*/
}