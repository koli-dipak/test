public class TH_IntegrationLog extends BaseTriggerHandler {
  
    public List<Integration_Log__c> newIntegrationLogs;
    public List<Integration_Log__c> oldIntegrationLogs;
    public Map<ID, Integration_Log__c> newIntegrationLogsMap;
    public Map<ID, Integration_Log__c> oldIntegrationLogsMap;

    public TH_IntegrationLog()
    {
        oldIntegrationLogs = (List<Integration_Log__c>)Trigger.old;
        newIntegrationLogs = (List<Integration_Log__c>)Trigger.new;
        newIntegrationLogsMap =  (Map<ID, Integration_Log__c>)Trigger.newMap;
        oldIntegrationLogsMap = (Map<ID, Integration_Log__c>)Trigger.oldMap;
    }
    
    
    protected override void beforeInsert()
    {
        if(Trigger_PAD.canRun('TH_INTEGRATIONLOG'))
        {
            this.processRecords();
        }
    }
    
    protected override void beforeUpdate()
    {
        if(Trigger_PAD.canRun('INTEGRATIONLOG_TH'))
        {
            this.processRecords();
        }
    }
    
    
    
    public  void processRecords()
    {
     
      List<Contact> contacts = new List<Contact>();
      List<Account> accounts = new List<Account>();
      List<LOB_Management__c> lobs = new List<LOB_Management__c>();
      List<Quote> quotes = new List<Quote>();
      
      for(Integration_Log__c log: newIntegrationLogs)
      {
       
         if(log.RecordId__c==null) continue;
         if(Schema.Account.SObjectType == Id.valueof(log.RecordId__c).getSobjectType())
         {
             log.Account__c = log.RecordId__c;
             if(log.Status__c == 'Error')
            {
                Account a = new Account();
                a.id = log.RecordId__c;
                
                accounts.add(a);
            }
         }
         else if(Schema.Contact.SObjectType== Id.valueof(log.RecordId__c).getSobjectType())
        {
            log.Contact__c = log.RecordId__c;
            if(log.Status__c == 'Error')
            {
                Contact c = new Contact();
                c.id = log.RecordId__c;
                
                contacts.add(c);
            }
            
        }
        else if(Schema.LOB_Management__c.SObjectType== Id.valueof(log.RecordId__c).getSobjectType())
        {
            log.Line_of_Business__c = log.RecordId__c;
            if(log.Status__c == 'Error')
            {
                LOB_Management__c lob = new LOB_Management__c();
                lob.id = log.RecordId__c;
                
                lobs.add(lob);
            }
            
        }
        /*else if(Schema.Contact.SObjectType== Id.valueof(log.RecordId__c).getSobjectType())
        {
            log.Contact__c = log.RecordId__c;
            if(log.Status__c == 'Error')
            {
                Contact c = new Contact();
                c.id = log.RecordId__c;
                
                contacts.add(c);
            }
            
        }*/
        else if(Schema.Quote.SObjectType== Id.valueof(log.RecordId__c).getSobjectType())
        {
            log.Rating_Container__c = log.RecordId__c;
            if(log.Status__c == 'Error')
            {
                Quote c = new Quote();
                c.id = log.RecordId__c;
                
                quotes.add(c);
            }
            
        }
     }

    if(!contacts.isEmpty())
         update contacts;
         
    if(!accounts.isEmpty())
         update accounts;
    
    if(!lobs.isEmpty())
         update lobs;
    
    if(!quotes.isEmpty())
         update quotes;
    }
    
    
}