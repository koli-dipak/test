@isTest
public class DAL_Quote_T {
   @isTest
   static void TestMethod1()
   {
       DAL_Quote.getQuotesByIds(new set<Id>{null});
       DAL_Quote.getQuoteDetails('');
       DAL_Quote.getQuoteDetailsList(new List<Id>{null});
    }
   
}