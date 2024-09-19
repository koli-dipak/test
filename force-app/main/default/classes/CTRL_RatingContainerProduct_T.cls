@isTest
public class CTRL_RatingContainerProduct_T {
    public static User admin_User;
    public static Integer count = 1;
    public static string SYSTEM_ADMINISTRATOR_PROFILE = 'System Administrator';
    public static List<Opportunity> Opp = new List<Opportunity>();
    public static List<Quote> quote = new List<Quote>();
    public static List<QuoteLineItem> quoteLineItem = new List<QuoteLineItem>();
    public static List<Product2> product = new List<Product2>();
    public static List<Account> acc = new List<Account>();
    
    static void proccesRecordDataForRatingContainerProduct()
    {
        admin_User = TestDataFactory.createUser(true,'Opportunity',SYSTEM_ADMINISTRATOR_PROFILE);
        insert admin_User;
        System.runAs(admin_User)
        {
            Map<String,Object>  Accountobj = new Map<String,Object>();
            Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
            Id insuredItemSpecRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('InsuredItemSpec').getRecordTypeId();
            Id coverageSpecRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('CoverageSpec').getRecordTypeId();
            Accountobj.put('RecordTypeId',RecordTypeId);
        	Accountobj.put('Name','NewAcco');
            Accountobj.put('Box_Folder_Name__c','test');
          	for(Integer i = 0 ; i <count; i++)
            {
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
            }
            
            Map<String,Object>  Opportunityobj = new Map<String,Object>();
            Opportunityobj.put('Name','test');
            Opportunityobj.put('CloseDate',System.today());
            Opportunityobj.put('StageName','Interest');
            Opportunityobj.put('AccountId',acc[0].Id);
            Opportunityobj.put('Line_of_Business__c','Commercial Umbrella;Ocean Marine');
            for(Integer i = 0 ; i <count; i++)
            {
                Opp.add((Opportunity) TestDataFactory.operationOnObjectRec('insert', 'Opportunity', Opportunityobj));
            }
            
            Map<String,Object> quoteObj = new Map<String,Object>();
            quoteObj.put('Name','test Quote');
            quoteObj.put('ExpirationDate', Date.today().addDays(30));
            quoteObj.put('Status','Interest');
            quoteObj.put('OpportunityId', Opp[0].Id);
            quoteObj.put('Pricebook2Id', Test.getStandardPricebookId());
            for(Integer i = 0 ; i <count; i++)
            {
                quote.add((Quote) TestDataFactory.operationOnObjectRec('insert', 'Quote', quoteObj));
            }
            
            Map<String,Object> productObj = new Map<String,Object>();
            productObj.put('Name','test Product');
            for(Integer i = 0 ; i < 6; i++)
            {
                product.add((Product2) TestDataFactory.operationOnObjectRec('', 'Product2', productObj));
            }
            product[2].RecordTypeId = insuredItemSpecRecordTypeId;
            product[3].RecordTypeId = coverageSpecRecordTypeId;
            product[4].RecordTypeId = insuredItemSpecRecordTypeId;
            product[5].RecordTypeId = coverageSpecRecordTypeId;
            Insert product;
            
            List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
            for(Integer i = 0 ; i < 6; i++)
            {
                Map<String,Object> priceBookEntryObj = new Map<String,Object>();
                priceBookEntryObj.put('Pricebook2Id', Test.getStandardPricebookId());
                priceBookEntryObj.put('Product2Id', product[i].Id);
                priceBookEntryObj.put('IsActive', true);
                priceBookEntryObj.put('UnitPrice', 150);
                PricebookEntry pbeRec = (PricebookEntry) TestDataFactory.operationOnObjectRec('', 'PricebookEntry', priceBookEntryObj);
                pricebookEntryList.add(pbeRec);
            }
            Insert pricebookEntryList;

            for(Integer i = 0 ; i < 6; i++)
            {
                Map<String,Object> quoteLineObj = new Map<String,Object>();
                quoteLineObj.put('PricebookEntryId', pricebookEntryList[i].Id);
                quoteLineObj.put('UnitPrice', 150);
                quoteLineObj.put('Quantity', 1);
                quoteLineObj.put('QuoteId', quote[0].Id);
                quoteLineItem.add((QuoteLineItem) TestDataFactory.operationOnObjectRec('', 'QuoteLineItem', quoteLineObj));
            }

            Insert quoteLineItem;

            quoteLineItem[2].vlocity_ins__ParentItemId2__c = quoteLineItem[0].Id;
            quoteLineItem[3].vlocity_ins__ParentItemId2__c = quoteLineItem[0].Id;
            quoteLineItem[4].vlocity_ins__ParentItemId2__c = quoteLineItem[1].Id;
            quoteLineItem[5].vlocity_ins__ParentItemId2__c = quoteLineItem[1].Id;
            Update quoteLineItem;

            Map<String,Object> attributCategoryObj = new Map<String,Object>();
            attributCategoryObj.put('Name', 'testCategoryName');
            attributCategoryObj.put('vlocity_ins__DisplaySequence__c', 1);
            vlocity_ins__AttributeCategory__c attributeCategoryAssignmentRec = (vlocity_ins__AttributeCategory__c) TestDataFactory.operationOnObjectRec('Insert', 'vlocity_ins__AttributeCategory__c', attributCategoryObj);
            
            List<vlocity_ins__AttributeAssignment__c> attributeAssignmentList = new List<vlocity_ins__AttributeAssignment__c>();
            for(Integer i = 0 ; i < 6; i++)
            {
                Map<String,Object> attributeAssignmentObj = new Map<String,Object>();
                attributeAssignmentObj.put('vlocity_ins__ObjectId__c', product[i].Id);
                attributeAssignmentObj.put('vlocity_ins__AttributeCategoryId__c', attributeCategoryAssignmentRec.Id);
                vlocity_ins__AttributeAssignment__c attributeAssignmentRec = (vlocity_ins__AttributeAssignment__c) TestDataFactory.operationOnObjectRec('', 'vlocity_ins__AttributeAssignment__c', attributeAssignmentObj);
                attributeAssignmentList.add(attributeAssignmentRec);
                
                attributeAssignmentRec = (vlocity_ins__AttributeAssignment__c) TestDataFactory.operationOnObjectRec('', 'vlocity_ins__AttributeAssignment__c', attributeAssignmentObj);
                attributeAssignmentList.add(attributeAssignmentRec);
            }
            Insert attributeAssignmentList;

            List<vlocity_ins__ProductChildItem__c> productChildItemList = new List<vlocity_ins__ProductChildItem__c>();
            for(Integer i = 2; i < 6; i++)
            {
                Map<String,Object> productChildItemObj = new Map<String,Object>();
                productChildItemObj.put('vlocity_ins__ParentProductId__c', product[Math.mod(i, 2)].Id);
                productChildItemObj.put('vlocity_ins__ChildProductId__c', product[i].Id);
                productChildItemObj.put('vlocity_ins__ChildLineNumber__c', String.valueOf(i));
                
                vlocity_ins__ProductChildItem__c productChildItemRec = (vlocity_ins__ProductChildItem__c) TestDataFactory.operationOnObjectRec('', 'vlocity_ins__ProductChildItem__c', productChildItemObj);
                productChildItemList.add(productChildItemRec);
                productChildItemRec = (vlocity_ins__ProductChildItem__c) TestDataFactory.operationOnObjectRec('', 'vlocity_ins__ProductChildItem__c', productChildItemObj);
                productChildItemList.add(productChildItemRec);
            }
            Insert productChildItemList;
         }
    }
    
    @isTest
    static void ratingContainerTestMethod() 
    {
        proccesRecordDataForRatingContainerProduct();
        
        Test.startTest();
        CTRL_RatingContainerProduct.quoteLineItem(quote[0].Id);
        Test.stopTest();
    }
    
    @isTest
    static void attributeFieldUpdateQLITestMethod1() 
    {
        proccesRecordDataForRatingContainerProduct();
        
        Test.startTest();
        CTRL_RatingContainerProduct.productAttributeUpdateQuoteLineItemRecord(quoteLineItem[0].Id, '{"testAttribute": "testData"}');
        CTRL_RatingContainerProduct.updateQuoteLineItemWithSubSectionData(quoteLineItem[0].Id, '{"testAttribute": "testData"}', 'Subjectivities__c');
        Test.stopTest();
    }
    
    @isTest
    static void cloneQLITestMethod() 
    {
        proccesRecordDataForRatingContainerProduct();
        
        Test.startTest();
        CTRL_RatingContainerProduct.cloneQuoteLine(quoteLineItem[0].Id);
        Test.stopTest();
    }
    
    @isTest
    static void deleteQLITestMethod() 
    {
        proccesRecordDataForRatingContainerProduct();
        
        Test.startTest();
        CTRL_RatingContainerProduct.deleteQuoteLine(quoteLineItem[0].Id);
        Test.stopTest();
    }
    
    @isTest
    static void getRatingContainerConfigs_T() 
    {
        
        Test.startTest();
        CTRL_RatingContainerProduct.getRatingContainerConfigs();
        Test.stopTest();
    }
    
}