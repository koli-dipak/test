global with sharing class DependentPicklistPopulation implements vlocity_ins.VlocityOpenInterface{

    global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
         if(methodName.equals('getDependentPicklistValues')) {
            getDependentPicklistValues(inputMap,outMap);
        }
        return true;
    }
    @AuraEnabled
    public static void getDependentPicklistValues(Map < String, Object > inputMap, Map < String, Object > outMap) {
        /*
        Schema.DescribeFieldResult stageFieldResult = LOB_Management__c.LOB_Stage__c.getDescribe();
        List<Schema.PicklistEntry> stagePicklist = stageFieldResult.getPicklistValues();
    	
        //stage
        List<stage> stageList = new List<stage>();
        for(Schema.PicklistEntry picklistValues : stagePicklist){
            stage addStage = new stage();
            addStage.label  = picklistValues.getLabel();
            addStage.value  = picklistValues.getValue();
            stageList.add(addStage);
        } 
        
        if(stageList.size() > 0){
            outMap.put('stageSuccess',JSON.serialize(stageList));
        }
        
        //reasoncode
        Schema.DescribeFieldResult reasoncodeFieldResult = LOB_Management__c.Loss_Reason__c.getDescribe();      
        List<Schema.PicklistEntry> reasoncodePicklist = reasoncodeFieldResult.getPicklistValues();
       
        List<reasoncode> reasoncodeList = new List<reasoncode>();
        for(Schema.PicklistEntry picklistValues : reasoncodePicklist){
            reasoncode addreasoncode = new reasoncode();
            addreasoncode.label  = picklistValues.getLabel();
            addreasoncode.value  = picklistValues.getValue();
            reasoncodeList.add(addreasoncode);
        } 
      
        if(reasoncodeList.size() > 0){
            outMap.put('reasoncodeSuccess',JSON.serialize(reasoncodeList));
        }*/

        //dependent value
        Schema.DescribeFieldResult F = LOB_Management__c.Loss_Reason__c.getDescribe();
        Schema.sObjectField dependToken = F.getSObjectField();
        //Schema.sObjectField dependToken = LOB_Management__c.LOB_Stage__c;
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        System.debug('depend'+depend);
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
 
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }
        // outMap.put('dependentPicklistValues',JSON.serialize(dependentPicklistValues));

        Map<String, List<Map<String, String>>> resultMap = new Map<String, List<Map<String, String>>>();
        // Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(dependentPicklistValues);
        Map<String, Object> jsonMap = (Map<String, Object>) dependentPicklistValues;
        for (String key : jsonMap.keySet()) {
            List<String> values = (List<String>) jsonMap.get(key);
            List<Map<String, String>> valueList = new List<Map<String, String>>();
            for (String value : values) {
                Map<String, String> valueMap = new Map<String, String>();
                valueMap.put('label', value);
                valueMap.put('value', value);
                valueList.add(valueMap);
            }
            resultMap.put(key, valueList);
        }

        String resultJson = JSON.serialize(resultMap);
        // System.debug('Result JSON: ' + resultJson);
        outMap.put('dependentPicklistValues',JSON.serialize(resultJson));
    }
    
    // global class stage{
    //     global String label{get; set;}
    //     global String value{get; set;}   
    // }
    
    // global class reasoncode{
    //     global String label{get; set;}
    //     global String value{get; set;}   
    // }
}