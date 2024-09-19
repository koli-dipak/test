trigger InsurancePolicyTrigger on InsurancePolicy (before insert,before update,after update,after delete, after insert) {
	    new TH_InsurancePolicy().run(); 
}