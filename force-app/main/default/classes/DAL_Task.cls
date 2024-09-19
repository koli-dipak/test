public class DAL_Task {

    public static List<Task> getTasksByWhatId(String quoteId) {
        return [
            SELECT Id, Subject, Priority, Notifiieuserid__c, Status, WhatId
            FROM Task
            WHERE WhatId = :quoteId
        ];
    }
    public static List<Task> getTasksByWhatIdsList(List<String> quoteIds) {
        return [
            SELECT Id, Subject, Priority, Notifiieuserid__c, Status, WhatId
            FROM Task
            WHERE WhatId IN :quoteIds
        ];
    }
}