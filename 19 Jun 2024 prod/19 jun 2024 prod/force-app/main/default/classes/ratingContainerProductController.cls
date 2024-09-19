public with sharing class ratingContainerProductController {

    @AuraEnabled
    public static quoteLineItemProductWrpper quoteLineItem(string quoteId){
        quoteLineItemProductWrpper quoteLineItemMapWrpper = new quoteLineItemProductWrpper();
        Map<String, Map<String, List<vlocity_ins__AttributeAssignment__c>>> quoteRelatedMetadata = new Map<String, Map<String, List<vlocity_ins__AttributeAssignment__c>>>();
        Map<Id, String> productIdwiseName = new Map<Id, String>();
        Map<Id, Id> childParentMap = new Map<Id, Id>();
        Map<String, Map<String, List<vlocity_ins__AttributeAssignment__c>>> coverageSpecChildItemMap = new Map<String, Map<String, List<vlocity_ins__AttributeAssignment__c>>>();
        Map<String, Map<String, List<vlocity_ins__AttributeAssignment__c>>> insuredItemSpecChildItemMap = new Map<String, Map<String, List<vlocity_ins__AttributeAssignment__c>>>();
        Map<String, String> coverageDataMap = new Map<String, String>();
        Map<String, List<String>> parentChildQLIProductMap = new Map<String, List<String>>();

        System.debug('quoteId:: '+ quoteId); 
        
        List<QuoteLineItem> quoteLineItems = [SELECT Id, vlocity_ins__AdjustmentComments__c,Policy_Number__c,TotalPrice, vlocity_ins__AttributeSelectedValues__c, Stage__c, 
                                              Exposures__c, Subjectivities__c, Forms__c, Underlying_Policies__c,Experience_Modifications__c, LARGE_DEDUCTIBLES__c, SMALL_DEDUCTIBLES__c,
                                              Product2Id, Product2.Name,Send_to_Instec__c FROM QuoteLineItem WHERE QuoteId = :quoteId AND 
                                              vlocity_ins__RecordTypeName__c = 'Product' ORDER BY CreatedDate DESC];
        System.debug('quoteLineItems:: '+ quoteLineItems);
        
        for(QuoteLineItem QLI : quoteLineItems){
            productIdwiseName.put(QLI.Product2Id, QLI.Product2.Name);
        }

        List<QuoteLineItem> childQuoteLineItems = [SELECT Id, vlocity_ins__AdjustmentComments__c,Policy_Number__c,TotalPrice, vlocity_ins__AttributeSelectedValues__c, Stage__c, 
                                                    Exposures__c, Subjectivities__c, Forms__c, Underlying_Policies__c,Experience_Modifications__c, LARGE_DEDUCTIBLES__c, SMALL_DEDUCTIBLES__c,
                                                    Product2Id, Product2.Name, Product2.ProductCode, Send_to_Instec__c, vlocity_ins__ParentItemId2__c
                                                    FROM QuoteLineItem WHERE QuoteId = :quoteId AND 
                                                    vlocity_ins__ParentItemId2__c IN :quoteLineItems ORDER BY CreatedDate DESC];
        
        for (QuoteLineItem childQuoteLine : childQuoteLineItems) {
            coverageDataMap.put(childQuoteLine.vlocity_ins__ParentItemId2__c + '_' + childQuoteLine.Product2Id, childQuoteLine.Id + '::' + childQuoteLine.vlocity_ins__AttributeSelectedValues__c);
            
            if(!parentChildQLIProductMap.containsKey(childQuoteLine.vlocity_ins__ParentItemId2__c)){
                parentChildQLIProductMap.put(childQuoteLine.vlocity_ins__ParentItemId2__c, new List<String>{childQuoteLine.Product2.Name});
            }
            else{
                parentChildQLIProductMap.get(childQuoteLine.vlocity_ins__ParentItemId2__c).add(childQuoteLine.Product2.Name);
            }
        }
        
        for(vlocity_ins__AttributeAssignment__c attributeData : [SELECT Id, OwnerId, Name, vlocity_ins__AttributeCategorySubType__c, vlocity_ins__AttributeName__c, vlocity_ins__AttributeUniqueCode__c, 
                                                                 vlocity_ins__CategoryCode__c,vlocity_ins__ValueDataType__c,  vlocity_ins__CategoryName__c, vlocity_ins__ObjectId__c,vlocity_ins__IsConfigurable__c, vlocity_ins__ValidValuesData__c
                                                                 FROM vlocity_ins__AttributeAssignment__c WHERE vlocity_ins__ObjectId__c IN :productIdwiseName.keySet() ORDER BY vlocity_ins__CategoryDisplaySequence__c, vlocity_ins__DisplaySequence__c, vlocity_ins__AttributeDisplaySequence__c])
        {            
            Map<String, List<vlocity_ins__AttributeAssignment__c>> categoryWiseAttributeRecs = new Map<String, List<vlocity_ins__AttributeAssignment__c>>();
            
            if(quoteRelatedMetadata.containsKey(attributeData.vlocity_ins__ObjectId__c)){
                categoryWiseAttributeRecs = quoteRelatedMetadata.get(attributeData.vlocity_ins__ObjectId__c);
            }
            
            if(attributeData.vlocity_ins__CategoryName__c != null){
                if(categoryWiseAttributeRecs.containsKey(attributeData.vlocity_ins__CategoryName__c)){
                    List<vlocity_ins__AttributeAssignment__c> allAttributeList = categoryWiseAttributeRecs.get(attributeData.vlocity_ins__CategoryName__c);
                    allAttributeList.add(attributeData);
                    categoryWiseAttributeRecs.put(attributeData.vlocity_ins__CategoryName__c, allAttributeList);
                }
                else{
                    List<vlocity_ins__AttributeAssignment__c> allAttributeList = new List<vlocity_ins__AttributeAssignment__c>();
                    allAttributeList.add(attributeData);
                    categoryWiseAttributeRecs.put(attributeData.vlocity_ins__CategoryName__c, allAttributeList);
                }
            }
            quoteRelatedMetadata.put(attributeData.vlocity_ins__ObjectId__c, categoryWiseAttributeRecs);
        }
        
        Set<Id> coverageSpecProductIds = new Set<Id>();
        Set<Id> insuredItemSpecProductIds = new Set<Id>();
        
        for(vlocity_ins__ProductChildItem__c productchildItem : [SELECT Id, Name, vlocity_ins__ChildProductId__c, vlocity_ins__ChildProductName__c, 
                                                                 vlocity_ins__ChildRecordType__c, vlocity_ins__CollapseHierarchy__c, 
                                                                 vlocity_ins__IsRootProductChildItem__c, vlocity_ins__ParentProductChildItemId__c, 
                                                                 vlocity_ins__ParentProductId__c, vlocity_ins__ParentProductName__c, vlocity_ins__ParentRecordType__c 
                                                                 FROM vlocity_ins__ProductChildItem__c WHERE vlocity_ins__ParentProductId__c = :productIdwiseName.keySet() AND (
                                                                     vlocity_ins__ChildRecordType__c = 'InsuredItemSpec' OR vlocity_ins__ChildRecordType__c = 'CoverageSpec'
                                                                 ) ORDER BY vlocity_ins__SeqNumber__c])
        {
            if(productchildItem.vlocity_ins__ChildRecordType__c == 'InsuredItemSpec'){
                insuredItemSpecProductIds.add(productchildItem.vlocity_ins__ChildProductId__c);
            }
            if(productchildItem.vlocity_ins__ChildRecordType__c == 'CoverageSpec'){
                coverageSpecProductIds.add(productchildItem.vlocity_ins__ChildProductId__c);
            }
            productIdwiseName.put(productchildItem.vlocity_ins__ChildProductId__c, productchildItem.vlocity_ins__ChildProductName__c);
            childParentMap.put(productchildItem.vlocity_ins__ChildProductId__c, productchildItem.vlocity_ins__ParentProductId__c);
        }

        
        for(vlocity_ins__AttributeAssignment__c attributeData : [SELECT Id, OwnerId, Name, vlocity_ins__AttributeCategorySubType__c, vlocity_ins__AttributeName__c, vlocity_ins__AttributeUniqueCode__c, 
                                                                 vlocity_ins__CategoryCode__c,vlocity_ins__ValueDataType__c,  vlocity_ins__CategoryName__c, vlocity_ins__ObjectId__c,vlocity_ins__IsConfigurable__c, vlocity_ins__ValidValuesData__c
                                                                 FROM vlocity_ins__AttributeAssignment__c WHERE vlocity_ins__ObjectId__c IN :coverageSpecProductIds OR vlocity_ins__ObjectId__c IN :insuredItemSpecProductIds ORDER BY vlocity_ins__CategoryDisplaySequence__c, vlocity_ins__DisplaySequence__c, vlocity_ins__AttributeDisplaySequence__c])
        {
            Id parentProductId = childParentMap.get(attributeData.vlocity_ins__ObjectId__c);
            String childProductName = productIdwiseName.get(attributeData.vlocity_ins__ObjectId__c);
            
            Map<String, List<vlocity_ins__AttributeAssignment__c>> parentCategoryWiseAttributeRecs = new Map<String, List<vlocity_ins__AttributeAssignment__c>>();
            
            if(coverageSpecProductIds.contains(attributeData.vlocity_ins__ObjectId__c)){
                if(coverageSpecChildItemMap.containsKey(parentProductId)){
                    parentCategoryWiseAttributeRecs = coverageSpecChildItemMap.get(parentProductId);
                }
                
                String productName = productIdwiseName.get(attributeData.vlocity_ins__ObjectId__c);
                if(productName != null){
                    if(parentCategoryWiseAttributeRecs.containsKey(productName)){
                        List<vlocity_ins__AttributeAssignment__c> parentAllAttributeList = parentCategoryWiseAttributeRecs.get(productName);
                        parentAllAttributeList.add(attributeData);
                        parentCategoryWiseAttributeRecs.put(productName, parentAllAttributeList);
                    }
                    else{
                        List<vlocity_ins__AttributeAssignment__c> parentAllAttributeList = new List<vlocity_ins__AttributeAssignment__c>();
                        parentAllAttributeList.add(attributeData);
                        parentCategoryWiseAttributeRecs.put(productName, parentAllAttributeList);
                    }
                }
                coverageSpecChildItemMap.put(parentProductId, parentCategoryWiseAttributeRecs);
            }
            else{
                if(insuredItemSpecChildItemMap.containsKey(parentProductId)){
                    parentCategoryWiseAttributeRecs = insuredItemSpecChildItemMap.get(parentProductId);
                }
                
                if(attributeData.vlocity_ins__CategoryName__c != null){
                    if(parentCategoryWiseAttributeRecs.containsKey(childProductName + '::' + attributeData.vlocity_ins__CategoryName__c)){
                        List<vlocity_ins__AttributeAssignment__c> parentAllAttributeList = parentCategoryWiseAttributeRecs.get(childProductName + '::' +attributeData.vlocity_ins__CategoryName__c);
                        parentAllAttributeList.add(attributeData);
                        parentCategoryWiseAttributeRecs.put(childProductName + '::' + attributeData.vlocity_ins__CategoryName__c, parentAllAttributeList);
                    }
                    else{
                        List<vlocity_ins__AttributeAssignment__c> parentAllAttributeList = new List<vlocity_ins__AttributeAssignment__c>();
                        parentAllAttributeList.add(attributeData);
                        parentCategoryWiseAttributeRecs.put(childProductName + '::' + attributeData.vlocity_ins__CategoryName__c, parentAllAttributeList);
                    }
                }
                insuredItemSpecChildItemMap.put(parentProductId, parentCategoryWiseAttributeRecs);
            }
        }
        
        quoteLineItemMapWrpper.productIdwiseName = productIdwiseName;
        quoteLineItemMapWrpper.coverageDataMap = coverageDataMap;
        quoteLineItemMapWrpper.quoteLineItems = quoteLineItems;
        quoteLineItemMapWrpper.quoteRelatedMetadata = quoteRelatedMetadata;
        quoteLineItemMapWrpper.coverageSpecChildItemMap = coverageSpecChildItemMap;
        quoteLineItemMapWrpper.insuredItemSpecChildItemMap = insuredItemSpecChildItemMap;
        quoteLineItemMapWrpper.parentChildQLIProductMap = parentChildQLIProductMap;
        return quoteLineItemMapWrpper;
    }

    @AuraEnabled
    public static void productAttributeUpdateQuoteLineItemRecord(String quoteLineItemId, String seletedAttributeJson){
        QuoteLineItem quoteLineRec = new QuoteLineItem();
        quoteLineRec.Id = quoteLineItemId;
        quoteLineRec.vlocity_ins__AttributeSelectedValues__c = seletedAttributeJson;
        Update quoteLineRec;
    }

    /*@AuraEnabled
    public static void productCoverageAttributeUpdateChildQLIRecord(String quoteLineItemId, String seletedAttributeJson){
        QuoteLineItem quoteLineRec = new QuoteLineItem();
        quoteLineRec.vlocity_ins__ParentItemId2__c = quoteLineItemId;
        quoteLineRec.vlocity_ins__AttributeSelectedValues__c = seletedAttributeJson;
        Update quoteLineRec;
    }

    @AuraEnabled
    public static void saveNewSubjectivites(String quoteLineItemId, String updatedSubjectivites){
        QuoteLineItem quoteLineRec = new QuoteLineItem();
        quoteLineRec.Id = quoteLineItemId;
        quoteLineRec.Subjectivities__c = updatedSubjectivites;
        Update quoteLineRec;
    }

    @AuraEnabled
    public static void saveNewUnderlyingPolicies(String quoteLineItemId, String updatedUnderlyingPolicies){
        QuoteLineItem quoteLineRec = new QuoteLineItem();
        quoteLineRec.Id = quoteLineItemId;
        quoteLineRec.Underlying_Policies__c = updatedUnderlyingPolicies;
        Update quoteLineRec;
    }*/

    @AuraEnabled
    public static void updateQuoteLineItemWithSubSectionData(String quoteLineItemId, String updatedAddSectionData, String fieldName){
        QuoteLineItem quoteLineRec = new QuoteLineItem();
        quoteLineRec.Id = quoteLineItemId;
        quoteLineRec.put(fieldName, updatedAddSectionData);
        Update quoteLineRec;
    }

    @AuraEnabled
    public static void cloneQuoteLine(String quoteLineItemId){
        QuoteLineItem qliRec = [SELECT Id, IsDeleted, LineNumber, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, Stage__c, 
                                SystemModstamp, LastViewedDate, LastReferencedDate, QuoteId, PricebookEntryId, OpportunityLineItemId, 
                                Quantity, UnitPrice, Discount, HasRevenueSchedule, HasQuantitySchedule, Description, ServiceDate, Product2Id, 
                                SortOrder, HasSchedule, ListPrice, Subtotal, TotalPrice, vlocity_ins__Action__c, vlocity_ins__AdjustmentComments__c, 
                                vlocity_ins__AttributeMetadataChanges__c, vlocity_ins__AttributeSelectedValues__c, vlocity_ins__AttributesData__c, 
                                vlocity_ins__CalculatedPriceJSON__c, vlocity_ins__ClassCodes__c, vlocity_ins__ContractCode__c, 
                                vlocity_ins__EnrollmentEndDate__c, vlocity_ins__EnrollmentStartDate__c, vlocity_ins__EnrollmentWaitingPeriod__c, 
                                vlocity_ins__FeeAmount__c, vlocity_ins__FormularyId__c, vlocity_ins__GroupCensusId__c, vlocity_ins__GroupClassId__c, 
                                vlocity_ins__GroupClassName__c, vlocity_ins__ImageId__c, vlocity_ins__Image__c, vlocity_ins__InCartQuantityMap__c, 
                                vlocity_ins__InsurableItemId__c, vlocity_ins__IsProductTrackAgreement__c, vlocity_ins__ItemName__c, 
                                vlocity_ins__JSONAttribute__c, vlocity_ins__JurisdictionId__c, vlocity_ins__LineNumber__c, vlocity_ins__NeedReprice__c, 
                                vlocity_ins__ParentItemId2__c, vlocity_ins__ParentItemId__c, vlocity_ins__PricingLogData__c, vlocity_ins__PricingSource__c, 
                                vlocity_ins__PrimaryChildLineItemId__c, vlocity_ins__ProductChildItemId__c, vlocity_ins__ProductChildItemSequence__c, 
                                vlocity_ins__ProductHierarchyPath__c, vlocity_ins__ProductName__c, vlocity_ins__ProviderNetworkId__c, 
                                vlocity_ins__ProvisioningStatus__c, vlocity_ins__RateBandId__c, vlocity_ins__RatingType__c, vlocity_ins__RecordTypeName__c, 
                                vlocity_ins__RelationshipType__c, vlocity_ins__RenewSourcePlanId__c, vlocity_ins__RootItemId__c, vlocity_ins__SubAction__c, 
                                vlocity_ins__SubParentItemId__c, vlocity_ins__SubscriptionId__c, vlocity_ins__TaxAmount__c, vlocity_ins__TotalAmount__c, 
                                vlocity_ins__TotalSumInsured__c, vlocity_ins__Type__c, Instec_ID__c, Instec_Transaction_Note__c, Instec_Total_Premium__c, 
                                Instec_Created_Date__c, Forms__c, Exposures__c, Underlying_Policies__c,LARGE_DEDUCTIBLES__c, SMALL_DEDUCTIBLES__c, Subjectivities__c, Deductible__c, 
                                Experience_Modifications__c, Policy_Number__c, Policy_Number_Holder__c, Send_to_Instec__c, Instec_Sequance__c, 
                                InstecSequance__c, ProductName_Version__c FROM QuoteLineItem WHERE Id = :quoteLineItemId];
        QuoteLineItem quoteLineRec = qliRec.clone(false, true, false, false);
        Insert quoteLineRec;
    }

    @AuraEnabled
    public static void deleteQuoteLine(String quoteLineItemId){
        QuoteLineItem qliRec = new QuoteLineItem(Id = quoteLineItemId);
        Delete qliRec;
    }

    public class quoteLineItemProductWrpper{
        @AuraEnabled
        public List<QuoteLineItem> quoteLineItems; // All quotelineItem
        @AuraEnabled
        public Map<Id, String> productIdwiseName;  // product Id wise category name
        //@AuraEnabled
        //public Map<Id, Id> childParentMap;
        @AuraEnabled
        public Map<String, Map<String, List<vlocity_ins__AttributeAssignment__c>>> quoteRelatedMetadata; // product Id wise category name And attribute record
        @AuraEnabled
        public Map<String, Map<String, List<vlocity_ins__AttributeAssignment__c>>> coverageSpecChildItemMap; // coverage [productchildlineitem category name And attribute record]
        @AuraEnabled
        public Map<String, Map<String, List<vlocity_ins__AttributeAssignment__c>>> insuredItemSpecChildItemMap; // insuredItem [additionalitems category name And attribute record]
        @AuraEnabled
        public Map<String, String> coverageDataMap; // quotelineitem => childquotelineitemparentproductId + Attributeselectedvalue

        @AuraEnabled
        public Map<String, List<String>> parentChildQLIProductMap;
    }
}