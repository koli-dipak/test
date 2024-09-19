public without sharing class RequestContactUpdateController {
    @AuraEnabled
    public static String getContactRecords(String accountId){
        List<Contact> contactList = DAL_Contact.getContactByAcc(accountId);
        return JSON.serialize(contactList);
    }
    
    @AuraEnabled
    public static void sendEmail(String recordId, String contactId,String comment){
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(recordId);
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
                agtCon.Comment__c = comment;
                agtCon.Manager__c  = selectedContact[0].Id;
                insert agtCon;
                
                String agtConencryptId = System.EncodingUtil.base64Encode(Blob.valueOf(agtCon.Id));
                agtCon.Encrypted_Id__c = agtConencryptId;
                update agtCon;
                
                EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName= 'Contact_Verification_Email'];
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setWhatId(agtCon.Id);
                email.setTemplateId(emailTemplate.Id);
                email.setToAddresses(new List<String>{selectedContact[0].Email});
                email.setSaveAsActivity(false);
                email.setTargetObjectId(selectedContact[0].Id);
                email.setTreatTargetObjectAsRecipient(false);
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
    
   @AuraEnabled(cacheable = true )
    public static Agent_Contact__c getAgentContactData(String recordId){
        List<Agent_Contact__c> listAC= DAL_AgentContact.getAgentContactById(recordId);
        if(listAC.size()>0){
            return listAC[0];
        }
        return null;
    }
    @AuraEnabled
    public static string getAgentContactDetail(String recordId){
        Map<String,Object> returnMap=new Map<string,Object>();
        Agent_Contact__c AC;
        List<Agent_Contact__c> listAC= DAL_AgentContact.getAgentContactWithBrokerDetail(recordId);
        if(listAC.size()>0){
            AC=listAC[0];
        }else{
            return JSON.serialize(returnMap);
        }
        
        
        
        returnMap.put('Data',AC);
        returnMap.put('Competitor1',picklistValues('Agent_Contact__c','Competitor_1__c'));
        returnMap.put('Competitor2',picklistValues('Agent_Contact__c','Competitor_2__c'));
        returnMap.put('Competitor3',picklistValues('Agent_Contact__c','Competitor_3__c'));
        returnMap.put('CompetitorName',picklistValues('Agent_Contact__c','Competitor_Name__c'));
        returnMap.put('LOBCompetitor1',picklistValues('Broker_Line_of_Business__c','Competitor_1__c'));
        returnMap.put('LOBCompetitor2',picklistValues('Broker_Line_of_Business__c','Competitor_2__c'));
        returnMap.put('LOBCompetitor3',picklistValues('Broker_Line_of_Business__c','Competitor_3__c'));
        returnMap.put('LOBProduct',picklistValues('Broker_Line_of_Business__c','Engagement_Product__c'));
        returnMap.put('Salutation',picklistValues('BrokerContact__c','Salutation__c'));
        if(AC.Id!=null){
            returnMap.put('Events',DAL_BrokerContact.getBrokerContactById(AC.Id, 'Events'));
            returnMap.put('TopCarrier',DAL_BrokerContact.getBrokerContactById(AC.Id, 'TopCarrier'));
            returnMap.put('SpecialityInfo',DAL_BrokerContact.getBrokerContactById(AC.Id, 'SpecialityInfo'));
            returnMap.put('LineOfBusiness',DAL_BrokerContact.getBrokerContactById(AC.Id, 'LineOfBusiness'));
            returnMap.put('BrokerContact',DAL_BrokerContact.getBrokerContactById(AC.Id, 'Contact','Broker'));
        }
        return JSON.serialize(returnMap);
    }
    
    public static Map<String, String> picklistValues(String objectName, String fieldName) {
        Map<String, String> values = new Map<String, String>();
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectName});
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    values.put(entry.getValue(), entry.getLabel());
                }
            }
        }
        
        return values;
    }
    
    @AuraEnabled
    public static string getContactDetails(String filter){
        filter='%'+filter+'%';
        List<Contact> con= [SELECT Id,Name FROM Contact Where name like :filter limit 1000];
        return JSON.serialize(con);
    }

    @AuraEnabled
    public static List<BrokerContact__c> updateAgentContact(String recordData,String headOfOfficeRec,String events,String specInfo,String topCarrier,String LOBInfo){
        Agent_Contact__c agtCon = new Agent_Contact__c();
        agtCon = (Agent_Contact__c)System.JSON.deserialize(recordData, Agent_Contact__c.class);
        
        delete [select id from BrokerContact__c where Agent_Contact__c = :agtCon.Id];
        if(headOfOfficeRec!=null){
            Map<String,Object> mapCreateRec=(Map<String,Object>) JSON.deserializeUntyped(headOfOfficeRec);
            if(mapCreateRec.containsKey('LastName') &&  mapCreateRec.containsKey('isSaved')  && Boolean.valueOf(mapCreateRec.get('isSaved'))){
                BrokerContact__c BrokerCon=new BrokerContact__c();
                BrokerCon.Salutation__c=String.valueOf(mapCreateRec.get('Salutation'));
                BrokerCon.FirstName__c=String.valueOf(mapCreateRec.get('FirstName'));
                BrokerCon.LastName__c=String.valueOf(mapCreateRec.get('LastName'));
                BrokerCon.Email__c=String.valueOf(mapCreateRec.get('Email'));
                BrokerCon.Phone__c=String.valueOf(mapCreateRec.get('Phone'));
                BrokerCon.Type__c='Broker';
                BrokerCon.Agent_Contact__c=agtCon.Id;
                BrokerCon.ObjectType__c='Contact';
                insert BrokerCon;
            }
           
        }
        
        List<BrokerContact__c> listContactToUpsert=new List<BrokerContact__c>();
        // Create Event Records
        if(events!=null ){
            List<Object> listEvents=(List<Object>) JSON.deserializeUntyped(events);
            for(Object records : listEvents){
                Map<String,Object> rec=(Map<String,Object>) records;
                BrokerContact__c BrokerCon=new BrokerContact__c();
                BrokerCon.Event_Name__c=String.valueOf(rec.get('Event_Name__c'));
                // BrokerCon.Location__c=String.valueOf(rec.get('Location__c'));
                BrokerCon.Event_Street__c=String.valueOf(rec.get('Event_Street__c'));
                BrokerCon.Event_City__c=String.valueOf(rec.get('Event_City__c'));
                BrokerCon.Event_State__c=String.valueOf(rec.get('Event_State__c'));
                BrokerCon.Event_Country__c=String.valueOf(rec.get('Event_Country__c'));
                BrokerCon.Event_PostalCode__c=String.valueOf(rec.get('Event_PostalCode__c'));
                if(String.valueOf(rec.get('Event_End_Date__c'))!=null){
                    BrokerCon.Event_End_Date__c=Date.valueOf(String.valueOf(rec.get('Event_End_Date__c')));
                }
                if(String.valueOf(rec.get('Event_Start_Date__c'))!=null){
                    BrokerCon.Event_Start_Date__c=Date.valueOf(String.valueOf(rec.get('Event_Start_Date__c')));
                
                }
                BrokerCon.Phone__c=String.valueOf(rec.get('Phone__c'));
                //BrokerCon.Type__c='SpecificInfo';
                BrokerCon.Agent_Contact__c=agtCon.Id;
                BrokerCon.ObjectType__c='Events';
                //insert BrokerCon;
                listContactToUpsert.add(BrokerCon);
            }
        }
        
        // Create Top Carrier Records
        if(topCarrier!=null ){
            List<Object> listEvents=(List<Object>) JSON.deserializeUntyped(topCarrier);
            for(Object records : listEvents){
                Map<String,Object> rec=(Map<String,Object>) records;
                BrokerContact__c BrokerCon=new BrokerContact__c();
                BrokerCon.Competitor_Name__c=String.valueOf(rec.get('Competitor_Name__c'));
                BrokerCon.Comment__c=String.valueOf(rec.get('Comment__c'));
                if(!String.isBlank(String.valueOf(rec.get('Premium__c')))){
                    BrokerCon.Premium__c=Decimal.valueOf(String.valueOf(rec.get('Premium__c')));
                }
                
                //BrokerCon.Type__c='SpecificInfo';
                BrokerCon.Agent_Contact__c=agtCon.Id;
                BrokerCon.ObjectType__c='TopCarrier';
                //insert BrokerCon;
                listContactToUpsert.add(BrokerCon);
            }
        }
        
        // Create Speciality Info Records
        if(specInfo!=null ){
            List<Object> listEvents=(List<Object>) JSON.deserializeUntyped(specInfo);
            Map<String,BrokerContact__c> listBrokerContact=new Map<String,BrokerContact__c>();
            for(Object records : listEvents){
                Map<String,Object> rec=(Map<String,Object>) records;
                //BrokerCon.Manager__c=String.valueOf(rec.get('Manager__c'));
                if( rec.get('Manager__c')  instanceof map<string,object> ){
                    Map<String,Object> mapCreateRec=(Map<String,Object>) rec.get('Manager__c');
                    if(mapCreateRec!=null &&  mapCreateRec.containsKey('isSaved') && Boolean.valueOf(mapCreateRec.get('isSaved'))){
                        BrokerContact__c BrokerCon=new BrokerContact__c();
                        BrokerCon.Salutation__c=String.valueOf(mapCreateRec.get('Salutation'));
                        BrokerCon.FirstName__c=String.valueOf(mapCreateRec.get('FirstName'));
                        BrokerCon.LastName__c=String.valueOf(mapCreateRec.get('LastName'));
                        BrokerCon.Email__c=String.valueOf(mapCreateRec.get('Email'));
                        BrokerCon.Phone__c=String.valueOf(mapCreateRec.get('Phone'));
                        BrokerCon.Type__c='SpecialityInfo';
                        BrokerCon.Agent_Contact__c=agtCon.Id;
                        BrokerCon.ObjectType__c='Contact';
                        listBrokerContact.put(BrokerCon.Email__c,BrokerCon);
                    }
                }
                
            }
            insert listBrokerContact.values();
            for(Object records : listEvents){
                Map<String,Object> rec=(Map<String,Object>) records;
                BrokerContact__c BrokerCon=new BrokerContact__c();
                BrokerCon.Product__c=String.valueOf(rec.get('Product__c'));
                if( rec.get('Manager__c')  instanceof map<string,object> ){
                    
                    Map<String,Object> mapCreateRec=(Map<String,Object>) rec.get('Manager__c');
                    if(mapCreateRec!=null ){
                        String Email=String.valueOf(mapCreateRec.get('Email'));
                        if(Email!=null && mapCreateRec.containsKey('isSaved') && Boolean.valueOf(mapCreateRec.get('isSaved')) && listBrokerContact.containsKey(Email)){
                            BrokerCon.Broker_Contact__c= listBrokerContact.get(Email).Id;
                        }else if(Email!=null && mapCreateRec.containsKey('Id')){
                            BrokerCon.Manager__c=String.valueOf(mapCreateRec.get('Id'));
                        }
                    }
                }
                
                //BrokerCon.Manager__c=String.valueOf(rec.get('Manager__c'));
                if(!String.isBlank(String.valueOf(rec.get('Premium__c')))){
                     BrokerCon.Premium__c=Decimal.valueOf(String.valueOf(rec.get('Premium__c')));
                }
                if(!String.isBlank(String.valueOf(rec.get('Wholesale__c')))){
                     BrokerCon.Wholesale__c=Decimal.valueOf(String.valueOf(rec.get('Wholesale__c')));
                }
                
                BrokerCon.Competitor_1__c=String.valueOf(rec.get('Competitor_1__c'));
                BrokerCon.Competitor_2__c=String.valueOf(rec.get('Competitor_2__c'));
                BrokerCon.Competitor_3__c=String.valueOf(rec.get('Competitor_3__c'));
                //BrokerCon.Type__c='SpecificInfo';
                BrokerCon.Agent_Contact__c=agtCon.Id;
                BrokerCon.ObjectType__c='SpecialityInfo';
                //insert BrokerCon;
                listContactToUpsert.add(BrokerCon);
            }
        }

        // Create LOB Records
        if(LOBInfo!=null ){
            List<Object> listEvents=(List<Object>) JSON.deserializeUntyped(LOBInfo);
            Map<String,BrokerContact__c> listBrokerContact=new Map<String,BrokerContact__c>();
            for(Object records : listEvents){
                Map<String,Object> rec=(Map<String,Object>) records;
                //BrokerCon.Manager__c=String.valueOf(rec.get('Manager__c'));
                if( rec.get('Manager__c')  instanceof map<string,object> ){
                    Map<String,Object> mapCreateRec=(Map<String,Object>) rec.get('Manager__c');
                    if(mapCreateRec!=null &&  mapCreateRec.containsKey('isSaved') && Boolean.valueOf(mapCreateRec.get('isSaved'))){
                        BrokerContact__c BrokerCon=new BrokerContact__c();
                        BrokerCon.Salutation__c=String.valueOf(mapCreateRec.get('Salutation'));
                        BrokerCon.FirstName__c=String.valueOf(mapCreateRec.get('FirstName'));
                        BrokerCon.LastName__c=String.valueOf(mapCreateRec.get('LastName'));
                        BrokerCon.Email__c=String.valueOf(mapCreateRec.get('Email'));
                        BrokerCon.Phone__c=String.valueOf(mapCreateRec.get('Phone'));
                        BrokerCon.Type__c='LineOfBusiness';
                        BrokerCon.Agent_Contact__c=agtCon.Id;
                        BrokerCon.ObjectType__c='Contact';
                        listBrokerContact.put(BrokerCon.Email__c,BrokerCon);
                    }
                }
                
            }
            insert listBrokerContact.values();
            for(Object records : listEvents){
                Map<String,Object> rec=(Map<String,Object>) records;
                BrokerContact__c BrokerCon=new BrokerContact__c();
                BrokerCon.Product__c=String.valueOf(rec.get('Product__c'));
                if( rec.get('Manager__c')  instanceof map<string,object> ){
                    
                    Map<String,Object> mapCreateRec=(Map<String,Object>) rec.get('Manager__c');
                    if(mapCreateRec!=null ){
                        String Email=String.valueOf(mapCreateRec.get('Email'));
                        if(Email!=null && mapCreateRec.containsKey('isSaved') && Boolean.valueOf(mapCreateRec.get('isSaved')) && listBrokerContact.containsKey(Email)){
                            BrokerCon.Broker_Contact__c= listBrokerContact.get(Email).Id;
                        }else if(Email!=null && mapCreateRec.containsKey('Id')){
                            BrokerCon.Manager__c=String.valueOf(mapCreateRec.get('Id'));
                        }
                    }
                }
                
                //BrokerCon.Manager__c=String.valueOf(rec.get('Manager__c'));
                if(!String.isBlank(String.valueOf(rec.get('Premium__c')))){
                     BrokerCon.Premium__c=Decimal.valueOf(String.valueOf(rec.get('Premium__c')));
                }
                if(!String.isBlank(String.valueOf(rec.get('Wholesale__c')))){
                     BrokerCon.Wholesale__c=Decimal.valueOf(String.valueOf(rec.get('Wholesale__c')));
                }
                
                BrokerCon.Competitor_1__c=String.valueOf(rec.get('Competitor_1__c'));
                BrokerCon.Competitor_2__c=String.valueOf(rec.get('Competitor_2__c'));
                BrokerCon.Competitor_3__c=String.valueOf(rec.get('Competitor_3__c'));
                //BrokerCon.Type__c='SpecificInfo';
                BrokerCon.Agent_Contact__c=agtCon.Id;
                BrokerCon.ObjectType__c='LineOfBusiness';
                //insert BrokerCon;
                listContactToUpsert.add(BrokerCon);
            }
        }
        
        upsert listContactToUpsert;
        
        agtCon.Is_Link_Expired__c=true;
        agtCon.IsSubmitted__c =true;
        agtCon.Status__c='Pending';
        upsert agtCon;
        return listContactToUpsert;
         
    }
    
    @AuraEnabled
    public static void updateReleatedObject(String recordId){
        Agent_Contact__c agtCon ;
        List<Agent_Contact__c> listAC= DAL_AgentContact.getAgentContactWithBrokerDetail(recordId);
        if(listAC.size()>0){
            agtCon=listAC[0];
        }else{
            return;
        }
        
        if(agtCon.Status__c == 'Approved'){
            
            String HeadOfOfficeContact,BrokerManager;
            Map<String,Contact> listBrokerContactToCreate=new Map<String,Contact>();
            
            set<String> listEmails=new set<String>();
            //Get Exiting Data To Update 
            for(BrokerContact__c BroCont : agtCon.BrokerContacts__r){
                listEmails.add(BroCont.Email__c);
            }
            Map<String,Id> EmailWiseContact=new Map<String,Id>();
            for(Contact con : DAL_Contact.getContactByEmail(listEmails)){
                EmailWiseContact.put(con.Email,Con.Id);
            }
            
            // Create Contact Record If Found
            for(BrokerContact__c BroCont : agtCon.BrokerContacts__r){
                if(BroCont.ObjectType__c=='Contact'){
                    if(BroCont.Type__c!='Broker'){
                        Contact con=new Contact(AccountId=agtCon.Account__c,FirstName=BroCont.FirstName__c,LastName=BroCont.LastName__c,Email=BroCont.Email__c,Phone=BroCont.Phone__c);
                        //insert con;
                        //BrokerManager=con.Id;
                        if(EmailWiseContact.containsKey(BroCont.Email__c)){
                            con.Id=EmailWiseContact.get(BroCont.Email__c);
                        }
                        listBrokerContactToCreate.put(con.Email,con);
                    }else {
                        Contact con=new Contact(AccountId=agtCon.Account__c,FirstName=BroCont.FirstName__c,LastName=BroCont.LastName__c,Email=BroCont.Email__c,Phone=BroCont.Phone__c);
                        if(EmailWiseContact.containsKey(BroCont.Email__c)){
                            con.Id=EmailWiseContact.get(BroCont.Email__c);
                        }
                        upsert con;
                        HeadOfOfficeContact=con.Id;
                    }
                }
            }
            upsert listBrokerContactToCreate.values();
            Integer count=0;
            List<Events__c> listEventToCreate=new List<Events__c>();
            List<Top_Carriers__c> listTopCarrierToCreate=new List<Top_Carriers__c>();
            List<Specialty_Info__c> listSpecialtyInfoCreate=new List<Specialty_Info__c>();
            List<Broker_Line_of_Business__c> listOfLOBToCreate=new List<Broker_Line_of_Business__c>();
            for(BrokerContact__c BroCont : agtCon.BrokerContacts__r){    
                 if(BroCont.ObjectType__c=='Events'){
                     System.debug('Inside approved');
                    Events__c event = new Events__c();
                    event.Name = BroCont.Event_Name__c;
                    event.Event_Start_Date__c = BroCont.Event_Start_Date__c;
                    event.Event_End_Date__c = BroCont.Event_End_Date__c;
                    //event.Location__c = BroCont.Location__c;
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
                    // insert specialtyinfo;
                    System.debug('specialtyinfo##########'+specialtyinfo);
                }else if(BroCont.ObjectType__c=='LineOfBusiness'){     
                    //create Specialty Info
                    Broker_Line_of_Business__c LOBInfo = new Broker_Line_of_Business__c();
                    LOBInfo.Product__c = BroCont.Product__c;
                    if(BroCont.Manager__c!=null ){
                        LOBInfo.Broker_Manager__c = BroCont.Manager__c;
                    }else if(BroCont.Broker_Contact__c!=null && listBrokerContactToCreate.containsKey(BroCont.Broker_Contact__r.Email__c)){
                        LOBInfo.Broker_Manager__c = listBrokerContactToCreate.get(BroCont.Broker_Contact__r.Email__c).Id;
                    }
                    LOBInfo.Premium__c = BroCont.Premium__c;
                    LOBInfo.Wholesale__c = BroCont.Wholesale__c;
                    LOBInfo.Competitor_1__c = BroCont.Competitor_1__c;
                    LOBInfo.Competitor_2__c = BroCont.Competitor_2__c;
                    LOBInfo.Competitor_3__c = BroCont.Competitor_3__c;
                    LOBInfo.Broker_Account__c=agtCon.Account__c;
                    listOfLOBToCreate.add(LOBInfo);
                    System.debug('LOBInfo##########'+LOBInfo);
                }
                
                
            }
            
            insert listEventToCreate;
            insert listTopCarrierToCreate;
            insert listSpecialtyInfoCreate;
            //insert listSpecialtyInfoCreate;
            insert listOfLOBToCreate;
            
            // Update Account
            Account Acc=new Account();
            acc.Id=agtCon.Account__c;
            acc.website = agtCon.website__c;
            acc.NumberOfEmployees =  Integer.valueOf(agtCon.No_of_Employees__c);
            if(agtCon.Head_of_Office__c!=null){
                acc.Head_of_Office__c = agtCon.Head_of_Office__c;
            }
            if(HeadOfOfficeContact!=null){
                acc.Head_of_Office__c = HeadOfOfficeContact;
            }
            acc.Annual_Premium_Volumne__c = agtCon.Annual_Premium_Volumne__c;
            acc.BillingStreet =agtCon.Street__c;
            acc.BillingCity = agtCon.City__c;
            acc.BillingState= agtCon.State__c ;
            acc.BillingPostalCode = agtCon.PostalCode__c;
            acc.BillingCountry =agtCon.Country__c;
            update acc;
                
           
            
        }
    }
    
}