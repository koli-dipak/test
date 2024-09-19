global with sharing class FCCalculation implements vlocity_ins.VlocityOpenInterface {
    // implements vlocity_ins.VlocityOpenInterface
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        if (methodName.equals('getCalculation')) {
            getCalculation(inputMap, outMap);
        }
        return true;
    }
    
    @AuraEnabled
    public static void getCalculation(Map < String, Object > inputMap, Map < String, Object > outMap) {
        system.debug('@@'+JSON.serialize(inputMap));
        try{
            
            Decimal SumMasterMinPremConfig=0;
            
            Map<string,FC_Reference_Local__c> mapaclist = new Map<string,FC_Reference_Local__c>();
            //List<Object> lstFcReferenceLcl = new List<Object>();
            Map<String,String> fcCaLcll = new Map<String,String>();
            
            Map <String,Object> step1Info=(Map <String,Object>)inputMap.get('Step1'); 
            List<Object> step1DataInfo=(List<Object>)step1Info.get('Data'); 
            //List<Object> step1LocalDataInfo=(List<Object>)step1Info.get('data'); 
            
            for(FC_Reference_Local__c fcRef : [Select Id, Name, Country_of_Domicile__c, EL_Loading__c, GL_Minimum_Premium__c,Other_local_extensions__c, Override__c, FOS_countries__c   From FC_Reference_Local__c ]){
                mapaclist.put(fcRef.Country_of_Domicile__c.toLowerCase(),fcRef);
            }
            
            List<FC_Reference_Expenses__c> lstFcReferenceLcl = [select N2G_Revenue_Local__c, Total_Commission_Local__c From FC_Reference_Expenses__c Limit 1];
            //for(FC_Reference_Expenses__c FcReferenceLcl : lst){
            //lstFcReferenceLcl.add(FcReferenceLcl.N2G_Revenue_Local__c);
            //}
            
            // Calculate Sum of Min Prem
            for(Master_minimum_premium_config__mdt mdt : [SELECT ID, Local_EL__c ,GL_Other_extensions__c,FVWC__c,BTA__c,Auto__c FROM Master_minimum_premium_config__mdt Where DeveloperName='Master_minimum_premium']){
                if(mdt.Local_EL__c!=null)SumMasterMinPremConfig+=mdt.Local_EL__c;
                if(mdt.GL_Other_extensions__c!=null)SumMasterMinPremConfig+=mdt.GL_Other_extensions__c;
                if(mdt.FVWC__c!=null)SumMasterMinPremConfig+=mdt.FVWC__c;
                if(mdt.BTA__c!=null)SumMasterMinPremConfig+=mdt.BTA__c;
                if(mdt.Auto__c!=null)SumMasterMinPremConfig+=mdt.Auto__c;
                step1Info.put('MasterMinPremiumLocalEL',mdt.Local_EL__c);  
                step1Info.put('MasterMinPremiumGLOtherExt',mdt.GL_Other_extensions__c);  
                step1Info.put('MasterMinPremiumFVWC',mdt.FVWC__c);  
                step1Info.put('MasterMinPremiumBTA',mdt.BTA__c);  
                step1Info.put('MasterMinPremiumAuto',mdt.Auto__c);  

            }
            
            
            Decimal totalModifyExposure = 0;
            Decimal totalLocalELActualPrem = 0;
            
            //calculate FC Casualty Premium
            
            // do not remove below code
            /*
//Limit_factor__c (value form excel);
if(String.isBlank(String.valueOf(step1Info.get('LimitFactor')))){
step1Info.put('LimitFactor', 0);
}
step1Info.put('LimitFactor', step1Info.get('LimitFactor'));

//DIC__c (userInput)
step1Info.put('DIC', 0);

//Min_premium_exposure_threshold__c (userInput)
step1Info.put('MinPremExpThre', 0);

//Min_premium_large exposer (userInput)
step1Info.put('MinPremLargeExp', 0);

//FOS_minimum_premium__c (userInput)
step1Info.put('FOSMinPre', 0);

//Separate_EL_policy_minimum_premium__c (userInput)
step1Info.put('SepELPolMinPre', 0);

//Master_broker_commission__c (userInput) - CommToEnterGerRate
step1Info.put('MstrBrkrComm', 0);

//Local_broker_commission__c (userInput) - CommToEnterGerRate
step1Info.put('LclBrkComm', 0);



//need to do it below below for Local_Percentage_of_Total__c.....

//Net_of_Comm_TP_local_EL__c(formula) - LocalTotal
if(String.isBlank(String.valueOf(step1Info.get('ExpenseLoading')))){
step1Info.put('ExpenseLoading', 0);
}
if(String.isBlank(String.valueOf(step1Info.get('InvestDis')))){
step1Info.put('InvestDis', 0);
}
//Net_of_Comm_TP_GL__c(formula) - TotalGlOtherExt
if(String.isBlank(String.valueOf(step1Info.get ('CommTpTotal')))){
step1Info.put('CommTpTotal',0);
}
*/        
            /*if(String.isBlank(String.valueOf(step1Info.get('ELIncluded')))){
step1Info.put('ELIncluded', 'Yes');
} 
if(String.isBlank(String.valueOf(step1Info.get('OtherLocalExtensionPFLIncluded')))){
step1Info.put('OtherLocalExtensionPFLIncluded', 'Yes');
}*/
            if(String.valueOf(step1Info.get ('RiskPreLocalEL'))==null || String.isBlank(String.valueOf(step1Info.get ('RiskPreLocalEL')))){
                step1Info.put ('RiskPreLocalEL',0);
            }
            if(String.valueOf(step1Info.get ('RiskPremiumFVWC'))==null || String.isBlank(String.valueOf(step1Info.get ('RiskPremiumFVWC')))){
                step1Info.put ('RiskPremiumFVWC',0);
            }
            if(String.valueOf(step1Info.get ('RiskPremiumAuto'))==null || String.isBlank(String.valueOf(step1Info.get ('RiskPremiumAuto')))){
                step1Info.put ('RiskPremiumAuto',0);
            }
            if(String.valueOf(step1Info.get ('RiskPremiumPFL'))==null || String.isBlank(String.valueOf(step1Info.get ('RiskPremiumPFL')))){
                step1Info.put ('RiskPremiumPFL',0);
            }
            if(String.valueOf(step1Info.get ('RiskPremiumBTA'))==null || String.isBlank(String.valueOf(step1Info.get ('RiskPremiumBTA')))){
                step1Info.put ('RiskPremiumBTA',0);
            }
            if(String.valueOf(step1Info.get ('PremExtensionsPrimary'))==null || String.isBlank(String.valueOf(step1Info.get ('PremExtensionsPrimary')))){
                step1Info.put ('PremExtensionsPrimary',0);
            }
            if(String.valueOf(step1Info.get ('CountryLoding'))==null || String.isBlank(String.valueOf(step1Info.get ('CountryLoding')))){
                step1Info.put ('CountryLoding',0);
            }
            
            system.debug('@@step1Info.get(RiskPremiumFVWC)'+step1Info.get('RiskPremiumFVWC'));
            system.debug('@@step1Info.get(InvestDis)'+step1Info.get('InvestDis'));
            system.debug('@@step1Info.get(ExpenseLoading)'+step1Info.get('ExpenseLoading'));
            system.debug('@@step1Info.'+Decimal.valueOf(String.valueOf(step1Info.get ('RiskPreLocalEL'))) *(1 + Decimal.valueOf(String.valueOf(step1Info.get('InvestDis'))))/(1 - Decimal.valueOf(String.valueOf(step1Info.get('ExpenseLoading')))));
            
            //step1Info.put('NetOfCommTpTotal',Decimal.valueOf(String.valueOf(step1Info.get ('CommTpTotal'))));
            step1Info.put('NetOfCommTpLocalEl', Decimal.valueOf(String.valueOf(step1Info.get('RiskPreLocalEL'))) * (1 + Decimal.valueOf(String.valueOf(step1Info.get('InvestDis')))) / (1 - Decimal.valueOf(String.valueOf(step1Info.get('ExpenseLoading')))));
            
            if(!step1Info.containsKey('NetOfCommTpFVWC')){
                step1Info.put('NetOfCommTpFVWC',Decimal.valueOf(String.valueOf(step1Info.get ('RiskPremiumFVWC'))) *(1 + Decimal.valueOf(String.valueOf(step1Info.get('InvestDis')))) /(1 - Decimal.valueOf(String.valueOf(step1Info.get ('ExpenseLoading')))));
            }
            if(!step1Info.containsKey('NetOfCommTpAuto')){
                step1Info.put('NetOfCommTpAuto',Decimal.valueOf(String.valueOf(step1Info.get ('RiskPremiumAuto'))) *(1 + Decimal.valueOf(String.valueOf(step1Info.get ('InvestDis')))) /(1 - Decimal.valueOf(String.valueOf(step1Info.get ('ExpenseLoading')))));
            }
            if(!step1Info.containsKey('NetOfCommTpBTA')){
                step1Info.put('NetOfCommTpBTA',Decimal.valueOf(String.valueOf(step1Info.get ('RiskPremiumBTA'))) *(1 + Decimal.valueOf(String.valueOf(step1Info.get ('InvestDis')))) /(1 - Decimal.valueOf(String.valueOf(step1Info.get ('ExpenseLoading')))));
            }
            step1Info.put('NetOfCommTpPFL',Decimal.valueOf(String.valueOf(step1Info.get ('RiskPremiumPFL'))) *(1 + Decimal.valueOf(String.valueOf(step1Info.get ('InvestDis')))) /(1 - Decimal.valueOf(String.valueOf(step1Info.get ('ExpenseLoading')))));
            step1Info.put('NetOfCommTpOtherExt',(decimal)(Decimal.valueOf(String.valueOf(step1Info.get ('PremExtensionsPrimary'))) - (Decimal.valueOf(String.valueOf(step1Info.get ('RiskPremiumFVWC'))) + Decimal.valueOf(String.valueOf(step1Info.get ('RiskPremiumAuto'))) + Decimal.valueOf(String.valueOf(step1Info.get ('RiskPremiumBTA')))+ Decimal.valueOf(String.valueOf(step1Info.get ('RiskPremiumPFL'))))) *(1 + Decimal.valueOf(String.valueOf(step1Info.get ('InvestDis')))) /(1 - Decimal.valueOf(String.valueOf(step1Info.get ('ExpenseLoading')))));
             
            //Local GL + Other extensions(formula) - LocalGlOtherExt
            step1Info.put('NetOfCommTpGL', Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpTotal'))) - ( Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpFVWC'))) + Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpAuto'))) + Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpBTA'))) + Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpLocalEl'))) + Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpPFL'))) + Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpOtherExt'))) ) );
            step1Info.put('TotalGlOtherExt', Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpGL'))) +Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpOtherExt'))) + Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpPFL'))));
             
            system.debug('@@NetOfCommTpPFL'+step1Info.get('NetOfCommTpPFL'));
            system.debug('@@NetOfCommTpOtherExt'+step1Info.get('NetOfCommTpOtherExt'));
            //changes according to new req 23-12-22
            /* (454)/(1 - (26/100))  (5659.636796665873)/(1 - (26/100))*/
            if(!step1Info.containsKey('GrossOfCommTpGl')){
                step1Info.put('GrossOfCommTpGl', (Decimal.valueOf(String.valueOf(step1Info.get('TotalGlOtherExt')))) / ( 1 - Decimal.valueOf(String.valueOf(step1Info.get('Commission')))));
                step1Info.put('UWOverrideGrossOfCommTpGl', Decimal.valueOf(String.valueOf(step1Info.get('GrossOfCommTpGl'))));
            }
            if(!step1Info.containsKey('GrossOfCommTpFVWC')){
                step1Info.put('GrossOfCommTpFVWC', (Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpFVWC')))) / ( 1 - Decimal.valueOf(String.valueOf(step1Info.get('Commission')))));
                step1Info.put('UWOverrideGrossOfCommTpFVWC', Decimal.valueOf(String.valueOf(step1Info.get('GrossOfCommTpFVWC'))));
            }
            if(!step1Info.containsKey('GrossOfCommTpAuto')){
                step1Info.put('GrossOfCommTpAuto', (Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpAuto')))) / ( 1 - Decimal.valueOf(String.valueOf(step1Info.get('Commission'))) ));
                step1Info.put('UWOverrideGrossOfCommTpAuto', Decimal.valueOf(String.valueOf(step1Info.get('GrossOfCommTpAuto'))));
            }
            if(!step1Info.containsKey('GrossOfCommTpBTA')){
                step1Info.put('GrossOfCommTpBTA', (Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpBTA')))) / ( 1 - Decimal.valueOf(String.valueOf(step1Info.get('Commission'))) ));
                step1Info.put('UWOverrideGrossOfCommTpBTA', Decimal.valueOf(String.valueOf(step1Info.get('GrossOfCommTpBTA'))));
            }
            if(!step1Info.containsKey('GrossOfCommTpLocalEl')){
                step1Info.put('GrossOfCommTpLocalEl', (Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpLocalEl')))) / ( 1 - Decimal.valueOf(String.valueOf(step1Info.get('Commission'))) ));
                step1Info.put('UWOverrideGrossOfCommTpLocalEl', Decimal.valueOf(String.valueOf(step1Info.get('GrossOfCommTpLocalEl'))));
            }
            if(!step1Info.containsKey('GrossOfCommTpTotal')){
                //step1Info.put('GrossOfCommTpTotal', Decimal.valueOf(String.valueOf(step1Info.get('GrossOfCommTpGl'))) + Decimal.valueOf(String.valueOf(step1Info.get('GrossOfCommTpFVWC'))) + Decimal.valueOf(String.valueOf(step1Info.get('GrossOfCommTpAuto'))) + Decimal.valueOf(String.valueOf(step1Info.get('GrossOfCommTpBTA'))) + Decimal.valueOf(String.valueOf(step1Info.get('GrossOfCommTpLocalEl'))) );
                //step1Info.put('UWOverrideGrossOfCommTpTotal', Decimal.valueOf(String.valueOf(step1Info.get('GrossOfCommTpTotal'))));
                step1Info.put('GrossOfCommTpTotal', (Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpTotal')))) / ( 1 - Decimal.valueOf(String.valueOf(step1Info.get('Commission'))) ));
                step1Info.put('UWOverrideGrossOfCommTpTotal', Decimal.valueOf(String.valueOf(step1Info.get('GrossOfCommTpTotal'))));
            }
            /*if(!step1Info.containsKey('GrossOfCommTpTotal')){
                step1Info.put('GrossOfCommTpPFL', (Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpPFL')))) / ( 1 - Decimal.valueOf(String.valueOf(step1Info.get('Commission')))));
            }*/
            
           
            //logic to fill NetOfCommTP values
            if(step1Info.containsKey('NetOfCommTpTotal') && step1Info.containsKey('UWOverrideGrossOfCommTpTotal') && step1Info.get('UWOverrideGrossOfCommTpTotal') != null && step1Info.get('Commission') != null){
                step1Info.put('NetOfCommTpTotal', Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpTotal'))) * (1 - Decimal.valueOf(String.valueOf(step1Info.get('Commission')))));
                //step1Info.put('UWOverrideGrossActualFinalGrossOfCommTpTotal', Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpTotal'))));
            }
            /*if(step1Info.containsKey('NetOfCommTpGL') && step1Info.containsKey('UWOverrideGrossOfCommTpGl')){
                //step1Info.put('NetOfCommTpGL', Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpGl'))) * (1 - Decimal.valueOf(String.valueOf(step1Info.get('Commission')))));
                step1Info.put('UWOverrideGrossActualFinalGrossOfCommTpGl', Decimal.valueOf(String.valueOf(step1Info.get('LocalGlOtherExt'))) + Decimal.valueOf(String.valueOf(step1Info.get('MasterGlOtherExt'))));
            }*/
            if(step1Info.containsKey('NetOfCommTpFVWC') && step1Info.containsKey('UWOverrideGrossOfCommTpFVWC')){
                step1Info.put('NetOfCommTpFVWC', Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpFVWC'))) * (1 - Decimal.valueOf(String.valueOf(step1Info.get('Commission')))));
                //step1Info.put('UWOverrideGrossActualFinalGrossOfCommTpFVWC', Decimal.valueOf(String.valueOf(step1Info.get('MasterFVWC'))));
            }
            if(step1Info.containsKey('NetOfCommTpAuto') && step1Info.containsKey('UWOverrideGrossOfCommTpAuto')){
                step1Info.put('NetOfCommTpAuto', Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpAuto'))) * (1 - Decimal.valueOf(String.valueOf(step1Info.get('Commission')))));
                //step1Info.put('UWOverrideGrossActualFinalGrossOfCommTpAuto', Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpAuto'))));
            }
            if(step1Info.containsKey('NetOfCommTpBTA') && step1Info.containsKey('UWOverrideGrossOfCommTpBTA')){
                step1Info.put('NetOfCommTpBTA', Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpBTA'))) * (1 - Decimal.valueOf(String.valueOf(step1Info.get('Commission')))));
                //step1Info.put('UWOverrideGrossActualFinalGrossOfCommTpBTA', Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpBTA'))));
            }
            if(step1Info.containsKey('NetOfCommTpLocalEl') && step1Info.containsKey('UWOverrideGrossOfCommTpLocalEl')){
                // changed 09-01-2023
                step1Info.put('NetOfCommTpLocalEl', Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpLocalEl'))) * (1 - Decimal.valueOf(String.valueOf(step1Info.get('Commission')))));
                //above commented code change due to calculation issue now belwo code formula refer from from gerrater : [Risk Premium local EL(Local EL.W4)*(1 + Investment_Discount__c(Pricing Summary - GL.G26)) / (1-Expense_Loading__c(Pricing Summary - GL.G25))] / (1 - Comissions (Pricing Summary - GL.G26))
                //step1Info.put('NetOfCommTpLocalEl', Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpLocalEl'))));
                step1Info.put('UWOverrideGrossActualFinalGrossOfCommTpLocalEl', Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpLocalEl'))));
            }
            
             //Local GL + Other extensions(formula) - LocalGlOtherExt
            step1Info.put('NetOfCommTpGL', Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpTotal'))) - ( Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpFVWC'))) + Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpAuto'))) + Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpBTA'))) + Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpLocalEl'))) + Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpPFL'))) + Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpOtherExt'))) ) );
            step1Info.put('TotalGlOtherExt', Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpGL'))) +Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpOtherExt'))) + Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpPFL'))));
            
            //if(step1Info.containsKey('NetOfCommTpPFL')){}
            //above code is not needed as of now bcz we don't have any user entry field for PFL on UI.
            
            
            // to again calculate the grossOfCommTpGl
            
                //step1Info.put('UWOverrideGrossOfCommTpGl', (Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpGL')))) / ( 1 - Decimal.valueOf(String.valueOf(step1Info.get('Commission')))));
                //step1Info.put('UWOverrideGrossOfCommTpGl', Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpTotal'))) - Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpFVWC'))) - Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpAuto'))) - Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpBTA'))) - Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpLocalEl'))));
                //above code was change for N2GFCB358 we need to include PFL value to.
            	//step1Info.put('UWOverrideGrossOfCommTpGl', Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpTotal'))) - Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpFVWC'))) - Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpAuto'))) - Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpBTA'))) - Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpLocalEl'))) - ((Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpPFL')))) / ( 1 - Decimal.valueOf(String.valueOf(step1Info.get('Commission'))))));
            
            ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            for(Object data : step1DataInfo){
                Map<String,object> rec=(Map<String,object>)data;
                system.debug('@@'+JSON.serialize(data));
                // Skip EL Record From Processing
                if(String.ValueOf(rec.get('type'))!=null && String.ValueOf(rec.get('type'))=='EL'){
                    continue;
                }                
                Decimal modifedExposers= Decimal.valueOf(String.ValueOf(rec.get('Exposure')))*(1+Decimal.valueOf(String.valueOf(rec.get('CountryLoding'))));
                totalModifyExposure+=modifedExposers;
                
                rec.put('ModifedExposers',modifedExposers);
                rec.put('ELLodingDefault', mapaclist.get(String.ValueOf(rec.get('Country')).toLowerCase()).EL_Loading__c/100);
                rec.put('OtherlocalextensionloadingDefault', mapaclist.get(String.ValueOf(rec.get('Country')).toLowerCase()).Other_local_extensions__c/100);
                    
                if(!rec.containsKey('ELLoding')){
                    if(String.ValueOf(rec.get('OtherLocalExtensionPFLIncluded'))=='Yes'){
                        rec.put('ELLoding', mapaclist.get(String.ValueOf(rec.get('Country')).toLowerCase()).EL_Loading__c/100);
                    }else{
                        rec.put('ELLoding', 0);
                    }
                    //rec.put('ELLoding', mapaclist.get(String.ValueOf(rec.get('Country')).toLowerCase()).EL_Loading__c/100);
                }
                if(!rec.containsKey('Otherlocalextensionloading')){
                    if(String.ValueOf(rec.get('OtherLocalExtensionPFLIncluded'))=='Yes'){
                        rec.put('Otherlocalextensionloading', mapaclist.get(String.ValueOf(rec.get('Country')).toLowerCase()).Other_local_extensions__c/100);
                    }else{
                        rec.put('Otherlocalextensionloading', 0);
                    }
                    //rec.put('Otherlocalextensionloading', mapaclist.get(String.ValueOf(rec.get('Country')).toLowerCase()).Other_local_extensions__c/100);
                }
                
                
                
                String Country=String.ValueOf(rec.get('Country'));
                if(Country==null || Country==''){
                    rec.put('DIL',null);
                }else{
                    
                    //25
                    if(String.ValueOf(rec.get('LoclPolReq'))=='FOS' && mapaclist.get(Country.toLowerCase()).FOS_countries__c != true){
                        //rec.put('FOSErrorWariningFlag', Country.toLowerCase()+ ' Cannot be FOS Country');
                        rec.put('FOSErrorWariningFlag', 'Cannot be FOS country. Check FOS country list');
                    }
                    
                    //28
                    if(String.ValueOf(rec.get('LoclPolReq'))=='Yes' || String.ValueOf(rec.get('LoclPolReq'))=='FOS'){
                        rec.put('OverRide',mapaclist.get(Country.toLowerCase()).Override__c);
                    }
                    
                    //29
                    if(String.ValueOf(rec.get('LoclPolReq'))=='Yes' && String.ValueOf(rec.get('ELIncluded'))=='Yes'){
                        rec.put('ELCoverIndicator', 1);
                    }else{
                        rec.put('ELCoverIndicator', 0);
                    }
                    
                    if(String.ValueOf(rec.get('LoclPolReq'))=='Yes' && String.ValueOf(rec.get('OtherLocalExtensionPFLIncluded'))=='Yes'){
                        rec.put('LocalExtensionIndicator', 1);
                    }else{
                        rec.put('LocalExtensionIndicator', 0);
                    }
                    
                    //30
                    if(String.ValueOf(rec.get('LoclPolReq'))=='Yes' || String.ValueOf(rec.get('LoclPolReq'))=='Fos-Master' || String.ValueOf(rec.get('LoclPolReq'))=='NOT INTEGRATED' ){
                        Decimal limitFactor=Decimal.valueOf(String.ValueOf(rec.get('LimitFactor')));
                        Decimal DeductibleFactor=Decimal.valueOf(String.ValueOf(rec.get('DeductibleFactor')));
                        rec.put('DIL',(Math.min(1, Math.max(0, (1 - (limitFactor-DeductibleFactor)/Decimal.valueOf(String.valueOf(step1Info.get('LimitFactor'))))))));
                    }else{
                        rec.put('DIL',0);
                    }
                    
                    //31
                    if(String.ValueOf(rec.get('LoclPolReq'))=='NOT INTEGRATED'){
                        rec.put('WeightToMaster', 0);
                    }else{
                        if(String.ValueOf(rec.get('LoclPolReq'))=='No' || String.ValueOf(rec.get('LoclPolReq'))=='' || String.isBlank(String.ValueOf(rec.get('LoclPolReq')))){
                            rec.put('WeightToMaster', 1);
                        }else{
                            rec.put('WeightToMaster', (Decimal.valueOf(String.ValueOf(rec.get('DIL')))+(String.valueOf(step1Info.get('DIC'))!=null?Decimal.valueOf(String.valueOf(step1Info.get('DIC'))):0.10)));
                        }
                    }
                }
                
                if(String.isBlank(String.valueOf(step1Info.get('MinPremExpThre')))){
                    step1Info.put('MinPremExpThre',0);
                }
                if(String.isBlank(String.valueOf(step1Info.get('FOSMinPre')))){
                    step1Info.put('FOSMinPre',0);
                }
                if(String.isBlank(String.valueOf(rec.get('Exposure')))){
                    rec.put('Exposure',0);
                }
                
                //32
                rec.put('MinimumPremiumRequired',0);
                if(String.valueOf(rec.get('OverRide')) == null || String.valueOf(rec.get('OverRide')) =='' || String.isBlank(String.valueOf(rec.get('OverRide')))){
                    rec.put('MinimumPremiumRequired',0);
                }else{
                    if(String.ValueOf(rec.get('LoclPolReq'))=='FOS'){
                        rec.put('MinimumPremiumRequired',step1Info.get('FOSMinPre'));
                    }else{
                        if(Decimal.valueOf(String.ValueOf(rec.get('Exposure'))) > Decimal.valueOf(String.ValueOf(step1Info.get('MinPremExpThre')))){
                            //rec.put('MinimumPremiumRequired',Math.max(Decimal.valueOf(String.ValueOf(step1Info.get('MinPremLargeExp'))),Decimal.valueOf(mapaclist.get(Country.toLowerCase()).GL_Minimum_Premium__c)));
                            rec.put('MinimumPremiumRequired',Math.max(Decimal.valueOf(String.ValueOf(step1Info.get('MinPreforLarPre'))),Decimal.valueOf(mapaclist.get(Country.toLowerCase()).GL_Minimum_Premium__c)));
                        }else{
                            rec.put('MinimumPremiumRequired',Decimal.valueOf(mapaclist.get(Country.toLowerCase()).GL_Minimum_Premium__c));
                        }
                    }
                }
                system.debug('@@MinimumPremiumRequired :: '+rec.get('MinimumPremiumRequired'));
                //Local EL Actual premium (gross of commission) // user input
                if(!(rec.get('LocalELActualPrem')==null ||rec.get('LocalELActualPrem')=='' || String.isBlank(String.valueOf(rec.get('LocalELActualPrem'))))) {
                    totalLocalELActualPrem+= Decimal.valueOf(String.ValueOf(rec.get('LocalELActualPrem'))) ;
                }
                    //rec.put('LocalELActualPrem',0);
                
                
                
                //user input
                //rec.put('UWOverrideGLLocalPrem',0);
                
            }
            Decimal TotalLocalGLExtensionAllocationBasis=0;
            Decimal TotalGLExtensionAllocateToMaster=0;
            Decimal TotalGLExtensionsAllocatedtoLocal_T27=0;
            
            for(Object data : step1DataInfo){
                Map<String,object> rec=(Map<String,object>)data;
                
                // Skip EL Record From Processing
                if(String.ValueOf(rec.get('type'))!=null && String.ValueOf(rec.get('type'))=='EL'){
                    continue;
                }  
                
                //33
                rec.put('ModifiedExposurePercentage',((Decimal.valueOf(String.valueOf(rec.get('ModifedExposers')))/totalModifyExposure)));
                
                //34
                if(String.ValueOf(rec.get('LoclPolReq'))=='NOT INTEGRATED'){
                    rec.put('GLExtensionsAllocatedNotIntegrate', String.ValueOf(rec.get('ModifiedExposurePercentage')));
                }
                
                //35
                if(String.ValueOf(rec.get('Country'))==null || String.ValueOf(rec.get('Country'))=='' || String.isBlank(String.ValueOf(rec.get('Country')))){
                    if(String.ValueOf(rec.get('LoclPolReq'))=='Yes' && String.ValueOf(rec.get('OtherLocalExtensionIncluded'))=='Yes'){
                        rec.put('LocalExtensionIndicator',1);
                    }else{
                        rec.put('LocalExtensionIndicator', 0);
                    }
                }
                
                //36
                rec.put('GLExtensionsAllocatedtoMaster',((Decimal.valueOf(String.ValueOf(rec.get('ModifiedExposurePercentage')))*(Decimal.valueOf(String.valueOf(rec.get('WeightToMaster')))))));
                
                TotalGLExtensionAllocateToMaster+=Decimal.valueOf(String.ValueOf(rec.get('GLExtensionsAllocatedtoMaster')));
            }
            
            // Calculate Premium Casuality
            
            //sum of all local policies "GL + Ext %Allocated to master"
            step1Info.put('SumOfAllLocalPolicieGLExtAllocatedToMaster', TotalGLExtensionAllocateToMaster);
            
            //Master_GL_Other_extensions__c(formula) - LocalGlOtherExt
             step1Info.put('MasterGlOtherExt',Decimal.valueOf(String.valueOf(step1Info.get ('TotalGlOtherExt'))) * Decimal.valueOf(String.valueOf(step1Info.get ('SumOfAllLocalPolicieGLExtAllocatedToMaster'))));
            //above is old code below is new code according to fourth screen 
            /*if(!step1Info.containsKey('MasterGlOtherExt')){
                step1Info.put('MasterGlOtherExt',Decimal.valueOf(String.valueOf(step1Info.get ('TotalGlOtherExt'))) * Decimal.valueOf(String.valueOf(step1Info.get ('SumOfAllLocalPolicieGLExtAllocatedToMaster'))));
            }  */  
                
            //Local GL Other Extensions (formula) - LocalTotal
            step1Info.put('LocalGlOtherExt', Decimal.valueOf(String.valueOf(step1Info.get('TotalGlOtherExt'))) - Decimal.valueOf(String.valueOf(step1Info.get('MasterGlOtherExt'))));
            
            
            
            
            
            //Local_Total__c (formula) - LocalPerToTotal
            step1Info.put('LocalTotal', Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpLocalEl'))) +  Decimal.valueOf(String.valueOf(step1Info.get('LocalGlOtherExt'))));
            //'= Sum of (Net of Comm TP FVWC + Net of Comm TP Auto + Net of Comm TP BTA + Total Net of Comm TP Local EL + Total Net of Comm TP GL Other Extensions) 
            step1Info.put('totalTotal', (Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpFVWC'))) + Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpAuto'))) + Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpBTA'))) + Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpLocalEl'))) + Decimal.valueOf(String.valueOf(step1Info.get('TotalGlOtherExt')))));
            
            
            //Local_Percentage_of_Total__c (forumla) - CommToEnterGerRate
            step1Info.put('LocalPerToTotal',Decimal.valueOf(String.valueOf(step1Info.get('totalTotal')))==0?0:( Decimal.valueOf(String.valueOf(step1Info.get('LocalTotal'))) / Decimal.valueOf(String.valueOf(step1Info.get('totalTotal')))));
            
            //need to do above it for Local_Percentage_of_Total__c............
            
            //below mapping are for Master_Percentage_of_Total__c........
            
            
            //step1Info.put('MasterFVWC',Decimal.valueOf(String.valueOf(step1Info.get ('NetOfCommTpFVWC'))));
            //step1Info.put('MasterAuto',Decimal.valueOf(String.valueOf(step1Info.get ('NetOfCommTpAuto'))));
            //step1Info.put('MasterBTA',Decimal.valueOf(String.valueOf(step1Info.get ('NetOfCommTpBTA'))));
            //above is old code below is new code according to fourth screen 
            if(!step1Info.containsKey('MasterFVWC')){
            	step1Info.put('MasterFVWC',Decimal.valueOf(String.valueOf(step1Info.get ('NetOfCommTpFVWC'))));
            }
            if(!step1Info.containsKey('MasterAuto')){
            	step1Info.put('MasterAuto',Decimal.valueOf(String.valueOf(step1Info.get ('NetOfCommTpAuto'))));
            }
            if(!step1Info.containsKey('MasterBTA')){
            	step1Info.put('MasterBTA',Decimal.valueOf(String.valueOf(step1Info.get ('NetOfCommTpBTA'))));
            }
            //step1Info.put('MasterGLotherExtentions',Decimal.valueOf(String.valueOf(step1Info.get('TotalGlOtherExt'))) * Decimal.valueOf(String.valueOf(step1Info.get('SumOfAllLocalPolicieGLExtAllocatedToMaster'))) );
            
            //Master_Total__c(formula) - MstrPerOfTotal
            step1Info.put('MasterTotal', (Decimal.valueOf(String.valueOf(step1Info.get('MasterFVWC'))) + Decimal.valueOf(String.valueOf(step1Info.get('MasterAuto'))) + Decimal.valueOf(String.valueOf(step1Info.get('MasterBTA'))) + Decimal.valueOf(String.valueOf(step1Info.get('MasterGlOtherExt'))) ));
            
            //Master_Percentage_of_Total__c(forumla) - CommToEnterGerRate
            step1Info.put('MstrPerOfTotal', Decimal.valueOf(String.valueOf(step1Info.get('totalTotal'))) ==0 ?0 :( Decimal.valueOf(String.valueOf(step1Info.get('MasterTotal'))) / Decimal.valueOf(String.valueOf(step1Info.get('totalTotal'))) ));
            
            //need to do above it for Master_Percentage_of_Total__c.................
            
            //Commission_to_enter_in_GeR_Rater_c (formula)
            step1Info.put('CommToEnterGerRate', ((lstFcReferenceLcl[0].N2G_Revenue_Local__c/100 + Decimal.valueOf(String.ValueOf(step1Info.get('MstrBrkrComm'))))*Decimal.valueOf(String.valueOf(step1Info.get('MstrPerOfTotal'))))+((lstFcReferenceLcl[0].Total_Commission_Local__c/100 + Decimal.valueOf(String.ValueOf(step1Info.get('LclBrkComm'))))*Decimal.valueOf(String.ValueOf(step1Info.get('LocalPerToTotal')))));
            //step1Info.put('CommToEnterGerRate', ((lstFcReferenceLcl[0].Total_Commission_Local__c/100 + Decimal.valueOf(String.ValueOf(step1Info.get('LclBrkComm'))))*Decimal.valueOf(String.ValueOf(step1Info.get('LocalPerToTotal')))));
            
            //Gross_of_comm_AP_Total__c (formula)
            
            // Technical Premium (gross of commission)
            step1Info.put('GrossTPTotal',  Decimal.valueOf(String.valueOf(step1Info.get('totalTotal'))) / (1 -  Decimal.valueOf(String.valueOf(step1Info.get('CommToEnterGerRate')))));
            
            //changes for N2GFCB311 This is new requirement
            //step1Info.put('GrossTPTotal', step1Info.get('GrossTechnicalPremium') !=null ? Decimal.valueOf(String.valueOf(step1Info.get ('GrossTechnicalPremium'))) :Decimal.valueOf(String.valueOf(step1Info.get ('GrossTPTotal'))));
            step1Info.put('GrossTPTotal', Decimal.valueOf(String.valueOf(step1Info.get ('GrossTechnicalPremium'))));
            
            if( step1Info.get('UWOverrideGrossAPTotal')!=null && !String.isBlank(String.valueOf(step1Info.get('UWOverrideGrossAPTotal')))){
                // Actual Premium (gross of commission)
                step1Info.put('GrossAPTotal', step1Info.get('UWOverrideGrossAPTotal'));
            }
            else { //if( step1Info.get('GrossAPTotal')==null || String.isBlank(String.valueOf(step1Info.get('GrossAPTotal')))){
                // Actual Premium (gross of commission)
                step1Info.put('GrossAPTotal', step1Info.get('GrossTPTotal'));
            }
            
            //new requirement for premium breakdown overview screen
            step1Info.put('UWOverrideGrossActualFinalGrossOfCommTpLocalEl', Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpLocalEl'))));
            if(step1Info.get('LocalGlOtherExt')!=null && step1Info.get('MasterGlOtherExt')!=null  && !String.isBlank(String.valueOf(step1Info.get('LocalGlOtherExt'))) && !String.isBlank(String.valueOf(step1Info.get('MasterGlOtherExt')))){
                step1Info.put('UWOverrideGrossActualFinalGrossOfCommTpGl', Decimal.valueOf(String.valueOf(step1Info.get('LocalGlOtherExt'))) + Decimal.valueOf(String.valueOf(step1Info.get('MasterGlOtherExt'))));
            }
            if(step1Info.get('MasterFVWC')!=null && !String.isBlank(String.valueOf(step1Info.get('MasterFVWC')))){
                step1Info.put('UWOverrideGrossActualFinalGrossOfCommTpFVWC', Decimal.valueOf(String.valueOf(step1Info.get('MasterFVWC'))));
            }
            if(step1Info.get('MasterAuto')!=null && !String.isBlank(String.valueOf(step1Info.get('MasterAuto')))){
                step1Info.put('UWOverrideGrossActualFinalGrossOfCommTpAuto', Decimal.valueOf(String.valueOf(step1Info.get('MasterAuto'))));
            }
            if(step1Info.get('MasterBTA')!=null && !String.isBlank(String.valueOf(step1Info.get('MasterBTA')))){
                step1Info.put('UWOverrideGrossActualFinalGrossOfCommTpBTA', Decimal.valueOf(String.valueOf(step1Info.get('MasterBTA'))));
            }
            //if(step1Info.get('MasterBTA')!=null && !String.isBlank(String.valueOf(step1Info.get('MasterBTA')))){
                step1Info.put('UWOverrideGrossActualFinalGrossOfCommTpTotal', Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossActualFinalGrossOfCommTpGl')))+Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossActualFinalGrossOfCommTpFVWC')))+Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossActualFinalGrossOfCommTpAuto')))+Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossActualFinalGrossOfCommTpBTA')))+Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossActualFinalGrossOfCommTpLocalEl'))) );
            //}
            //Local GL Other Extensions (formula) - LocalTotal
            //step1Info.put('LocalGlOtherExt', Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossActualFinalGrossOfCommTpGl'))) - Decimal.valueOf(String.valueOf(step1Info.get('MasterGlOtherExt'))));
            
            //Master_Total__c(formula) - MstrPerOfTotal
            //step1Info.put('MasterTotal', (Decimal.valueOf(String.valueOf(step1Info.get('MasterFVWC'))) + Decimal.valueOf(String.valueOf(step1Info.get('MasterAuto'))) + Decimal.valueOf(String.valueOf(step1Info.get('MasterBTA'))) + Decimal.valueOf(String.valueOf(step1Info.get('MasterGlOtherExt'))) ));
            
            ///////////////////////////////////////////////////////
            Decimal totalLocalELTechnicalGrossOfComm=0;
            for(Object data : step1DataInfo){
                Map<String,object> rec=(Map<String,object>)data;
                
                // Skip EL Record From Processing
                if(String.ValueOf(rec.get('type'))!=null && String.ValueOf(rec.get('type'))=='EL'){
                    continue;
                }  
                
                //37
                if(String.ValueOf(rec.get('LoclPolReq'))=='NOT INTEGRATED'){
                    rec.put('GLExtensionsAllocatedtoLocal_T27', 0);
                }else{
                    rec.put('GLExtensionsAllocatedtoLocal_T27', Decimal.valueOf(String.ValueOf(rec.get('ModifiedExposurePercentage'))) - Decimal.valueOf(String.ValueOf(rec.get('GLExtensionsAllocatedtoMaster'))));
                }
                
                //38
                if(String.ValueOf(rec.get('LoclPolReq'))!='NOT INTEGRATED'){
                    // need to change logic
                    rec.put('GLExtActualpremlocalExcEL', Decimal.valueOf(String.ValueOf(rec.get('ModifedExposers'))) - Decimal.valueOf(String.ValueOf(rec.get('GLExtensionsAllocatedtoMaster'))));
                }
                
                //39
                if(String.ValueOf(rec.get('LocalELIncluded'))=='Separate Policy'){
                    rec.put('LocalELMinimumPremiumRequired', Decimal.valueOf(String.ValueOf(step1Info.get('SepELPolMinPre'))));
                }
                
                //if(String.isBlank(String.valueOf(step1Info.get('CommToEnterGerRate')))){
                //    step1Info.put('CommToEnterGerRate',0);
                //}
                if(String.isBlank(String.valueOf(rec.get('LocalELTechnicalpremium')))){
                    rec.put('LocalELTechnicalpremium',0);
                }
                
                //40
                //if(String.ValueOf(rec.get('LocalELTechnicalpremium'))!=null ||String.ValueOf(rec.get('LocalELTechnicalpremium'))!='' ){
                if(String.ValueOf(rec.get('LocalELTechnicalpremium'))!=null && String.ValueOf(rec.get('LocalELTechnicalpremium'))!='' ){
                   // rec.put('LocalELTechnicalGrossOfComm',  Decimal.valueOf(String.ValueOf(rec.get('LocalELTechnicalpremium')))/(1-Decimal.valueOf(String.ValueOf(step1Info.get('CommToEnterGerRate')))));
                    rec.put('LocalELTechnicalGrossOfComm',  Decimal.valueOf(String.ValueOf(rec.get('LocalELTechnicalpremium')))/(1-Decimal.valueOf(String.ValueOf(step1Info.get('Commission')))));
                    if(String.ValueOf(rec.get('LocalELIncluded'))=='Separate Policy'){
                        if(!(rec.get('LocalELActualPrem')==null ||rec.get('LocalELActualPrem')=='' || String.isBlank(String.valueOf(rec.get('LocalELActualPrem'))))) {
                            totalLocalELTechnicalGrossOfComm+=(Decimal.valueOf(String.ValueOf(rec.get('LocalELActualPrem'))));
                        }else{
                            totalLocalELTechnicalGrossOfComm+=(Decimal.valueOf(String.ValueOf(rec.get('LocalELTechnicalGrossOfComm'))));
                        }
                    }
                    system.debug('@@LocalELTechnicalGrossOfComm'+Decimal.valueOf(String.ValueOf(rec.get('LocalELTechnicalGrossOfComm'))));
                }else{
                    rec.put('LocalELTechnicalGrossOfComm',  0);
                }
                
                //41
                /*if(String.ValueOf(rec.get('LocalELIncluded'))=='Separate Policy'){
rec.put('ActualTotalLocalPremium', Decimal.valueOf(String.ValueOf(rec.get('GLExtensionsAllocatedtoLocal'))));
}*/
                
                //Local GL + extension allocation basis
                rec.put('LocalGLExtensionAllocationBasis',Decimal.valueOf(String.ValueOf(rec.get('GLExtensionsAllocatedtoLocal_T27'))) * (1+Decimal.valueOf(String.ValueOf(rec.get('Otherlocalextensionloading')))*Decimal.valueOf(String.ValueOf(rec.get('ELCoverIndicator')))) * (1+Decimal.valueOf(String.ValueOf(rec.get('ELLoding')))*Decimal.valueOf(String.ValueOf(rec.get('LocalExtensionIndicator'))))  );
                
                TotalLocalGLExtensionAllocationBasis+=Decimal.valueOf(String.ValueOf(rec.get('LocalGLExtensionAllocationBasis')));
            	TotalGLExtensionsAllocatedtoLocal_T27+=Decimal.valueOf(String.ValueOf(rec.get('GLExtensionsAllocatedtoLocal_T27')));
            }
            step1Info.put('totalLocalELTechnicalGrossOfComm',totalLocalELTechnicalGrossOfComm);
            step1Info.put('TotalGLExtensionsAllocatedtoLocal_T27',TotalGLExtensionsAllocatedtoLocal_T27);
            
            // changed to new formula 18-01
            //step1Info.put('UWOverrideGrossOfCommTpGl', Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpTotal'))) - Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpFVWC'))) - Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpAuto'))) - Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpBTA'))) - Decimal.valueOf(String.valueOf(step1Info.get('totalLocalELTechnicalGrossOfComm'))) - ((Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpPFL')))) / ( 1 - Decimal.valueOf(String.valueOf(step1Info.get('Commission'))))) - ((Decimal.valueOf(String.valueOf(step1Info.get('NetOfCommTpOtherExt')))) / ( 1 - Decimal.valueOf(String.valueOf(step1Info.get('Commission'))))));
            step1Info.put('UWOverrideGrossOfCommTpGl', Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpTotal'))) - Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpFVWC'))) - Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpAuto'))) - Decimal.valueOf(String.valueOf(step1Info.get('UWOverrideGrossOfCommTpBTA'))) - Decimal.valueOf(String.valueOf(step1Info.get('totalLocalELTechnicalGrossOfComm'))) );
            
            // added on 10-01-2023 calculate local with commision
            if(!step1Info.containsKey('LocalGlOtherExtWithComm') || ((step1Info.containsKey('ReCalculateGL') && Boolean.valueOf(step1Info.get('ReCalculateGL'))==true))){
                step1Info.put('LocalGlOtherExtWithComm',Decimal.valueOf(String.valueOf(step1Info.get ('UWOverrideGrossOfCommTpGl'))) * (1 - Decimal.valueOf(String.valueOf(step1Info.get ('SumOfAllLocalPolicieGLExtAllocatedToMaster')))));
           		step1Info.put('TotalLocalGlOtherExtWithComm'  ,Decimal.valueOf(String.ValueOf(step1Info.get('LocalGlOtherExtWithComm'))));
                
            } 
            step1Info.put('MasterGlOtherExtWithComm',Decimal.valueOf(String.valueOf(step1Info.get ('UWOverrideGrossOfCommTpGl'))) - Decimal.valueOf(String.valueOf(step1Info.get('LocalGlOtherExtWithComm'))));
            
            
            Decimal totalMeetMiniumLocalEL=0;
            Decimal LocalGlDiff=0;
            Decimal sum_MeetMinLocEL_ActualLocPremBefore=0;
            // Local EL
            for(Object data : step1DataInfo){
                Map<String,object> rec=(Map<String,object>)data;
                
                // Skip EL Record From Processing
                if(String.ValueOf(rec.get('type'))!=null && String.ValueOf(rec.get('type'))=='EL'){
                    continue;
                }  
                
                /*if(String.isNotBlank(String.ValueOf(rec.get('UWOverrideGLLocalPrem')))){
                    System.debug('@@@UWOverrideGLLocalPrem:::'+String.ValueOf(rec.get('UWOverrideGLLocalPrem')));
                    System.debug('@@@AllocatedActualGLLocalPrem:::'+String.ValueOf(rec.get('AllocatedActualGLLocalPrem')));
                    LocalGlDiff+=Decimal.valueOf(String.valueOf(rec.get ('UWOverrideGLLocalPrem'))) - Decimal.valueOf(String.valueOf(rec.get ('AllocatedActualGLLocalPrem')));
    
                }*/
                
                if(TotalLocalGLExtensionAllocationBasis!=0){
                   rec.put('GLExtensionsAllocatedtoLocal_Y27',Decimal.valueOf(String.ValueOf(rec.get('LocalGLExtensionAllocationBasis')))/TotalLocalGLExtensionAllocationBasis);
                }else{
                    rec.put('GLExtensionsAllocatedtoLocal_Y27',0);
                }
                
                if(String.isBlank(String.valueOf(step1Info.get('GrossAPTotal')))){
                    step1Info.put('GrossAPTotal',0);
                } 
                if(String.isBlank(String.valueOf(step1Info.get('LocalPerToTotal')))){
                    step1Info.put('LocalPerToTotal',0);
                }
                
                if(TotalGLExtensionsAllocatedtoLocal_T27!=0){
                    //38 // new logic change as per excel
                    rec.put('GLExtActualpremlocalExcEL',((((Decimal.valueOf(String.ValueOf(step1Info.get('GrossAPTotal')))*Decimal.valueOf(String.ValueOf(step1Info.get('LocalPerToTotal')))) - totalLocalELActualPrem)*Decimal.valueOf(String.ValueOf(rec.get('GLExtensionsAllocatedtoLocal_T27'))))/TotalGLExtensionsAllocatedtoLocal_T27));
                    
                    if(String.ValueOf(step1Info.get('UWOverrideGrossOfCommTpTotal'))!=null && String.ValueOf(step1Info.get('UWOverrideGrossOfCommTpTotal'))!=''){
                        //38 // new logic change as per excel
                        rec.put('GLExtActualpremlocalExcEL',((((Decimal.valueOf(String.ValueOf(step1Info.get('UWOverrideGrossOfCommTpTotal')))*Decimal.valueOf(String.ValueOf(step1Info.get('LocalPerToTotal')))) - totalLocalELActualPrem)*Decimal.valueOf(String.ValueOf(rec.get('GLExtensionsAllocatedtoLocal_T27'))))/TotalGLExtensionsAllocatedtoLocal_T27));
                      
                    }
                    
                }else{
                     rec.put('GLExtActualpremlocalExcEL',0);
                   
                }                
                
                //GL + Extensions actual premiums allocated to Local (adjusted)
                rec.put('GLExtensionsActualPremAllocatedtoLocalAdjusted',((Decimal.valueOf(String.ValueOf(step1Info.get('GrossAPTotal')))*Decimal.valueOf(String.ValueOf(step1Info.get('LocalPerToTotal')))) - totalLocalELActualPrem)*Decimal.valueOf(String.ValueOf(rec.get('GLExtensionsAllocatedtoLocal_Y27'))));
                
                if(String.ValueOf(step1Info.get('UWOverrideGrossOfCommTpTotal'))!=null && String.ValueOf(step1Info.get('UWOverrideGrossOfCommTpTotal'))!=''){
                     rec.put('GLExtensionsActualPremAllocatedtoLocalAdjusted',((Decimal.valueOf(String.ValueOf(step1Info.get('UWOverrideGrossOfCommTpTotal')))*Decimal.valueOf(String.ValueOf(step1Info.get('LocalPerToTotal')))) - totalLocalELActualPrem)*Decimal.valueOf(String.ValueOf(rec.get('GLExtensionsAllocatedtoLocal_Y27'))));
               
                }
                //Actual Local Premium before minimum (excl.standalone EL)
                rec.put('ActualLocalPremBeforeMin',rec.get('GLExtensionsActualPremAllocatedtoLocalAdjusted'));
                
                //Meet minimum+local EL?
                rec.put('MeetMinimumLocalEL',0);
                if(String.ValueOf(rec.get('GLExtensionsActualPremAllocatedtoLocalAdjusted'))!=null && String.ValueOf(rec.get('GLExtensionsActualPremAllocatedtoLocalAdjusted'))!=''){
                    if(String.ValueOf(rec.get('MinimumPremiumRequired'))!=null && String.ValueOf(rec.get('MinimumPremiumRequired'))!=''){
                        if((Decimal.valueOf(String.ValueOf(rec.get('GLExtensionsActualPremAllocatedtoLocalAdjusted'))) - Decimal.valueOf(String.ValueOf(rec.get('MinimumPremiumRequired'))))>0){
                            rec.put('MeetMinimumLocalEL',1);
                        }
                    }
                }
                
                
                if(Decimal.valueOf(String.ValueOf(rec.get('MeetMinimumLocalEL')))==0){
                    totalMeetMiniumLocalEL+=(Decimal.valueOf(String.ValueOf(rec.get('GLExtensionsActualPremAllocatedtoLocalAdjusted'))) - Decimal.valueOf(String.ValueOf(rec.get('MinimumPremiumRequired'))));
                }
                if(Decimal.valueOf(String.ValueOf(rec.get('MeetMinimumLocalEL')))==1){
                    sum_MeetMinLocEL_ActualLocPremBefore+=(Decimal.valueOf(String.ValueOf(rec.get('GLExtensionsActualPremAllocatedtoLocalAdjusted'))));
                }
                
            }
            //step1Info.put('TotalLocalGlOtherExtWithComm'  ,Decimal.valueOf(String.ValueOf(step1Info.get('LocalGlOtherExtWithComm')))+LocalGlDiff);
            //step1Info.put('MasterGlOtherExtWithComm'  ,Decimal.valueOf(String.ValueOf(step1Info.get('MasterGlOtherExtWithComm')))-LocalGlDiff);
            step1Info.put('totalMeetMiniumLocalEL',totalMeetMiniumLocalEL);
            //Actual Total Local Premium 
            Decimal sumActualTotalLocalPremium=0;
            Decimal minMasterPremium=0;
            for(Object data : step1DataInfo){
                Map<String,object> rec=(Map<String,object>)data;  
                
                // Skip EL Record From Processing
                if(String.ValueOf(rec.get('type'))!=null && String.ValueOf(rec.get('type'))=='EL'){
                    if(!(rec.get('LocalELTechnicalGrossOfComm')==null ||rec.get('LocalELTechnicalGrossOfComm')=='' || String.isBlank(String.valueOf(rec.get('LocalELTechnicalGrossOfComm'))))) {
                        rec.put('Rate',(Decimal.valueOf(String.ValueOf(rec.get('LocalELTechnicalGrossOfComm')))/Decimal.valueOf(String.ValueOf(rec.get('Exposure')))* Decimal.valueOf(String.ValueOf(rec.get('Per'))) ));
                    }
                    if(!(rec.get('LocalELActualPrem')==null ||rec.get('LocalELActualPrem')=='' || String.isBlank(String.valueOf(rec.get('LocalELActualPrem'))))) {
                        rec.put('Rate',(Decimal.valueOf(String.ValueOf(rec.get('LocalELActualPrem')))/Decimal.valueOf(String.ValueOf(rec.get('Exposure')))* Decimal.valueOf(String.ValueOf(rec.get('Per'))) ));
                    }
                    continue;
                }  
                
                //Allocated Actual GL Local Premium
                if( String.ValueOf(rec.get('ActualLocalPremBeforeMin'))!=null && String.ValueOf(rec.get('ActualLocalPremBeforeMin'))!='' ){
                    
                    
                    Decimal calVal=(Math.max(Decimal.valueOf(String.ValueOf(rec.get('ActualLocalPremBeforeMin'))),Decimal.valueOf(String.ValueOf(rec.get('MinimumPremiumRequired')))));
                    Decimal sumVal=(totalMeetMiniumLocalEL * Decimal.valueOf(String.ValueOf(rec.get('ActualLocalPremBeforeMin'))) *   Decimal.valueOf(String.ValueOf(rec.get('MeetMinimumLocalEL'))) );
                    if(sum_MeetMinLocEL_ActualLocPremBefore !=0){
                        calVal+=sumVal/sum_MeetMinLocEL_ActualLocPremBefore;
                    }
                    if(String.ValueOf(rec.get('LocalELIncluded'))!='Separate Policy'){
                          system.debug('@@@LocalELActualPrem'+String.ValueOf(rec.get('LocalELActualPrem')));
                        if(!(rec.get('LocalELActualPrem')==null ||rec.get('LocalELActualPrem')=='' || String.isBlank(String.valueOf(rec.get('LocalELActualPrem'))))) {
                            calVal+=(Decimal.valueOf(String.ValueOf(rec.get('LocalELActualPrem'))));
                        }
                    }
                    system.debug('@@@LocalELIncluded'+String.ValueOf(rec.get('LocalELIncluded')));
                    system.debug('@@@cal'+calVal);
                    rec.put('AllocatedActualGLLocalPrem',calVal);
                    
                }
                if(String.isNotBlank(String.ValueOf(rec.get('UWOverrideGLLocalPrem')))){
                    System.debug('@@@UWOverrideGLLocalPrem:::'+String.ValueOf(rec.get('UWOverrideGLLocalPrem')));
                    System.debug('@@@AllocatedActualGLLocalPrem:::'+String.ValueOf(rec.get('AllocatedActualGLLocalPrem')));
                    LocalGlDiff+=Decimal.valueOf(String.valueOf(rec.get ('UWOverrideGLLocalPrem'))) - Decimal.valueOf(String.valueOf(rec.get ('AllocatedActualGLLocalPrem')));
    
                }
                
                
                //Actual GL Local Premium 
                if(String.ValueOf(rec.get('UWOverrideGLLocalPrem'))!=null && String.ValueOf(rec.get('UWOverrideGLLocalPrem'))!='' && String.ValueOf(rec.get('UWOverrideGLLocalPrem'))!='0'){
                    if(String.ValueOf(rec.get('MinimumPremiumRequired'))!=null && String.ValueOf(rec.get('MinimumPremiumRequired'))!=''){
                        if(Decimal.valueOf(String.ValueOf(rec.get('UWOverrideGLLocalPrem')))< Decimal.valueOf(String.ValueOf(rec.get('MinimumPremiumRequired')))){
                            rec.put('ActualGLLocalPrem','ERROR-below minimum');
                        }else{
                            rec.put('ActualGLLocalPrem',rec.get('UWOverrideGLLocalPrem'));

                            //new requirement N2GFCB353
                            rec.put('ActualGLLocalPremWithCommision',rec.get('ActualGLLocalPrem'));
                            //rec.put('ActualGLLocalPremWithCommision', Decimal.valueOf(String.ValueOf(rec.get('ActualGLLocalPrem'))) * Decimal.valueOf(String.valueOf(step1Info.get('Commission'))) + Decimal.valueOf(String.ValueOf(rec.get('ActualGLLocalPrem'))));
                        }
                    }else{
                        rec.put('ActualGLLocalPrem','ERROR-no policy issued');
                    }
                }else{
                    rec.put('ActualGLLocalPrem',rec.get('AllocatedActualGLLocalPrem'));
                    /*if(!rec.containsKey('UWOverrideGLLocalPrem')){
rec.put('UWOverrideGLLocalPrem',rec.get('AllocatedActualGLLocalPrem'));
}*/
                    //new requirement N2GFCB353
                    rec.put('ActualGLLocalPremWithCommision', Decimal.valueOf(String.ValueOf(rec.get('ActualGLLocalPrem'))) * Decimal.valueOf(String.valueOf(step1Info.get('Commission'))) + Decimal.valueOf(String.ValueOf(rec.get('ActualGLLocalPrem'))));
                }
                
                // Actual Total Local Premium 
                if(String.ValueOf(rec.get('ActualLocalPremBeforeMin'))!=null && String.ValueOf(rec.get('ActualLocalPremBeforeMin'))!=''){
                    Decimal localELActualPrem=0;
                    if(String.ValueOf(rec.get('LocalELIncluded'))=='Separate Policy'){
                        localELActualPrem=0;
                        if(!(rec.get('LocalELActualPrem')==null ||rec.get('LocalELActualPrem')=='' || String.isBlank(String.valueOf(rec.get('LocalELActualPrem'))))) {
                        	localELActualPrem=(Decimal.valueOf(String.ValueOf(rec.get('LocalELActualPrem'))));
                        }
                        
                    }
                    
                    Decimal ActualGLLocalPrem=Decimal.valueOf(String.ValueOf(rec.get('ActualGLLocalPrem')));
                    if(String.valueOf(rec.get('UWOverrideGLLocalPrem'))!=null && String.valueOf(rec.get('UWOverrideGLLocalPrem'))!=''){
                        ActualGLLocalPrem=Decimal.valueOf(String.ValueOf(rec.get('UWOverrideGLLocalPrem')));
                    }
                    system.debug('@@ActualGLLocalPrem :: '+ActualGLLocalPrem);
                    rec.put('ActualTotalLocalPremium',(ActualGLLocalPrem + localELActualPrem ));
                    sumActualTotalLocalPremium+=Decimal.valueOf(String.ValueOf(rec.get('ActualTotalLocalPremium')));
                }
                 
                rec.put('Rate',0);
                // Rate
                // changing rate logic 08-02
                /*if(String.ValueOf(rec.get('ActualTotalLocalPremium'))!=null && String.ValueOf(rec.get('ActualTotalLocalPremium'))!=''
                   && String.ValueOf(rec.get('Exposure'))!=null && String.ValueOf(rec.get('Exposure'))!='' && Decimal.valueOf(String.ValueOf(rec.get('Exposure')))!=0
                   && String.ValueOf(rec.get('Per'))!=null && String.ValueOf(rec.get('Per'))!='' && Decimal.valueOf(String.ValueOf(rec.get('Per')))!=0){ 
                       rec.put('Rate',(Decimal.valueOf(String.ValueOf(rec.get('ActualTotalLocalPremium')))/Decimal.valueOf(String.ValueOf(rec.get('Exposure')))* Decimal.valueOf(String.ValueOf(rec.get('Per'))) ));
                   } */
                if(String.ValueOf(rec.get('ActualGLLocalPrem'))!=null && String.ValueOf(rec.get('ActualGLLocalPrem'))!=''
                   && String.ValueOf(rec.get('Exposure'))!=null && String.ValueOf(rec.get('Exposure'))!='' && Decimal.valueOf(String.ValueOf(rec.get('Exposure')))!=0
                   && String.ValueOf(rec.get('Per'))!=null && String.ValueOf(rec.get('Per'))!='' && Decimal.valueOf(String.ValueOf(rec.get('Per')))!=0){ 
                       rec.put('Rate',(Decimal.valueOf(String.ValueOf(rec.get('ActualGLLocalPrem')))/Decimal.valueOf(String.ValueOf(rec.get('Exposure')))* Decimal.valueOf(String.ValueOf(rec.get('Per'))) ));
                   } 
                // Calculate Master Minimum Premium Required
                if(String.isNotBlank(String.ValueOf(rec.get('MinimumPremiumRequired'))) ){
                    minMasterPremium+=Decimal.valueOf(String.ValueOf(rec.get('MinimumPremiumRequired')));
                }
                if(String.isNotBlank(String.ValueOf(rec.get('LocalELMinimumPremiumRequired'))) ){
                    minMasterPremium+=Decimal.valueOf(String.ValueOf(rec.get('LocalELMinimumPremiumRequired')));
                }
            }
            if(!step1Info.containsKey('LocalGlOtherExtWithComm') || ((step1Info.containsKey('ReCalculateGL') && Boolean.valueOf(step1Info.get('ReCalculateGL'))==true))){
                step1Info.put('TotalLocalGlOtherExtWithComm'  ,Decimal.valueOf(String.ValueOf(step1Info.get('LocalGlOtherExtWithComm')))+LocalGlDiff);
            } 
            step1Info.put('LocalGlDiff'  ,LocalGlDiff);
          
            //step1Info.put('MasterGlOtherExtWithComm'  ,Decimal.valueOf(String.ValueOf(step1Info.get('MasterGlOtherExtWithComm')))-LocalGlDiff);
          	step1Info.put('MasterGlOtherExtWithComm'  ,Decimal.valueOf(String.ValueOf(step1Info.get('UWOverrideGrossOfCommTpGl')))-Decimal.valueOf(String.ValueOf(step1Info.get('TotalLocalGlOtherExtWithComm'))));
          
            step1Info.put('GrossAPLocalOverride'  ,Decimal.valueOf(String.ValueOf(step1Info.get('totalLocalELTechnicalGrossOfComm')))+Decimal.valueOf(String.ValueOf(step1Info.get('TotalLocalGlOtherExtWithComm'))));
            System.debug('@@GrossAPLocalOverride::'+String.ValueOf(step1Info.get('GrossAPLocalOverride')));
            step1Info.put('GrossAPMasterOverride'  ,Decimal.valueOf(String.ValueOf(step1Info.get('UWOverrideGrossOfCommTpTotal'))) - Decimal.valueOf(String.ValueOf(step1Info.get('GrossAPLocalOverride'))));
            System.debug('@@GrossAPMasterOverride::'+String.ValueOf(step1Info.get('GrossAPMasterOverride')));
            
            step1Info.put('SumMasterMinPremium',SumMasterMinPremConfig+minMasterPremium);  
            step1Info.put('MasterMinPremium',SumMasterMinPremConfig);  
            
                       
            step1Info.put('GrossAPLocal',sumActualTotalLocalPremium);
            step1Info.put('GrossAPMaster',Decimal.valueOf(String.ValueOf(step1Info.get('GrossAPTotal')))-sumActualTotalLocalPremium);
            step1Info.put('GrossPerLocal',Decimal.valueOf(String.ValueOf(step1Info.get('GrossAPTotal')))==0?0:(sumActualTotalLocalPremium/Decimal.valueOf(String.ValueOf(step1Info.get('GrossAPTotal')))));
            step1Info.put('GrossPerMaster',Decimal.valueOf(String.ValueOf(step1Info.get('GrossAPTotal')))==0?0:(Decimal.valueOf(String.ValueOf(step1Info.get('GrossAPMaster')))/Decimal.valueOf(String.ValueOf(step1Info.get('GrossAPTotal')))));
            step1Info.put('APTPTotal',Decimal.valueOf(String.ValueOf(step1Info.get('GrossTPTotal')))==0?0:(Decimal.valueOf(String.ValueOf(step1Info.get('GrossAPTotal')))/Decimal.valueOf(String.ValueOf(step1Info.get('GrossTPTotal')))));
            
            if(String.ValueOf(step1Info.get('LocMinErnPrem'))==null ){
                step1Info.put('LocMinErnPrem',0);
            }
            //step1Info.put('MinimumEarnedPremium',Decimal.valueOf(String.ValueOf(step1Info.get('GrossAPTotal')))*Decimal.valueOf(String.ValueOf(step1Info.get('LocMinErnPrem'))));
            step1Info.put('MinimumEarnedPremium',Decimal.valueOf(String.ValueOf(step1Info.get('UWOverrideGrossOfCommTpTotal')))*Decimal.valueOf(String.ValueOf(step1Info.get('LocMinErnPrem'))));
            System.debug('@@GrossAPTotal'+Decimal.valueOf(String.ValueOf(step1Info.get('GrossAPTotal'))));
            System.debug('@@LocMinErnPrem'+Decimal.valueOf(String.ValueOf(step1Info.get('LocMinErnPrem'))));
            System.debug('@@MinimumEarnedPremium@@'+Decimal.valueOf(String.ValueOf(step1Info.get('MinimumEarnedPremium'))));
            step1Info.put('ReCalculateGL',false);
                
            
            //System.debug('sfdd@@@'+FcCaLcll.keySet());
            System.debug('sfdd@@'+mapaclist.get(String.valueOf(fcCaLcll.keySet())));
            System.debug('Step1@@::::::'+step1Info);
            outMap.put('Step1',step1Info);
        }catch(Exception e){
            system.debug('@@'+e);
            system.debug('@@e.getStackTraceString:::'+e.getStackTraceString());
            system.debug('@@e.getLineNumber():::'+e.getLineNumber());
            // outMap.put('Step1',inputMap.get('Step1'));
        }
    }
}