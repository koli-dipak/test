@isTest
public class DecisionTableClass_T {
    public static User admin_User;
    public static Integer count =1;
    public static string SYSTEM_ADMINISTRATOR_PROFILE ='System Administrator';
    public static List<Opportunity> Opp = new List<Opportunity>();
    public static List<Account> acc = new List<Account>();
    public static List<LOB_Management__c> LOBManagement = new List<LOB_Management__c>();
    public static List<Quote> QuoteobjList = new List<Quote>();
    public static List<QuoteLineItem> QuoteLineList = new List<QuoteLineItem>();
    public static List<Pricebook2> pricebooklist = new List<Pricebook2>();
    public static List<Product2> Product2list = new List<Product2>();
    public static List<PricebookEntry> pricebookEntrylist = new List<PricebookEntry>();
     @IsTest(SeeAllData=true)
     public static void testDecisionTableInput(){
        User admin_User = TestDataFactory.createUser(true, '','System Administrator');
        System.runAs(admin_User){
             Map<String,Object>  Accountobj = new Map<String,Object>();
            Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
            Accountobj.put('RecordTypeId',RecordTypeId);
            //Accountobj.put('Name','TI Sparkle Americas, Inc., TI Sparkle S. Croix, TI Sparkle (GER Program - Telecom Italia');
            Accountobj.put('Name','Test Account');
            Accountobj.put('Box_Folder_Name__c','test');
            for(Integer i = 0 ; i <count; i++)
            {
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
            }
            
            Map<String, Object> pricebookobj = new Map<String, Object>();
            pricebookobj.put('Name', 'Standard Price Book');
            pricebookobj.put('IsActive', true);
            pricebookobj.put('vlocity_ins__IsDefault__c', false);
            for(Integer i = 0 ; i <count; i++)
            {
                pricebooklist.add((Pricebook2) TestDataFactory.operationOnObjectRec('insert', 'Pricebook2', pricebookobj));
            }
            
            Map<String,Object>  Opportunityobj = new Map<String,Object>();
            Opportunityobj.put('Name','test');
            Opportunityobj.put('CloseDate',System.today());
            Opportunityobj.put('StageName','Interest');
            Opportunityobj.put('Type','New');
            Opportunityobj.put('AccountId',acc[0].Id);
            Opportunityobj.put('Line_of_Business__c','Commercial Umbrella');
            Opportunityobj.put('Pricebook2Id', pricebooklist[pricebooklist.size()-1].Id);
            for(Integer i = 0 ; i <count; i++)
            {
                Opp.add((Opportunity) TestDataFactory.operationOnObjectRec('insert', 'Opportunity', Opportunityobj));
            }
            
            Map<String,Object>  Quoteobj = new Map<String,Object>(); 
            Quoteobj.put('Name',acc[0].Name);
            Quoteobj.put('OpportunityId',Opp[0].Id);
            quoteObj.put('Pricebook2Id', Test.getStandardPricebookId());
            for(Integer i = 0 ; i <count; i++)
            {
                QuoteobjList.add((Quote)TestDataFactory.operationOnObjectRec('insert', 'Quote', Quoteobj));
            }
            Map<String, Object> productObj = new Map<String, Object>();
            productObj.put('Name', 'test Product');
            List<Product2> product = new List<Product2>();

            for (Integer i = 0; i < count; i++) {
                product.add((Product2) TestDataFactory.operationOnObjectRec('insert', 'Product2', productObj));
            }

            Map<String, Object> priceBookEntryObj = new Map<String, Object>();
            priceBookEntryObj.put('Pricebook2Id', Test.getStandardPricebookId());
            priceBookEntryObj.put('Product2Id', product[0].Id);
            priceBookEntryObj.put('IsActive', true);
            priceBookEntryObj.put('UnitPrice', 150);

            PricebookEntry pbeRec = (PricebookEntry) TestDataFactory.operationOnObjectRec('insert', 'PricebookEntry', priceBookEntryObj);

            Map<String, Object> quoteLineObj = new Map<String, Object>();
            quoteLineObj.put('PricebookEntryId', pbeRec.Id);
            quoteLineObj.put('UnitPrice', 150);
            quoteLineObj.put('Quantity', 1);
            quoteLineObj.put('QuoteId', QuoteobjList[0].Id);
            List<QuoteLineItem> quoteLineItem = new List<QuoteLineItem>();
            for (Integer i = 0; i < 5; i++) {
                quoteLineItem.add((QuoteLineItem) TestDataFactory.operationOnObjectRec('insert', 'QuoteLineItem', quoteLineObj));
            }
            
            
            
            Test.startTest();
            Map<string, Object> inputMapData = new Map<string, Object>();
            Map<string, Object> outputMapData = new Map<string, Object>();
            //String jsonString = '[{"AuStates":["MA","MA","NJ"],"Coverage":"TestData","FCCountry":"","PayPlan":"Annual","ProductName1":"AU","QuoteLineItemId":"0QLEa0000002QJNOA2","States":"All","WCStates":"","LobType":"New","isAlreadyDocumentChecklistItem":false, "DeregulationApplies":false}]';
            //String jsonString = '[{"AuStates":["MA","MA","NJ"],"Coverage":[{"ProductCode":"UMUIM","ApplicationJSON":{"CAULIMITS":"Scheduled","CAUDEDUCTIBLE":"Not Applicable","CAUSYMBOL":"2"}},{"ProductCode":"SCL","ApplicationJSON":{"CAULIMITS":"Lesser of Actual Cash Value, Cost of Repair or Stated Amount"}},{"ProductCode":"proIns"},{"ProductCode":"PIP","ApplicationJSON":{"CAULIMITS":"Scheduled","CAUDEDUCTIBLE":"Scheduled","CAUSYMBOL":"5"}},{"ProductCode":"pdtl","ApplicationJSON":{"CAULIMITS":"$                   For Each Disablement of a Private Passenger Auto"}},{"ProductCode":"meaIl"},{"ProductCode":"LPD"},{"ProductCode":"lBI"},{"ProductCode":"lcsl","ApplicationJSON":{"CAULIMITS":"$1,000,000","CAUDEDUCTIBLE":"Not Applicable","CAUSYMBOL":"7,8,9"}},{"ProductCode":"comprehensive","ApplicationJSON":{"CAULIMITS":"Lesser of Actual Cash Value, Cost of Repair or Stated Amount","CAUDEDUCTIBLE":"$1,000","CAUSYMBOL":"7,8"}},{"ProductCode":"COL","ApplicationJSON":{"CAULIMITS":"Lesser of Actual Cash Value, Cost of Repair or Stated Amount","CAUDEDUCTIBLE":"$1,000","CAUSYMBOL":"7,8"}},{"ProductCode":"AMP"},{"ProductCode":"AddPIP"}],"FCCountry":"","PayPlan":"Annual","ProductName1":"AU","QuoteLineItemId":"0QLEa0000005k0bOAA","States":"All","WCStates":"","LobType":"Renewal","isAlreadyDocumentChecklistItem":false,"InsuredState":"","DeregulationApplies":"","DeregulationClass":"","LCSL_Symbol":"","FCCoverages":"","FCLocType":""}]';
          //  String jsonString = '[{"AuStates":["MA","MA","NJ"],"Coverage":[{"ProductCode":"LPD"},{"ProductCode":"lBI"},{"ProductCode":"lcsl","ApplicationJSON":{"CAULIMITS":"$1,000,000","CAUDEDUCTIBLE":"Not Applicable","CAUSYMBOL":"8,9"}}],"FCCountry":"","PayPlan":"Annual","ProductName1":"AU","QuoteLineItemId":"'+quoteLineItem[0].Id+'","States":"All","WCStates":"","LobType":"Renewal","isAlreadyDocumentChecklistItem":false,"InsuredState":"","DeregulationApplies":true,"DeregulationClass":2,"LCSL_Symbol":"","FCCoverages":"","FCLocType":""},{"AuStates":"","FCCountry":"","PayPlan":"Annual","ProductName1":"GL","QuoteLineItemId":"'+quoteLineItem[1].Id+'","States":"All","WCStates":"","LobType":"New","isAlreadyDocumentChecklistItem":false,"InsuredState":"NJ","DeregulationApplies":true,"DeregulationClass":2,"LCSL_Symbol":"","FCCoverages":"","FCLocType":""},{"AuStates":"","FCCountry":"","PayPlan":"Annual","ProductName1":"UMB","QuoteLineItemId":"'+quoteLineItem[2].Id+'","States":"All","WCStates":"","LobType":"New","isAlreadyDocumentChecklistItem":false,"InsuredState":"VA","DeregulationApplies":false,"DeregulationClass":"","LCSL_Symbol":"","FCCoverages":"","FCLocType":""},{"AuStates":"","Coverage":[{"ProductCode":"FCTA","ApplicationJSON":{"FCTATC":"500","FCTATI":"500","FCTATD":"500","FCTABD":"250","FCTALDB":"250","FCTAJWE":"100","FCTAPTAS":"100","FCTAPP":"10000","FCTRPEXPBSC":"TRIPS"}},{"ProductCode":"FCKR","ApplicationJSON":{"FCBADDP":"50000","FCBDEI":"Included","FCBC":"10000","FCBCCF":"3000","FCBCEG":"5000","FCBCC":"25000","FCBCV":"5000","FCBCOUN":"1000","FCBFA":"3000","FCBHAPA":"10000","FCBHAVM":"10000","FCBR":"5000","FCBSD":"3000","FCBVSC":"10000","FCBBD":"5000","FCBIHI":"5000","FCBMESA":"5000","FCBMESI":"1000","FCBDED":"1000","FCBSB":"5000","FCBCRLRC":"300","FCBPC":"250","FCBMPC":"180","FCEHG":"1000","FCKREXPBSC":"TRIPS","FCBALI":"1000000"}},{"ProductCode":"FVWC","ApplicationJSON":{"FCThirdCoun":"Country of Hire","FCLclCoun":"Country of Hire","FCLOCNT":"Country of Hire","FCCANEMP":"Province of Hire","FCTHCON":"Country of Hire","FCUSEMP":"State of Hire","FCINBYDES":"1000000","FCCOVPOlLIM":"1000000","FCINJACC":"1000000"}},{"ProductCode":"FCGL","ApplicationJSON":{"phFCCovMstrProAgr":"8000000","phFCCovGenAgr":"4000000","phFCCovGnLi":"2000000","phFCCovProComOpr":"4000000","phFCCovPerAdvInj":"2000000","phFCCovDmgPremisis":"1000000","phFCCovMedPay":"50000","phFCTriggergl":"Occurrence","phFCEpmBenLiab":"1000000","phFCEpmBenLiabae":"1000000","phFCEpmBenLiabdeduae":"1000","phFCRetDtgl":"03/01/2024","FCGLEXPAMT":"1229274000.00","FCBDED":"1000"}},{"ProductCode":"FCCA","ApplicationJSON":{"OPPAL":true,"OWL":"true","NOAHAL":"true","phFCOPPAC":"false","phFCOWC":"false","phFCNOHAC":"true","phFCOPPACL":"false","phFCOWCL":"false","phFCNOHACL":"true","phFCOPPASCL":"false","phFCOWSCL":"false","phFCNWHASCL":"false","phFCCovALib":"1000000","phFCCovBMedExp":"50000","phFCCovCPhyDmgCov":"50000","phFCTow":"100","phFCNAHACDEDU":"false","FCOPvAU":true,"FCNOHAuComp":"500","FCNOHAuColl":"500"}},{"ProductCode":"FCSE","ApplicationJSON":{"FCME":"1000000","FCMR":"Included in Evacuation","FCNMR":"Included in Evacuation","FCROR":"10000","FCHV":"5000","FCROC":"5000","FCROCM":"5000","FCALL":"1000000","FCECAF":"1000","FCECLE":"1000","FCECCT":"1000","FCECPPAL":"5000","FCECT":"2500","FCECPE":"2500","FCECKRE":"250000","FCECKREE":"250000","FCECDH":"250000","FCECITC":"250000","FCECDD":"250000","FCECCRF":"250000","FCECCRFSE":"Unity/On-call","FCECLC":"250000","FCECAA":"250000","FCECRETAMT":"0","FCEACExpBsc":"TRIPS","FCECD":"250","FCECALI":"5000","FCECLDIDTE":"1000","FCECITS":"1000"}}],"FCCountry":["IRELAND","FRANCE","BRAZIL","ARGENTINA","COLOMBIA","GERMANY","UNITED KINGDOM","UNITED KINGDOM","DENMARK","ITALY","SPAIN","SERBIA","SINGAPORE","AUSTRALIA","CHINA","INDIA","KOREA (SOUTH)"],"PayPlan":"Annual","ProductName1":"FC","QuoteLineItemId":"'+quoteLineItem[3].Id+'","States":"All","WCStates":"","LobType":"New","isAlreadyDocumentChecklistItem":false,"InsuredState":"","DeregulationApplies":"","DeregulationClass":"","LCSL_Symbol":"","FCCoverages":[{"Type":"GL","isSelected":true},{"Type":"Auto","isSelected":true},{"Type":"FVWC","isSelected":true},{"Type":"EA","isSelected":true},{"Type":"BTA","isSelected":true},{"Type":"Trip","isSelected":true}],"FCLocType":["GL","GL","GL","GL","GL","GL","GL","EL","GL","GL","GL","GL","GL","GL","GL","GL","GL"]},{"AuStates":"","FCCountry":"","PayPlan":"Annual","ProductName1":"WC","QuoteLineItemId":"'+quoteLineItem[4].Id+'","States":"","WCStates":"AL,CA,CO,CT,DC,FL,GA,ID,IL,KY,LA,MA,MD,MI,MN,NC,NJ,NY,PA,TX,VA,WI","LobType":"New","isAlreadyDocumentChecklistItem":false,"InsuredState":"","DeregulationApplies":"","DeregulationClass":"","LCSL_Symbol":"","FCCoverages":"","FCLocType":""}]';
              String jsonString = '[{"AuStates":["MA","MA","NJ"],"Coverage":[{"ProductCode":"UMUIM","ApplicationJSON":{"CAULIMITS":"Scheduled","CAUDEDUCTIBLE":"Not Applicable","CAUSYMBOL":"2"}},{"ProductCode":"SCL","ApplicationJSON":{"CAULIMITS":"Lesser of Actual Cash Value, Cost of Repair or Stated Amount"}},{"ProductCode":"proIns"},{"ProductCode":"PIP","ApplicationJSON":{"CAULIMITS":"Scheduled","CAUDEDUCTIBLE":"Scheduled","CAUSYMBOL":"5"}},{"ProductCode":"pdtl","ApplicationJSON":{"CAULIMITS":"$                   For Each Disablement of a Private Passenger Auto"}},{"ProductCode":"meaIl"},{"ProductCode":"LPD"},{"ProductCode":"lBI"},{"ProductCode":"lcsl","ApplicationJSON":{"CAULIMITS":"$1,000,000","CAUDEDUCTIBLE":"Not Applicable","CAUSYMBOL":"7,8,9"}},{"ProductCode":"comprehensive","ApplicationJSON":{"CAULIMITS":"Lesser of Actual Cash Value, Cost of Repair or Stated Amount","CAUDEDUCTIBLE":"$1,000","CAUSYMBOL":"7,8"}},{"ProductCode":"COL","ApplicationJSON":{"CAULIMITS":"Lesser of Actual Cash Value, Cost of Repair or Stated Amount","CAUDEDUCTIBLE":"$1,000","CAUSYMBOL":"7,8"}},{"ProductCode":"AMP"},{"ProductCode":"AddPIP"}],"FCCountry":"","PayPlan":"Annual","ProductName1":"AU","QuoteLineItemId":"'+quoteLineItem[0].Id+'","States":"All","WCStates":"","LobType":"","isAlreadyDocumentChecklistItem":false,"InsuredState":"","DeregulationApplies":"","DeregulationClass":"","LCSL_Symbol":"","FCCoverages":"","FCLocType":"","wcDivindentPlancheckbox":"","checkValueGratherThan100k":true},{"AuStates":["IL","OR","TX","NM","NY","IA","NC","MS","NJ","FL"],"Coverage":[{"ProductCode":"UMUIM","ApplicationJSON":{"CAULIMITS":"Scheduled","CAUDEDUCTIBLE":"Not Applicable","CAUSYMBOL":"1"}},{"ProductCode":"SCL","ApplicationJSON":{"CAULIMITS":"Lesser of Actual Cash Value, Cost of Repair or Stated Amount"}},{"ProductCode":"proIns"},{"ProductCode":"PIP","ApplicationJSON":{"CAULIMITS":"Scheduled","CAUDEDUCTIBLE":"Scheduled","CAUSYMBOL":"1"}},{"ProductCode":"pdtl"},{"ProductCode":"meaIl"},{"ProductCode":"LPD"},{"ProductCode":"lBI"},{"ProductCode":"lcsl","ApplicationJSON":{"CAULIMITS":"$1,000,000","CAUDEDUCTIBLE":"Not Applicable","CAUSYMBOL":"1"}},{"ProductCode":"comprehensive","ApplicationJSON":{"CAULIMITS":"Lesser of Actual Cash Value, Cost of Repair or Stated Amount","CAUDEDUCTIBLE":"See Schedule","CAUSYMBOL":"1,8,9"}},{"ProductCode":"COL","ApplicationJSON":{"CAULIMITS":"Lesser of Actual Cash Value, Cost of Repair or Stated Amount","CAUDEDUCTIBLE":"See Schedule","CAUSYMBOL":"1,8,9"}},{"ProductCode":"AMP","ApplicationJSON":{"CAULIMITS":"See Schedule","CAUDEDUCTIBLE":"Not Applicable","CAUSYMBOL":"1"}},{"ProductCode":"AddPIP"}],"FCCountry":"","PayPlan":"Annual","ProductName1":"AU","QuoteLineItemId":"'+quoteLineItem[0].Id+'","States":"All","WCStates":"","LobType":"","isAlreadyDocumentChecklistItem":false,"InsuredState":"IL","DeregulationApplies":false,"DeregulationClass":"","LCSL_Symbol":"","FCCoverages":"","FCLocType":"","wcDivindentPlancheckbox":"","checkValueGratherThan100k":""},{"AuStates":"","Coverage":[{"ProductCode":"covum","ApplicationJSON":{"AggregateLimit":"$2,000,000"}},{"ProductCode":"covcpa","ApplicationJSON":{"AnyOnePersonorOrganization":"$1,000,000"}},{"ProductCode":"covcmp","ApplicationJSON":{"AnyOnePerson":"$5,000"}},{"ProductCode":"covcgl","ApplicationJSON":{"EachOccurrence":"$1,000,000"}},{"ProductCode":"covcga","ApplicationJSON":{"AggregateLimit":"$2,000,000"}},{"ProductCode":"EMPBEN","ApplicationJSON":{"AggregateLimit":1000000,"EachOccurrence":"1000000","IsCoverageIncluded":"True","GLEblAll":"$1,000"}},{"ProductCode":"covcgldpry","ApplicationJSON":{"AnyOnePremises":"$100,000"}}],"FCCountry":"","PayPlan":"Annual","ProductName1":"GL","QuoteLineItemId":"'+quoteLineItem[0].Id+'","States":"All","WCStates":"","LobType":"","isAlreadyDocumentChecklistItem":false,"InsuredState":"NJ","DeregulationApplies":false,"DeregulationClass":"","LCSL_Symbol":"","FCCoverages":"","FCLocType":"","wcDivindentPlancheckbox":"","checkValueGratherThan100k":true},{"AuStates":"","Coverage":[{"ProductCode":"covum","ApplicationJSON":{"AggregateLimit":"$2,000,000"}},{"ProductCode":"covcpa","ApplicationJSON":{"AnyOnePersonorOrganization":"$1,000,000"}},{"ProductCode":"covcmp","ApplicationJSON":{"AnyOnePerson":"$10,000"}},{"ProductCode":"covcgl","ApplicationJSON":{"EachOccurrence":"$1,000,000"}},{"ProductCode":"covcga","ApplicationJSON":{"AggregateLimit":"$2,000,000"}},{"ProductCode":"EMPBEN","ApplicationJSON":{"AggregateLimit":1000000,"EachOccurrence":"1000000","Trigger":"Claims made","RETROACTIVEDATE":"01/01/2016","IsCoverageIncluded":"True","GLEblAll":"$1,000"}},{"ProductCode":"covcgldpry","ApplicationJSON":{"AnyOnePremises":"$100,000"}}],"FCCountry":"","PayPlan":"Annual","ProductName1":"GL","QuoteLineItemId":"'+quoteLineItem[0].Id+'","States":"All","WCStates":"","LobType":"","isAlreadyDocumentChecklistItem":false,"InsuredState":"NY","DeregulationApplies":true,"DeregulationClass":"2","LCSL_Symbol":"","FCCoverages":"","FCLocType":"","wcDivindentPlancheckbox":"","checkValueGratherThan100k":""},{"AuStates":"","Coverage":[{"ProductCode":"covcpa","ApplicationJSON":{"AnyOnePersonorOrganization":"Exclude"}},{"ProductCode":"covcga","ApplicationJSON":{"AggregateLimit":"5000000"}},{"ProductCode":"covumb","ApplicationJSON":{"EachOccLmtCur":"5000000"}}],"FCCountry":"","PayPlan":"Annual","ProductName1":"UMB","QuoteLineItemId":"'+quoteLineItem[0].Id+'","States":"All","WCStates":"","LobType":"","isAlreadyDocumentChecklistItem":false,"InsuredState":"VA","DeregulationApplies":true,"DeregulationClass":"","LCSL_Symbol":"","FCCoverages":"","FCLocType":"","wcDivindentPlancheckbox":"","checkValueGratherThan100k":""},{"AuStates":"","Coverage":[{"ProductCode":"wc_covC","ApplicationJSON":{"AllStates":"No","isWkOtherStatesInsuranceAvaliable":true,"StatLmt":"AK, AR, AZ, DE, HI, IA, IN, KS, ME, MO, MS, MT, NE, NH, NM, NV, OK, OR, RI, SC, SD, TN, UT, VT, WV"}},{"ProductCode":"wc_covB","ApplicationJSON":{"BodyInjAccLmt":"1000000","BodyInjDeseaseLmt":"1000000","BodyInjDeseasePolLmt":"1000000"}},{"ProductCode":"wc_covA","ApplicationJSON":{"StatLmt":"AL, CA, CO, CT, DC, FL, GA, ID, IL, KY, LA, MA, MD, MI, MN, NC, NJ, NY, PA, TX, VA, WI"}}],"FCCountry":"","PayPlan":"Annual","ProductName1":"WC","QuoteLineItemId":"'+quoteLineItem[0].Id+'","States":"","WCStates":"AL, CA, CO, CT, DC, FL, GA, ID, IL, KY, LA, MA, MD, MI, MN, NC, NJ, NY, PA, TX, VA, WI","LobType":"","isAlreadyDocumentChecklistItem":false,"InsuredState":"","checkValueGratherThan100k":true,"DeregulationApplies":"","DeregulationClass":"","LCSL_Symbol":"","FCCoverages":"","FCLocType":"","wcDivindentPlancheckbox":true}]';
            System.debug('JSON String: ' + jsonString);
            //Map<String, Object> ChecklistProductMap = (Map<String, Object>)json.deserializeuntyped(jsonString);
            List<Object> ChecklistProductMap = (List<Object>)json.deserializeuntyped(jsonString);
            String QuoteId = QuoteobjList[0].Id;
            inputMapData.put('ContextId', QuoteId);
            inputMapData.put('ChecklistProductCodeList', ChecklistProductMap);
            
            DecisionTableClass.DecisionTableInput(inputMapData, outputMapData);
            //check exit doucmentchecklist item on quote
            //List<DocumentChecklistItem> DocumentChecklistIdList = [Select Id, Generate_Quote_and_Binder__c, Quote_Line_Item__c from DocumentChecklistItem where Generate_Quote_and_Binder__c =: QuoteId ];
            
            Boolean value=New DecisionTableClass().invokeMethod('DecisionTableInput', inputMapData, new Map<String, Object>(), new Map<String, Object>());
            System.assertEquals(value, true);
            Test.stopTest();
        }
    }
}