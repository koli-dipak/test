global class BatchTaskReminder implements Schedulable {
    global void execute(SchedulableContext ctx) {
        List<Task> tasks = [SELECT Id, Subject, WhatId, Owner.Email, Owner.Name 
                            FROM Task 
                            WHERE Subject LIKE 'Binding Checklist Task%' 
                            AND Status != 'Completed'];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate taskEmailTemplate1 = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Task_Notification_of_Checklist_to_UWA_and_UW' LIMIT 1];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail;
        Map<String, Object> emailMap = new Map<String, Object>();
        
        List<String> emailAddresses = new List<String>();
        String orgDomain = URL.getOrgDomainUrl().getHost();
        for (Task newTask : tasks) {
            
            emailMap.put('BothUWandUW',newTask.Owner.Name);
            emailMap.put('TaskLink', 'https://' + orgDomain + '/' + newTask.Id);
            
            mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(newTask.OwnerId);
            mail.setSaveAsActivity(false);
            String originalString = newTask.Subject;
            String updatedString = originalString.replaceAll('^Binding Checklist Task\\s*', '').trim();
            String subject=updatedString +' | Binder Checklist Notification';    
            mail.setSubject(subject);
            if (taskEmailTemplate1.HtmlValue != null) {
                mail.setHtmlBody(replaceDynamicContent(emailMap, taskEmailTemplate1.HtmlValue));
            }
            emailList.add(mail);
            
        }
        
        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
        }   
        
        
        
    }
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
    
}