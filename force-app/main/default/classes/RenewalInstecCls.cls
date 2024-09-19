public class RenewalInstecCls {
    public String newRenewalLobId;
    public String newRenewalOppId;

    //@AuraEnabled(cacheable=true)
    @AuraEnabled
    public static List<Policy_Number_Holder__c> getRenewalLob(Id LobRecordId){
    //public static void getRenewalLob(Id LobRecordId){
        System.debug('LobRecordId : '+LobRecordId);
        RenewalInstecCls renewalInstecObj = new RenewalInstecCls();
        renewalInstecObj.newRenewalLobId = LobRecordId; 
        LOB_Management__c RenewalLobId = [SELECT Id, Name, Opportunity_Related__c, Renewed_Line_of_Business__c, Cloned__c from LOB_Management__c where Id = :LobRecordId Limit 1];
        renewalInstecObj.newRenewalOppId = RenewalLobId.Opportunity_Related__c;
        System.debug('RenewalLobIdDetails: '+RenewalLobId);
        return getPoliciesAndInstecDetilsFromLob(RenewalLobId.Renewed_Line_of_Business__c, renewalInstecObj);
        //getPoliciesAndInstecDetilsFromLob(RenewalLobId.Renewed_Line_of_Business__c, renewalInstecObj);
    }

    @AuraEnabled
    public static List<Policy_Number_Holder__c> getPoliciesAndInstecDetilsFromLob(Id LobRecordId, RenewalInstecCls renewalInstecObj){
    //public static void getPoliciesAndInstecDetilsFromLob(Id LobRecordId, RenewalInstecCls renewalInstecObj){
        System.debug('LobRecordId : '+LobRecordId);
        List<Policy_Number_Holder__c> PolicyAndInstecDetails = [select Id, Name, Line_of_Business__c, Policy_Number__c, Quote_Line_Item__c, Quote_Line_Item__r.Instec_System_Id__c, Instec_Storage_Id__c from Policy_Number_Holder__c where Line_of_Business__c != null And Line_of_Business__c = :LobRecordId];
        if(PolicyAndInstecDetails.size() > 0){
            sendToInstec(PolicyAndInstecDetails, renewalInstecObj);
        }
        return PolicyAndInstecDetails;
    }

    public static void sendToInstec(List<Policy_Number_Holder__c> PolicyAndInstecDetails, RenewalInstecCls renewalInstecObj){
        System.debug('PolicyAndInstecDetails '+PolicyAndInstecDetails[0].Quote_Line_Item__r.Instec_System_Id__c);
        List<Renewal_Instec__e> RenewalinstecList = new List<Renewal_Instec__e>();
        
        for(Policy_Number_Holder__c polInsDetails : PolicyAndInstecDetails){
            Renewal_Instec__e RenewalInstec = new Renewal_Instec__e();
            RenewalInstec.LobId__c = renewalInstecObj.newRenewalLobId;
            // RenewalInstec.InstecId__c = polInsDetails.Quote_Line_Item__r.Instec_System_Id__c; ass disscuss with judd we need to fetch from Instec_Storage_ID__c formula field
            RenewalInstec.InstecId__c = polInsDetails.Instec_Storage_ID__c;
            RenewalInstec.OpportunityId__c = renewalInstecObj.newRenewalOppId;
            RenewalinstecList.add(RenewalInstec);
        }
        System.debug('RenewalinstecList '+RenewalinstecList);
        if(RenewalinstecList.size()>0){
            EventBus.publish(RenewalinstecList);
        }
        
    }
}