public class DAL_Product {

    public static List<Product2> getProductList(Set<String> externalIds){
        return [Select Id, Name, ExternalId__c, (Select Id, Name From PricebookEntries) From Product2 Where ExternalId__c IN :externalIds];
    }
}