public class TH_Task extends BaseTriggerHandler{
    
    
    private List<Task> newTaskList;
    private List<Task> oldTaskList;
    private Map<ID,Task> newTaskMap;
    private Map<ID,Task> oldTaskMap;
    
    public TH_Task()
    {
        oldTaskList = (List<Task>)Trigger.old;
        newTaskList = (List<Task>)Trigger.new;
        newTaskMap = (Map<Id,Task>)Trigger.newMap;
        oldTaskMap = (Map<Id,Task>)Trigger.oldMap;
    }
    
    protected override void afterInsert() { 
        if(Trigger_PAD.canRun('TH_TaskAfterInsert')){
            proccesRecordAfterTask(newTaskList,oldTaskMap);
            sendEmailForNewTask(newTaskList);
        }
    } 
    
    protected override void beforeInsert() { 
        if(Trigger_PAD.canRun('TH_TaskBeforeInsert')){
            //proccesRecordBeforeTask(newTaskList,oldTaskMap);
        }
    } 
    
    protected override void beforeUpdate() { 
        if(Trigger_PAD.canRun('TH_TaskBeforeUpdate')){
            proccesRecordBeforeTask(newTaskList,oldTaskMap);
        }
    } 
    
    public static void proccesRecordAfterTask(List<Task> newTaskList, Map<Id, Task> oldTaskMap){
        system.debug('@@'+JSON.serialize(newTaskList));
        List<Box_Sync__e> boxList = new List<Box_Sync__e>();
        for(Task task:newTaskList){
            system.debug('@@task.TaskSubtype ::'+task.TaskSubtype);
            if(task.TaskSubtype == 'Email' && task.WhatId!=null && ((String)task.WhatId).StartsWith('006') && task.WhoId==null){
                Box_Sync__e box = new Box_Sync__e();
                box.OpportunityId__c = task.WhatId;
                box.TaskId__c = task.Id;
                box.Object_Name__c = 'Task';
                boxList.add(box);
            }
        }
        system.debug('@@'+boxList);
        if(boxList.size()>0){
            EventBus.publish(boxList);
        }
    }
    //this method for create custom Notification when in Task Owener ID field is Rating Queue and Status will update to completed then we will notify to Particular user 
    public static void proccesRecordBeforeTask(List<Task> newTaskList, Map<Id, Task> oldTaskMap){
        
        Set<String> userIds = new Set<String>();
        Set<Id> ownerIds = new Set<Id>();
        List<LOB_Management__c> listofLOBupdate = new List<LOB_Management__c>();
        Map<Id, User> user;
        Map<Id, User> owner;
        Group ratingqueuegroup=DAL_Group.getQueueGroupByName('Rating_Queue');
        Group n2gDomesticOperation=DAL_Group.getQueueGroupByName('N2G_Domestic_Operations');
        Group highProrityQueue=DAL_Group.getQueueGroupByName('Priority_Rating_Queue');
        CustomNotificationType notificationType =DAL_CustomNotificationType.getCustomNotificationType('LOB_Task_Completion'); 
        
        for(Task task:newTaskList){
            userIds.add(task.Notifiieuserid__c);
            ownerIds.add(task.OwnerId);
        }
        user = DAL_User.getUsersByIds(userIds);
        owner = DAL_User.getUsersByIds(ownerIds);
        
        for(Task task:newTaskList)
        {
            if(task.Description==null)
                task.Description=' ';
            if(task.Line_of_Business__c !=null && task.Status=='Completed' && (task.OwnerId==ratingqueuegroup.Id || task.OwnerId==highProrityQueue.Id )){
                
                //Custom Notification Generation
                sendCustomNotification('BPO Completes the task on ' + task.Line_of_Business_Name__c,'Task on LOB is completed by BPO.\n\n' + ' BPO\'s comments:\n' + task.Description,notificationType.Id,n2gDomesticOperation.Id, task.Id );
                // Update LOB field Comments_from_BPO__c by Taks Description
                LOB_Management__c lobupdate = new LOB_Management__c(Comments_from_BPO__c =task.Description ,Id=Task.Line_of_Business__c);
                listofLOBupdate.add(lobupdate);
                task.OwnerId=n2gDomesticOperation.Id;
                task.Status='Open';
            }
            if(task.Line_of_Business__c !=null && task.Status=='Completed' && task.OwnerId==n2gDomesticOperation.Id)
            {
                //Custom Notification Generation
                sendCustomNotification('BPO Completes the task on ' + task.Line_of_Business_Name__c,'Task on LOB is completed by N2G Domestic Operations.\n\n' + ' BPO\'s comments:\n' + task.Description, notificationType.Id,task.Notifiieuserid__c, task.Id);
                LOB_Management__c lobupdate = new LOB_Management__c(Comments_from_BPO__c =task.Description ,Id=Task.Line_of_Business__c);
                listofLOBupdate.add(lobupdate);
                //N2G-757
                Id tasknewOwnerId=sendTaskNotificationEmail(task);
                if(tasknewOwnerId!=null)
                    task.OwnerId=tasknewOwnerId;
                else
                    task.OwnerId=task.Notifiieuserid__c;
                task.Status='Open';
            }
        }
        update listofLOBupdate;
        
    }
    
    public static void sendEmailForNewTask(List<Task> tasks) {
        String OppName='';
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> fetchedQuoteIds = new Set<Id>();
        Set<Id> underwritingAssociateIds = new Set<Id>();
        Set<String> underwriterNames = new Set<String>();
        Map<Id, String> underwritingAssociateEmails = new Map<Id, String>();
        Map<Id, String> underwritingAssociateName = new Map<Id, String>();
        Map<Id, Opportunity> opportunitiesMap= new Map<Id, Opportunity>();
        List<Quote> relatedQuotes;
        List<User> underwritingAssociates;
        List<User> underwriters;
        for (Task newTask : tasks) {
            if (newTask.Subject != null && newTask.Subject.startsWith('Binding Checklist Task') && newTask.WhatId != null) {
                quoteIds.add(newTask.WhatId);
            }
        }
        relatedQuotes = DAL_Quote.getQuotesByIds(quoteIds);
        for (Quote relatedQuote : relatedQuotes) {
            fetchedQuoteIds.add(relatedQuote.OpportunityId);
        }
        opportunitiesMap =DAL_Opportunity.getAllOpportunityMapById(fetchedQuoteIds);
        for (Opportunity opp : opportunitiesMap.values()) {
            OppName=opp.Name;
            if (opp.Underwriting_Associate__c != null) {
                underwritingAssociateIds.add(opp.Underwriting_Associate__c);
                
            }
        }
        
       /* underwritingAssociates = DAL_User.getUserRecordsByUserIdsSet(underwritingAssociateIds);
        for (User u : underwritingAssociates) {
            underwritingAssociateEmails.put(u.Id, u.Email);
            underwritingAssociateName.put(u.Id,u.Name);
        }*/
        for (Opportunity opp : opportunitiesMap.values()) {
            if (opp.Underwriter_Name__c != null) {
                underwriterNames.add(opp.Underwriter_Name__c);
            }
        }
        if(underwriterNames!=null)
        {
            underwriters =DAL_User.getUsersByName(underwriterNames);
            for (User u : underwriters) {
                underwritingAssociateEmails.put(u.Id, u.Email);
                underwritingAssociateName.put(u.Id,u.Name);
            }
        }
        EmailTemplate taskEmailTemplate1 = DAL_EmailTemplate.getTaskEmailTemplate('Task_Notification_of_Checklist_to_UWA_and_UW');
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail;
        Map<String, Object> emailMap = new Map<String, Object>();
        List<String> emailAddresses = new List<String>();
        if(underwritingAssociateEmails!=null)
        {
            for (String email : underwritingAssociateEmails.values()) {
                if (email != null) {
                    emailAddresses.add(email);
                }
            }
        }
        String emailUserName = '';
        boolean isFirst = true;
        for (String name : underwritingAssociateName.values()) {
            if (name != null) {
                if (isFirst) {
                    emailUserName += name;
                    isFirst = false;
                } else {
                    emailUserName += ' & ' + name;
                }
            }
        }
        emailMap.put('BothUWandUW',emailUserName);
        String orgDomain = URL.getOrgDomainUrl().getHost();
        for (Task newTask : tasks) {
            if (newTask.Subject != null && newTask.Priority == 'Normal' && newTask.Subject.startsWith('Binding Checklist Task') && newTask.WhatId != null) {
                emailMap.put('TaskLink', 'https://' + orgDomain + '/' + newTask.Id);
                
                
            }
        }
        System.debug('emailAddresses::'+emailAddresses);
        if (!emailAddresses.isEmpty()) {
            mail = new Messaging.SingleEmailMessage();
            
            mail.setToAddresses(emailAddresses);
            
            String subject=OppName+' | Binder Checklist Notification';    
            mail.setSubject(subject);
            if (taskEmailTemplate1.HtmlValue != null) {
                mail.setHtmlBody(replaceDynamicContent(emailMap, taskEmailTemplate1.HtmlValue));
            }
            emailList.add(mail);
            System.debug('mail::'+mail);
            System.debug('emailList::'+emailList);
            
            if (!emailList.isEmpty()) {
                try {
                    Messaging.sendEmail(emailList);
                    System.debug('Email sent successfully!');
                } catch (Exception e) {
                    System.debug('Error sending email: ' + e.getMessage());
                    //e.printStackTrace();
                }
            }
        }
        
        
        
    }
    //utility function for replacing dynamic content in a given text string
    public static string replaceDynamicContent(Map<String,Object> inputMap,String textToReplace){
        Pattern pattrn = Pattern.compile('\\{\\{[iI][fF]\\([a-zA-Z0-9\', .\\-]*\\)\\}\\}');
        Matcher matcher = pattrn.matcher(textToReplace);
        while(matcher.find()) {
            String conditionalVariable=matcher.group(0).replaceAll('\\{\\{[iI][fF]\\(','').replaceAll('\\)\\}\\}','');
            List<String> ConditionList=conditionalVariable.split(',\''); 
            String dynamicData='';
            if(ConditionList.size()>2){
                if(inputMap.get(ConditionList[0])!=null && Boolean.valueOf(inputMap.get(ConditionList[0]))){
                    dynamicData=ConditionList[1];
                }else{
                    dynamicData=ConditionList[2];
                }
            }
            if(dynamicData.length()>1 && dynamicData.substring(dynamicData.length()-1)=='\''){
                dynamicData=dynamicData.substring(0,dynamicData.length()-1);  
            }else{
                dynamicData='';
            }
            textToReplace=textToReplace.replaceAll('\\{\\{[iI][fF]\\('+conditionalVariable+'\\)\\}\\}', dynamicData);
        }        
        pattrn = Pattern.compile('\\{\\{[a-zA-Z0-9]*\\}\\}');
        matcher = pattrn.matcher(textToReplace);
        while(matcher.find()) {
            String variableName=matcher.group(0).replaceAll('\\{\\{','').replaceAll('\\}\\}','');
            if(string.valueOf(inputMap.get(variableName))!=null){
                // to remove $ issues for reason for request N2G-702
                String finalText=(string.valueOf(inputMap.get(variableName)).replaceAll('\\$','\\\\\\$'));
                textToReplace=textToReplace.replaceAll('\\{\\{'+variableName+'\\}\\}',finalText );
            }
        }        
        return textToReplace;
    }
    
    public static void sendCustomNotification(String title, String body, Id notificationTypeId, Id targetUserId, Id taskId) {
        // Custom Notification Generation
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(title);
        notification.setBody(body);
        notification.setNotificationTypeId(notificationTypeId);
        notification.setTargetId(taskId);
        
        try {
            notification.send(new Set<String>{targetUserId});
        } catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
            
        }
    }
    
    public static Id sendTaskNotificationEmail(Task task) {
        // Assuming DAL_EmailTemplate is a class with a method getTaskEmailTemplate
        EmailTemplate taskEmailTemplate = DAL_EmailTemplate.getTaskEmailTemplate('Task_Notification_UW');
        Messaging.SingleEmailMessage mail;
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Map<String, Object> emailMap = new Map<String, Object>();
        
        // Populate emailMap with relevant data
        String orgDomain = URL.getOrgDomainUrl().getHost();
        emailMap.put('TaskLink', 'https://' + orgDomain + '/' + task.Id);
        emailMap.put('TaskSubject', task.Subject);
        
        String email = null;
        String name = null;
        Id taskNewOwnerId = null;
        
        if (task.Notifiieuserid__c != null) {
            
            List<User> notifyingUsers =DAL_User.getNotifyingUsers(task.Notifiieuserid__c);
            
            if (!notifyingUsers.isEmpty()) {
                User notifyingUser = notifyingUsers[0];
                if (notifyingUser != null) {
                    if (notifyingUser.Underwriting_Associate__c != null) {
                        name = notifyingUser.Underwriting_Associate__r.Name;
                        taskNewOwnerId = notifyingUser.Underwriting_Associate__c;
                    } else {
                        name = notifyingUser.Name;
                        taskNewOwnerId = notifyingUser.Id;
                    }
                    email = notifyingUser.Email;
                }
            }
            
            if (name != null) {
                emailMap.put('TaskOwner', name);
            }
            
            mail = new Messaging.SingleEmailMessage();
            String subject = taskEmailTemplate.Subject;
            mail.setSubject(subject);
            
            // Set body by replacing dynamic content
            if (taskEmailTemplate.HtmlValue != null) {
                mail.setHtmlBody(replaceDynamicContent(emailMap, taskEmailTemplate.HtmlValue));
            }
            
            if (email != null) {
                mail.setToAddresses(new List<String>{ email });
                emailList.add(mail);
            }
            
            if (!emailList.isEmpty()) {
                Messaging.sendEmail(emailList);
            }
        }
        if(taskNewOwnerId!=null)
            return taskNewOwnerId;
        else
            return null;
    }
}