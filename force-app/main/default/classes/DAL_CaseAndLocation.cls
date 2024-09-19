public class DAL_CaseAndLocation {
    
    Public Static List<CaseAndLocaiton__c> getLocationByLocationsIds (Set<Id> locationRecordIds){
        return[select Id, Location__r.Name,  Case__c, Case__r.Id,Location__c from CaseAndLocaiton__c where Location__c IN :locationRecordIds];
    }

}