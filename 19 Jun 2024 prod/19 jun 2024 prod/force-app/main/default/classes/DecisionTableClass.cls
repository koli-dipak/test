/**
* Invokes the specified method with input parameters and populates the output map.
* 
* @param methodName The name of the method to invoke.
* @param inputMap   The input parameters for the method.
* @param outMap     The map to store the output of the method.
* @param options    Additional options for method invocation.
* @return           True if the method was successfully invoked, false otherwise.
*/

global with sharing class DecisionTableClass implements vlocity_ins.VlocityOpenInterface {
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        if (methodName.equals('DecisionTableInput')) {
            DecisionTableInput(inputMap, outMap);
        }
        return true;
    }
    
    //public static void DecisionTableInput(String LobFieldApiName, String LobFieldvalue, String StateFieldApiName, String StateFieldvalue, String decisionTableId){
    public static void DecisionTableInput(Map < String, Object > inputMap, Map < String, Object > outMap){
        System.debug('QuoteId== '+inputMap.get('ContextId'));
        String QuoteId = (String)inputMap.get('ContextId');
        List<String> existingQuoteLines=new List<String>();
        List<DocumentChecklistItem> DocumentChecklistIdList = [Select Id, Generate_Quote_and_Binder__c, Quote_Line_Item__c from DocumentChecklistItem where Generate_Quote_and_Binder__c =: QuoteId ];
        for(DocumentChecklistItem checklistItem : DocumentChecklistIdList){
            existingQuoteLines.add(checklistItem.Quote_Line_Item__c);
        }
        
        //fetching DecisionTable Id
        List<DecisionTable> DecisionTableGLId = [Select Id, DeveloperName from DecisionTable where DeveloperName = 'Binding_Checklist_Decision_Lookup_Table_GL' Limit 1];
        List<DecisionTable> DecisionTableUMBId = [Select Id, DeveloperName from DecisionTable where DeveloperName = 'Binding_Checklist_Decision_Lookup_Table_UMB' Limit 1];
        List<DecisionTable> DecisionTableWCId = [Select Id, DeveloperName from DecisionTable where DeveloperName = 'Binding_Checklist_Decision_Lookup_WC' Limit 1];
        List<DecisionTable> DecisionTableAUId = [Select Id, DeveloperName from DecisionTable where DeveloperName = 'Binding_Checklist_Decision_Lookup_AU' Limit 1];
        List<DecisionTable> DecisionTableFCId = [Select Id, DeveloperName from DecisionTable where DeveloperName = 'Binding_Checklist_Decision_Lookup_Table_FC' Limit 1];
        
        //Will Remove
        List<DecisionTable> DecisionTableId = [Select Id, DeveloperName from DecisionTable where DeveloperName = 'Broker_Checklist_Decision_Lookup_Table_v2' Limit 1];
        String DecisionTableRecordId = DecisionTableId[DecisionTableId.size()-1].Id; 
        
        String DecisionTableRecordGLId = DecisionTableGLId[DecisionTableGLId.size()-1].Id;
        String DecisionTableRecordUMBId = DecisionTableUMBId[DecisionTableUMBId.size()-1].Id;
        String DecisionTableRecordWCId = DecisionTableWCId[DecisionTableWCId.size()-1].Id;
        String DecisionTableRecordAUId = DecisionTableAUId[DecisionTableAUId.size()-1].Id;
        String DecisionTableRecordFCId = DecisionTableFCId[DecisionTableFCId.size()-1].Id;
        //String DecisionTableRecordWCId = DecisionTableWCId[DecisionTableWCId.size()-1].Id;
        //create list of object to store the ChecklistProductCodeList object result into array form
        List<Object> checklistProductCodeList = (List<Object>) inputMap.get('ChecklistProductCodeList');
        ConnectApi.DecisionTableInput input = new ConnectApi.DecisionTableInput();
        input.conditions = new List<ConnectApi.DecisionTableCondition>();
        List<Object> outputRecords = new List<Object>();
        // Store Action_Plan_Template__c IDs
        List<String> actionPlanTemplateIds = new List<String>();
        // Store Binding checklist record IDs
        List<String> BindingChecklistRecordIds = new List<String>();
        //store Action_Plan_Template__c Ids along with Type__c value
        Map<String, String> ActionTemplateIdsWithTypeRec = new Map<String, String>();
        Map<String, String> ActionTemplateIdsWithBindingCheckListId = new Map<String, String>();
        
        
        //store quoteLineItemID with QuoteLineItem_Reference__c
        Map<String, QuoteLineItem_Reference__c> MapQuoteLineIdWithObj = new Map<String, QuoteLineItem_Reference__c>();
        Map<String, QuoteLineItem_Reference__c> MapAPIdWithObj = new Map<String, QuoteLineItem_Reference__c>();
        Map<String, String> APWithQuoteLineItemId = new Map<String, String>();
        //added for bindingId mapping with quoteLineId
        Map<String, String> BindingRecordIdWithQuoteLineItemId = new Map<String, String>();
        Map<String,String> inputData=new Map<String,String>();
        if(ChecklistProductCodeList.size()>0){
            for (Object checklistItem : checklistProductCodeList) {
                Map<String, Object> checklist = (Map<String, Object>)checklistItem;
                String lineItemId=(String)checklist.get('QuoteLineItemId');
                if(!existingQuoteLines.contains(lineItemId)){
                    String lobCode=String.valueOf(checklist.get('ProductName1')).toUpperCase();
                    String lobType=(String.valueOf(checklist.get('LobType'))==null || String.valueOf(checklist.get('LobType'))=='')?'New':String.valueOf(checklist.get('LobType'));
                    
                    /*
// ALL LOB FILTER
// LOBCODE+Payment type+ Lob Type
inputData=new Map<String,String>();
inputData.put('Lob_Code__c',lobCode);
inputData.put('LoB_Type__c',lobType);
inputData.put('Payment_Type__c',checklist.get('PayPlan')==null?'-':String.valueOf(checklist.get('PayPlan')));
outputRecords.add(getDataFromDecisionTable(lineItemId,DecisionTableRecordId,inputData));

// LOBTYPE ( ALL) 
inputData=new Map<String,String>();
inputData.put('LoB_Type__c',lobType);
outputRecords.add(getDataFromDecisionTable(lineItemId,DecisionTableRecordId,inputData));

// LOBCODE+LOBTYPE
inputData=new Map<String,String>();
inputData.put('Lob_Code__c',lobCode);
inputData.put('LoB_Type__c',lobType);
outputRecords.add(getDataFromDecisionTable(lineItemId,DecisionTableRecordId,inputData));
*/
                    
                    if(lobCode == 'GL'){
                        // LOBTYPE ( ALL) 
                        inputData=new Map<String,String>();
                        inputData.put('LoB_Type__c',lobType);
                        outputRecords.add(getDataFromDecisionTableGL(lineItemId,DecisionTableRecordGLId,inputData));
                        
                        // LOBCODE+LOBTYPE
                        inputData=new Map<String,String>();
                        inputData.put('Lob_Code__c',lobCode);
                        inputData.put('LoB_Type__c',lobType);
                        outputRecords.add(getDataFromDecisionTableGL(lineItemId,DecisionTableRecordGLId,inputData));
                        
                        //LOBCODE+LOBTYPE+STATE
                        inputData=new Map<String,String>();
                        inputData.put('Lob_Code__c',lobCode);
                        inputData.put('LoB_Type__c',lobType);
                        inputData.put('States__c',String.valueOf(checklist.get('States')).toUpperCase());
                        outputRecords.add(getDataFromDecisionTableGL(lineItemId,DecisionTableRecordGLId,inputData));
                        
                        if(Boolean.valueOf(checklist.get('checkValueGratherThan100k'))){
                            System.debug('--->'+Boolean.valueOf(checklist.get('checkValueGratherThan100k')));
                            inputData=new Map<String,String>();
                            //LOBCODE+LOBTYPE + Large_Deductible_Flag__c
                            inputData.put('Lob_Code__c',lobCode);
                            inputData.put('LoB_Type__c',lobType);
                            inputData.put('Large_Deductible_WC_Flag__c',Boolean.valueOf(checklist.get('checkValueGratherThan100k')).toString());
                            outputRecords.add(getDataFromDecisionTableGL(lineItemId,DecisionTableRecordGLId,inputData));
                            
                        }
                        
                        
                            //LOBCODE+LOBTYPE+STATE+Symbol+dereg
                        if(Boolean.valueOf(checklist.get('DeregulationApplies'))){
                            inputData=new Map<String,String>();
                            inputData.put('Lob_Code__c',lobCode);
                            inputData.put('LoB_Type__c',lobType);
                            inputData.put('States__c',String.valueOf(checklist.get('InsuredState')).toUpperCase());
                            inputData.put('Deregulation_Applies_Type__c','True');
                            outputRecords.add(getDataFromDecisionTableGL(lineItemId,DecisionTableRecordGLId,inputData));
                            
                            if(checklist.get('DeregulationClass')!=null && checklist.get('DeregulationClass')!=''){
                                //LOBCODE+LOBTYPE+STATE+Symbol+dereg+ClassType
                                inputData=new Map<String,String>();
                                inputData.put('Lob_Code__c',lobCode);
                                inputData.put('LoB_Type__c',lobType);
                                inputData.put('States__c',String.valueOf(checklist.get('InsuredState')).toUpperCase());
                                inputData.put('Deregulation_Applies_Type__c','True');
                                inputData.put('Deregulation_NYTFZ_Class_Type__c',String.valueOf(checklist.get('DeregulationClass')));
                                outputRecords.add(getDataFromDecisionTableGL(lineItemId,DecisionTableRecordGLId,inputData));
                            }
                            
                      }
                           
                }
                    else if(lobCode == 'UMB'){
                    // LOBTYPE ( ALL) 
                    inputData=new Map<String,String>();
                    inputData.put('LoB_Type__c',lobType);
                    outputRecords.add(getDataFromDecisionTableUMB(lineItemId,DecisionTableRecordUMBId,inputData));
                    
                    // LOBCODE+LOBTYPE
                    inputData=new Map<String,String>();
                    inputData.put('Lob_Code__c',lobCode);
                    inputData.put('LoB_Type__c',lobType);
                    outputRecords.add(getDataFromDecisionTableUMB(lineItemId,DecisionTableRecordUMBId,inputData));
                    
                    //LOBCODE+LOBTYPE+STATE
                    inputData=new Map<String,String>();
                    inputData.put('Lob_Code__c',lobCode);
                    inputData.put('LoB_Type__c',lobType);
                    inputData.put('States__c',String.valueOf(checklist.get('States')).toUpperCase());
                    outputRecords.add(getDataFromDecisionTableUMB(lineItemId,DecisionTableRecordUMBId,inputData));
                    
                       
                        
                    //LOBCODE+LOBTYPE+STATE+Symbol+dereg
                    if(Boolean.valueOf(checklist.get('DeregulationApplies'))){
                        inputData=new Map<String,String>();
                        inputData.put('Lob_Code__c',lobCode);
                        inputData.put('LoB_Type__c',lobType);
                        inputData.put('States__c',String.valueOf(checklist.get('InsuredState')).toUpperCase());
                        inputData.put('Deregulation_Applies_Type__c','True');
                        outputRecords.add(getDataFromDecisionTableUMB(lineItemId,DecisionTableRecordUMBId,inputData));
                        
                        if(checklist.get('DeregulationClass')!=null && checklist.get('DeregulationClass')!=''){
                            //LOBCODE+LOBTYPE+STATE+Symbol+dereg+ClassType
                            inputData=new Map<String,String>();
                            inputData.put('Lob_Code__c',lobCode);
                            inputData.put('LoB_Type__c',lobType);
                            inputData.put('States__c',String.valueOf(checklist.get('InsuredState')).toUpperCase());
                            inputData.put('Deregulation_Applies_Type__c','True');
                            inputData.put('Deregulation_NYTFZ_Class_Type__c',String.valueOf(checklist.get('DeregulationClass')));
                            outputRecords.add(getDataFromDecisionTableUMB(lineItemId,DecisionTableRecordUMBId,inputData));
                        }
                        
                        
                    }
                    
                }
                    else if(lobCode == 'WC'){
                    // LOBTYPE ( ALL) 
                    inputData=new Map<String,String>();
                    inputData.put('LoB_Type__c',lobType);
                    outputRecords.add(getDataFromDecisionTableWC(lineItemId,DecisionTableRecordWCId,inputData));
                    
                    // LOBCODE+LOBTYPE
                    inputData=new Map<String,String>();
                    inputData.put('Lob_Code__c',lobCode);
                    inputData.put('LoB_Type__c',lobType);
                    outputRecords.add(getDataFromDecisionTableWC(lineItemId,DecisionTableRecordWCId,inputData));
                    
                    // LOBCODE+Payment type+ Lob Type
                    inputData=new Map<String,String>();
                    inputData.put('Lob_Code__c',lobCode);
                    inputData.put('LoB_Type__c',lobType);
                    inputData.put('Payment_Type__c',checklist.get('PayPlan')==null?'-':String.valueOf(checklist.get('PayPlan')));
                    outputRecords.add(getDataFromDecisionTableWC(lineItemId,DecisionTableRecordWCId,inputData));
                    
                    String stateFieldValues = String.valueOf(checklist.get('WCStates'));
                    if (stateFieldValues != null && !stateFieldValues.equals('')) {
                        stateFieldValues += ',ALL';
                    } else {
                        stateFieldValues = 'ALL';
                    }
                    String[] stateValues = stateFieldValues.split(',\\s*');
                    for (String stateValue : stateValues) {
                        inputData=new Map<String,String>();
                        //LOBCODE+LOBTYPE+STATE
                        inputData.put('Lob_Code__c',lobCode);
                        inputData.put('LoB_Type__c',lobType);
                        inputData.put('States__c',stateValue.trim());
                        outputRecords.add(getDataFromDecisionTableWC(lineItemId,DecisionTableRecordWCId,inputData));
                        if(Boolean.valueOf(checklist.get('wcDivindentPlancheckbox'))){
                            inputData=new Map<String,String>();
                            //LOBCODE+LOBTYPE +States + Divident Plan
                            inputData.put('Lob_Code__c',lobCode);
                            inputData.put('LoB_Type__c',lobType);
                            inputData.put('States__c',stateValue.trim());
                            inputData.put('WC_Dividend_Plan__c',Boolean.valueOf(checklist.get('wcDivindentPlancheckbox')).toString());
                            outputRecords.add(getDataFromDecisionTableWC(lineItemId,DecisionTableRecordWCId,inputData));
                            
                        }
                        if(Boolean.valueOf(checklist.get('checkValueGratherThan100k'))){
                            System.debug('--->'+Boolean.valueOf(checklist.get('checkValueGratherThan100k')));
                            inputData=new Map<String,String>();
                            //LOBCODE+LOBTYPE + Large_Deductible_WC_Flag__c
                            inputData.put('Lob_Code__c',lobCode);
                            inputData.put('LoB_Type__c',lobType);
                            inputData.put('Large_Deductible_WC_Flag__c',Boolean.valueOf(checklist.get('checkValueGratherThan100k')).toString());
                            outputRecords.add(getDataFromDecisionTableWC(lineItemId,DecisionTableRecordWCId,inputData));
                            
                        }
                        system.debug('@@outputRecords '+JSON.serialize(outputRecords));
                        
                    }
                    
                    
                }
                    else if(lobCode == 'AU'){
                    // LOBTYPE ( ALL) 
                    inputData=new Map<String,String>();
                    inputData.put('LoB_Type__c',lobType);
                    outputRecords.add(getDataFromDecisionTableAU(lineItemId,DecisionTableRecordAUId,inputData));
                    
                    // LOBCODE+LOBTYPE
                    inputData=new Map<String,String>();
                    inputData.put('Lob_Code__c',lobCode);
                    inputData.put('LoB_Type__c',lobType);
                    outputRecords.add(getDataFromDecisionTableAU(lineItemId,DecisionTableRecordAUId,inputData));
                    
                     if(Boolean.valueOf(checklist.get('checkValueGratherThan100k'))){
                            System.debug('--->'+Boolean.valueOf(checklist.get('checkValueGratherThan100k')));
                            inputData=new Map<String,String>();
                            //LOBCODE+LOBTYPE + Large_Deductible_Flag__c
                            inputData.put('Lob_Code__c',lobCode);
                            inputData.put('LoB_Type__c',lobType);
                            inputData.put('Large_Deductible_WC_Flag__c',Boolean.valueOf(checklist.get('checkValueGratherThan100k')).toString());
                            outputRecords.add(getDataFromDecisionTableUMB(lineItemId,DecisionTableRecordUMBId,inputData));
                            
                        } 
                        
                    String stateAbbreviationsString = String.valueOf(checklist.get('AuStates'));
                    If (checklist.get('AuStates') instanceof List<Object>) {
                        stateAbbreviationsString = String.valueOf(String.join((List<Object>)checklist.get('AuStates'),','));
                    } 
                    // Check if the string is not null and not empty before appending "ALL"
                    if (stateAbbreviationsString != null && !stateAbbreviationsString.equals('')) {
                        stateAbbreviationsString += ',ALL';
                    } else {
                        stateAbbreviationsString = 'ALL';
                    }
                    Set<String> stateAbbreviations = new Set<String>(stateAbbreviationsString.split(','));
                    //LOBCODE+LOBTYPE+STATE 
                    for (String stateAbbreviation : stateAbbreviations) {
                        
                        inputData=new Map<String,String>();
                        inputData.put('Lob_Code__c',lobCode);
                        inputData.put('LoB_Type__c',lobType);
                        inputData.put('States__c',stateAbbreviation.trim());
                        outputRecords.add(getDataFromDecisionTableAU(lineItemId,DecisionTableRecordAUId,inputData));
                    }
                    //LOBCODE+LOBTYPE+STATE+Symbol
                    if(checklist.get('Coverage')!=null){
                        List<Object> coverages = (List<Object>)checklist.get('Coverage');
                        for(Object covObj: coverages){
                            Map<String,Object> prodRec=(Map<String,Object>)covObj;
                            String cauSymbol ='';
                            String ProductCode = String.valueOf(prodRec.get('ProductCode'));
                            if(prodRec.get('ApplicationJSON')!=null){
                                Map<String,Object>  appJson = (Map<String,Object> )prodRec.get('ApplicationJSON');
                                cauSymbol = appJson.get('CAUSYMBOL')!=null?String.ValueOf(appJson.get('CAUSYMBOL')):'';
                            }
                            if(cauSymbol!=''  && (ProductCode=='lcsl' || ProductCode=='LPD' || ProductCode=='lBI')){
                                List<String> cauSymbols = new List<String>(cauSymbol.split(','));
                                
                                for (String stateAbbreviation : stateAbbreviations) {
                                    
                                    for (String symbol : cauSymbols) {
                                        inputData=new Map<String,String>();
                                        inputData.put('Lob_Code__c',lobCode);
                                        inputData.put('LoB_Type__c',lobType);
                                        inputData.put('States__c',stateAbbreviation.trim());
                                        inputData.put('Symbol__c',symbol.trim());
                                        outputRecords.add(getDataFromDecisionTableAU(lineItemId,DecisionTableRecordAUId,inputData));
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                    }
                    
                    //LOBCODE+LOBTYPE+STATE+Symbol+dereg
                    if(Boolean.valueOf(checklist.get('DeregulationApplies'))){
                        inputData=new Map<String,String>();
                        inputData.put('Lob_Code__c',lobCode);
                        inputData.put('LoB_Type__c',lobType);
                        inputData.put('States__c',String.valueOf(checklist.get('InsuredState')).toUpperCase());
                        inputData.put('Deregulation_Applies_Type__c','True');
                        outputRecords.add(getDataFromDecisionTableAU(lineItemId,DecisionTableRecordAUId,inputData));
                        
                        if(checklist.get('DeregulationClass')!=null && checklist.get('DeregulationClass')!=''){
                            //LOBCODE+LOBTYPE+STATE+Symbol+dereg+ClassType
                            inputData=new Map<String,String>();
                            inputData.put('Lob_Code__c',lobCode);
                            inputData.put('LoB_Type__c',lobType);
                            inputData.put('States__c',String.valueOf(checklist.get('InsuredState')).toUpperCase());
                            inputData.put('Deregulation_Applies_Type__c','True');
                            inputData.put('Deregulation_NYTFZ_Class_Type__c',String.valueOf(checklist.get('DeregulationClass')));
                            outputRecords.add(getDataFromDecisionTableAU(lineItemId,DecisionTableRecordAUId,inputData));
                        }
                        
                        
                    }
                    
                }
                    else if(lobCode == 'FC'){
                        // LOBTYPE ( ALL) 
                        inputData=new Map<String,String>();
                        inputData.put('LoB_Type__c',lobType);
                        outputRecords.add(getDataFromDecisionTableFC(lineItemId,DecisionTableRecordFCId,inputData));
                        
                        // LOBCODE+LOBTYPE
                        inputData=new Map<String,String>();
                        inputData.put('Lob_Code__c',lobCode);
                        inputData.put('LoB_Type__c',lobType);
                        outputRecords.add(getDataFromDecisionTableFC(lineItemId,DecisionTableRecordFCId,inputData));
                        //Selected Coverage
                        List<String> listFCCov=new List<String>();
                        List<Object>  fcCoverages = (List<Object>)checklist.get('FCCoverages');
                        for(Object covrages:fcCoverages){
                            Map<String, Object> covMap = (Map<String, Object>)covrages;
                            if(String.valueOf(covMap.get('Type'))=='EA' && (Boolean)covMap.get('isSelected')){
                                listFCCov.add('FCSE');
                            }
                        }
                        
                        List<Object>  countryValue = (List<Object>)checklist.get('FCCountry');
                        List<Object> countrylobTypeList = (List<Object>)checklist.get('FCLocType');
                        Set<String> countryListData = new Set<String>();
                        countryListData.add('All');
                        List<String> listELCountry=new List<String>();
                        integer i=0;
                        for(object ob: countryValue){
                            String cntry = String.ValueOf(ob);
                            countryListData.add(cntry);
                            if(countrylobTypeList.size()>i){
                                String countrylobType =  String.ValueOf(countrylobTypeList[i]);
                                if(countrylobType=='Employers Liability'){
                                    listELCountry.add(cntry);
                                }
                            }
                            
                            i++;
                        }
                        
                        for (String countryAbbreviation : countryListData) {
                            inputData=new Map<String,String>();
                            inputData.put('Lob_Code__c',lobCode);
                            inputData.put('LoB_Type__c',lobType);
                            inputData.put('Country__c',countryAbbreviation);
                            outputRecords.add(getDataFromDecisionTableFC(lineItemId,DecisionTableRecordFCId,inputData));
                            
                            if(listELCountry.contains(countryAbbreviation)){
                                
                                inputData=new Map<String,String>();
                                inputData.put('Lob_Code__c',lobCode);
                                inputData.put('LoB_Type__c',lobType);
                                inputData.put('Country__c',countryAbbreviation);
                                inputData.put('Local_Policy_Coverage__c','EL');
                                outputRecords.add(getDataFromDecisionTableFC(lineItemId,DecisionTableRecordFCId,inputData));
                            }
                        }
                        
                        for(String cov: listFCCov){
                            inputData=new Map<String,String>();
                            inputData.put('Lob_Code__c',lobCode);
                            inputData.put('LoB_Type__c',lobType);
                            inputData.put('Coverage_Code__c',cov);
                            outputRecords.add(getDataFromDecisionTableFC(lineItemId,DecisionTableRecordFCId,inputData));
                        }
                }
                // AU Filter
                /*
                else if(lobCode == 'AU'){
                    
                    String stateAbbreviationsString = String.valueOf(checklist.get('AuStates'));
                    If (checklist.get('AuStates') instanceof List<Object>) {
                        stateAbbreviationsString = String.valueOf(String.join((List<Object>)checklist.get('AuStates'),','));
                    } 
                    // Check if the string is not null and not empty before appending "ALL"
                    if (stateAbbreviationsString != null && !stateAbbreviationsString.equals('')) {
                        stateAbbreviationsString += ',ALL';
                    } else {
                        stateAbbreviationsString = 'ALL';
                    }
                    Set<String> stateAbbreviations = new Set<String>(stateAbbreviationsString.split(','));
                    //LOBCODE+LOBTYPE+STATE 
                    for (String stateAbbreviation : stateAbbreviations) {
                        
                        inputData=new Map<String,String>();
                        inputData.put('Lob_Code__c',lobCode);
                        inputData.put('LoB_Type__c',lobType);
                        inputData.put('States__c',stateAbbreviation.trim());
                        outputRecords.add(getDataFromDecisionTable(lineItemId,DecisionTableRecordId,inputData));
                    }
                    //LOBCODE+LOBTYPE+STATE+Symbol
                    if(checklist.get('Coverage')!=null){
                        List<Object> coverages = (List<Object>)checklist.get('Coverage');
                        for(Object covObj: coverages){
                            Map<String,Object> prodRec=(Map<String,Object>)covObj;
                            String cauSymbol ='';
                            String ProductCode = String.valueOf(prodRec.get('ProductCode'));
                            if(prodRec.get('ApplicationJSON')!=null){
                                Map<String,Object>  appJson = (Map<String,Object> )prodRec.get('ApplicationJSON');
                                cauSymbol = appJson.get('CAUSYMBOL')!=null?String.ValueOf(appJson.get('CAUSYMBOL')):'';
                            }
                            if(cauSymbol!=''  && (ProductCode=='lcsl' || ProductCode=='LPD' || ProductCode=='lBI')){
                                List<String> cauSymbols = new List<String>(cauSymbol.split(','));
                                
                                for (String stateAbbreviation : stateAbbreviations) {
                                    
                                    for (String symbol : cauSymbols) {
                                        inputData=new Map<String,String>();
                                        inputData.put('Lob_Code__c',lobCode);
                                        inputData.put('LoB_Type__c',lobType);
                                        inputData.put('States__c',stateAbbreviation.trim());
                                        inputData.put('Symbol__c',symbol.trim());
                                        outputRecords.add(getDataFromDecisionTable(lineItemId,DecisionTableRecordId,inputData));
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                    }
                    
                    //LOBCODE+LOBTYPE+STATE+Symbol+dereg
                    if(Boolean.valueOf(checklist.get('DeregulationApplies'))){
                        inputData=new Map<String,String>();
                        inputData.put('Lob_Code__c',lobCode);
                        inputData.put('LoB_Type__c',lobType);
                        inputData.put('States__c',String.valueOf(checklist.get('InsuredState')).toUpperCase());
                        inputData.put('Deregulation_Applies_Type__c','True');
                        outputRecords.add(getDataFromDecisionTable(lineItemId,DecisionTableRecordId,inputData));
                        
                        if(checklist.get('DeregulationClass')!=null && checklist.get('DeregulationClass')!=''){
                            //LOBCODE+LOBTYPE+STATE+Symbol+dereg+ClassType
                            inputData=new Map<String,String>();
                            inputData.put('Lob_Code__c',lobCode);
                            inputData.put('LoB_Type__c',lobType);
                            inputData.put('States__c',String.valueOf(checklist.get('InsuredState')).toUpperCase());
                            inputData.put('Deregulation_Applies_Type__c','True');
                            inputData.put('Deregulation_NYTFZ_Class_Type__c',String.valueOf(checklist.get('DeregulationClass')));
                            outputRecords.add(getDataFromDecisionTable(lineItemId,DecisionTableRecordId,inputData));
                        }
                        
                        
                    }
                }
                else if(lobCode == 'FC'){
                    //Selected Coverage
                    List<String> listFCCov=new List<String>();
                    List<Object>  fcCoverages = (List<Object>)checklist.get('FCCoverages');
                    for(Object covrages:fcCoverages){
                        Map<String, Object> covMap = (Map<String, Object>)covrages;
                        if(String.valueOf(covMap.get('Type'))=='EA' && (Boolean)covMap.get('isSelected')){
                            listFCCov.add('FCSE');
                        }
                    }
                    
                    List<Object>  countryValue = (List<Object>)checklist.get('FCCountry');
                    List<Object> countrylobTypeList = (List<Object>)checklist.get('FCLocType');
                    Set<String> countryListData = new Set<String>();
                    countryListData.add('All');
                    List<String> listELCountry=new List<String>();
                    integer i=0;
                    for(object ob: countryValue){
                        String cntry = String.ValueOf(ob);
                        countryListData.add(cntry);
                        if(countrylobTypeList.size()>i){
                            String countrylobType =  String.ValueOf(countrylobTypeList[i]);
                            if(countrylobType=='Employers Liability'){
                                listELCountry.add(cntry);
                            }
                        }
                        
                        i++;
                    }
                    
                    for (String countryAbbreviation : countryListData) {
                        inputData=new Map<String,String>();
                        inputData.put('Lob_Code__c',lobCode);
                        inputData.put('LoB_Type__c',lobType);
                        inputData.put('Country__c',countryAbbreviation);
                        outputRecords.add(getDataFromDecisionTable(lineItemId,DecisionTableRecordId,inputData));
                        
                        if(listELCountry.contains(countryAbbreviation)){
                            
                            inputData=new Map<String,String>();
                            inputData.put('Lob_Code__c',lobCode);
                            inputData.put('LoB_Type__c',lobType);
                            inputData.put('Country__c',countryAbbreviation);
                            inputData.put('Local_Policy_Coverage__c','EL');
                            outputRecords.add(getDataFromDecisionTable(lineItemId,DecisionTableRecordId,inputData));
                        }
                    }
                    
                    for(String cov: listFCCov){
                        inputData=new Map<String,String>();
                        inputData.put('Lob_Code__c',lobCode);
                        inputData.put('LoB_Type__c',lobType);
                        inputData.put('Coverage_Code__c',cov);
                        outputRecords.add(getDataFromDecisionTable(lineItemId,DecisionTableRecordId,inputData));
                    }
                    
                }
                else if(lobCode == 'WC'){
                    String stateFieldValues = String.valueOf(checklist.get('WCStates'));
                    if (stateFieldValues != null && !stateFieldValues.equals('')) {
                        stateFieldValues += ',ALL';
                    } else {
                        stateFieldValues = 'ALL';
                    }
                    String[] stateValues = stateFieldValues.split(',\\s*');
                    for (String stateValue : stateValues) {
                        inputData=new Map<String,String>();
                        inputData.put('Lob_Code__c',lobCode);
                        inputData.put('LoB_Type__c',lobType);
                        inputData.put('States__c',stateValue.trim());
                        outputRecords.add(getDataFromDecisionTableWC(lineItemId,DecisionTableRecordWCId,inputData));
                        if(Boolean.valueOf(checklist.get('wcDivindentPlancheckbox'))){
                            inputData=new Map<String,String>();
                            inputData.put('Lob_Code__c',lobCode);
                            inputData.put('LoB_Type__c',lobType);
                            inputData.put('States__c',stateValue.trim());
                            inputData.put('WC_Dividend_Plan__c',Boolean.valueOf(checklist.get('wcDivindentPlancheckbox')).toString());
                            outputRecords.add(getDataFromDecisionTableWC(lineItemId,DecisionTableRecordWCId,inputData));
                            
                        }
                        if(Boolean.valueOf(checklist.get('checkValueGratherThan100k'))){
                            System.debug('--->'+Boolean.valueOf(checklist.get('checkValueGratherThan100k')));
                            inputData=new Map<String,String>();
                            inputData.put('Lob_Code__c',lobCode);
                            inputData.put('LoB_Type__c',lobType);
                            inputData.put('Large_Deductible_WC_Flag__c',Boolean.valueOf(checklist.get('checkValueGratherThan100k')).toString());
                            outputRecords.add(getDataFromDecisionTableWC(lineItemId,DecisionTableRecordWCId,inputData));
                            
                        }
                        system.debug('@@outputRecords '+JSON.serialize(outputRecords));
                        
                    }
                    
                }
                else{
                    //LOBCODE+LOBTYPE+STATE
                    inputData=new Map<String,String>();
                    inputData.put('Lob_Code__c',lobCode);
                    inputData.put('LoB_Type__c',lobType);
                    inputData.put('States__c',String.valueOf(checklist.get('States')).toUpperCase());
                    outputRecords.add(getDataFromDecisionTable(lineItemId,DecisionTableRecordId,inputData));
                    
                    //LOBCODE+LOBTYPE+STATE+Symbol+dereg
                    if(Boolean.valueOf(checklist.get('DeregulationApplies'))){
                        inputData=new Map<String,String>();
                        inputData.put('Lob_Code__c',lobCode);
                        inputData.put('LoB_Type__c',lobType);
                        inputData.put('States__c',String.valueOf(checklist.get('InsuredState')).toUpperCase());
                        inputData.put('Deregulation_Applies_Type__c','True');
                        outputRecords.add(getDataFromDecisionTable(lineItemId,DecisionTableRecordId,inputData));
                        
                        if(checklist.get('DeregulationClass')!=null && checklist.get('DeregulationClass')!=''){
                            //LOBCODE+LOBTYPE+STATE+Symbol+dereg+ClassType
                            inputData=new Map<String,String>();
                            inputData.put('Lob_Code__c',lobCode);
                            inputData.put('LoB_Type__c',lobType);
                            inputData.put('States__c',String.valueOf(checklist.get('InsuredState')).toUpperCase());
                            inputData.put('Deregulation_Applies_Type__c','True');
                            inputData.put('Deregulation_NYTFZ_Class_Type__c',String.valueOf(checklist.get('DeregulationClass')));
                            outputRecords.add(getDataFromDecisionTable(lineItemId,DecisionTableRecordId,inputData));
                        }
                        
                        
                    }
                }*/
            }
        }
    }
    System.debug('Output: ' + outputRecords);
    Map<String,List<Map<String, Object>>> quoteLineWisePlans=new Map<String,List<Map<String, Object>>>();
    for(Object obj : outputRecords){
        Map<String, Object> outputMap = (Map<String, Object>)obj;
        if (outputMap.containsKey('outcomeList')) {
            List<Object> outcomeList = (List<Object>)outputMap.get('outcomeList');
            String QLIId=(String)outputMap.get('QuoteLineItemId');
            for (Object outcome : outcomeList) {
                Map<String, Object> outcomeMap = (Map<String, Object>)outcome;
                if (outcomeMap.containsKey('values')) {
                    Map<String, Object> valuesMap = (Map<String, Object>)outcomeMap.get('values');
                    
                    if (valuesMap.containsKey('Action_Plan_Template__c')) {
                        if(!quoteLineWisePlans.containsKey(QLIId)){
                            quoteLineWisePlans.put(QLIId,new List<Map<String, Object>>());
                        }
                        quoteLineWisePlans.get(QLIId).add(valuesMap);
                        actionPlanTemplateIds.add((String)valuesMap.get('Action_Plan_Template__c'));
                        BindingChecklistRecordIds.add((String)valuesMap.get('Id'));
                    }
                }
            }
        }
    }
    
    List<Quote> QuoteDetails = [Select Id, OpportunityId from Quote where Id =: QuoteId];
    List<ActionPlanTemplateVersion> ActionPlanVersionRecord = [select Id, Name, ActionPlanTemplateId, Version, Status from ActionPlanTemplateVersion where ActionPlanTemplateId =: actionPlanTemplateIds];
    
    Map<String,ActionPlanTemplateVersion> idWiseActionPlan=new Map<String,ActionPlanTemplateVersion>();
    for(ActionPlanTemplateVersion APTV :ActionPlanVersionRecord ){
        idWiseActionPlan.put(APTV.ActionPlanTemplateId,APTV);
    }                       
    
    List<ActionPlan> APList = new List<ActionPlan>();     
    Map<String,List<String>> APWiseQLI = new Map<String,List<String>>(); 
    List<QuoteLineItem_Reference__c> recordsToInsert = new List<QuoteLineItem_Reference__c>();
    Map<String,QuoteLineItem_Reference__c> QLIWithAPToInsert = new Map<String,QuoteLineItem_Reference__c>();
    for(String QLIId : quoteLineWisePlans.keySet()){
        for(Map<String, Object> actionPlanRec : quoteLineWisePlans.get(QLIId)){
            String apId=(String)actionPlanRec.get('Action_Plan_Template__c');
            if(!idWiseActionPlan.containsKey(apId)){
                continue;
            }
            if(!APWiseQLI.containsKey(apId)){
                APWiseQLI.put(apId,new List<String>());
            }
            if( QLIWithAPToInsert.containsKey(QLIId+'_'+apId)){
                continue;
            }
            QuoteLineItem_Reference__c QLIRef = new QuoteLineItem_Reference__c();
            QLIRef.Quote_Line_Item__c = QLIId;
            QLIRef.Type__c = (String)actionPlanRec.get('Type__c');
            QLIRef.Binding_Checklist__c =(String)actionPlanRec.get('Id');
            APWiseQLI.get(apId).add(QLIRef.Binding_Checklist__c);
            
            QLIWithAPToInsert.put(QLIId+'_'+ apId,QLIRef);
            
            ActionPlan ap = new ActionPlan();
            ap.Name = idWiseActionPlan.get(apId).Name + '_ActionPlan';
            ap.ActionPlanTemplateVersionId = idWiseActionPlan.get(apId).Id;
            ap.ActionPlanType = 'Industries';
            ap.QuoteLineItem_Reference__r = QLIWithAPToInsert.get(QLIId+'_'+apId);
            ap.ActionPlanState = 'Not Started';
            ap.Generate_Quote_and_Binder__c = QuoteId;
            ap.StartDate = System.today();
            ap.Type__c = (String)actionPlanRec.get('Type__c');
            APList.add(ap);
        }                     
    }
    if(!QLIWithAPToInsert.isEmpty()){
        insert QLIWithAPToInsert.values();
    }
    List<String> listQuoteLineRef=new List<String>();
    for(ActionPlan ap : APList){
        ap.targetId= ap.QuoteLineItem_Reference__r.Id;
        ap.QuoteLineItem_Reference__c= ap.QuoteLineItem_Reference__r.Id;
        ap.QuoteLineItem_Reference__r=null;
        listQuoteLineRef.add(ap.targetId);
    }
    if (APList.size() > 0) {
        system.debug('@@'+JSON.serialize(APList));
        // Perform the insert operation
        Database.SaveResult[] insertResults = Database.insert(APList, false);
        // Collect the IDs of successfully inserted records
        List<Id> insertedRecordIds = new List<Id>();
        
        // Iterate through the results to get the IDs of the successfully inserted records
        for (Integer i = 0; i < insertResults.size(); i++) {
            if (insertResults[i].isSuccess()) {
                insertedRecordIds.add(insertResults[i].getId());
            } else {
                System.debug('Insert failed for record ' + i + '. Errors: ' + insertResults[i].getErrors());
            }
        }
        
        if(insertedRecordIds!=null)
        {
            Set<Id> quoteIdsForTask = new Set<Id>();
            quoteIdsForTask.add(QuoteId);        
            createOrUpdateBindingChecklistTasks(quoteIdsForTask);
        }  
    }
    updateDocumentChecklist(listQuoteLineRef);
    List<ContentDocumentLink> linkListToInsert = new List<ContentDocumentLink>();
    //804 logic here 
    if (BindingChecklistRecordIds.size() > 0) {
        List<ContentDocumentLink> linkList = [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId IN :BindingChecklistRecordIds];
        
        Map<String, List<String>> existingQuoteDocIdMap = new Map<String, List<String>>();
        for (ContentDocumentLink CDL : linkList) {
            if (!existingQuoteDocIdMap.containsKey(CDL.LinkedEntityId)) {
                existingQuoteDocIdMap.put(CDL.LinkedEntityId, new List<String>{CDL.ContentDocumentId});
            } else {
                List<String> ext = new List<String>();
                ext.addAll(existingQuoteDocIdMap.get(CDL.LinkedEntityId));
                ext.add(CDL.ContentDocumentId);
                existingQuoteDocIdMap.put(CDL.LinkedEntityId, ext);
            }
        }
        for(String QliRef_apId : QLIWithAPToInsert.KeySet()){
            String QliRefId = QliRef_apId.split('_')[0];
            String apId = QliRef_apId.split('_')[1];
            
            for(String BinderId: APWiseQLI.get(apId)){
                if (existingQuoteDocIdMap.containsKey(BinderId)) {
                    for(String CDI : existingQuoteDocIdMap.get(BinderId)){
                        ContentDocumentLink link = new ContentDocumentLink();
                        link.ContentDocumentId = CDI;
                        link.LinkedEntityId = QLIWithAPToInsert.get(QliRef_apId).Id;
                        link.ShareType = 'V';
                        linkListToInsert.add(link);
                    }
                }
            }
            
        }
        if (linkListToInsert.size() > 0) {
            Database.insert(linkListToInsert,false);
        }
        
        
    }
}
//N2G-723 for Task Create
public static void createOrUpdateBindingChecklistTasks(Set<Id> quoteIdsForTask) {
    // Maps to store relevant data
    Map<Id, String> quoteIdToOppNameMap = new Map<Id, String>();
    Map<Id, String> quoteIdToOppUWAssMap = new Map<Id, String>();
    Map<Id, String> quoteIdToOppUWMap = new Map<Id, String>();
    Map<String, Id> usernameToIdMap = new Map<String, Id>();
    List<Task> updatedTasks = new List<Task>();
    Map<Id, Task> existingTasks = new Map<Id, Task>();
    
    // Populate data from quotes
    List<Quote> quoteList = DAL_Quote.getQuoteDetailsList(new List<Id>(quoteIdsForTask));
    for (Quote quote : quoteList) {
        quoteIdToOppNameMap.put(quote.Id, quote.Opportunity.Name);
        quoteIdToOppUWAssMap.put(quote.Id, quote.Opportunity.Underwriting_Associate__c);
        quoteIdToOppUWMap.put(quote.Id, quote.Opportunity.Underwriter_Name__c);
    }
    
    // Retrieve users based on unique names from quotes
    Set<String> uniqueUserNames = new Set<String>(quoteIdToOppUWMap.values());
    List<User> userList = DAL_User.getUsersByNamesList(new List<String>(uniqueUserNames));
    for (User user : userList) {
        usernameToIdMap.put(user.Name, user.Id);
    }
    
    // Retrieve existing tasks related to the given quotes
    for (Task task : DAL_Task.getTasksByWhatIdsList(new List<Id>(quoteIdsForTask))) {
        System.debug('Processing Task: ' + task.Id);
        if (task.Subject.startsWith('Binding Checklist Task')) {
            existingTasks.put(task.WhatId, task);
        }
    }
    
    // Lists to store tasks for insertion and status update
    List<Task> tasksToInsert = new List<Task>();
    List<Task> tasksToUpdateStatus = new List<Task>();
    
    Task taskToUpdate;
    for (Id quoteId : quoteIdsForTask) {
        taskToUpdate = existingTasks.get(quoteId);
        
        if (taskToUpdate != null) {
            updatedTasks.add(taskToUpdate);
        }
    }
    
    // Creating a new Task
    String quoteId;
    for (Id myId : quoteIdsForTask) {
        quoteId= (String.valueOf(myId));
    }
    System.debug('Creating new Task for quoteId: ' + quoteId);
    Task newTask = new Task();
    newTask.Subject = 'Binding Checklist Task ' + quoteIdToOppNameMap.get(quoteId);
    newTask.WhatId = quoteId;
    newTask.ActivityDate = System.today().addDays(21);
    newTask.Status = 'Open';
    
    // Set OwnerId based on Underwriting Associate or Underwriter Name
    String assigneeUsername = quoteIdToOppUWAssMap.get(quoteId);
    if (assigneeUsername != null) {
        newTask.OwnerId = assigneeUsername;
    } else {
        assigneeUsername = quoteIdToOppUWMap.get(quoteId);
        if (String.isNotBlank(assigneeUsername) && usernameToIdMap.containsKey(assigneeUsername)) {
            newTask.OwnerId = usernameToIdMap.get(assigneeUsername);
            
        }
    }
    
    tasksToInsert.add(newTask);
    
    // Update existing task status if applicable
    if (taskToUpdate != null) {
        //Integer completedChecklistCount = DAL_DocumentChecklistItem.getCompletedChecklistCount(quoteId);
        //Integer totalChecklist = DAL_DocumentChecklistItem.getDocumentChecklistItemCount(quoteId);
        
        //if (completedChecklistCount == totalChecklist) {
        //  taskToUpdate.Status = 'Completed';
        //} else
        if (taskToUpdate.Status != 'Open') {
            taskToUpdate.Status = 'Open';
            TH_Task.sendEmailForNewTask(updatedTasks);
        }
        
        tasksToUpdateStatus.add(taskToUpdate);
    }
    
    
    // Bulk insert and update tasks
    if (!tasksToInsert.isEmpty() && existingTasks.size()==0) {
        insert tasksToInsert;
    }
    
    if (!tasksToUpdateStatus.isEmpty() && existingTasks.size()!=0) {
        update tasksToUpdateStatus;
    }
}

public static void updateDocumentChecklist(List<String> QLIRefIds){
    List<DocumentChecklistItem> documentChecklist=[SELECT ID,parentRecordId,Generate_Quote_and_Binder__c,Quote_Line_Item__c,Type__c,States__c,Country__c,Country_States__c
                                                   FROM DocumentChecklistItem Where parentRecordId=:QLIRefIds];
    Map<Id,QuoteLineItem_Reference__c> quoteLineRefMap=new Map<Id,QuoteLineItem_Reference__c>([SELECT ID,Quote_Line_Item__c,Quote_Line_Item__r.Quote.Id, Type__c,Binding_Checklist__r.States__c,Binding_Checklist__r.Country__c, Binding_Checklist__r.Type__c FROM QuoteLineItem_Reference__c  Where Id=:QLIRefIds]);
    for(DocumentChecklistItem Doc : documentChecklist ){
        if(quoteLineRefMap.containsKey(Doc.parentRecordId)){
            QuoteLineItem_Reference__c qliref=quoteLineRefMap.get(Doc.parentRecordId);
            Doc.Generate_Quote_and_Binder__c=qliref.Quote_Line_Item__r.Quote.Id;
            Doc.Quote_Line_Item__c=qliref.Quote_Line_Item__c;
            doc.Type__c=qliref.Binding_Checklist__r.Type__c;
            //N2G-1001
            if(qliref.Binding_Checklist__r.Type__c=='File attachment' || qliref.Binding_Checklist__r.Type__c=='Note to Broker')
            {
                doc.Status='Complete';
            }
            doc.States__c=qliref.Binding_Checklist__r.States__c;
            doc.Country__c=qliref.Binding_Checklist__r.Country__c;
            if(doc.States__c!=null && !String.isBlank(doc.States__c)){
                doc.Country_States__c= doc.States__c;
            }else{
                doc.Country_States__c= doc.Country__c;
            }
        }
    }
    Trigger_PAD.deactivateTrigger('TH_DocumentChecklistItemBeforeUpdate');
    Trigger_PAD.deactivateTrigger('TH_DocumentChecklistItemAfterUpdate');
    update documentChecklist;
    Trigger_PAD.activateTrigger('TH_DocumentChecklistItemBeforeUpdate');
    Trigger_PAD.activateTrigger('TH_DocumentChecklistItemAfterUpdate'); 
}
/*
public static Map<String, Object>  getDataFromDecisionTable(String lineItem,String DecisionTableRecordId,Map<String,String> inputData) {
    String[] fieldsToFilter= new String[] {'Lob_Code__c','Country__c','Coverage_Code__c','Payment_Type__c','States__c','Symbol__c','Deregulation_Applies_Type__c','Deregulation_NYTFZ_Class_Type__c','Local_Policy_Coverage__c','LoB_Type__c'};
        
        ConnectApi.DecisionTableInput input = new ConnectApi.DecisionTableInput();
    input.conditions = new List<ConnectApi.DecisionTableCondition>();
    
    for(String field:fieldsToFilter){
        //dynamic field filter condition 
        ConnectApi.DecisionTableCondition lobCondition = new ConnectApi.DecisionTableCondition();
        lobCondition.fieldName = field;
        lobCondition.value = inputData.containsKey(field)?inputData.get(field):'-';
        if(field=='Deregulation_Applies_Type__c' && lobCondition.value=='-'){
            lobCondition.value =false;
        }
        if(field=='States__c' && lobCondition.value=='-'){
            lobCondition.value ='ALL';
        }
        if(field=='Deregulation_Applies_Type__c' && lobCondition.value=='True'){
            lobCondition.value =true;
        }
        input.conditions.add(lobCondition);
    }
    
    ConnectApi.DecisionTableOutcome output = ConnectApi.DecisionTable.execute(DecisionTableRecordId, input);
    Map<String, Object> outputMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(output));
    outputMap.put('QuoteLineItemId', lineItem); 
    return outputMap;
}*/
//BRE WC N2G-1039
public static Map<String, Object>  getDataFromDecisionTableGL(String lineItem,String DecisionTableRecordId,Map<String,String> inputData) {
    String[] fieldsToFilter= new String[] {'LoB_Type__c','Lob_Code__c','States__c','Deregulation_Applies_Type__c','Deregulation_NYTFZ_Class_Type__c','Large_Deductible_WC_Flag__c'};
        
        ConnectApi.DecisionTableInput input = new ConnectApi.DecisionTableInput();
    input.conditions = new List<ConnectApi.DecisionTableCondition>();
    
    for(String field:fieldsToFilter){
        //dynamic field filter condition 
        ConnectApi.DecisionTableCondition lobCondition = new ConnectApi.DecisionTableCondition();
        lobCondition.fieldName = field;
        lobCondition.value = inputData.containsKey(field)?inputData.get(field):'-';
        
        if(field=='Deregulation_Applies_Type__c' && lobCondition.value=='-'){
            lobCondition.value =false;
        }
        if(field=='States__c' && lobCondition.value=='-'){
            lobCondition.value ='ALL';
        }
        if(field=='Deregulation_Applies_Type__c' && lobCondition.value=='True'){
            lobCondition.value =true;
        }
        
        if(field=='Large_Deductible_WC_Flag__c' && (lobCondition.value=='-' || lobCondition.value=='false')){
            lobCondition.value =false;
        }
        if(field=='Large_Deductible_WC_Flag__c' && lobCondition.value=='true'){
            lobCondition.value =true;
        }
        
        
        input.conditions.add(lobCondition);
    }
    
    ConnectApi.DecisionTableOutcome output = ConnectApi.DecisionTable.execute(DecisionTableRecordId, input);
    Map<String, Object> outputMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(output));
    outputMap.put('QuoteLineItemId', lineItem); 
    return outputMap;
}
//BRE WC N2G-1039
public static Map<String, Object>  getDataFromDecisionTableUMB(String lineItem,String DecisionTableRecordId,Map<String,String> inputData) {
    String[] fieldsToFilter= new String[] {'LoB_Type__c','Lob_Code__c','States__c','Deregulation_Applies_Type__c','Deregulation_NYTFZ_Class_Type__c'};
        
        ConnectApi.DecisionTableInput input = new ConnectApi.DecisionTableInput();
    input.conditions = new List<ConnectApi.DecisionTableCondition>();
    
    for(String field:fieldsToFilter){
        //dynamic field filter condition 
        ConnectApi.DecisionTableCondition lobCondition = new ConnectApi.DecisionTableCondition();
        lobCondition.fieldName = field;
        lobCondition.value = inputData.containsKey(field)?inputData.get(field):'-';
        
        
        if(field=='Deregulation_Applies_Type__c' && lobCondition.value=='-'){
            lobCondition.value =false;
        }
        if(field=='States__c' && lobCondition.value=='-'){
            lobCondition.value ='ALL';
        }
        if(field=='Deregulation_Applies_Type__c' && lobCondition.value=='True'){
            lobCondition.value =true;
        }
         if(field=='Large_Deductible_WC_Flag__c' && (lobCondition.value=='-' || lobCondition.value=='false')){
            lobCondition.value =false;
        }
        if(field=='Large_Deductible_WC_Flag__c' && lobCondition.value=='true'){
            lobCondition.value =true;
        }
        
        
        input.conditions.add(lobCondition);
    }
    
    ConnectApi.DecisionTableOutcome output = ConnectApi.DecisionTable.execute(DecisionTableRecordId, input);
    Map<String, Object> outputMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(output));
    outputMap.put('QuoteLineItemId', lineItem); 
    return outputMap;
}
//BRE WC N2G-1039
public static Map<String, Object>  getDataFromDecisionTableWC(String lineItem,String DecisionTableRecordId,Map<String,String> inputData) {
    String[] fieldsToFilter= new String[] {'LoB_Type__c','Lob_Code__c','States__c','WC_Dividend_Plan__c','Payment_Type__c','Large_Deductible_WC_Flag__c'};
        
        ConnectApi.DecisionTableInput input = new ConnectApi.DecisionTableInput();
    input.conditions = new List<ConnectApi.DecisionTableCondition>();
    
    for(String field:fieldsToFilter){
        //dynamic field filter condition 
        ConnectApi.DecisionTableCondition lobCondition = new ConnectApi.DecisionTableCondition();
        lobCondition.fieldName = field;
        lobCondition.value = inputData.containsKey(field)?inputData.get(field):'-';
        
        if(field=='WC_Dividend_Plan__c' && (lobCondition.value=='-' || lobCondition.value=='false')){
            lobCondition.value =false;
        }
        if(field=='WC_Dividend_Plan__c' && lobCondition.value=='true'){
            lobCondition.value =true;
        }
        if(field=='Large_Deductible_WC_Flag__c' && (lobCondition.value=='-' || lobCondition.value=='false')){
            lobCondition.value =false;
        }
        if(field=='Large_Deductible_WC_Flag__c' && lobCondition.value=='true'){
            lobCondition.value =true;
        }
        if(field=='States__c' && lobCondition.value=='-'){
            lobCondition.value ='ALL';
        }
        
        
        input.conditions.add(lobCondition);
    }
    
    ConnectApi.DecisionTableOutcome output = ConnectApi.DecisionTable.execute(DecisionTableRecordId, input);
    Map<String, Object> outputMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(output));
    outputMap.put('QuoteLineItemId', lineItem); 
    return outputMap;
}
//BRE WC N2G-1039
public static Map<String, Object>  getDataFromDecisionTableAU(String lineItem,String DecisionTableRecordId,Map<String,String> inputData) {
    String[] fieldsToFilter= new String[] {'LoB_Type__c','Lob_Code__c','States__c','Deregulation_Applies_Type__c','Symbol__c','Deregulation_NYTFZ_Class_Type__c','Large_Deductible_WC_Flag__c'};
        
        ConnectApi.DecisionTableInput input = new ConnectApi.DecisionTableInput();
    input.conditions = new List<ConnectApi.DecisionTableCondition>();
    
    for(String field:fieldsToFilter){
        //dynamic field filter condition 
        ConnectApi.DecisionTableCondition lobCondition = new ConnectApi.DecisionTableCondition();
        lobCondition.fieldName = field;
        lobCondition.value = inputData.containsKey(field)?inputData.get(field):'-';
        
        if(field=='Deregulation_Applies_Type__c' && lobCondition.value=='-'){
            lobCondition.value =false;
        }
        if(field=='States__c' && lobCondition.value=='-'){
            lobCondition.value ='ALL';
        }
        if(field=='Deregulation_Applies_Type__c' && lobCondition.value=='True'){
            lobCondition.value =true;
        }
        
        if(field=='Large_Deductible_WC_Flag__c' && (lobCondition.value=='-' || lobCondition.value=='false')){
            lobCondition.value =false;
        }
        if(field=='Large_Deductible_WC_Flag__c' && lobCondition.value=='true'){
            lobCondition.value =true;
        }
        
        
        input.conditions.add(lobCondition);
    }
    
    ConnectApi.DecisionTableOutcome output = ConnectApi.DecisionTable.execute(DecisionTableRecordId, input);
    Map<String, Object> outputMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(output));
    outputMap.put('QuoteLineItemId', lineItem); 
    return outputMap;
}
//BRE WC N2G-1039
public static Map<String, Object>  getDataFromDecisionTableFC(String lineItem,String DecisionTableRecordId,Map<String,String> inputData) {
    String[] fieldsToFilter= new String[] {'LoB_Type__c','Lob_Code__c','Country__c','Local_Policy_Coverage__c','Coverage_Code__c'};
        
        ConnectApi.DecisionTableInput input = new ConnectApi.DecisionTableInput();
    input.conditions = new List<ConnectApi.DecisionTableCondition>();
    
    for(String field:fieldsToFilter){
        //dynamic field filter condition 
        ConnectApi.DecisionTableCondition lobCondition = new ConnectApi.DecisionTableCondition();
        lobCondition.fieldName = field;
        lobCondition.value = inputData.containsKey(field)?inputData.get(field):'-';
        
        
        
        input.conditions.add(lobCondition);
    }
    
    ConnectApi.DecisionTableOutcome output = ConnectApi.DecisionTable.execute(DecisionTableRecordId, input);
    Map<String, Object> outputMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(output));
    outputMap.put('QuoteLineItemId', lineItem); 
    return outputMap;
}

}