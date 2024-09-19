global class FcLocalExtension implements vlocity_ins.VlocityOpenInterface {
    // implements vlocity_ins.VlocityOpenInterface
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        if (methodName.equals('getDefaultData')) {
            getDefaultData(inputMap,outMap);
        }
        if(methodName.equals('getFormsDet')){
             getFormsDet(inputMap, outMap);
        }
        if(methodName.equals('createLocalExtension')){
            createLocalExtension(inputMap, outMap);
        }
        if(methodName.equals('getCountryList')){
            getCountryList(inputMap, outMap);
        }
        
        return true;
    }
    
    @AuraEnabled
    public static void getFormsDet(Map<String, Object> inputMap, Map<String, Object> outMap) {
         String PremiumId = String.valueOf(inputMap.get('premiumId'));
         List<FC_Casualty_Local__c> FcCasualLocal = new List<FC_Casualty_Local__c>([SELECT Id, Country__c, LOB__c, Limit__c, Exposure__c, Local_Policy_Required__c, Premium__c, Other_local_extension_e_g_PFL_included__c From FC_Casualty_Local__c Where Other_local_extension_e_g_PFL_included__c = 'Yes' AND FC_Casualty_Premium__c = :PremiumId]);
         System.debug('FcCasualLocal::-->'+FcCasualLocal);
        
    		outMap.put('data',FcCasualLocal);
    		System.debug('@@outMap:::'+outMap);
        
    }

    
    public static void getDefaultData(Map < String, Object > inputMap, Map < String, Object > outMap){
        Map<String,Object> returnData=new Map<String,Object>();
                    Schema.DescribeFieldResult fieldResult = FC_Casualty_Local_Extention__c.Extension_Type__c.getDescribe();
                    List<String> pickListValuesList= new List<String>();
                    List<Schema.PicklistEntry> fieldValueList = fieldResult.getPicklistValues();
                    for( Schema.PicklistEntry pickListVal : fieldValueList){
                        pickListValuesList.add(pickListVal.getValue());
                    }    
                    outMap.put('ExtensionTypeList',pickListValuesList);
                    // FC_Casualty_Local__c casualLocal = (FC_Casualty_Local__c)FC_Casualty_Local__c.sObjectType.newSObject(null, true);
                    // outMap.put('AggregateLimit',casualLocal.get(FC_Casualty_Local__c.Aggregate_Limit__c));
                    //return JSON.serialize(returnData);
    }

    @AuraEnabled
    public static void createLocalExtension(Map<String, Object> inputMap, Map<String, Object> outMap){
        System.debug('inputMap::-->'+inputMap.get('recordIds'));
        System.debug('newExtensionData::-->'+inputMap.get('newExtensionData'));
        Map <String, Object> newExtensionDataMap = ( Map <String, Object>)JSON.deserializeUntyped(String.valueOf(inputMap.get('newExtensionData')) );
        String Premium  = String.valueOf(newExtensionDataMap.get('Premium'));
        String Deductible  = String.valueOf(newExtensionDataMap.get('Deductible'));
        String OccurrenceLimit  = String.valueOf(newExtensionDataMap.get('OccurenceLimit'));
        String AggregateLimit  = String.valueOf(newExtensionDataMap.get('AggregateLimit'));
        String ExtensionType  = String.valueOf(newExtensionDataMap.get('extensionType'));
        String PremiumId = String.valueOf(newExtensionDataMap.get('premiumId'));

        String LeId  = String.valueOf(inputMap.get('recordIds'));
        Set<String> recordIdSet = new Set<String>();
        List<String> recordIdList = LeId.split(',');
        recordIdSet.addAll(recordIdList);
        String leRecords  = String.valueOf(inputMap.get('allRecords'));

        List<FC_Casualty_Local_Extention__c> casualLocalList = new List<FC_Casualty_Local_Extention__c>();
       
            for(String fcLocalId :recordIdSet){
                if(String.isNotEmpty(fcLocalId)){
                    FC_Casualty_Local_Extention__c casualLocal = new FC_Casualty_Local_Extention__c();
                    casualLocal.FC_Casualty_Local__c = (Id)fcLocalId.trim();
                    casualLocal.Premium__c = String.valueOf(Premium);
                    casualLocal.Aggregate_Limit__c = AggregateLimit;
                    casualLocal.Deductible__c = Deductible;
                    casualLocal.Occurrence_Limit__c = OccurrenceLimit;
                    casualLocal.Extension_Type__c = ExtensionType;
                    casualLocalList.add(casualLocal);
                }
            }

            if(!casualLocalList.isEmpty()){
                //insert casualLocalList;
                List<Database.SaveResult> results = Database.insert(casualLocalList, false);
                for(Database.SaveResult result : results){
                    if(result.isSuccess()){
                        system.debug('@@success::::');
                    }
                    else{
                        system.debug('@@error::::: '+result.getErrors());
                    }
                }
            }
            
    }
    
    public static void getCountryList(Map < String, Object > inputMap, Map < String, Object > outMap){
        Map<String,Object> returnData=new Map<String,Object>();
        Schema.DescribeFieldResult fieldResult = FC_Casualty_Local__c.Aggregate_Currency__c.getDescribe();
        List<String> pickListValuesList= new List<String>();
        List<Schema.PicklistEntry> fieldValueList = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : fieldValueList){
            pickListValuesList.add(pickListVal.getValue());
        }    
        outMap.put('CountryList',pickListValuesList);
    }
}