public class EmailHelperClass {
    @AuraEnabled
    public static List<SObject> search(String searchString, String AccountId) {
        List<SObject> searchList = new List<SObject>();
        try {
            String searchStr = '*' + searchString + '*';
            String searchquery =
                'FIND\'' +
                searchStr +
                '\'IN ALL FIELDS RETURNING Contact(Id, Name, Email WHERE Email != null AND AccountId = :AccountId) LIMIT 10';
                // , User(id, name, email where email != null AND isActive = true)
            List<List<SObject>> searchResult = search.query(searchquery);
            for (List<SObject> curList : searchResult) {
                searchList.addAll(curList);
            }
            system.debug('searchList:::' + searchList.size());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return searchList;
    }

    @AuraEnabled
    public static void sendEmail(String emailDetailStr, String contactId){
        EmailHelperWrapper emailDetails = (EmailHelperWrapper) JSON.deserialize(emailDetailStr, EmailHelperWrapper.class);
        try{
            List<Contact> selectedContact = DAL_Contact.getContactById(contactId);
            if(selectedContact.size() > 0){
                 
                Agent_Contact__c agtCon = new Agent_Contact__c();
                agtCon.Name = selectedContact[0].Name;
                agtCon.Contact_Number__c = selectedContact[0].Phone;
                agtCon.Contact_Name__c = selectedContact[0].Name;
                agtCon.Email__c = selectedContact[0].Email;
                agtCon.Account__c = selectedContact[0].AccountId;
                agtCon.Website__c = selectedContact[0].Account.website;
                agtCon.No_of_Employees__c =  selectedContact[0].Account.NumberOfEmployees;
                agtCon.Head_of_Office__c = selectedContact[0].Account.Head_of_Office__c;
                agtCon.Annual_Premium_Volumne__c = selectedContact[0].Account.Annual_Premium_Volumne__c;
                agtCon.Distribution_Leader__c = selectedContact[0].Account.Distribution_Leader__r.Name;
                agtCon.Street__c = selectedContact[0].Account.BillingStreet;
                agtCon.City__c = selectedContact[0].Account.BillingCity;
                agtCon.State__c = selectedContact[0].Account.BillingState;
                agtCon.PostalCode__c = selectedContact[0].Account.BillingPostalCode;
                agtCon.Country__c =selectedContact[0].Account.BillingCountry;
                agtCon.Agency_Name__c = selectedContact[0].Account.Name;
                agtCon.Broker_Code__c = selectedContact[0].Account.Broker_External_Id__c;
                // agtCon.Comment__c = comment;
                agtCon.Manager__c  = selectedContact[0].Id;
                insert agtCon;
                
                String agtConencryptId = System.EncodingUtil.base64Encode(Blob.valueOf(agtCon.Id));
                agtCon.Encrypted_Id__c = agtConencryptId;
                update agtCon;
                
                OrgWideEmailAddress orgWideEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName =:System.Label.N2G_Broker_Management_Email_Display_Name];

                string stringToReplace = '<a href="' + System.Label.Broker_Portal_URL+agtConencryptId + '">Click here to Open broker Portal</a>';

                emailDetails.body = emailDetails.body.replaceAll('\\{'+System.Label.Dont_change_this_value_in_email_body+'\\}', stringToReplace);
                System.debug('@@emailDetails.body::'+emailDetails.body);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSaveAsActivity(true);
                email.setOrgWideEmailAddressId(orgWideEmail.Id);
                email.setTargetObjectId((Id)contactId);
                email.setTreatTargetObjectAsRecipient(false);
                email.setSubject(emailDetails.subject);
                email.setHtmlBody(emailDetails.body);
                email.setToAddresses(emailDetails.toAddress);
                email.setCcAddresses(emailDetails.ccAddress);
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
                
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }
            }
            
        }catch(Exception ex){
            System.debug('Error-->'+ex.getMessage());
        }
    }


    @AuraEnabled
    public static void sendEmailController(String emailDetailStr) {
        EmailHelperWrapper emailDetails = (EmailHelperWrapper) JSON.deserialize(emailDetailStr, EmailHelperWrapper.class);
        Messaging.reserveSingleEmailCapacity(1);
        try {
            messaging.SingleEmailMessage mail = new messaging.SingleEmailMessage();
            mail.setToAddresses(emailDetails.toAddress);
            mail.setCcAddresses(emailDetails.ccAddress);
            mail.setReplyTo('noreply@n2g.com'); //noreply@n2g.com
            mail.setSenderDisplayName('N2G'); // N2G
            mail.setSubject(emailDetails.subject);
            mail.setHtmlBody(emailDetails.body);
            //mail.setEntityAttachments(emailDetails.files);
            Messaging.sendEmail(new List<messaging.SingleEmailMessage>{ mail });
        } catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static SObject getDefaultEmailTemplateRecord(){
        String emailTemplateDeveloperName = System.Label.Request_Broker_Updates_Account_Email_Template;
        EmailTemplate emailTemplateRec = DAL_Utility.getEmailTemplateRecByDeveloperName(emailTemplateDeveloperName);
        return emailTemplateRec;
    }

    @AuraEnabled
    public static SObject getDynamicEmailTemplateRecord(String ContactId){
        System.debug('@@ContactId::'+ContactId);
        List<String> allMergeFieldNamesList = new List<String>();

        String emailTemplateDeveloperName = System.Label.Request_Broker_Updates_Account_Email_Template;
        EmailTemplate emailTemplateRec = DAL_Utility.getEmailTemplateRecByDeveloperName(emailTemplateDeveloperName);
        Set<String> allMergeFieldNamesSet = getSalesforceFieldNames(emailTemplateRec.HtmlValue);
        Map<String, SObjectField> fields = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
        System.debug('@@fields::'+fields.keySet());
        for(String field : allMergeFieldNamesSet){
            System.debug('@@field::'+field);
            if(!fields.containsKey(field)){
                System.debug('@@inside:::');
                allMergeFieldNamesSet.remove(field);
            }
        }
        System.debug('@@allMergeFieldNamesSet::'+allMergeFieldNamesSet);
        allMergeFieldNamesList.addAll(allMergeFieldNamesSet);

        String fieldNamesToQuery = String.join( allMergeFieldNamesList, ', ' );
        if(String.isBlank(fieldNamesToQuery)){
            fieldNamesToQuery = 'Id';
        }
        String query = 'SELECT ' + fieldNamesToQuery + ' FROM Contact WHERE Id = \''+ ContactId + '\' LIMIT 1';
        Contact contactRec = Database.query(query);
        emailTemplateRec.HtmlValue = getDynamicSMSText(contactRec, emailTemplateRec.HtmlValue, allMergeFieldNamesSet);
        System.debug('@@emailTemplateRec.HtmlValue::'+emailTemplateRec.HtmlValue);
        return emailTemplateRec;
    }


    //Replace Field name and calls from Invocable Method
    public static set<String> getSalesforceFieldNames(String textToReplace){
        system.debug('@@textToReplace :: '+textToReplace);
        set<String> listFieldName=new set<String>();
        if(textToReplace==null) return listFieldName;
        Pattern pattrn = Pattern.compile('\\{\\{[iI][fF]\\([a-zA-Z0-9\', .\\-]*\\)\\}\\}');
        Matcher matcher = pattrn.matcher(textToReplace);
       
        pattrn = Pattern.compile('\\{\\{[a-zA-Z0-9]*\\}\\}');
        matcher = pattrn.matcher(textToReplace);
        while(matcher.find()) {
            String fieldName=matcher.group(0).replaceAll('\\{\\{','').replaceAll('\\}\\}','');
            listFieldName.add(fieldName);
        }        
        
        return listFieldName;
    }
    
    //remove curly braces calls from Invocable Method
    public static string getDynamicSMSText(Contact con,String textToReplace, Set<String> allMergeFieldNamesSet){
        
        Pattern pattrn = Pattern.compile('\\{\\{[iI][fF]\\([a-zA-Z0-9\', .\\-]*\\)\\}\\}');
        Matcher matcher = pattrn.matcher(textToReplace);
       
        pattrn = Pattern.compile('\\{\\{[a-zA-Z0-9]*\\}\\}');
        matcher = pattrn.matcher(textToReplace);
        while(matcher.find()) {
            String fieldName=matcher.group(0).replaceAll('\\{\\{','').replaceAll('\\}\\}','');
            if(string.valueOf(fieldName)!=null && allMergeFieldNamesSet.contains(fieldName) && string.valueOf(con.get(fieldName)) != null){
                textToReplace=textToReplace.replaceAll('\\{\\{'+fieldName+'\\}\\}', string.valueOf(con.get(fieldName)));
            }
            else if(allMergeFieldNamesSet.contains(fieldName) && string.valueOf(con.get(fieldName)) == null){
                textToReplace=textToReplace.replaceAll('\\{\\{'+fieldName+'\\}\\}', '');
            }
        }        
        
        return textToReplace;
    }

    Public Class EmailHelperWrapper {
        public List<String> toAddress;
        public List<String> ccAddress;
        public String subject;
        public String body;
        //public List<String> files;
    }
}