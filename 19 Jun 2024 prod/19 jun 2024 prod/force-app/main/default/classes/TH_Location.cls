public class TH_Location  extends BaseTriggerHandler {
    
    
    private List<Schema.Location> newLocationList;
    private List<Schema.Location> oldLocationList;
    private Map<ID, Schema.Location> newLocationMap;
    private Map<ID, Schema.Location> oldLocationMap;
    
    public TH_Location() {
        
        oldLocationList = (List<Schema.Location>)Trigger.old;
        newLocationList = (List<Schema.Location>)Trigger.new;
        newLocationMap = (Map<Id, Schema.Location>)Trigger.newMap;
        oldLocationMap = (Map<Id, Schema.Location>)Trigger.oldMap;
    }
    
    protected override void beforeInsert() {
        if (Trigger_PAD.canRun('TH_LocationBeforeInsert')) {
            proccesRecordBefore(newLocationList,oldLocationMap);
        }
    }
    
    protected override void beforeUpdate() {
        if (Trigger_PAD.canRun('TH_LocationBeforeUpdate')) {
            proccesRecordBefore(newLocationList,oldLocationMap);
        }
    }
    
    public static void proccesRecordBefore(List < Schema.Location > newLocationList,Map<Id, Schema.Location > oldLocationMap) {
     LocationBeforeProcess(newLocationList,oldLocationMap);
    }
    
    public static void LocationBeforeProcess(List < Schema.Location > newLocationList,Map<Id, Schema.Location > oldLocationMap) {
        // Set Address Field With new value
        List<String> listAddresses=new List<String>();
        for(Schema.Location Loc: newLocationList){
            if(oldLocationMap==null || (Loc.Building_Property_Name__c != oldLocationMap.get(Loc.Id).Building_Property_Name__c
                                        || Loc.Address__Street__s != oldLocationMap.get(Loc.Id).Address__Street__s
                                       ||Loc.Address__City__s != oldLocationMap.get(Loc.Id).Address__City__s
                                       ||Loc.Address__PostalCode__s != oldLocationMap.get(Loc.Id).Address__PostalCode__s
                                       ||Loc.Address__StateCode__s != oldLocationMap.get(Loc.Id).Address__StateCode__s
                                       ||Loc.Address__CountryCode__s != oldLocationMap.get(Loc.Id).Address__CountryCode__s))
            {
                System.debug('oldLocationMap'+ JSON.serialize(oldLocationMap));
                System.debug('newLocationList'+ JSON.serialize(newLocationList));
                Loc.Address_Details__c=LOC.Building_Property_Name__c+' '+LOC.Address__Street__s+' '+LOC.Address__City__s+' '+LOC.Address__PostalCode__s+' '+LOC.Address__StateCode__s+' '+LOC.Address__CountryCode__s;
            }
            listAddresses.add( Loc.Address_Details__c);
        }
        /*
        String AddressClause=String.join(listAddresses, ' OR ');
        // Find similar Record Exist or not
        List<List<SObject>> searchList = [FIND :AddressClause IN ALL FIELDS 
                                          RETURNING Location(Id Where ID!=:newLocationList)];
        List<Schema.Location> searchLocations = (List<Schema.Location>)searchList[0];
        System.debug('searchLocations'+searchLocations);
        if(searchLocations.size()>0){
            // Duplicate Found for some of record, so throw error for all
            for(Schema.Location Loc: newLocationList){
                 loc.addError('The record you are about to create looks like a duplicate. Open an existing record instead?');
            }
        } */
    
        
        /*system.debug('@@ Before Trigger  is Called:::');
        
        //Convert result to lower case (Making our solution case insensetive)
        List<Schema.Location>  locationList = new List<Schema.Location>();
        List<Schema.Location>  locationListTemp = [Select Id, Address__Street__s, Address__StateCode__s,Address__PostalCode__s, Address__City__s, Address__CountryCode__s,Name from Location  where id!=:newLocationList  Limit 50000];
        for(Schema.Location lowerLoc: locationListTemp){
            if(lowerLoc.Address__Street__s != null)
                lowerLoc.Address__Street__s = lowerLoc.Address__Street__s.toLowerCase();
            if(lowerLoc.Address__StateCode__s != null)
                lowerLoc.Address__StateCode__s = lowerLoc.Address__StateCode__s.toLowerCase();
            if(lowerLoc.Address__City__s != null)
                lowerLoc.Address__City__s = lowerLoc.Address__City__s.toLowerCase();
            if(lowerLoc.Address__CountryCode__s != null)
                lowerLoc.Address__CountryCode__s = lowerLoc.Address__CountryCode__s.toLowerCase();
            if(lowerLoc.Name != null)
                lowerLoc.Name = lowerLoc.Name.toLowerCase();
            
            locationList.add(lowerLoc);
        }
        System.debug('locationList::: ' + locationList); 
        
        //Prepare this set with already inserted address
        Set<object[]> alreadySeen = new Set<object[]>();
        for(Schema.Location loc : locationList){
            object[] key = new object[]{
                loc.Name  == null ? loc.Name : loc.Name.toLowerCase() , 
                loc.Address__Street__s == null ? loc.Address__Street__s : loc.Address__Street__s.toLowerCase(), 
                loc.Address__StateCode__s  == null ? loc.Address__StateCode__s : loc.Address__StateCode__s.toLowerCase(),
                loc.Address__PostalCode__s,
                loc.Address__City__s  == null ? loc.Address__City__s : loc.Address__City__s.toLowerCase() , 
                loc.Address__CountryCode__s  == null ? loc.Address__CountryCode__s : loc.Address__CountryCode__s.toLowerCase()};
                alreadySeen.add(key);
        }
        
        //check for duplicate address (which are newly coming in trigger)
        //List<Schema.Location> uniqueLocs = new List<Schema.Location>();
        for(Schema.Location  loc : newLocationList){
            object[] key = new object[]{
                loc.Name  == null ? loc.Name : loc.Name.toLowerCase() , 
                loc.Address__Street__s == null ? loc.Address__Street__s : loc.Address__Street__s.toLowerCase(), 
                loc.Address__StateCode__s  == null ? loc.Address__StateCode__s : loc.Address__StateCode__s.toLowerCase(),
                loc.Address__PostalCode__s,
                loc.Address__City__s  == null ? loc.Address__City__s : loc.Address__City__s.toLowerCase() , 
                loc.Address__CountryCode__s  == null ? loc.Address__CountryCode__s : loc.Address__CountryCode__s.toLowerCase()};
                                    
                //Prevent Creation of Location if there is duplicate records
                if(alreadySeen.contains(key)){
                    System.debug(alreadySeen);
                      loc.addError('The record you are about to create looks like a duplicate. Open an existing record instead?');
                }
        }*/
   	}
}