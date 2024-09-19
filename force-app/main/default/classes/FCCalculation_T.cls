@isTest
public class FCCalculation_T {
    @isTest
    public static void TestFcCalculationFormulas(){
        User admin_User = TestDataFactory.createUser(true, '','System Administrator');
        System.runAs(admin_User){
            Test.startTest();
            Map<string, Object> FcinputMapData = new Map<string, Object>();
            Map<string, Object> StepMapData = new Map<string, Object>();
            /*FcinputMapData.put('AccountName', 'N2G_Global');
            FcinputMapData.put('EffectiveDate', '09/07/2022');
            FcinputMapData.put('ExpiryDate', '02/28/2023');
            FcinputMapData.put('ExposureBase', 'Global Turnover (USD)');
            FcinputMapData.put('TotalExposureAmount', 1229274000);
            FcinputMapData.put('GLOccurenceLimit', 2000000);
            FcinputMapData.put('GLDeductible', 343);
            FcinputMapData.put('LimitFactor', 343);
            FcinputMapData.put('OccLimitPub', 2000000);
            FcinputMapData.put('OccLimitProd', 2000000);
            FcinputMapData.put('DeductiblePublic', 200);
            FcinputMapData.put('DeductiblePublic', 100000);
            FcinputMapData.put('RiskPreLocalEL', 23427.24601299102);
            FcinputMapData.put('RiskPremiumPFL', 6000);
            FcinputMapData.put('NetofCommTPTotal', 140948.35745752417);
            FcinputMapData.put('ExposureBasis', 'Global Turnover (USD)');
            FcinputMapData.put('ExposureAmount', 1229274000);
            FcinputMapData.put('CoveragesGL', 2000000);
            FcinputMapData.put('VerbiageLimitGL', 'Loss Occurrence');
            FcinputMapData.put('Deductible', 100000);
            FcinputMapData.put('Limit', 2000000);
            FcinputMapData.put('AggregateLimit', 2000000);
            FcinputMapData.put('Trigger', 'Loss Occurrence');
            FcinputMapData.put('CoverageALiability', 1000000);
            FcinputMapData.put('DeductibleExcess', 2500);
            FcinputMapData.put('CoverageBMedicalExp', 25000);
            FcinputMapData.put('CoverageCHiredNonOwned', 25000);
            FcinputMapData.put('InjuryByAccident', 1000000);*/
            StepMapData.put('Boolean', 'true');
            StepMapData.put('GrossTechnicalPremium', '361170');
            StepMapData.put('Commission', '0.232192362');
            StepMapData.put('InjuryByAccident', '1000000');
            StepMapData.put('CoverageCHiredNonOwned', '25000');
            StepMapData.put('CoverageBMedicalExp', '25000');
            StepMapData.put('DeductibleExcess', '2500');
            StepMapData.put('CoverageALiability', '1000000');
            StepMapData.put('Trigger', 'Loss Occurrence');
            StepMapData.put('AggregateLimit', '2000000');
            StepMapData.put('Limit', '2000000');
            StepMapData.put('Deductible', '100000');
            StepMapData.put('VerbiageLimitGL', 'Loss Occurrence');
            StepMapData.put('CoveragesGL', '2000000');
            StepMapData.put('HGProd', '4');
            StepMapData.put('HGPublic', '1');
            StepMapData.put('MainSICDesc', 'SURGICAL AND MEDICAL INSTRUMENTS AND APPARATUS');
            StepMapData.put('MainSIC', '3841');
            StepMapData.put('ILFGroup', '1');
            StepMapData.put('ExposureAmount', '1229274000');
            StepMapData.put('ExposureBasis', 'Global Turnover (USD)');
            StepMapData.put('NetOfCommTpTotal', '276579.326752147');
            //StepMapData.put('PremExtensionsPrimary', '0');
            //StepMapData.put('RiskPremiumBTA', '0');
            StepMapData.put('MinimumEarnedPremium', '288936');
            //StepMapData.put('RiskPremiumAuto', '0');
            //StepMapData.put('RiskPremiumFVWC', '0');
            StepMapData.put('RiskPremiumTotal', '225137.30542289276');
            StepMapData.put('GrossAPLocalEL', '19000');
            StepMapData.put('APGrossCom', '277005');
            //StepMapData.put('RiskPremiumPFL', '0');
            //StepMapData.put('RiskPreLocalEL', '0');
            StepMapData.put('DeductibleProd', '100000');
            StepMapData.put('DeductiblePublic', 'null');
            StepMapData.put('OccLimitProd', '2000000');
            StepMapData.put('OccLimitPub', '2000000');
            StepMapData.put('LimitFactor', '1.0663897921725647');
            StepMapData.put('Commission', '0.26');
            StepMapData.put('ExpenseLoading', '0.19019540540540542');
            StepMapData.put('InvestDis', '-0.022588863447449592');
            StepMapData.put('LocMinErnPrem', '0.8');
            StepMapData.put('MinErnPrem', '288176');
            StepMapData.put('LclBrkComm', '0.15');
            StepMapData.put('SepELPolMinPre', '2500');
            StepMapData.put('MinPreforLarPre', '1500');
            StepMapData.put('DIC', '0.1');
            StepMapData.put('MstrBrkrComm', '0.1');
            StepMapData.put('FOSMinPre', '500');
            StepMapData.put('MinPremExpThre', '3000000');
            StepMapData.put('UWBId', '51157');
            StepMapData.put('GLDeductible', '100000');
            StepMapData.put('GLOccurenceLimit', '2000000');
            StepMapData.put('ExposureBase', 'Global Turnover (USD)');
            StepMapData.put('TotalExposureAmount', '1229274000');
            StepMapData.put('ActualPremium', '');
            StepMapData.put('ExpiryDate', '02/28/2023');
            StepMapData.put('AccountName', 'West Pharmaceutical Services, Inc.');
            StepMapData.put('EffectiveDate', '03/01/2022');
            StepMapData.put('UWOverrideGrossAPTotal', '361170');
            
            Map<string, Object> DataMap = new Map<string, Object>();
            List<Object> DataList = new List<Object>();
            DataMap.put('OtherLocalExtensionPFLIncluded', 'No');
            DataMap.put('ELIncluded', 'No');
            DataMap.put('uniqueKey', 'Ireland_GL');
            DataMap.put('CasualityLocalID', '');
            DataMap.put('type', 'GL');
            DataMap.put('icnNm', 'utility:right');
            DataMap.put('Per', '1000');
            DataMap.put('Rate', '0');
            DataMap.put('Premium', '20000');
            DataMap.put('LocalELIncluded', '');
            DataMap.put('LoclPolReq', 'Yes');
            DataMap.put('OtherLocalExtensionIncluded', 'Yes');
            DataMap.put('LocalPolDect', '100000');
            DataMap.put('DIL', '0.4941831217116044');
            //DataMap.put('WeightToMaster', '');
            DataMap.put('ExposurePer', '0.17721598276706413');
            DataMap.put('Exposure', '217847000');
            DataMap.put('DeductibleFactor', '0.448');
            DataMap.put('CountryLoding', '0');
            DataMap.put('Country', 'Ireland');
            DataMap.put('CostAssociatedtoLocalPolicies', '560.5');
            DataMap.put('LimitFactor', '0.9873979557153376');
            DataMap.put('AggregateLimit', '2000000');
            DataMap.put('Limit', '1000000');
            DataMap.put('UWOverrideGrossAPTotal', '0');
            
        
            
            DataList.add(DataMap);
            DataMap = new Map<string, Object>();
            DataMap.put('OtherLocalExtensionPFLIncluded', 'No');
            DataMap.put('ELIncluded', 'No');
            DataMap.put('uniqueKey', 'Germany_GL');
            DataMap.put('CasualityLocalID', '');
            DataMap.put('type', 'GL');
            DataMap.put('icnNm', 'utility:right');
            DataMap.put('Per', '1000');
            DataMap.put('Rate', '0');
            DataMap.put('Premium', '20000');
            DataMap.put('LocalELIncluded', '');
            DataMap.put('LoclPolReq', 'FOS');
            DataMap.put('OverRide', '');
            DataMap.put('LocalPolDect', '');
            DataMap.put('DIL', '');
            //DataMap.put('WeightToMaster', '');
            DataMap.put('ExposurePer', '0.28072016491034546');
            DataMap.put('Exposure', '345082000');
            DataMap.put('DeductibleFactor', '');
            DataMap.put('CountryLoding', '-0.25');
            DataMap.put('LocalGlOtherExt', '0.25');
             DataMap.put('MasterGlOtherExt', '1.25');
            DataMap.put('Country', 'Germany');
            DataMap.put('CostAssociatedtoLocalPolicies', '560.5');
            DataMap.put('LimitFactor', '');
            DataMap.put('AggregateLimit', '0');
            DataMap.put('Limit', '');
            DataMap.put('UWOverrideGrossAPTotal', '');
            
            
            DataList.add(DataMap);
            StepMapData.put('Data', DataList);
            FcinputMapData.put('Step1', StepMapData);
            
            Map<string, Object> FcoutputMapData = new Map<string, Object>();

            // Object step1Info = (Object) TestDataFactory.operationOnObjectRec('insert','Object',FcinputMapData);

            Map<string,Object> FcRefLocal = new Map<string,Object>();
            FcRefLocal.put('Country_of_Domicile__c', 'Ireland');
            FcRefLocal.put('EL_Loading__c', 5);
            FcRefLocal.put('GL_Minimum_Premium__c', '1000'); 
            FcRefLocal.put('Other_local_extensions__c', 0.10);
            FcRefLocal.put('Override__c', '0.5');
            FcRefLocal.put('FOS_countries__c', false);
            FC_Reference_Local__c FCRefLocl = (FC_Reference_Local__c) TestDataFactory.operationOnObjectRec('insert','FC_Reference_Local__c',FcRefLocal);
            
            FcRefLocal = new Map<string,Object>();
            FcRefLocal.put('Country_of_Domicile__c', 'Germany');
            FcRefLocal.put('EL_Loading__c', 0);
            FcRefLocal.put('GL_Minimum_Premium__c', '1000'); 
            FcRefLocal.put('Other_local_extensions__c', 0);
            FcRefLocal.put('Override__c', '0.5');
            FcRefLocal.put('FOS_countries__c', true);
            FCRefLocl = (FC_Reference_Local__c) TestDataFactory.operationOnObjectRec('insert','FC_Reference_Local__c',FcRefLocal);

            Map<string,Object> FcRefExpMap = new Map<string,Object>();
            FcRefExpMap.put('N2G_Revenue_Local__c' ,10);
            FcRefExpMap.put('Total_Commission_Local__c' ,10);
            FC_Reference_Expenses__c FcRefExpRec = (FC_Reference_Expenses__c) TestDataFactory.operationOnObjectRec('insert','FC_Reference_Expenses__c',FcRefExpMap);

            //FcoutputMapData.put('Step1', StepMapData);
            FCCalculation.getCalculation(FcinputMapData, FcoutputMapData);
            
            
            System.debug('@@Test'+FcoutputMapData.get('Step1'));
            //System.assertEquals(FcoutputMapData.get('LimitFactor'), StepMapData.get('LimitFactor'));
            //
            Map<String,Object> returnData= (Map<String,Object>)FcoutputMapData.get('Step1');
            
            system.debug('@@'+JSON.serialize(returnData));
            /*if(returnData != null){
            System.assertEquals(288936,Decimal.valueOf(String.valueOf(returnData.get('MinimumEarnedPremium'))).setScale(0));
            System.assertEquals(1,Decimal.valueOf(String.valueOf(returnData.get('APTPTotal'))).setScale(0));
            System.assertEquals(0.32,Decimal.valueOf(String.valueOf(returnData.get('GrossPerMaster'))).setScale(2));
            System.assertEquals(0.68,Decimal.valueOf(String.valueOf(returnData.get('GrossPerLocal'))).setScale(2));
            System.assertEquals(114032,Decimal.valueOf(String.valueOf(returnData.get('GrossAPMaster'))).setScale(0));
            System.assertEquals(247138,Decimal.valueOf(String.valueOf(returnData.get('GrossAPLocal'))).setScale(0));
            System.assertEquals(3500,Decimal.valueOf(String.valueOf(returnData.get('MasterMinPremium'))).setScale(0));
			System.assertEquals(5500,Decimal.valueOf(String.valueOf(returnData.get('SumMasterMinPremium'))).setScale(0));
            System.assertEquals(0.00,Decimal.valueOf(String.valueOf(returnData.get('totalMeetMiniumLocalEL'))).setScale(2));
            System.assertEquals(361170,Decimal.valueOf(String.valueOf(returnData.get('GrossAPTotal'))).setScale(0));
            System.assertEquals(361170,Decimal.valueOf(String.valueOf(returnData.get('GrossTPTotal'))).setScale(0));
            System.assertEquals(0.23,Decimal.valueOf(String.valueOf(returnData.get('CommToEnterGerRate'))).setScale(2));
            System.assertEquals(0.32,Decimal.valueOf(String.valueOf(returnData.get('MstrPerOfTotal'))).setScale(2));
            System.assertEquals(87324,Decimal.valueOf(String.valueOf(returnData.get('MasterTotal'))).setScale(0));
            System.assertEquals(2414,Decimal.valueOf(String.valueOf(returnData.get('MasterBTA'))).setScale(0));
            System.assertEquals(1439,Decimal.valueOf(String.valueOf(returnData.get('MasterAuto'))).setScale(0));
            System.assertEquals(5660,Decimal.valueOf(String.valueOf(returnData.get('MasterFVWC'))).setScale(0));
            System.assertEquals(0.68,Decimal.valueOf(String.valueOf(returnData.get('LocalPerToTotal'))).setScale(2));
            System.assertEquals(276579,Decimal.valueOf(String.valueOf(returnData.get('totalTotal'))).setScale(0));
            System.assertEquals(189255,Decimal.valueOf(String.valueOf(returnData.get('LocalTotal'))).setScale(0));
            System.assertEquals(160979,Decimal.valueOf(String.valueOf(returnData.get('LocalGlOtherExt'))).setScale(0));
            System.assertEquals(77811,Decimal.valueOf(String.valueOf(returnData.get('MasterGlOtherExt'))).setScale(0));
            System.assertEquals(0.33,Decimal.valueOf(String.valueOf(returnData.get('SumOfAllLocalPolicieGLExtAllocatedToMaster'))).setScale(2));
            System.assertEquals(238790,Decimal.valueOf(String.valueOf(returnData.get('TotalGlOtherExt'))).setScale(0));
            System.assertEquals(214794,Decimal.valueOf(String.valueOf(returnData.get('NetOfCommTpGL'))).setScale(0));
            System.assertEquals(16755,Decimal.valueOf(String.valueOf(returnData.get('NetOfCommTpOtherExt'))).setScale(0));
            System.assertEquals(7242,Decimal.valueOf(String.valueOf(returnData.get('NetOfCommTpPFL'))).setScale(0));
            System.assertEquals(2414,Decimal.valueOf(String.valueOf(returnData.get('NetOfCommTpBTA'))).setScale(0));
            System.assertEquals(1439,Decimal.valueOf(String.valueOf(returnData.get('NetOfCommTpAuto'))).setScale(0));
            System.assertEquals(5660,Decimal.valueOf(String.valueOf(returnData.get('NetOfCommTpFVWC'))).setScale(0));
            System.assertEquals(28276,Decimal.valueOf(String.valueOf(returnData.get('NetOfCommTpLocalEl'))).setScale(0));
            System.assertEquals(0.00,Decimal.valueOf(String.valueOf(returnData.get('CountryLoding'))).setScale(2));
            System.assertEquals('03/01/2022',returnData.get('EffectiveDate'));
            System.assertEquals('West Pharmaceutical Services, Inc.',returnData.get('AccountName'));
            System.assertEquals('02/28/2023',returnData.get('ExpiryDate'));
            System.assertEquals(1229274000,Decimal.valueOf(String.valueOf(returnData.get('TotalExposureAmount'))).setScale(0));
            System.assertEquals('Global Turnover (USD)',returnData.get('ExposureBase'));
            System.assertEquals(2000000,Decimal.valueOf(String.valueOf(returnData.get('GLOccurenceLimit'))).setScale(0));
            System.assertEquals(100000,Decimal.valueOf(String.valueOf(returnData.get('GLDeductible'))).setScale(0));
            System.assertEquals(51157,Decimal.valueOf(String.valueOf(returnData.get('UWBId'))).setScale(0));
            System.assertEquals(3000000,Decimal.valueOf(String.valueOf(returnData.get('MinPremExpThre'))).setScale(0));
            System.assertEquals(500,Decimal.valueOf(String.valueOf(returnData.get('FOSMinPre'))).setScale(0));
            System.assertEquals(0.10,Decimal.valueOf(String.valueOf(returnData.get('MstrBrkrComm'))).setScale(2));
            System.assertEquals(0.10,Decimal.valueOf(String.valueOf(returnData.get('DIC'))).setScale(2));
            System.assertEquals(1500,Decimal.valueOf(String.valueOf(returnData.get('MinPreforLarPre'))).setScale(0));
            System.assertEquals(2500,Decimal.valueOf(String.valueOf(returnData.get('SepELPolMinPre'))).setScale(0));
            System.assertEquals(0.15,Decimal.valueOf(String.valueOf(returnData.get('LclBrkComm'))).setScale(2));
            System.assertEquals(288176,Decimal.valueOf(String.valueOf(returnData.get('MinErnPrem'))).setScale(0));
            System.assertEquals(0.80,Decimal.valueOf(String.valueOf(returnData.get('LocMinErnPrem'))).setScale(2));
            System.assertEquals(-0.02,Decimal.valueOf(String.valueOf(returnData.get('InvestDis'))).setScale(2));
            System.assertEquals(0.19,Decimal.valueOf(String.valueOf(returnData.get('ExpenseLoading'))).setScale(2));
            System.assertEquals(0.26,Decimal.valueOf(String.valueOf(returnData.get('Commission'))).setScale(2));
            System.assertEquals(1,Decimal.valueOf(String.valueOf(returnData.get('LimitFactor'))).setScale(0));
            System.assertEquals(2000000,Decimal.valueOf(String.valueOf(returnData.get('OccLimitPub'))).setScale(0));
            System.assertEquals(2000000,Decimal.valueOf(String.valueOf(returnData.get('OccLimitProd'))).setScale(0));
            System.assertEquals('null',returnData.get('DeductiblePublic'));
            System.assertEquals(100000,Decimal.valueOf(String.valueOf(returnData.get('DeductibleProd'))).setScale(0));
            System.assertEquals(23427,Decimal.valueOf(String.valueOf(returnData.get('RiskPreLocalEL'))).setScale(0));
            System.assertEquals(6000,Decimal.valueOf(String.valueOf(returnData.get('RiskPremiumPFL'))).setScale(0));
            System.assertEquals(277005,Decimal.valueOf(String.valueOf(returnData.get('APGrossCom'))).setScale(0));
            System.assertEquals(19000,Decimal.valueOf(String.valueOf(returnData.get('GrossAPLocalEL'))).setScale(0));
            System.assertEquals(225137,Decimal.valueOf(String.valueOf(returnData.get('RiskPremiumTotal'))).setScale(0));
            System.assertEquals(4689,Decimal.valueOf(String.valueOf(returnData.get('RiskPremiumFVWC'))).setScale(0));
            System.assertEquals(1193,Decimal.valueOf(String.valueOf(returnData.get('RiskPremiumAuto'))).setScale(0));
            System.assertEquals(2000,Decimal.valueOf(String.valueOf(returnData.get('RiskPremiumBTA'))).setScale(0));
            System.assertEquals(13882,Decimal.valueOf(String.valueOf(returnData.get('PremExtensionsPrimary'))).setScale(0));
            System.assertEquals(276579,Decimal.valueOf(String.valueOf(returnData.get('NetOfCommTpTotal'))).setScale(0));
            System.assertEquals('Global Turnover (USD)',returnData.get('ExposureBasis'));
            System.assertEquals(1229274000,Decimal.valueOf(String.valueOf(returnData.get('ExposureAmount'))).setScale(0));
            System.assertEquals(1,Decimal.valueOf(String.valueOf(returnData.get('ILFGroup'))).setScale(0));
            System.assertEquals(3841,Decimal.valueOf(String.valueOf(returnData.get('MainSIC'))).setScale(0));
            System.assertEquals('SURGICAL AND MEDICAL INSTRUMENTS AND APPARATUS',returnData.get('MainSICDesc'));
            System.assertEquals(1,Decimal.valueOf(String.valueOf(returnData.get('HGPublic'))).setScale(0));
            System.assertEquals(4,Decimal.valueOf(String.valueOf(returnData.get('HGProd'))).setScale(0));
            System.assertEquals(2000000,Decimal.valueOf(String.valueOf(returnData.get('CoveragesGL'))).setScale(0));
            System.assertEquals('Loss Occurrence',returnData.get('VerbiageLimitGL'));
            System.assertEquals(100000,Decimal.valueOf(String.valueOf(returnData.get('Deductible'))).setScale(0));
            System.assertEquals(2000000,Decimal.valueOf(String.valueOf(returnData.get('Limit'))).setScale(0));
            System.assertEquals(2000000,Decimal.valueOf(String.valueOf(returnData.get('AggregateLimit'))).setScale(0));
            System.assertEquals('Loss Occurrence',returnData.get('Trigger'));
            System.assertEquals(1000000,Decimal.valueOf(String.valueOf(returnData.get('CoverageALiability'))).setScale(0));
            System.assertEquals(2500,Decimal.valueOf(String.valueOf(returnData.get('DeductibleExcess'))).setScale(0));
            System.assertEquals(25000,Decimal.valueOf(String.valueOf(returnData.get('CoverageBMedicalExp'))).setScale(0));
            System.assertEquals(25000,Decimal.valueOf(String.valueOf(returnData.get('CoverageCHiredNonOwned'))).setScale(0));
            System.assertEquals(1000000,Decimal.valueOf(String.valueOf(returnData.get('InjuryByAccident'))).setScale(0));
                System.assertEquals('true',returnData.get('Boolean'));}
            if(returnData!=null){
                List<Object> step1DataInfo=(List<Object>)returnData.get('Data');
            for(Object data : step1DataInfo){
                Map<String,object> rec=(Map<String,object>)data;
                if(String.ValueOf(rec.get('Country')) == 'Ireland'){
                    System.assertEquals(67993,Decimal.valueOf(String.valueOf(rec.get('ActualTotalLocalPremium'))).setScale(0));
                    System.assertEquals(67993,Decimal.valueOf(String.valueOf(rec.get('ActualGLLocalPrem'))).setScale(0));
                    System.assertEquals(67993,Decimal.valueOf(String.valueOf(rec.get('AllocatedActualGLLocalPrem'))).setScale(0));
                    System.assertEquals(1,Decimal.valueOf(String.valueOf(rec.get('MeetMinimumLocalEL'))).setScale(0));
                    System.assertEquals(67993,Decimal.valueOf(String.valueOf(rec.get('ActualLocalPremBeforeMin'))).setScale(0));
                    System.assertEquals(67993,Decimal.valueOf(String.valueOf(rec.get('GLExtensionsActualPremAllocatedtoLocalAdjusted'))).setScale(0));
                    System.assertEquals(0.28,Decimal.valueOf(String.valueOf(rec.get('GLExtensionsAllocatedtoLocal_Y27'))).setScale(2));
                    System.assertEquals(0.19,Decimal.valueOf(String.valueOf(rec.get('LocalGLExtensionAllocationBasis'))).setScale(2));
                    System.assertEquals(0.00,Decimal.valueOf(String.valueOf(rec.get('LocalELTechnicalGrossOfComm'))).setScale(2));
                    System.assertEquals(0.00,Decimal.valueOf(String.valueOf(rec.get('LocalELTechnicalpremium'))).setScale(2));
                    //System.assertEquals(217847000,Decimal.valueOf(String.valueOf(rec.get('GLExtActualpremlocalExcEL'))).setScale(0));
                    System.assertEquals(67993,Decimal.valueOf(String.valueOf(rec.get('GLExtActualpremlocalExcEL'))).setScale(0));
                    System.assertEquals(0.19,Decimal.valueOf(String.valueOf(rec.get('GLExtensionsAllocatedtoLocal_T27'))).setScale(2));
                    System.assertEquals(0.27,Decimal.valueOf(String.valueOf(rec.get('GLExtensionsAllocatedtoMaster'))).setScale(2));
                    System.assertEquals(0.46,Decimal.valueOf(String.valueOf(rec.get('ModifiedExposurePercentage'))).setScale(2));
                    System.assertEquals(0.00,Decimal.valueOf(String.valueOf(rec.get('LocalELActualPrem'))).setScale(2));
                    System.assertEquals(1500,Decimal.valueOf(String.valueOf(rec.get('MinimumPremiumRequired'))).setScale(0));
                    System.assertEquals(0.59,Decimal.valueOf(String.valueOf(rec.get('WeightToMaster'))).setScale(2));
                    System.assertEquals(0.00,Decimal.valueOf(String.valueOf(rec.get('LocalExtensionIndicator'))).setScale(2));
                    System.assertEquals(0.00,Decimal.valueOf(String.valueOf(rec.get('ELCoverIndicator'))).setScale(2));
                    System.assertEquals(0.50,Decimal.valueOf(String.valueOf(rec.get('OverRide'))).setScale(2));
                    System.assertEquals(0.00,Decimal.valueOf(String.valueOf(rec.get('Otherlocalextensionloading'))).setScale(2));
                    System.assertEquals(0.00,Decimal.valueOf(String.valueOf(rec.get('OtherlocalextensionloadingDefault'))).setScale(2));
                    System.assertEquals(0.00,Decimal.valueOf(String.valueOf(rec.get('ELLoding'))).setScale(2));
                    System.assertEquals(0.05,Decimal.valueOf(String.valueOf(rec.get('ELLodingDefault'))).setScale(2));
                    System.assertEquals(217847000,Decimal.valueOf(String.valueOf(rec.get('ModifedExposers'))).setScale(0));
                    System.assertEquals(1000000,Decimal.valueOf(String.valueOf(rec.get('Limit'))).setScale(0));
                    System.assertEquals(2000000,Decimal.valueOf(String.valueOf(rec.get('AggregateLimit'))).setScale(0));
                    System.assertEquals(0.99,Decimal.valueOf(String.valueOf(rec.get('LimitFactor'))).setScale(2));
                    System.assertEquals(0.00,Decimal.valueOf(String.valueOf(rec.get('CountryLoding'))).setScale(2));
                    System.assertEquals(0.45,Decimal.valueOf(String.valueOf(rec.get('DeductibleFactor'))).setScale(2));
                    System.assertEquals(217847000,Decimal.valueOf(String.valueOf(rec.get('Exposure'))).setScale(0));
                    System.assertEquals(0.18,Decimal.valueOf(String.valueOf(rec.get('ExposurePer'))).setScale(2));
                    System.assertEquals(0.49,Decimal.valueOf(String.valueOf(rec.get('DIL'))).setScale(2));
                    System.assertEquals(100000,Decimal.valueOf(String.valueOf(rec.get('LocalPolDect'))).setScale(0));
                    System.assertEquals(20000,Decimal.valueOf(String.valueOf(rec.get('Premium'))).setScale(0));
                    System.assertEquals(0.31,Decimal.valueOf(String.valueOf(rec.get('Rate'))).setScale(2));
                    System.assertEquals(1000,Decimal.valueOf(String.valueOf(rec.get('Per'))).setScale(0));
                }
                if(String.ValueOf(rec.get('Country')) == 'Germany'){
                    System.assertEquals(179146,Decimal.valueOf(String.valueOf(rec.get('ActualTotalLocalPremium'))).setScale(0));
                    System.assertEquals(179146,Decimal.valueOf(String.valueOf(rec.get('ActualGLLocalPrem'))).setScale(0));
                    System.assertEquals(179146,Decimal.valueOf(String.valueOf(rec.get('AllocatedActualGLLocalPrem'))).setScale(0));
                    System.assertEquals(1,Decimal.valueOf(String.valueOf(rec.get('MeetMinimumLocalEL'))).setScale(0));
                    System.assertEquals(179146,Decimal.valueOf(String.valueOf(rec.get('ActualLocalPremBeforeMin'))).setScale(0));
                    System.assertEquals(179146,Decimal.valueOf(String.valueOf(rec.get('GLExtensionsActualPremAllocatedtoLocalAdjusted'))).setScale(0));
                    System.assertEquals(0.72,Decimal.valueOf(String.valueOf(rec.get('GLExtensionsAllocatedtoLocal_Y27'))).setScale(2));
                    System.assertEquals(0.49,Decimal.valueOf(String.valueOf(rec.get('LocalGLExtensionAllocationBasis'))).setScale(2));
                    System.assertEquals(0.00,Decimal.valueOf(String.valueOf(rec.get('LocalELTechnicalGrossOfComm'))).setScale(2));
                    System.assertEquals(0.00,Decimal.valueOf(String.valueOf(rec.get('LocalELTechnicalpremium'))).setScale(2));
                    //System.assertEquals(258811500,Decimal.valueOf(String.valueOf(rec.get('GLExtActualpremlocalExcEL'))).setScale(0));
                    System.assertEquals(179146,Decimal.valueOf(String.valueOf(rec.get('GLExtActualpremlocalExcEL'))).setScale(0));
                    System.assertEquals(0.49,Decimal.valueOf(String.valueOf(rec.get('GLExtensionsAllocatedtoLocal_T27'))).setScale(2));
                    System.assertEquals(0.05,Decimal.valueOf(String.valueOf(rec.get('GLExtensionsAllocatedtoMaster'))).setScale(2));
                    System.assertEquals(0.54,Decimal.valueOf(String.valueOf(rec.get('ModifiedExposurePercentage'))).setScale(2));
                    System.assertEquals(0.00,Decimal.valueOf(String.valueOf(rec.get('LocalELActualPrem'))).setScale(2));
                    System.assertEquals(500,Decimal.valueOf(String.valueOf(rec.get('MinimumPremiumRequired'))).setScale(0));
                    System.assertEquals(0.10,Decimal.valueOf(String.valueOf(rec.get('WeightToMaster'))).setScale(2));
                    System.assertEquals(0.00,Decimal.valueOf(String.valueOf(rec.get('LocalExtensionIndicator'))).setScale(2));
                    System.assertEquals(0.00,Decimal.valueOf(String.valueOf(rec.get('ELCoverIndicator'))).setScale(2));
                    System.assertEquals(0.50,Decimal.valueOf(String.valueOf(rec.get('OverRide'))).setScale(2));
                    System.assertEquals(0.00,Decimal.valueOf(String.valueOf(rec.get('Otherlocalextensionloading'))).setScale(2));
                    System.assertEquals(0.00,Decimal.valueOf(String.valueOf(rec.get('OtherlocalextensionloadingDefault'))).setScale(2));
                    System.assertEquals(0.00,Decimal.valueOf(String.valueOf(rec.get('ELLoding'))).setScale(2));
                    System.assertEquals(0.00,Decimal.valueOf(String.valueOf(rec.get('ELLodingDefault'))).setScale(2));
                    System.assertEquals(258811500,Decimal.valueOf(String.valueOf(rec.get('ModifedExposers'))).setScale(0));
                    System.assertEquals(0.00,Decimal.valueOf(String.valueOf(rec.get('AggregateLimit'))).setScale(2));
                    System.assertEquals(-0.25,Decimal.valueOf(String.valueOf(rec.get('CountryLoding'))).setScale(2));
                    System.assertEquals(345082000,Decimal.valueOf(String.valueOf(rec.get('Exposure'))).setScale(0));
                    System.assertEquals(0.28,Decimal.valueOf(String.valueOf(rec.get('ExposurePer'))).setScale(2));
                    System.assertEquals(0.00,Decimal.valueOf(String.valueOf(rec.get('DIL'))).setScale(2));
                    System.assertEquals(20000,Decimal.valueOf(String.valueOf(rec.get('Premium'))).setScale(0));
                    System.assertEquals(0.52,Decimal.valueOf(String.valueOf(rec.get('Rate'))).setScale(2));
                    System.assertEquals(1000,Decimal.valueOf(String.valueOf(rec.get('Per'))).setScale(0));
                }
            }
            }
       */
            Boolean value=New FCCalculation().invokeMethod('getCalculation', new Map<String, Object>(), new Map<String, Object>(), new Map<String, Object>());
            System.assertEquals(value, true);
            Test.stopTest();
        }
    }
    
}