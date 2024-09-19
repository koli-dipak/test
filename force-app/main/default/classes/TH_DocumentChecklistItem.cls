public class TH_DocumentChecklistItem extends BaseTriggerHandler{
    
    private List<DocumentChecklistItem> newDocumentChecklistItemList;
    private List<DocumentChecklistItem> oldDocumentChecklistItemList;
    private Map<ID, DocumentChecklistItem> newDocumentChecklistItemMap;
    private Map<ID, DocumentChecklistItem> oldDocumentChecklistItemMap;
    
    public TH_DocumentChecklistItem()
    {
        oldDocumentChecklistItemList = (List<DocumentChecklistItem>)Trigger.old;
        newDocumentChecklistItemList = (List<DocumentChecklistItem>)Trigger.new;
        newDocumentChecklistItemMap = (Map<Id, DocumentChecklistItem>)Trigger.newMap;
        oldDocumentChecklistItemMap = (Map<Id, DocumentChecklistItem>)Trigger.oldMap;
    }
    
    protected override void afterUpdate()
    {
        if(Trigger_PAD.canRun('TH_DocumentChecklistItemAfterUpdate'))
        {
            //N2G-723 for Task Update When DocumentCheckList Update
            completeTaskWhenDocumentChecklistUpdate(newDocumentChecklistItemList,oldDocumentChecklistItemMap);
            
        }
    }
    
    protected override void beforeUpdate()
    {
        if(Trigger_PAD.canRun('TH_DocumentChecklistItemBeforeUpdate'))
        {
            //N2G-891 
            throwEditAndDeleteException(newDocumentChecklistItemList,oldDocumentChecklistItemMap);
        }
    }
    protected override void beforeDelete()
    {
        if(Trigger_PAD.canRun('TH_DocumentChecklistItemBeforeDelete'))
        {
            //N2G-891 
            throwEditAndDeleteException(oldDocumentChecklistItemList,oldDocumentChecklistItemMap);
        }
    }
    
    public static void throwEditAndDeleteException(List<DocumentChecklistItem> newDocumentChecklistItemList, Map<Id, DocumentChecklistItem> oldDocumentChecklistItemMap) {
        Set<Id> documentChecklistItemIds = new Set<Id>();
        Boolean isOwner = false;
        Boolean thisIsError = false;
        Boolean thisDeleteError = false;
        
        Profile n2gUserProfile = [SELECT Id FROM Profile WHERE Name = 'N2G - Users' LIMIT 1];
        Profile n2gUwProfile = [SELECT Id FROM Profile WHERE Name = 'N2G - UW' LIMIT 1];
        
        Map<String, Schema.SObjectField> documentChecklistItemFieldsMap = new Map<String, Schema.SObjectField>();
        List<String> allowedFields = new List<String>{'status','instruction','isselectedfordocument__c'};
            
            try {
                documentChecklistItemFieldsMap = ((SObject)Type.forName('Schema', 'DocumentChecklistItem').newInstance())
                    .getSObjectType().getDescribe().fields.getMap();
            } catch (Exception e) {
                System.debug('Error: ' + e.getMessage());
            } 
        
        Map<Id, DocumentChecklistItem> documentChecklistItemMap = new Map<Id, DocumentChecklistItem>();
        
        try {
            documentChecklistItemMap = new Map<Id, DocumentChecklistItem>(newDocumentChecklistItemList);
        } catch (Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
        }
        
        // Collect case IDs to be checked
        for (DocumentChecklistItem updatedDocumentCl : newDocumentChecklistItemList) {
            documentChecklistItemIds.add(updatedDocumentCl.Id);
        }
        
        if (Trigger.isBefore && Trigger.isDelete) {
            // Check delete permissions here
            List<DocumentChecklistItem> selectedItems = DAL_DocumentChecklistItem.getDocumentChecklistItems(documentChecklistItemIds);
            for (DocumentChecklistItem documentChecklistItemToDelete : selectedItems) {
                // Perform delete permission checks
                isOwner = (UserInfo.getProfileId() == n2gUserProfile.Id || UserInfo.getProfileId() == n2gUwProfile.Id);
                if (isOwner) {
                    thisDeleteError = true;
                }
            }
        }
        
        for (DocumentChecklistItem documentChecklistItemFieldsObj : documentChecklistItemMap.values()) {
            DocumentChecklistItem oldRecord = oldDocumentChecklistItemMap.get(documentChecklistItemFieldsObj.Id);
            isOwner = (UserInfo.getProfileId() == n2gUserProfile.Id || UserInfo.getProfileId() == n2gUwProfile.Id);
            System.Debug('--->isOwner'+isOwner+' '+UserInfo.getProfileId()+' '+n2gUserProfile.Id);
            if (isOwner) {
                for (String field : documentChecklistItemFieldsMap.keySet()) {
                    // Check if the field value has changed and the field modified is not among the allowed fields and custom setting for validation is not disabled 
                    if (documentChecklistItemFieldsObj.get(field) != oldRecord.get(field) && !allowedFields.contains(field)) {
                        thisIsError = true;
                    }
                }
            }
        }
        
        for (DocumentChecklistItem documentChecklistItemFieldsObj : newDocumentChecklistItemList) {
            if (thisIsError) {
                documentChecklistItemFieldsObj.addError('Edit permission is exclusively reserved for administrators.');
            }
        }
        
        
        for (DocumentChecklistItem documentChecklistItemFieldsObj : newDocumentChecklistItemList) {
            if (thisDeleteError) {
                documentChecklistItemFieldsObj.addError('Delete permission is exclusively reserved for administrators.');
            }
        }
        
    }
    public static void completeTaskWhenDocumentChecklistUpdate(List<DocumentChecklistItem> newDocumentChecklistItemList, Map<ID, DocumentChecklistItem> oldDocumentChecklistItemMap) {
        // Collect unique Quote Ids from the new DocumentChecklistItems
        Set<Id> quoteIdsForTask = new Set<Id>();
        Map<Id, Task> existingTasks = new Map<Id, Task>();
        List<Task> tasksToUpdateStatus = new List<Task>();
        for (DocumentChecklistItem documentChecklistItem : newDocumentChecklistItemList) {
            quoteIdsForTask.add(documentChecklistItem.Generate_Quote_and_Binder__c);
        }
        
        if (!quoteIdsForTask.isEmpty()) {
            
            // Retrieve existing tasks related to the given quotes
            for (Task task : DAL_Task.getTasksByWhatIdsList(new List<Id>(quoteIdsForTask))) {
                System.debug('Processing Task: ' + task.Id);
                if (task.Subject.startsWith('Binding Checklist Task')) {
                    existingTasks.put(task.WhatId, task);
                }
            }
            
            
            
            // Loop through the quoteIdsForTask set and update tasks if applicable
            String quoteId;
            Task taskToUpdate;
            if(existingTasks!=null && !quoteIdsForTask.isEmpty()){
                for (Id quoteIds : quoteIdsForTask) {
                    taskToUpdate = existingTasks.get(quoteIds);
                    quoteId= (String.valueOf(quoteIds));
                }
            }
            
            // Update existing task status if applicable
            if (taskToUpdate != null) {
                Integer completedChecklistCount = DAL_DocumentChecklistItem.getCompletedChecklistCount(quoteId);
                Integer totalChecklist = DAL_DocumentChecklistItem.getDocumentChecklistItemCount(quoteId);
                
                if (completedChecklistCount == totalChecklist) 
                    taskToUpdate.Status = 'Completed';
                else
                    taskToUpdate.Status = 'Open';
                tasksToUpdateStatus.add(taskToUpdate);
            }
        }
        
        // Update tasks if there are any changes
        if (!tasksToUpdateStatus.isEmpty() && existingTasks.size()!=0) {
            update tasksToUpdateStatus;
        }
    }
}