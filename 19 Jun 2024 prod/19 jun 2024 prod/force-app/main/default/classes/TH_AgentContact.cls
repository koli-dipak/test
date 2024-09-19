public class TH_AgentContact extends BaseTriggerHandler {
    
    private List<Agent_Contact__c> newAgentContactList;
    private List<Agent_Contact__c> oldAgentContactList;
    private Map<ID, Agent_Contact__c> newAgentContactMap;
    private Map<ID, Agent_Contact__c> oldAgentContactMap;
    
    public TH_AgentContact()
    {
        oldAgentContactList = (List<Agent_Contact__c>)Trigger.old;
        newAgentContactList = (List<Agent_Contact__c>)Trigger.new;
        newAgentContactMap = (Map<Id, Agent_Contact__c>)Trigger.newMap;
        oldAgentContactMap = (Map<Id, Agent_Contact__c>)Trigger.oldMap;
    }
    
    
    protected override void afterUpdate()
    {
        if(Trigger_PAD.canRun('TH_AgentContactAfterUpdate'))
        {
            proccesRecordAfterUpdate(newAgentContactList,oldAgentContactMap);
        }
    }
    protected override void beforeUpdate()
    {
        if(Trigger_PAD.canRun('TH_AgentContactBeforeUpdate'))
        {
            proccesRecordBeforeUpdate(newAgentContactList,oldAgentContactMap);
        }
    }
    
    
    public static void proccesRecordAfterUpdate(List<Agent_Contact__c> AgentContactLists,Map<ID, Agent_Contact__c> oldAgentContactMap)
    {
        List<String> listAgentContactToApprove=new List<String>();
        List<Messaging.SingleEmailmessage> listEmailToSend=new List<Messaging.SingleEmailmessage>();
        List<Task> listTaskToCreate=new List<Task>();
        for(Agent_Contact__c agtCon :AgentContactLists){
            if(agtCon.Status__c == 'Approved'){
                listAgentContactToApprove.add(agtCon.Id);
            }
            
        }
        
        List<Agent_Contact__c> agtConList = DAL_AgentContact.getAgentContactWithBrokerDetail(listAgentContactToApprove);
        
        set<String> listEmails=new set<String>();
        
        for(Agent_Contact__c agtCon : agtConList){
            if(agtCon.Status__c == 'Approved'){
                
                
                //Get Exiting Data To Update
                for(BrokerContact__c BroCont : agtCon.BrokerContacts__r){
                    listEmails.add(BroCont.Email__c);
                }
            }
        }
        Map<String,Id> EmailWiseContact=new Map<String,Id>();
        for(Contact con : DAL_Contact.getContactByEmail(listEmails)){
            EmailWiseContact.put(con.Email,Con.Id);
        }
        List<Events__c> listEventToCreate=new List<Events__c>();
        List<Top_Carriers__c> listTopCarrierToCreate=new List<Top_Carriers__c>();
        List<Specialty_Info__c> listSpecialtyInfoCreate=new List<Specialty_Info__c>();
        List<Broker_Line_of_Business__c> listLOBToCreate=new List<Broker_Line_of_Business__c>();
        Map<Id,Account> mapAccountToUpdate=new Map<Id,Account>();
        Map<String,String> accWiseHeadOfOfficeEmailMap=new Map<String,String>();
        Map<String,Contact> listBrokerContactToCreate=new Map<String,Contact>();
        
        for(Agent_Contact__c agtCon : agtConList){
            if(agtCon.Status__c == 'Approved'){
                
                // Create Contact Record If Found
                for(BrokerContact__c BroCont : agtCon.BrokerContacts__r){
                    if(BroCont.ObjectType__c=='Contact'){
                        Contact con=new Contact(AccountId=agtCon.Account__c,Salutation=BroCont.Salutation__c,FirstName=BroCont.FirstName__c,LastName=BroCont.LastName__c,Email=BroCont.Email__c,Phone=BroCont.Phone__c);
                        if(EmailWiseContact.containsKey(BroCont.Email__c)){
                            con.Id=EmailWiseContact.get(BroCont.Email__c);
                        }
                        listBrokerContactToCreate.put(con.Email,con);
                        if(BroCont.Type__c=='Broker'){
                            accWiseHeadOfOfficeEmailMap.put(agtCon.Account__c,con.Email);
                        }
                        /*else {
                            Contact con=new Contact(AccountId=agtCon.Account__c,FirstName=BroCont.FirstName__c,LastName=BroCont.LastName__c,Email=BroCont.Email__c,Phone=BroCont.Phone__c);
                            if(EmailWiseContact.containsKey(BroCont.Email__c)){
                                con.Id=EmailWiseContact.get(BroCont.Email__c);
                            }
                            listBrokerContactToCreate.put(con.Email,con);
                        }*/
                    }
                }
                
            }
        }
        upsert listBrokerContactToCreate.values();
        for(Agent_Contact__c agtCon : agtConList){
            if(agtCon.Status__c == 'Approved'){       
                for(BrokerContact__c BroCont : agtCon.BrokerContacts__r){    
                    if(BroCont.ObjectType__c=='Events'){
                        System.debug('Inside approved');
                        Events__c event = new Events__c();
                        event.Name = BroCont.Event_Name__c;
                        event.Event_Start_Date__c = BroCont.Event_Start_Date__c;
                        event.Event_End_Date__c = BroCont.Event_End_Date__c;
                        // event.Location__c = BroCont.Location__c;
                        event.Event_Street__c = BroCont.Event_Street__c;
                        event.Event_City__c = BroCont.Event_City__c;
                        event.Event_State__c = BroCont.Event_State__c;
                        event.Event_Country__c = BroCont.Event_Country__c;
                        event.Event_PostalCode__c = BroCont.Event_PostalCode__c;
                        event.account__c=agtCon.Account__c;
                        listEventToCreate.add(event);
                        //insert event;
                    }else if(BroCont.ObjectType__c=='TopCarrier'){    
                        //Create Top Carriers
                        Top_Carriers__c topCarriers = new Top_Carriers__c();
                        topCarriers.Competitor_Name__c = BroCont.Competitor_Name__c;
                        topCarriers.Comment__c = BroCont.Comment__c;
                        topCarriers.Premium__c = BroCont.Premium__c;
                        topCarriers.account__c=agtCon.Account__c;
                        listTopCarrierToCreate.add(topCarriers);
                        //insert topCarriers;
                    }else if(BroCont.ObjectType__c=='SpecialityInfo'){     
                        //create Specialty Info
                        Specialty_Info__c specialtyinfo = new Specialty_Info__c();
                        specialtyinfo.Product__c = BroCont.Product__c;
                        if(BroCont.Manager__c!=null ){
                            specialtyinfo.Manager__c = BroCont.Manager__c;
                        }else if(BroCont.Broker_Contact__c!=null && listBrokerContactToCreate.containsKey(BroCont.Broker_Contact__r.Email__c)){
                            specialtyinfo.Manager__c = listBrokerContactToCreate.get(BroCont.Broker_Contact__r.Email__c).Id;
                        }
                        specialtyinfo.Premium__c = BroCont.Premium__c;
                        specialtyinfo.Wholesale__c = BroCont.Wholesale__c;
                        specialtyinfo.Competitor_1__c = BroCont.Competitor_1__c;
                        specialtyinfo.Competitor_2__c = BroCont.Competitor_2__c;
                        specialtyinfo.Competitor_3__c = BroCont.Competitor_3__c;
                        specialtyinfo.account__c=agtCon.Account__c;
                        listSpecialtyInfoCreate.add(specialtyinfo);
                        //insert specialtyinfo;
                    }else if(BroCont.ObjectType__c=='LineOfBusiness'){     
                        //create Specialty Info
                        Broker_Line_of_Business__c LOB = new Broker_Line_of_Business__c();
                        LOB.Engagement_Product__c = BroCont.Product__c;
                        if(BroCont.Manager__c!=null ){
                            LOB.Broker_Manager__c = BroCont.Manager__c;
                        }else if(BroCont.Broker_Contact__c!=null && listBrokerContactToCreate.containsKey(BroCont.Broker_Contact__r.Email__c)){
                            LOB.Broker_Manager__c = listBrokerContactToCreate.get(BroCont.Broker_Contact__r.Email__c).Id;
                        }
                        LOB.Premium__c = BroCont.Premium__c;
                        LOB.Wholesale__c = BroCont.Wholesale__c;
                        LOB.Competitor_1__c = BroCont.Competitor_1__c;
                        LOB.Competitor_2__c = BroCont.Competitor_2__c;
                        LOB.Competitor_3__c = BroCont.Competitor_3__c;
                        LOB.Broker_Account__c=agtCon.Account__c;
                        listLOBToCreate.add(LOB);
                        //insert LOB;
                    }
                    
                    
                }
                
                // Update Account
                Account Acc=new Account();
                acc.Id=agtCon.Account__c;
                acc.website = agtCon.website__c;
                acc.NumberOfEmployees =  Integer.valueOf(agtCon.No_of_Employees__c);
                if(agtCon.Head_of_Office__c!=null){
                    acc.Head_of_Office__c = agtCon.Head_of_Office__c;
                }
                if(accWiseHeadOfOfficeEmailMap.containsKey(agtCon.Account__c) && listBrokerContactToCreate.containsKey(accWiseHeadOfOfficeEmailMap.get(agtCon.Account__c))){
                    acc.Head_of_Office__c = listBrokerContactToCreate.get(accWiseHeadOfOfficeEmailMap.get(agtCon.Account__c)).Id;
                }
                acc.Annual_Premium_Volumne__c = agtCon.Annual_Premium_Volumne__c;
                acc.BillingStreet =agtCon.Street__c;
                acc.BillingCity = agtCon.City__c;
                acc.BillingState= agtCon.State__c ;
                acc.BillingPostalCode = agtCon.PostalCode__c;
                acc.BillingCountry =agtCon.Country__c;
                mapAccountToUpdate.put(acc.Id,acc);
                //update acc;
                
                /*EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName= 'Contact_Approve_Email'];
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setWhatId(agtCon.Id);
                email.setTemplateId(emailTemplate.Id);
                //email.setToAddresses(new List<String>{agtCon.Owner.Email});
                email.setSaveAsActivity(false);
                email.setTargetObjectId(agtCon.Owner.Id);
                email.setTreatTargetObjectAsRecipient(false);
                listEmailToSend.add(email);
                
                Task T=new Task();
                T.WhoId=agtCon.Owner.Id;
                T.Priority='Normal';
                T.Status='Open';
                T.WhatId=agtCon.Account__c;
                T.Subject='Contact Information Pending for Approval';
                T.Description='New Agent Contact Info Required';
                listTaskToCreate.add(T);*/
            }
            
        }
        insert listEventToCreate;
        insert listTopCarrierToCreate;
        insert listSpecialtyInfoCreate;
        insert listLOBToCreate;
        
        update mapAccountToUpdate.values();
        
       /* if(listEmailToSend.size()>0){
            insert listTaskToCreate;
            Messaging.SendEmailResult[] results = Messaging.sendEmail(listEmailToSend);
            
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }*/
    }
    public static void proccesRecordBeforeUpdate(List<Agent_Contact__c> AgentContactLists,Map<ID, Agent_Contact__c> oldAgentContactMap)
    {
        List<String> listAgentContactToApprove=new List<String>();
        List<Messaging.SingleEmailmessage> listEmailToSend=new List<Messaging.SingleEmailmessage>();
        List<Task> listTaskToCreate=new List<Task>();
        for(Agent_Contact__c agtCon :AgentContactLists){
            if(agtCon.Status__c == 'Resend'){
                agtCon.Is_Link_Expired__c=false;
                agtCon.IsSubmitted__c=false;
            }
            
        }
    }
}