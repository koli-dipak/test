public class DAL_AgentContact {
    public static List<Agent_Contact__c> getAgentContactById(String recordId){
        return [SELECT Id, OwnerId, IsDeleted, CreatedDate, Name, LastModifiedById, SystemModstamp, LastModifiedDate, CreatedById, Account__c, 
                Contact_Number__c, Website__c, Annual_Premium_Volumne__c, Event_Name__c, Competitor_Name__c, Agency_Name__c,Status__c,Broker_Code__c,
                Product__c, Competitor_1__c, Competitor_2__c, Wholesale__c, Event_Start_Date__c, Head_of_Office__c, Competitor_3__c, No_of_Employees__c, Email__c,
                Manager__c, Comment__c, City__c, Street__c, Location__c, Event_Street__c, Event_City__c, Event_State__c, Event_Country__c, Event_PostalCode__c, Country__c, State__c, PostalCode__c, Premium__c, Event_End_Date__c,Is_Link_Expired__c 
                FROM Agent_Contact__c WHERE Encrypted_Id__c  =: recordId limit 1];
    }
    public static List<Agent_Contact__c> getAgentContactWithBrokerDetail(String recordId){
        return [SELECT Id, OwnerId, IsDeleted, CreatedDate, Name, LastModifiedById, SystemModstamp, LastModifiedDate, CreatedById, Account__c, 
                Contact_Number__c, Website__c, Annual_Premium_Volumne__c,Distribution_Leader__c, Event_Name__c, Competitor_Name__c, Agency_Name__c,Status__c,Broker_Code__c ,
                Product__c, Competitor_1__c, Competitor_2__c, Wholesale__c, Event_Start_Date__c,Head_of_Office__c, Competitor_3__c, No_of_Employees__c, Email__c,
                Manager__c, Comment__c, City__c, Street__c, Location__c, Event_Street__c, Event_City__c, Event_State__c, Event_Country__c, Event_PostalCode__c, Country__c, State__c, PostalCode__c, Premium__c, Event_End_Date__c ,Is_Link_Expired__c
                ,(SELECT Salutation__c, FirstName__c, LastName__c, Email__c, Phone__c, Agent_Contact__c, 
                  Type__c, Comment__c, Competitor_1__c, Competitor_2__c, Competitor_3__c, 
                  Competitor_Name__c, Event_End_Date__c, Event_Name__c, Event_Start_Date__c, Location__c, Event_Street__c, Event_City__c, Event_State__c, Event_Country__c, Event_PostalCode__c,
                  Premium__c, Product__c, Wholesale__c, ObjectType__c, Manager__c,Broker_Contact__r.Email__c
                  FROM BrokerContacts__r 
                  order by ObjectType__c)
                FROM Agent_Contact__c WHERE Encrypted_Id__c =: recordId limit 1];
    }
    public static List<Agent_Contact__c> getAgentContactWithBrokerDetail(List<String> recordId){
        return [SELECT Id, OwnerId, IsDeleted, CreatedDate, Name, LastModifiedById, SystemModstamp, LastModifiedDate, CreatedById, Account__c, 
                Contact_Number__c, Website__c, Annual_Premium_Volumne__c,Distribution_Leader__c, Event_Name__c, Competitor_Name__c, Agency_Name__c,Status__c,Broker_Code__c ,
                Product__c, Competitor_1__c, Competitor_2__c, Wholesale__c, Event_Start_Date__c,Head_of_Office__c, Competitor_3__c, No_of_Employees__c, Email__c,
                Manager__c, Comment__c, City__c, Street__c, Location__c, Event_Street__c, Event_City__c, Event_State__c, Event_Country__c, Event_PostalCode__c, Country__c, State__c, PostalCode__c, Premium__c, Event_End_Date__c ,Is_Link_Expired__c 
                ,(SELECT Salutation__c, FirstName__c, LastName__c, Email__c, Phone__c, Agent_Contact__c, 
                  Type__c, Comment__c, Competitor_1__c, Competitor_2__c, Competitor_3__c, 
                  Competitor_Name__c, Event_End_Date__c, Event_Name__c, Event_Start_Date__c, Location__c, Event_Street__c, Event_City__c, Event_State__c, Event_Country__c, Event_PostalCode__c,
                  Premium__c, Product__c, Wholesale__c, ObjectType__c, Manager__c,Broker_Contact__r.Email__c
                  FROM BrokerContacts__r 
                  order by ObjectType__c)
                FROM Agent_Contact__c WHERE id =: recordId limit 1];
    }
    
}