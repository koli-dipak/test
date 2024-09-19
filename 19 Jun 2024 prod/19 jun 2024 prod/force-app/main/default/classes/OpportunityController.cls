public with sharing class OpportunityController {
    
    // Method to fetch lookup search result
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName) {
        List < sObject > returnList = new List < sObject > ();
        
        string sWildCardText = '%' + searchKey + '%';
        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Name Like : sWildCardText order by createdDate DESC ';
        
        //Get only recently viewed records
        if(searchKey == ''){
            sQuery = 'SELECT Id, Name, Type, LastViewedDate FROM RecentlyViewed WHERE Type = :sObjectApiName ORDER BY LastViewedDate DESC';
            
            System.debug('sQuery:: ' + sQuery);
        }
        
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    // Method to fetch lookup default value
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
        string sRecId = recordId;
        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        string lastViewOnlyQuery = 'SELECT Id, Name, Type, LastViewedDate FROM RecentlyViewed WHERE Type =\'Opportunity\' ORDER BY LastViewedDate DESC';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }
}