@isTest
public class TH_PolicyForRiskEngineering_T {
    public static User admin_User;
    public static Integer count =1;
    public static string ADMIN_PROFILE ='System Administrator';
    public static List<Account> acc = new List<Account>();
    public static List<InsurancePolicy> Ipol = new List<InsurancePolicy>();
    public static List<Case> CaseList = new List<Case>();
    
    static void proccesRecordData()
    {
        admin_User = TestDataFactory.createUser(true,'Case_and_InsurancePolicy__c',ADMIN_PROFILE);
        insert admin_User;
        System.runAs(admin_User)
        {
            try{
                Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Insured').getRecordTypeId();
                Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.N2G_Internal_Cases_Record_Type_Dev_Name).getRecordTypeId();
                for(Integer i = 0 ; i <count; i++)
                {
                    Map<String,Object>  Accountobj = new Map<String,Object>();
                    Accountobj.put('RecordTypeId',accRecordTypeId);
                    Accountobj.put('Name','Test Account '+i);
                    acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
                }
                
                for(Integer i = 0 ; i <count; i++)
                {
                    Map<String,Object>  InsurancePolicyobj = new Map<String,Object>();
                    InsurancePolicyobj.put('NameInsuredId',acc[0].Id);
                    InsurancePolicyobj.put('Name','Newtes'+i);
                    Ipol.add((InsurancePolicy) TestDataFactory.operationOnObjectRec('insert', 'InsurancePolicy',  InsurancePolicyobj));
                }
                
                Map<String,Object> caseObj = new Map<String,Object>();
                caseObj.put('Subject','Test Case');
                caseObj.put('Topic__c','Risk Engineering');
                caseObj.put('Case_Detail__c','Property');
                caseObj.put('RecordTypeId',caseRecordTypeId);
                for(Integer i = 0 ; i <count; i++)
                {
                    CaseList.add((Case) TestDataFactory.operationOnObjectRec('insert', 'Case', caseObj));
                }
                
                Map<String,Object>  casePolicyObj = new Map<String,Object>();
                casePolicyObj.put('Case__c',CaseList[0].Id);
                casePolicyObj.put('Insurance_Policy__c', Ipol[0].Id);
                Case_and_InsurancePolicy__c casePolicyRecord = (Case_and_InsurancePolicy__c) TestDataFactory.operationOnObjectRec('insert', 'Case_and_InsurancePolicy__c', casePolicyObj);
                
                Map<String,Object>  casePolicyObj2 = new Map<String,Object>();
                casePolicyObj2.put('Case__c',CaseList[0].Id);
                casePolicyObj2.put('Insurance_Policy__c', Ipol[0].Id);
                Case_and_InsurancePolicy__c casePolicyRecord2 = (Case_and_InsurancePolicy__c) TestDataFactory.operationOnObjectRec('insert', 'Case_and_InsurancePolicy__c', casePolicyObj2);
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('The records you are trying to include already exists in the list') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
        }
    }
    
    @isTest
    static void casePolicyProccesRecordDataTest() 
    {
        proccesRecordData();
    }
}