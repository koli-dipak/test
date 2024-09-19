trigger PolicyForRiskEngineeringTrigger on Case_and_InsurancePolicy__c (before insert) {
	new TH_PolicyForRiskEngineering().run();
}