trigger CaseAndLocationTrigger on CaseAndLocaiton__c (before insert) {
      new TH_CaseAndLocation().run();
}