@isTest
public class DocumentChecklistControlle_T {
    public static User admin_User;
    public static Integer count = 1;
    public static string SYSTEM_ADMINISTRATOR_PROFILE = 'System Administrator';
    public static List<Opportunity> Opp = new List<Opportunity>();
    public static List<Quote> quote = new List<Quote>();
    public static List<QuoteLineItem> quoteLineItem = new List<QuoteLineItem>();
    public static List<QuoteLineItem_Reference__c> quotelinereference = new List<QuoteLineItem_Reference__c>();
    public static List<DocumentChecklistItem> documentChecklistItem = new List<DocumentChecklistItem>();
    public static List<Task> taskList = new List<Task>();
    public static List<Product2> product = new List<Product2>();
    public static List<Account> acc = new List<Account>();
    
    public static void proccesRecordDataForDCI(String PROFILE){
        admin_User = TestDataFactory.createUser(true, 'Opportunity', PROFILE);
        insert admin_User;
        
        System.runAs(admin_User){
            Map<String, Object> Accountobj = new Map<String, Object>();
            Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insured').getRecordTypeId();
            Accountobj.put('RecordTypeId', RecordTypeId);
            Accountobj.put('Name', 'NewAcco');
            Accountobj.put('Box_Folder_Name__c', 'test');

            for (Integer i = 0; i < count; i++) {
                acc.add((Account) TestDataFactory.operationOnObjectRec('insert', 'Account', Accountobj));
            }

            Map<String, Object> Opportunityobj = new Map<String, Object>();
            Opportunityobj.put('Name', 'test');
            Opportunityobj.put('CloseDate', System.today());
            Opportunityobj.put('StageName', 'Interest');
            Opportunityobj.put('AccountId', acc[0].Id);
            Opportunityobj.put('Line_of_Business__c', 'Commercial Umbrella;Ocean Marine');

            for (Integer i = 0; i < count; i++) {
                Opp.add((Opportunity) TestDataFactory.operationOnObjectRec('insert', 'Opportunity', Opportunityobj));
            }

            Map<String, Object> quoteObj = new Map<String, Object>();
            quoteObj.put('Name', 'test Quote');
            quoteObj.put('ExpirationDate', Date.today().addDays(30));
            quoteObj.put('Status', 'Interest');
            quoteObj.put('OpportunityId', Opp[0].Id);
            quoteObj.put('Pricebook2Id', Test.getStandardPricebookId());

            for (Integer i = 0; i < count; i++) {
                quote.add((Quote) TestDataFactory.operationOnObjectRec('insert', 'Quote', quoteObj));
            }
            Map<String, Object> productObj = new Map<String, Object>();
            productObj.put('Name', 'test Product');

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
            quoteLineObj.put('QuoteId', quote[0].Id);

            for (Integer i = 0; i < count; i++) {
                quoteLineItem.add((QuoteLineItem) TestDataFactory.operationOnObjectRec('insert', 'QuoteLineItem', quoteLineObj));
            }
            
            Map<String, Object> quotelinereferenceObj = new Map<String, Object>();
            quotelinereferenceObj.put('Quote_Line_Item__c', quoteLineItem[0].Id);

            for (Integer i = 0; i < count; i++) {
                quotelinereference.add((QuoteLineItem_Reference__c) TestDataFactory.operationOnObjectRec('insert', 'QuoteLineItem_Reference__c', quotelinereferenceObj));
            }
            
            
            Map<String, Object> documentChecklistItemObj = new Map<String, Object>();
            documentChecklistItemObj.put('Quote_Line_Item__c', quote[0].Id);
            documentChecklistItemObj.put('Generate_Quote_and_Binder__c', quote[0].Id);
            documentChecklistItemObj.put('Quote_Line_Item__c', quoteLineItem[0].Id);
            documentChecklistItemObj.put('ParentRecordId', quotelinereference[0].Id);
            documentChecklistItemObj.put('IsRequired', false);
            documentChecklistItemObj.put('Name', 'Workers Compensation | ALL | Insured risk engineering');
            documentChecklistItemObj.put('Status', 'Pending Collection');

            for (Integer i = 0; i < count; i++) {
                documentChecklistItem.add((DocumentChecklistItem) TestDataFactory.operationOnObjectRec('insert', 'DocumentChecklistItem', documentChecklistItemObj));
            }
            
            Map<String, Object> quotedChecklistItemObj = new Map<String, Object>();
        quotedChecklistItemObj.put('Quote_Line_Item__c', quoteLineItem[0].Id);
        quotedChecklistItemObj.put('ParentRecordId', quotelinereference[0].Id);
        quotedChecklistItemObj.put('Quote_Line_Item__c', quoteLineItem[0].Id);
        quotedChecklistItemObj.put('Generate_Quote_and_Binder__c', quote[0].Id);
        quotedChecklistItemObj.put('IsRequired', false);
        quotedChecklistItemObj.put('Name', 'Quoted Checklist Item');
        quotedChecklistItemObj.put('Status', 'Pending Collection');
        //quotedChecklistItemObj.put('Quote_Line_Item__r.Stage__c', 'Quoted');
             for (Integer i = 0; i < count; i++) {
                documentChecklistItem.add((DocumentChecklistItem) TestDataFactory.operationOnObjectRec('insert', 'DocumentChecklistItem', quotedChecklistItemObj));
            }
            
        Map<String, Object> binderChecklistItemObj = new Map<String, Object>();
        binderChecklistItemObj.put('Quote_Line_Item__c', quoteLineItem[0].Id);
        binderChecklistItemObj.put('ParentRecordId', quotelinereference[0].Id);
        binderChecklistItemObj.put('Generate_Quote_and_Binder__c', quote[0].Id);
        binderChecklistItemObj.put('Quote_Line_Item__c', quoteLineItem[0].Id);
        binderChecklistItemObj.put('IsRequired', false);
        binderChecklistItemObj.put('Name', 'Binder Checklist Item');
        binderChecklistItemObj.put('Status', 'Pending Collection');
        binderChecklistItemObj.put('Type__c', 'Checklist');
         
            for (Integer i = 0; i < count; i++) {
                documentChecklistItem.add((DocumentChecklistItem) TestDataFactory.operationOnObjectRec('insert', 'DocumentChecklistItem', binderChecklistItemObj));
            }
            
        Map<String, Object> relatedBinderChecklistItemObj = new Map<String, Object>();
        relatedBinderChecklistItemObj.put('Quote_Line_Item__c', quoteLineItem[0].Id);
        relatedBinderChecklistItemObj.put('ParentRecordId', quotelinereference[0].Id);
        relatedBinderChecklistItemObj.put('Generate_Quote_and_Binder__c', quote[0].Id);
        relatedBinderChecklistItemObj.put('Quote_Line_Item__c', quoteLineItem[0].Id);
        relatedBinderChecklistItemObj.put('IsRequired', false);
        relatedBinderChecklistItemObj.put('Name', 'Related Binder Checklist Item');
        relatedBinderChecklistItemObj.put('Status', 'Pending Collection');
            
            for (Integer i = 0; i < count; i++) {
                documentChecklistItem.add((DocumentChecklistItem) TestDataFactory.operationOnObjectRec('insert', 'DocumentChecklistItem', relatedBinderChecklistItemObj));
            }

        }
        
    }
    
    @isTest
    static void testDocumentChecklistItemMethods(){
        String PROFILE = 'System Administrator';
        proccesRecordDataForDCI(PROFILE);
        
        List<DocumentChecklistItem> checklistItems = [
            SELECT Id, Status
            FROM DocumentChecklistItem
            WHERE Generate_Quote_and_Binder__c = :quote[0].Id
        ];
        
        // Prepare the records to update
        List<Map<String, Object>> recordsToUpdate = new List<Map<String, Object>>();
        for (DocumentChecklistItem item : checklistItems) {
            Map<String, Object> recordMap = new Map<String, Object>();
            recordMap.put('Id', item.Id);
            recordMap.put('Status', 'Completed');
            recordsToUpdate.add(recordMap);
        }
        
		test.startTest();
        
        List<DocumentChecklistItem> getQuotedChecklistItemsTest = DocumentChecklistSelectionTableControlle.getQuotedChecklistItems(quote[0].Id);
        System.assertNotEquals(1, getQuotedChecklistItemsTest.size());
        
        List<DocumentChecklistItem> getBinderChecklistItemsTest = DocumentChecklistSelectionTableControlle.getBinderChecklistItems(quote[0].Id);
        System.assertNotEquals(1, getBinderChecklistItemsTest.size());
        
        List<String> getStatusPicklistValuesTest = DocumentChecklistSelectionTableControlle.getStatusPicklistValues();
        System.assertNotEquals(1, getStatusPicklistValuesTest.size());
        
        List<DocumentChecklistItem> getRelatedBinderChecklistItemsTest = DocumentChecklistSelectionTableControlle.getRelatedBinderChecklistItems(quote[0].Id);
        System.assertNotEquals(1, getRelatedBinderChecklistItemsTest.size());
        
        DocumentChecklistSelectionTableControlle.updateRecords(recordsToUpdate);
        
        test.stopTest();
        
        // Verify the updates
        List<DocumentChecklistItem> updatedChecklistItems = [
            SELECT Id, Status
            FROM DocumentChecklistItem
            WHERE Id IN :checklistItems
        ];
        
        for (DocumentChecklistItem item : updatedChecklistItems) {
            System.assertEquals('Completed', item.Status, 'The status should be updated to Completed');
        }
    }

}