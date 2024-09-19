public with sharing class LocationDetailController {
   
    @AuraEnabled(cacheable = true)
    public static List<CaseAndLocaiton__c> getLocationCase(String caseId, List<String> ids){
        //List<CaseAndLocaiton__c> accList =[SELECT Id, Location__r.Name, Location__r.Address__c, Location__r.Location_Adress__c, Location__r.CreatedDate, Location__r.CreatedBy.Name, Location__r.Address__City__s, Location__r.Location_Full_Address__c FROM CaseAndLocaiton__c Where Case__c =: caseId Or Id IN : ids];
        List<CaseAndLocaiton__c> accList =[SELECT Id, Location__r.Name, Location__r.Address__c, Location__r.Location_Adress__c, Location__r.CreatedDate, Location__r.CreatedBy.Name, Location__r.Address__City__s, Location__r.Location_Full_Address__c FROM CaseAndLocaiton__c Where Case__c =: caseId];
         System.debug('accList'+accList);
        return accList; 
    }
    
    //delete method 
    @AuraEnabled
    public static void deleteLocationCase(String recordId) {
        System.debug('recordId'+recordId);
        try {
            List<CaseAndLocaiton__c> junctionRecords = [SELECT Id, Location__c FROM CaseAndLocaiton__c WHERE Id = :recordId Limit 1];
            System.debug('junctionRecords'+junctionRecords);
            if (!junctionRecords.isEmpty()) {
                delete junctionRecords;
            }
        } catch (Exception e) {
            throw new AuraHandledException('An error occurred while deleting the record: ' + e.getMessage());
        }
    }
    //get case junction location value
    @AuraEnabled
    public static List<CaseAndLocaiton__c> getCjrValue(String recordId) {
        List<CaseAndLocaiton__c> cjr = [select id from CaseAndLocaiton__c where Case__c = :recordId];
        return cjr;
    }
    
    @AuraEnabled
    public static Map<String, String> getLocationCountryCode() {
        Schema.DescribeFieldResult fieldResult = Schema.Location.Address__CountryCode__s.getDescribe();
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        Map<String, String> countryMap = new Map<String, String>();
        
        for (Schema.PicklistEntry pickListEntry : pickListValues) {
            String countryName = pickListEntry.getLabel();
            String countryCode = pickListEntry.getValue();
            countryMap.put(countryName, countryCode);
        }
        return countryMap;
    }

    @AuraEnabled
    public static Map<String, String> getLocationStateCode() {
        Schema.DescribeFieldResult fieldResult = Schema.Location.Address__StateCode__s.getDescribe();
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
        
        Map<String, String> stateMap = new Map<String, String>();
        
        for (Schema.PicklistEntry pickListEntry : pickListValues) {
            String stateName = pickListEntry.getLabel();
            String stateCode = pickListEntry.getValue();
            stateMap.put(stateName, stateCode);
        }
        return stateMap;
    }

   /* @AuraEnabled
    public static List<Schema.Location> getLocation(List<String> locId){
        List<Schema.Location> LocList =[select Id, Name, Location_Adress__c, (select Id , Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Client_Name__c from Location_And_Contacts__r) from Location Where ID IN : locId ];
        System.debug('LocList '+  JSON.serialize(LocList));
        return LocList; 
    } */
     @AuraEnabled
    public static String getLocation(List<String> locId, String caseId){
        List<Schema.Location> LocList =[select Id, Name, Location_Adress__c, (select Id , Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Client_Name__c from Location_And_Contacts__r where Case__c =: caseId) from Location Where ID IN : locId ];
        System.debug('LocList '+  JSON.serialize(LocList));
        return JSON.serialize(LocList); 
    }
    
    @AuraEnabled
    public static void associateLocationRecord(Object selectedLobRecords, Object selectedContactRecords, String CaseId, List<String> removeListOfLocationAndContact){
        Map<String, object> temp = (Map<String, object>)JSON.deserializeUntyped(JSON.serialize(selectedLobRecords));
        System.debug('key'+temp.keyset());
        System.debug('values'+temp.values());
        List<Location_And_Line_Of_Business__c> locationAndLOB = new List<Location_And_Line_Of_Business__c>();
        for(String key : temp.keyset()){
            for(String value : (List<String>)JSON.deserialize(JSON.serialize(temp.get(key)), List<String>.class)){
                Location_And_Line_Of_Business__c locAndLob = new Location_And_Line_Of_Business__c();
                locAndLob.Location__c = key;
                locAndLob.Line_of_Business__c = value;
                locAndLob.Case__c = CaseId;
                locationAndLOB.add(locAndLob);
            } 
        }
        if(locationAndLOB.size() > 0){
            insert locationAndLOB;
        }
        
        // associate contact with location
        Map<String, object> conRecords = (Map<String, object>)JSON.deserializeUntyped(JSON.serialize(selectedContactRecords));
        System.debug('conkey'+conRecords.keyset());
        System.debug('convalues'+conRecords.values());
        List<Location_And_Contact__c> locationAndContact = new List<Location_And_Contact__c>();
        for(String key : conRecords.keyset()){
            for(String value : (List<String>)JSON.deserialize(JSON.serialize(conRecords.get(key)), List<String>.class)){
                Location_And_Contact__c locAndCon = new Location_And_Contact__c();
                locAndCon.Contact__c = value;
                locAndCon.Location__c = key;
                locAndCon.Case__c = CaseId;
                locationAndContact.add(locAndCon);
            }
        }
        if(locationAndContact.size()>0){
            insert locationAndContact;
        }
        
        if(removeListOfLocationAndContact.size()>0){
            deleteLocationAndContacts(removeListOfLocationAndContact);
        }
    }

    // add to insert new location record
    @AuraEnabled
    public static List<Schema.Location> insertLocationRecord(Object LocationRecord){
        try {
            String LocationList = JSON.serialize(LocationRecord);
            Map<String,Object> LocationRecords = (Map<String,Object>)JSON.deserializeUntyped(LocationList);
            List<Schema.Location> LocationLists = new List<Schema.Location>();
            Schema.Location loc = new Schema.Location();
            loc.Case__c = (String)LocationRecords.get('Case__c');
            loc.Currency_Code__c = (String)LocationRecords.get('Currency_Code__c');
            // loc.Suite__c = (String)LocationRecords.get('Suite__c');
            loc.Building_Property_Name__c = (String)LocationRecords.get('Building_Property_Name__c'); 
            loc.Address__Street__s = (String)LocationRecords.get('Address__Street__s');
            loc.Address__City__s = (String)LocationRecords.get('Address__City__s'); 
            loc.Address__PostalCode__s = (String)LocationRecords.get('Address__PostalCode__s'); 
            loc.Address__StateCode__s = (String)LocationRecords.get('Address__StateCode__s'); 
            loc.Address__CountryCode__s = (String)LocationRecords.get('Address__CountryCode__s'); 
            LocationLists.add(loc);
            insert LocationLists;
            return LocationLists;
        } catch (Exception ex)  {
            throw new AuraHandledException('An error occurred while saving records: ' + ex.getMessage());
        }
    }
    
    // added for find duplicate location for N2G-546 26-aug-2023
    @AuraEnabled
     public static List<Schema.Location> proccesRecordBefore(Object LocationRecord) {
         Map<String, Object > LocationObj =  (Map<String, Object >) JSON.deserializeUntyped(JSON.serialize(LocationRecord));
        List < Schema.Location > newLocationList = new List < Schema.Location >();
         Schema.Location loc = new Schema.Location();
         loc.Address__City__s = String.isNotBlank(String.valueOf(LocationObj.get('Address__City__s'))) ? String.valueOf(LocationObj.get('Address__City__s')):'' ;
         loc.Address__CountryCode__s = String.isNotBlank(String.valueOf(LocationObj.get('Address__PostalCode__s'))) ? String.valueOf(LocationObj.get('Address__PostalCode__s')):'' ;
         loc.Address__PostalCode__s = String.isNotBlank(String.valueOf(LocationObj.get('Address__City__s'))) ? String.valueOf(LocationObj.get('Address__City__s')):'' ;
         loc.Address__Street__s = String.isNotBlank(String.valueOf(LocationObj.get('Address__Street__s'))) ? String.valueOf(LocationObj.get('Address__Street__s')):'' ;
         loc.Building_Property_Name__c = String.isNotBlank(String.valueOf(LocationObj.get('Building_Property_Name__c'))) ? String.valueOf(LocationObj.get('Building_Property_Name__c')):'' ;
         loc.Address__StateCode__s = String.isNotBlank(String.valueOf(LocationObj.get('Address__StateCode__s'))) ?String.valueOf(LocationObj.get('Address__StateCode__s')):'' ;

         newLocationList.add(loc);
        //Map<Id, Schema.Location > oldLocationMap = new Map<Id, Schema.Location >([select Id, Building_Property_Name__c, Address__Street__s, Address__City__s, Address__PostalCode__s, Address__StateCode__s, Address__CountryCode__s from Location]);
         if(newLocationList.size() > 0){
             //LocationBeforeProcess(newLocationList,oldLocationMap);
             return LocationBeforeProcess(newLocationList);
         }
         return new List<Schema.Location>();
         
    }
    
    //public static void LocationBeforeProcess(List < Schema.Location > newLocationList,Map<Id, Schema.Location > oldLocationMap) {
     public static List<Schema.Location> LocationBeforeProcess(List < Schema.Location > newLocationList) {
        // Set Address Field With new value
        List<String> listAddresses=new List<String>();
        String str;
        for(Schema.Location Loc: newLocationList){
            //System.debug('oldLocationMap '+oldLocationMap);
            /*
            if(oldLocationMap==null || (Loc.Building_Property_Name__c != oldLocationMap.get(Loc.Id).Building_Property_Name__c
                                        || Loc.Address__Street__s != oldLocationMap.get(Loc.Id).Address__Street__s
                                       ||Loc.Address__City__s != oldLocationMap.get(Loc.Id).Address__City__s
                                       ||Loc.Address__PostalCode__s != oldLocationMap.get(Loc.Id).Address__PostalCode__s
                                       ||Loc.Address__StateCode__s != oldLocationMap.get(Loc.Id).Address__StateCode__s
                                       ||Loc.Address__CountryCode__s != oldLocationMap.get(Loc.Id).Address__CountryCode__s))
            {
                Loc.Address_Details__c=LOC.Building_Property_Name__c+' '+LOC.Address__Street__s+' '+LOC.Address__City__s+' '+LOC.Address__PostalCode__s+' '+LOC.Address__StateCode__s+' '+LOC.Address__CountryCode__s;
                str='%'+LOC.Address__City__s+' '+LOC.Address__Street__s+' '+' '+LOC.Address__StateCode__s+' '+LOC.Address__CountryCode__s+' '+LOC.Address__PostalCode__s+'%';
            }*/
            Loc.Address_Details__c=LOC.Building_Property_Name__c+' '+LOC.Address__Street__s+' '+LOC.Address__City__s+' '+LOC.Address__PostalCode__s+' '+LOC.Address__StateCode__s+' '+LOC.Address__CountryCode__s;
            System.debug('Loc.Address_Details__c '+Loc.Address_Details__c);
            listAddresses.add( Loc.Address_Details__c);
        }
        String AddressClause=String.join(listAddresses, ' OR ');
        // Find similar Record Exist or not
        List<List<SObject>> searchList = [FIND :AddressClause IN ALL FIELDS 
                                          RETURNING Location(Id, Building_Property_Name__c, Address__Street__s,Address__City__s,Address__PostalCode__s,Address__StateCode__s,Address__CountryCode__s, Address_Details__c, Currency_Code__c  Where ID!=:newLocationList)];
        // List<Schema.Location> searchLocations = (List<Schema.Location>)searchList[0];
        // List<Schema.Location> searchLocations = (List<Schema.Location>)searchList;
        // System.debug('searchLocations'+searchLocations);
        // return searchLocations;

        List<Schema.Location> searchLocations = new List<Schema.Location>();
    
        for (List<SObject> innerList : searchList) {
            searchLocations.addAll((List<Schema.Location>) innerList);
        }
        
        System.debug('searchLocations' + searchLocations);
        return searchLocations;
    }

    // below method is for insert record into CaseAndLocation object for N2G-546 
    @AuraEnabled
    public static CaseAndLocaiton__c insertLocationRecordIntoCaseAndLocationObject(String LocationId, String CaseId) {
        try {
            CaseAndLocaiton__c caseLocJunction = new CaseAndLocaiton__c();
            caseLocJunction.Case__c = CaseId;
            caseLocJunction.Location__c = LocationId;
            insert caseLocJunction;
            return caseLocJunction;
        } catch (Exception ex)  {
            throw new AuraHandledException('An error occurred while saving records: ' + ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteLocationAndContacts(List<String> recordIds) {
        try {
            List<Location_And_Contact__c> recordsToDelete = [
                SELECT Id
                FROM Location_And_Contact__c
                WHERE Id IN :recordIds
            ];
            
            if (!recordsToDelete.isEmpty()) {
                delete recordsToDelete;
            }
        } catch (Exception e) {
            System.debug('exception ' + e);
        }
    }
    
    
}