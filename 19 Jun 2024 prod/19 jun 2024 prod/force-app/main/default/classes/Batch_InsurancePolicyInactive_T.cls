@isTest
public class Batch_InsurancePolicyInactive_T {
    public static String CRON_EXP = '0 0 0 15 3 ? *';
    public static User admin_User;
    public static Integer count =2;
    public static string ADMIN_PROFILE ='System Administrator';
    public static List<Account> acc = new List<Account>();
    
    @isTest
    public static void updatePolicyInactiveTestMethod(){
        admin_User = TestDataFactory.createUser(true,'Account',ADMIN_PROFILE);
        insert admin_User;
        User currentUser = [SELECT BypassValidation__c from User where Id = :admin_User.Id];
        currentUser.BypassValidation__c = true;
        update currentUser;  
        system.runAs(currentUser) {
            
            Map <String,Object> accountFieldMap = new Map <String,Object>(); 
            accountFieldMap.put('Name','TestAccount');
            Account accountRec = (Account) TestDataFactory.operationOnObjectRec('insert','Account',accountFieldMap);
            
            // Id recordTypeId1 = Schema.SObjectType.InsurancePolicy.getRecordTypeInfosByDeveloperName().get('Policy').getRecordTypeId();
            Map <String,Object> InsuranceFieldMap = new Map <String,Object>(); 
            InsuranceFieldMap.put('Name','12355665');
            InsuranceFieldMap.put('PolicyName','TestPolicy');
            InsuranceFieldMap.put('PolicyType','Cyber Liability');
            InsuranceFieldMap.put('Status','Initial');
            //InsuranceFieldMap.put('RecordTypeId',recordTypeId1);   
            InsuranceFieldMap.put('NameInsuredId',accountRec.Id);
            InsuranceFieldMap.put('ExpirationDate',date.today().addDays(-10));
            //InsuranceFieldMap.put('PolicyExp__c',date.today().addDays(-10));
            InsurancePolicy insuranceRec = (InsurancePolicy) TestDataFactory.operationOnObjectRec('insert','InsurancePolicy',InsuranceFieldMap);
            
            Batch_InsurancePolicyInactive batchInsPolicy = new Batch_InsurancePolicyInactive();
            Test.startTest();
            String jobId = System.schedule('InsurancePolicyInactiveBatchTest', CRON_EXP,  new Batch_InsurancePolicyInactive()); 
            DataBase.executeBatch(batchInsPolicy, 200); 
            
            // System.assert(jobId.Id != null);
            Test.stopTest();   
        }
        User currentUser1 = [SELECT BypassValidation__c from User where Id = :admin_User.Id];
        currentUser1.BypassValidation__c = false;
        update currentUser1;  
    }
}