public class DAL_BrokerContact {
    public static List<BrokerContact__c> getBrokerContactById(String recordId,String objType){
        return [SELECT Id,Event_End_Date__c, Event_Name__c, Event_Start_Date__c, Location__c , Event_Street__c, Event_City__c, Event_State__c, Event_Country__c, Event_PostalCode__c,
                Competitor_Name__c,Comment__c,Premium__c,
                Product__c,Wholesale__c,Manager__c,Broker_Contact__c,Competitor_1__c, Competitor_2__c, 
                Competitor_3__c,Broker_Contact__r.FirstName__c, Broker_Contact__r.LastName__c, Broker_Contact__r.Email__c, 
                Broker_Contact__r.Phone__c,Manager__r.FirstName,Manager__r.LastName,Manager__r.Email,Manager__r.Phone,
                FirstName__c, LastName__c, Email__c, Phone__c 
                from BrokerContact__c 
                Where  Agent_Contact__c=:recordId and ObjectType__c=:objType ];
    }
    public static List<BrokerContact__c> getBrokerContactById(String recordId,String objType,string recType){
        return [SELECT Id,Event_End_Date__c, Event_Name__c, Event_Start_Date__c, Location__c , Event_Street__c, Event_City__c, Event_State__c, Event_Country__c, Event_PostalCode__c,
                Competitor_Name__c,Comment__c,Premium__c,
                Product__c,Wholesale__c,Manager__c,Broker_Contact__c,Competitor_1__c, Competitor_2__c, 
                Competitor_3__c, Broker_Contact__r.Salutation__c, Broker_Contact__r.FirstName__c, Broker_Contact__r.LastName__c, Broker_Contact__r.Email__c, 
                Broker_Contact__r.Phone__c,Manager__r.FirstName,Manager__r.LastName,Manager__r.Email,Manager__r.Phone,Manager__r.Salutation,
                FirstName__c, LastName__c, Email__c, Phone__c, Salutation__c 
                from BrokerContact__c 
                Where  Agent_Contact__c=:recordId and ObjectType__c=:objType and Type__c=:recType ];
    }
    
}