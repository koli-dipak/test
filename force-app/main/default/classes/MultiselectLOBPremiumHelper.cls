public with sharing class MultiselectLOBPremiumHelper{
    @AuraEnabled
    public static List<LOB_Management__c> getLOBRecords(String OpportunityId){
        system.debug('OpportunityId:: ' + OpportunityId);
        List<LOB_Management__c> LOBList = DAL_LOB_Management.getLOBRecordsByOppId(OpportunityId);
        System.debug('LOBList:: ' + LOBList);
        return LOBList;
    }

    @AuraEnabled
    public static String updateLOBRecords(Map<String, Decimal> responseMap, Map<String, Double> probabilityMap){
        try{
            system.debug('responseMap:: ' + responseMap);
            system.debug('responseMapkeySet:: ' + responseMap.keySet());
            system.debug('probabilityMap:: ' + probabilityMap);
            system.debug('probabilityMapkeySet:: ' + probabilityMap.keySet());
            // List<LOB_Management__c> LOBRecordsToUpdate = new List<LOB_Management__c>();
            // for (String LOBId : responseMap.keySet()){
            //     LOB_Management__c LOB = new LOB_Management__c();
            //     LOB.Id = LOBId;
            //     LOB.Estimated_LOB_Premium__c = responseMap.get(LOBId);
            //     LOBRecordsToUpdate.add(LOB);
            // }
            
            // BaseTriggerHandler.bypass('TH_LOBMANAGEMENT');
            // Update LOBRecordsToUpdate;
            // BaseTriggerHandler.clearBypass('TH_LOBMANAGEMENT');

            Set<String> changedIdsSet = new Set<String>();
            List<LOB_Management__c> LOBRecordsToUpdate = new List<LOB_Management__c>();
            
            if(!responseMap.isEmpty()){
                for (String LOBId : responseMap.keySet()){
                    changedIdsSet.add(LOBId);
                }
            }
            
            if(!probabilityMap.isEmpty()){
                for (String LOBId : probabilityMap.keySet()){
                    changedIdsSet.add(LOBId);
                }
            }
            
            if(!changedIdsSet.isEmpty()){
                for (String LOBId : changedIdsSet){
                    LOB_Management__c LOB = new LOB_Management__c();
                    LOB.Id = LOBId;
                    if(probabilityMap.containsKey(LOBId))
                        LOB.Probability__c = probabilityMap.get(LOBId);
                    if(responseMap.containsKey(LOBId))
                        LOB.Estimated_LOB_Premium__c = responseMap.get(LOBId);
                        LOBRecordsToUpdate.add(LOB);
                }
            }
            Update LOBRecordsToUpdate;
            
            // if(!LOBRecordsToUpdate.isEmpty()){
            //     BaseTriggerHandler.bypass('TH_LOBMANAGEMENT');
            //     Update LOBRecordsToUpdate;
            //     BaseTriggerHandler.clearBypass('TH_LOBMANAGEMENT');
            // }

        } catch (Exception e){
            return e.getMessage() + e.getLineNumber();
        }

        return 'Success';
    }

    @AuraEnabled
    public static String updateLOBEffectiveDateRecords(Map<String, Date> responseMap){
        try{
            system.debug('responseMap:: ' + responseMap);
            system.debug('responseMapkeySet:: ' + responseMap.keySet());
            List<LOB_Management__c> LOBRecordsToUpdate = new List<LOB_Management__c>();
            for (String LOBId : responseMap.keySet()){
                LOB_Management__c LOB = new LOB_Management__c();
                LOB.Id = LOBId;
                LOB.LOB_Effective_Date__c = responseMap.get(LOBId);
                LOBRecordsToUpdate.add(LOB);
            }
            
            BaseTriggerHandler.bypass('TH_LOBMANAGEMENT');
            Update LOBRecordsToUpdate;
            BaseTriggerHandler.clearBypass('TH_LOBMANAGEMENT');
        } catch (Exception e){
            return e.getMessage() + e.getLineNumber();
        }

        return 'Success';
    }

    @AuraEnabled
    public static String updateLOBUnderWriterRecords(Map<String, String> responseMap, String OpportunityId, Map<String, String> instructionNoteMap){
        try{
            system.debug('responseMap:: ' + responseMap);
            system.debug('responseMapkeySet:: ' + responseMap.keySet());
            List<LOB_Management__c> LOBRecordsToUpdate = new List<LOB_Management__c>();
            List<User> userRecords = DAL_User.getUserRecordsByUserIds(responseMap.values());
            Map<String, String> userIdWiseUserName = new Map<String, String>();
            Map<String, String> userIdWiseUserEmail = new Map<String, String>();
            Map<String, Task> userIdWiseTaskRec = new Map<String, Task>();
            Map<String, Messaging.SingleEmailMessage> userIdWiseEmailRec = new Map<String, Messaging.SingleEmailMessage>();
            Map<String, Integer> userIdWiseLOBCount = new Map<String, Integer>();

            System.debug('@@userRecords::'+userRecords);
            if(!userRecords.isEmpty()){
                for (User userRec : userRecords) {
                    userIdWiseUserName.put(userRec.Id, userRec.Name);
                    userIdWiseUserEmail.put(userRec.Id, userRec.Email);
                }
            }

            for (String LOBId : responseMap.keySet()){
                // Integer count = 0;
                LOB_Management__c LOB = new LOB_Management__c();
                LOB.Id = LOBId;
                LOB.Underwriter__c = responseMap.get(LOBId);
                LOB.LOB_Underwriter_Instructions__c = instructionNoteMap.get(LOBId);
                LOBRecordsToUpdate.add(LOB);

                // create task for underwriter
                if(!userIdWiseTaskRec.containsKey(responseMap.get(LOBId))){
                    Task taskRec = new Task();
                    taskRec.OwnerId = responseMap.get(LOBId);
                    taskRec.WhatId = OpportunityId;
                    taskRec.ActivityDate = System.today();
                    taskRec.Status = 'Completed';
                    taskRec.Subject = 'LOB underwriter assignment notification';
                    taskRec.Description = 'Good day ';
                    if(userIdWiseUserName.containsKey(responseMap.get(LOBId))){
                        taskRec.Description = taskRec.Description + userIdWiseUserName.get(responseMap.get(LOBId)) + ', ';
                    }else{
                        taskRec.Description = taskRec.Description + 'Underwriter, ';
                    }
                    taskRec.Description = taskRec.Description + '\r\n';
                    if(OpportunityId != null){
                        taskRec.Description = taskRec.Description + '\r\nRegarding the following opportunity.\r\n ';
                        taskRec.Description = taskRec.Description + System.Label.Org_URL_With_Last_Slash + OpportunityId +'. \r\n';
                    }
                    taskRec.Description = taskRec.Description + '\r\n';
                    taskRec.Description = taskRec.Description + 'Please note that you have been assigned to the following lines of business.\r\n ';
                    userIdWiseTaskRec.put(responseMap.get(LOBId), taskRec);
                    userIdWiseLOBCount.put(responseMap.get(LOBId), 1);


                     // Email Functionality
                     if(userIdWiseUserEmail.containsKey(responseMap.get(LOBId))){
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setSaveAsActivity(false);
                        email.setTreatTargetObjectAsRecipient(false);
                        email.setSubject(userIdWiseTaskRec.get(responseMap.get(LOBId)).Subject);
                        email.setToAddresses(new List<String>{userIdWiseUserEmail.get(responseMap.get(LOBId))});
                        userIdWiseEmailRec.put(responseMap.get(LOBId), email);
                     }
                }
                userIdWiseTaskRec.get(responseMap.get(LOBId)).Description = userIdWiseTaskRec.get(responseMap.get(LOBId)).Description + userIdWiseLOBCount.get(responseMap.get(LOBId)) + '. '+ System.Label.Org_URL_With_Last_Slash + LOBId +'.\r\n';
              
                if(instructionNoteMap.containsKey(LOBId) && String.isNotBlank(instructionNoteMap.get(LOBId)))
                    userIdWiseTaskRec.get(responseMap.get(LOBId)).Description = userIdWiseTaskRec.get(responseMap.get(LOBId)).Description + instructionNoteMap.get(LOBId) +'\r\n';
                userIdWiseTaskRec.get(responseMap.get(LOBId)).Description = userIdWiseTaskRec.get(responseMap.get(LOBId)).Description +'\r\n';
                Integer count = (Integer)userIdWiseLOBCount.get(responseMap.get(LOBId));
                userIdWiseLOBCount.put(responseMap.get(LOBId), ++count);
                
                // set Email body
                String emailBody = userIdWiseTaskRec.get(responseMap.get(LOBId)).Description + 'Thanks & Regards\r\nN2G Team';
                emailBody = emailBody.replaceAll('\r\n' , '<br />');
                if(userIdWiseUserEmail.containsKey(responseMap.get(LOBId)))
                    userIdWiseEmailRec.get(responseMap.get(LOBId)).setHtmlBody(emailBody);

            }
            System.debug('@@userIdWiseTaskRec::'+userIdWiseTaskRec);
            if(!LOBRecordsToUpdate.isEmpty()){
            	BaseTriggerHandler.bypass('TH_LOBMANAGEMENT');
                update LOBRecordsToUpdate;
            	BaseTriggerHandler.clearBypass('TH_LOBMANAGEMENT');
            }
            if(!userIdWiseTaskRec.isEmpty()){
                Trigger_PAD.deactivateTrigger('TH_TaskAfterInsert');
                Trigger_PAD.deactivateTrigger('TH_TaskBeforeInsert');
                Trigger_PAD.deactivateTrigger('TH_TaskBeforeUpdate');
                insert userIdWiseTaskRec.values();
                Trigger_PAD.activateTrigger('TH_TaskAfterInsert');
                Trigger_PAD.activateTrigger('TH_TaskBeforeInsert');
                Trigger_PAD.activateTrigger('TH_TaskBeforeUpdate');
            }

            // Send Email to Underwrite
            if(!userIdWiseEmailRec.isEmpty()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(userIdWiseEmailRec.values());
                
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                    return results[0].errors[0].message;
                }
            }

        } catch (Exception e){
            return e.getMessage() + e.getLineNumber();
        }

        return 'Success';
    }

    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName) {    
        List < sObject > returnList = new List < sObject > ();
        string sWildCardText = '%' + searchKey + '%';
        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    // Method to fetch lookup default value 
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
        string sRecId = recordId;    
        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }
}