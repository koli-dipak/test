trigger ClearanceTrigger on Clearance__c (before insert,before update) {
    new TH_Clearance().run();
}