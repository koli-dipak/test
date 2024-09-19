public class TH_CaseAndLocation extends BaseTriggerHandler {
    private List<CaseAndLocaiton__c> newCaseAndLocationList;
    private List<CaseAndLocaiton__c> oldCaseAndLocationList;
    private Map<ID, CaseAndLocaiton__c> newCaseAndLocationMap;
    private Map<ID, CaseAndLocaiton__c> oldCaseAndLocationMap;
    
    public TH_CaseAndLocation()
    {
        oldCaseAndLocationList = (List<CaseAndLocaiton__c>)Trigger.old;
        newCaseAndLocationList = (List<CaseAndLocaiton__c>)Trigger.new;
        newCaseAndLocationMap = (Map<Id, CaseAndLocaiton__c>)Trigger.newMap;
        oldCaseAndLocationMap = (Map<Id, CaseAndLocaiton__c>)Trigger.oldMap;
    }
    
    protected override void beforeInsert() { 
        if(Trigger_PAD.canRun('TH_CaseAndLocationBeforeInsert')){
            processRecordBefore(newCaseAndLocationList, oldCaseAndLocationMap);
        }
    } 
    
    public static void processRecordBefore(List<CaseAndLocaiton__c> newCaseAndLocationList, Map<Id, CaseAndLocaiton__c> oldCaseAndLocationMap){
        System.debug('@@newCaseAndLocationList:::'+newCaseAndLocationList);
        Set<Id> locationRecordIds = new Set<Id>();
        List<CaseAndLocaiton__c> ExistingRecords = new List<CaseAndLocaiton__c>();
        Map<Id, Set<Id>> ExistingLocationWiseLocationCaseMap = new Map<Id, Set<Id>>();
        Map<Id, String> LocationCaseIdWiseNameMap = new Map<Id, String>();
        Map<Id, List<String>> locationIdWiseErrorNames = new Map<Id, List<String>>();
        Map<Id, List<CaseAndLocaiton__c>> locationIdWiseErrorLocationsRecords = new Map<Id, List<CaseAndLocaiton__c>>();
        
        for (CaseAndLocaiton__c locations : newCaseAndLocationList) {
            locationRecordIds.add(locations.Location__c);
        }
        
        if(!locationRecordIds.isEmpty()){
            ExistingRecords = DAL_CaseAndLocation.getLocationByLocationsIds(locationRecordIds);
        }
        
        if(!ExistingRecords.isEmpty()){
            for (CaseAndLocaiton__c locations : ExistingRecords) {
                if(!ExistingLocationWiseLocationCaseMap.containsKey(locations.Location__c))
                    ExistingLocationWiseLocationCaseMap.put(locations.Location__c, new Set<Id>());
                ExistingLocationWiseLocationCaseMap.get(locations.Location__c).add(locations.Case__c);
                //LocationCaseIdWiseNameMap.put(locations.Case__c, locations.Case__r.Id);
                LocationCaseIdWiseNameMap.put(locations.Location__c, locations.Location__c);
            }
        }
        
        if(!ExistingLocationWiseLocationCaseMap.isEmpty()){
            for (CaseAndLocaiton__c locations : newCaseAndLocationList) {
                if(ExistingLocationWiseLocationCaseMap.containsKey(locations.Location__c)){
                    for (Id locationId : ExistingLocationWiseLocationCaseMap.get(locations.Location__c)) {
                        if(locations.Case__c == locationId){
                            //broker.addError('The records you are trying to include already exists in the list: '+BrokerAccountIdWiseNameMap.get(broker.Broker_Account__c));
                            if(!locationIdWiseErrorNames.containsKey(locations.Location__c)){
                                locationIdWiseErrorNames.put(locations.Location__c, new List<String>());
                            }
                            //locationIdWiseErrorNames.get(locations.Location__c).add(LocationCaseIdWiseNameMap.get(locations.Case__c));
                            locationIdWiseErrorNames.get(locations.Location__c).add(LocationCaseIdWiseNameMap.get(locations.Location__c));
                            if(!locationIdWiseErrorLocationsRecords.containsKey(locations.Location__c)){
                                locationIdWiseErrorLocationsRecords.put(locations.Location__c, new List<CaseAndLocaiton__c>());
                            }
                            locationIdWiseErrorLocationsRecords.get(locations.Location__c).add(locations);
                        }
                    }
                }
            }
            system.debug('@@locationIdWiseErrorNames::'+locationIdWiseErrorNames);
            system.debug('@@locationIdWiseErrorLocationsRecords::'+locationIdWiseErrorLocationsRecords);
            //system.debug('@@locationIdWiseErrorLocationsRecords::Location_Adress__c'+locationIdWiseErrorLocationsRecords.get('131Ea0000001xajIAA')[0].Location_Adress__c);
            String concatenatedAddresses = '';
            if(!locationIdWiseErrorNames.isEmpty()){
                for (List<CaseAndLocaiton__c> caseAndLocation : locationIdWiseErrorLocationsRecords.values()) {
                    if (!String.isEmpty(concatenatedAddresses)) {
                        concatenatedAddresses += '; ';
                    }
                    concatenatedAddresses += caseAndLocation[0].Location_Adress__c;
                }
                
                System.debug('Concatenated Addresses: ' + concatenatedAddresses);
            }
            
            if(!locationIdWiseErrorNames.isEmpty()){
                for(Id locationId : locationIdWiseErrorNames.keySet()){
                    for(CaseAndLocaiton__c locations : locationIdWiseErrorLocationsRecords.get(locationId)){
                        //locations.addError(System.Label.Junction_object_record_already_exists_erorr + String.join(locationIdWiseErrorNames.get(locationId), ';'));
                        locations.addError('Duplicate Record Found '+ concatenatedAddresses);
                    }
                }
            }
        }
    }
    
    
}