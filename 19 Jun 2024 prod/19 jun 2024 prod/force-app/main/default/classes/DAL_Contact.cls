public class DAL_Contact {
    
    public static List<Contact> getContactByAcc(String accountId) {
        return [SELECT Id, Name
                FROM Contact 
                WHERE AccountId =: accountId 
                Order by Name asc];
    }
    
    public static List<Contact> getContactById(String recordId) {
        return [SELECT Id, Account.Name,Account.Broker_External_Id__c ,Account.Distribution_Leader__r.Name, Account.Annual_Premium_Volumne__c,Account.Distribution_Leader__c,Account.Head_of_Office__c,AccountId,Name,Account.Box_Folder_Name__c,Account.NumberOfEmployees,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingCountry,Account.BillingPOstalCode, LastName, FirstName, MiddleName,Account.website, Phone, MobilePhone, Email, Title
                FROM Contact WHERE Id = :recordId];
    }
    public static List<Contact> getContactByEmail(set<String> emails) {
        return [SELECT Id,Email From Contact Where Email = :emails];
    }
    
    public static List<Contact> getContactByIdSet(set<Id> contactIds) {
		return [SELECT Id, Email, AccountId FROM Contact WHERE Id IN :contactIds];        
    }
}