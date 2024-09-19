trigger QuoteLineItemTrigger on QuoteLineItem (after insert,after update) {
     new TH_QuoteLineItem().run();
}