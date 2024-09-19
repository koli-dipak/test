public class BatchLobInstec implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([SELECT Id, Line_of_Business__c, Line_of_Business__r.is_Instec_Lob__c, Line_of_Business__r.Lob_Expiry_Date__c, Instec_Expiration__c, Effective_Date__c FROM Policy_Number_Holder__c WHERE Instec_Storage_ID__c != NULL And Line_of_Business__r.LOB_Stage__c = 'Bound' And Line_of_Business__r.RecordType.Name != 'Builders Risk']);
    }

    public void execute(Database.BatchableContext context, List<Policy_Number_Holder__c> scope) {
        System.debug('::Scope:: '+ scope);
        Map<Id, Lob_Management__c> uniqueLobManagementMap = new Map<Id, Lob_Management__c>();

        for (Policy_Number_Holder__c policyHolder : scope) {
            if (policyHolder.Line_of_Business__r != null) {
                Id lineOfBusinessId = policyHolder.Line_of_Business__c;

                Lob_Management__c lobManagement = uniqueLobManagementMap.get(lineOfBusinessId);

                if (lobManagement == null) {
                    // If it's not in the map, create a new Lob_Management__c record
                    lobManagement = new Lob_Management__c(Id = lineOfBusinessId);
                    uniqueLobManagementMap.put(lineOfBusinessId, lobManagement);
                }

                if (policyHolder.Instec_Expiration__c == null) {
                    lobManagement.Lob_Expiry_Date__c = policyHolder.Effective_Date__c.addYears(1);
                } else if (lobManagement.Lob_Expiry_Date__c == null || policyHolder.Instec_Expiration__c < lobManagement.Lob_Expiry_Date__c) {
                    lobManagement.Lob_Expiry_Date__c = policyHolder.Instec_Expiration__c;
                }

                lobManagement.is_Instec_Lob__c = true;
            }
        }

        if (!uniqueLobManagementMap.isEmpty()) {
            update uniqueLobManagementMap.values();
        }
    }

    public void finish(Database.BatchableContext context) {
        System.debug('Batch Process Completed Successfully');
    }
    
    public void execute(SchedulableContext context) {
        BatchLobInstec batch = new BatchLobInstec();
        Database.executeBatch(batch,50);
    }
}