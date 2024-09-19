public class Batch_InsurancePolicyInactive implements Database.Batchable<sObject>,Schedulable ,Database.Stateful,Database.AllowsCallouts{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        string query='SELECT Id, ExpirationDate,IsActive FROM InsurancePolicy WHERE ExpirationDate <today and Status != \'InActive\'';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<InsurancePolicy> listPloicy){
        for(InsurancePolicy policy : listPloicy){
            policy.Status = 'InActive';
        } 
        update listPloicy;
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    public void execute(SchedulableContext sc) {
        Batch_InsurancePolicyInactive b = new Batch_InsurancePolicyInactive(); 
        database.executebatch(b,200); 
    }
    
}