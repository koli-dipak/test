trigger IntegrationTrigger on Integration_Log__c (before insert,before update) {

new TH_IntegrationLog().run();

}