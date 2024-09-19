@isTest
public class FcLocalExtension_T {
    @isTest
    public static void getDefaultDataTest(){
        User admin_User = TestDataFactory.createUser(true, '','System Administrator');
        System.runAs(admin_User){
            
            Test.startTest();
            
            Map<String, Object > inputMap = new Map<String, Object>();
            Map<String, Object > outMap = new Map<String, Object>();
            Map<String, Object > newExtensionDataMap = new Map<String, Object>();
            //Map<String, Object > newCasualLocalData = new Map<String, Object >();
            FcLocalExtension.getDefaultData(inputMap,outMap);
            FcLocalExtension.getCountryList(inputMap,outMap);
            
            
            newExtensionDataMap.put('recordIds','1324rfft1');
            newExtensionDataMap.put('Premium','12');
            newExtensionDataMap.put('Deductible','1522');
            newExtensionDataMap.put('OccurenceLimit','1400');
            newExtensionDataMap.put('AggregateLimit','1500');
            newExtensionDataMap.put('extensionType','yes');
            newExtensionDataMap.put('premiumId','42527575');
            
            
            Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
            Map<String,Object>  Accountobj = new Map<String,Object>();
            Accountobj.put('RecordTypeId',RecordTypeId);
            Accountobj.put('Name','NewAcco');
            Accountobj.put('Box_Folder_Name__c','test');
            Account accountRec = (Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj);

            Map<String,Object>  Opportunityobj = new Map<String,Object>();
            Opportunityobj.put('Name','test');
            Opportunityobj.put('CloseDate',System.today());
            Opportunityobj.put('StageName','Unqualified');
            Opportunityobj.put('AccountId',accountRec.Id);
            Opportunityobj.put('Line_of_Business__c','Commercial Umbrella;Ocean Marine');
            Opportunityobj.put('Submission_Type__c','Domestic');
            BaseTriggerHandler.bypass('TH_OPPORTUNITY');
            Opportunity OpportunityRec = (Opportunity) TestDataFactory.operationOnObjectRec('insert', 'Opportunity', Opportunityobj);
            BaseTriggerHandler.bypass('TH_OPPORTUNITY');
            
            
            
            Map<String,Object> lineBuisness = new Map<String,Object>();
            lineBuisness.put('Opportunity_Related__c',OpportunityRec.Id);
            //casualtyLocalExtension.put('Form_Name__c','COMMON POLICY DECLARATIONS');
            //casualtyLocalExtensioncords.put('Form_Name_ID__c','OP-D-1100CT-N2G0621');
            //casualtyLocalExtension.put('LOB_CODE__c','Auto');
            LOB_Management__c lineOfBuisnessRec = (LOB_Management__c) TestDataFactory.operationOnObjectRec('insert','LOB_Management__c',lineBuisness);
			
      
            
            Map<String,Object> engagement = new Map<String,Object>();
            engagement.put('Assign_To__c',admin_User.Id);
            Engagement__c engagementRec = (Engagement__c) TestDataFactory.operationOnObjectRec('insert','Engagement__c',engagement);

            Map<String,Object> broker = new Map<String,Object>();
            broker.put('Broker__c',engagementRec.Id);
            broker.put('Broker_Account__c',accountRec.Id);
            Engagement_Broker__c brokerRec = (Engagement_Broker__c) TestDataFactory.operationOnObjectRec('insert','Engagement_Broker__c',broker);

            Map<String,Object> application = new Map<String,Object>();
            //application.put('Application__c','');
            //application.put('Broker__c',brokerRec.Id);
            //application.put('Insured_Name__c',accountRec.Id);
            application.put('Name','testApp');
            application.put('LineofBusiness__c',lineOfBuisnessRec.Id);
            
            
            //casualtyLocalExtension.put('Form_Name__c','COMMON POLICY DECLARATIONS');
            //casualtyLocalExtensioncords.put('Form_Name_ID__c','OP-D-1100CT-N2G0621');
            //casualtyLocalExtension.put('LOB_CODE__c','Auto');
            vlocity_ins__Application__c applicationRec = (vlocity_ins__Application__c) TestDataFactory.operationOnObjectRec('insert','vlocity_ins__Application__c',application);
            
            
            Map<String,Object> casualtyPremium = new Map<String,Object>();
            casualtyPremium.put('Application__c',applicationRec.Id);
            casualtyPremium.put('Broker__c',brokerRec.Id);
            casualtyPremium.put('Insured_Name__c',accountRec.Id);
            casualtyPremium.put('Line_of_Business__c',lineOfBuisnessRec.Id);
            
            
            //casualtyLocalExtension.put('Form_Name__c','COMMON POLICY DECLARATIONS');
            //casualtyLocalExtensioncords.put('Form_Name_ID__c','OP-D-1100CT-N2G0621');
            //casualtyLocalExtension.put('LOB_CODE__c','Auto');
            FC_Casualty_Premium__c casualtyPremiumRec = (FC_Casualty_Premium__c) TestDataFactory.operationOnObjectRec('insert','FC_Casualty_Premium__c',casualtyPremium);

                
            Map<String,Object> casualtyLocal = new Map<String,Object>();
            casualtyLocal.put('FC_Casualty_Premium__c',casualtyPremiumRec.Id);
            casualtyLocal.put('LOB__c',lineOfBuisnessRec.Id);
            casualtyLocal.put('Aggregate_Limit__c','Not Schedule');
            //casualtyLocalExtension.put('Form_Name__c','COMMON POLICY DECLARATIONS');
            //casualtyLocalExtensioncords.put('Form_Name_ID__c','OP-D-1100CT-N2G0621');
            //casualtyLocalExtension.put('LOB_CODE__c','Auto');
            FC_Casualty_Local__c casualtyLocalRec = (FC_Casualty_Local__c) TestDataFactory.operationOnObjectRec('insert','FC_Casualty_Local__c',casualtyLocal);

            
            
            
            inputMap.put('recordIds',casualtyLocalRec.Id);
            inputMap.put('Premium','Not Schedule');
            inputMap.put('Deductible','Not Schedule');
            inputMap.put('OccurenceLimit','1400');
            inputMap.put('AggregateLimit','1500');
            inputMap.put('extensionType','yes');
            inputMap.put('newExtensionData',JSON.serialize(newExtensionDataMap));
            
            
       		FcLocalExtension.createLocalExtension(inputMap,outMap);
            
            
            Map<String, Object > inputtMap = new Map<String, Object>();
            Map<String, Object > outtMap = new Map<String, Object>();
            
            
            Map<string,Object> casualtyLocalInput = new Map<string,Object>();
            casualtyLocalInput.put('Id','283762372');
            casualtyLocalInput.put('FC_Casualty_Premium__c','124332432');
            casualtyLocalInput.put('Country__c','Russia');
            casualtyLocalInput.put('LOB__c','GL');
            casualtyLocalInput.put('Limit__c',1522.88);
            casualtyLocalInput.put('Exposure__c',1400.99);
            casualtyLocalInput.put('Local_Policy_Required__c','No');
            casualtyLocalInput.put('Premium__c',123.22);
            casualtyLocalInput.put('Other_local_extension_e_g_PFL_included__c','yes');
            
            inputtMap.put('Id','283762372');
            inputtMap.put('FC_Casualty_Premium__c',casualtyPremiumRec.Id);
            inputtMap.put('LOB__c','GL');
            inputtMap.put('Limit__c',1522.88);
            inputtMap.put('Exposure__c',1400.99);
            inputtMap.put('Local_Policy_Required__c','No');
            inputtMap.put('Premium__c',123.22);
            inputtMap.put('Other_local_extension_e_g_PFL_included__c','Yes');
            inputtMap.put('newformData', casualtyLocalInput);
            
            FcLocalExtension.getFormsDet(inputtMap,outtMap);
                        
            Boolean value=New FcLocalExtension().invokeMethod('getDefaultData', new Map<String, Object>(), new Map<String, Object>(), new Map<String, Object>());
        	System.assertEquals(value, true);
            value=New FcLocalExtension().invokeMethod('createLocalExtension', inputMap, outMap, new Map<String, Object>());
        	System.assertEquals(value, true);
            value=New FcLocalExtension().invokeMethod('getFormsDet', inputtMap, outtMap, new Map<String, Object>());
        	System.assertEquals(value, true);
            
            
            Test.stopTest();
        }
    }
}