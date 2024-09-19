public class DAL_Quote {

     public static List<Quote> getQuoteDetails(String quoteId) {
        return [
            SELECT Id, Opportunity.Name, Opportunity.Underwriting_Associate__c, Opportunity.Underwriter_Name__c
            FROM Quote
            WHERE Id = :quoteId
        ];
    }
    
    public static List<Quote> getQuoteDetailsList(List<Id> quoteIds) {
        return [
            SELECT Id, Opportunity.Name, Opportunity.Underwriting_Associate__c, Opportunity.Underwriter_Name__c
            FROM Quote
            WHERE Id IN :quoteIds
        ];
    }
    
    public static List<Quote> getQuotesByIds(Set<Id> quoteIds) {
        return [
            SELECT Id, OpportunityId
            FROM Quote
            WHERE Id IN :quoteIds
        ];
    }
}