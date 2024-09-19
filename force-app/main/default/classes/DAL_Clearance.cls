public class DAL_Clearance {
	public Static Clearance__c getClearanceById(Id recId){
        return [SELECT Id, Name, Opportunity__r.Id, recordType.Name, External_Key__c FROM Clearance__c Where id = : recId];
    }
    public static List<Clearance__c> getAllClearanceByOpp(Set<Id> oppIds){
		return [SELECT Id, Opportunity__c, recordType.Name FROM Clearance__c Where Opportunity__c IN : oppIds];
    }
}