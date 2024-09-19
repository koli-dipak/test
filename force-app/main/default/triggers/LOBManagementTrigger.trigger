trigger LOBManagementTrigger on LOB_Management__c (before insert, after insert, before update, after update, before delete,after delete) {
    new TH_LOBManagement().run(); 
}