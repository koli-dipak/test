trigger AgentContactTrigger on Agent_Contact__c (after Update,before update) {
    new TH_AgentContact().run();
}