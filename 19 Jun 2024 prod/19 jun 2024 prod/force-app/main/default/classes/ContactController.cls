public with sharing class ContactController {
    
    // Method to fetch lookup search result
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName) {
        List < sObject > returnList = new List < sObject > ();
        
        string sWildCardText = '%' + searchKey + '%';
        string sQuery = 'Select Id,Name,Email,Client_Name__c From ' + sObjectApiName + ' Where Name Like : sWildCardText order by createdDate DESC ';
        List<String> recId=new List<String>();
        //Get only recently viewed records
        if(searchKey == ''){
            sQuery = 'SELECT Id, Name,Email, Type, LastViewedDate FROM RecentlyViewed WHERE Type = :sObjectApiName ORDER BY LastViewedDate DESC';
          
            for (sObject obj: database.query(sQuery)) {
                recId.add(obj.Id);
            }

            sQuery = 'Select Id,Name,Email,Client_Name__c From ' + sObjectApiName + ' Where Name Like : sWildCardText and id=:recId order by createdDate DESC ';
        

            System.debug('sQuery:: ' + sQuery);
        }
        
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        System.debug('sQuery:: ' + sQuery);
        System.debug('@@ContactList::'+Json.serialize(returnList));
        return returnList;
    }
    
    // Method to fetch lookup default value
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
        string sRecId = recordId;
        string sQuery = 'Select Id,Name,Email,Client_Name__c From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        string lastViewOnlyQuery = 'SELECT Id, Name, Type,Email, LastViewedDate FROM RecentlyViewed WHERE Type =\'Contact\' ORDER BY LastViewedDate DESC';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }


    @AuraEnabled
    public static Object insertContactRecord(Object contatcRecord){
        try {
            String ContactList = JSON.serialize(contatcRecord);
            Map<String,Object> contactRecords = (Map<String,Object>)JSON.deserializeUntyped(ContactList);
            List<Contact> conList = new List<Contact>();
            Contact con = new Contact();
            con.FirstName = (String)contactRecords.get('FirstName');
            con.LastName = (String)contactRecords.get('LastName');
            con.Email = (String)contactRecords.get('Email');
            con.Title = (String)contactRecords.get('Title'); 
            con.Salutation = (String)contactRecords.get('Salutation');
            con.MobilePhone = (String)contactRecords.get('Mobile'); 
            con.Phone = (String)contactRecords.get('Phone'); 
            conList.add(con);
            insert conList;
            return JSON.serializePretty(ContactList);
        } catch (Exception ex)  {
            throw new AuraHandledException('An error occurred while saving records: ' + ex.getMessage());
        }
    }
}