public with sharing class CTRL_RatingContainerProduct {

    @AuraEnabled
    public static List<Rating_Container_Config__mdt> getRatingContainerConfigs(){
        List<Rating_Container_Config__mdt> ratingContainerConfigs =  DAL_QuoteLineItem.getAllActiveRatingContainerConfigs();
        return ratingContainerConfigs;
    }

    @AuraEnabled
    public static quoteLineItemProductWrpper quoteLineItem(string quoteId){
        quoteLineItemProductWrpper quoteLineItemMapWrpper = new quoteLineItemProductWrpper();
        Map<String, Map<String, List<vlocity_ins__AttributeAssignment__c>>> quoteRelatedMetadata = new Map<String, Map<String, List<vlocity_ins__AttributeAssignment__c>>>();
        Map<Id, String> productIdwiseName = new Map<Id, String>();
        Map<Id, Id> childParentMap = new Map<Id, Id>();
        Map<Id, List<Id>> parentWiseChildMap = new Map<Id, List<Id>>();
        Map<String, Map<String, List<vlocity_ins__AttributeAssignment__c>>> coverageSpecChildItemMap = new Map<String, Map<String, List<vlocity_ins__AttributeAssignment__c>>>();
        Map<String, Map<String, List<vlocity_ins__AttributeAssignment__c>>> insuredItemSpecChildItemMap = new Map<String, Map<String, List<vlocity_ins__AttributeAssignment__c>>>();
        Map<String, String> coverageDataMap = new Map<String, String>();
        Map<String, List<String>> parentChildQLIProductMap = new Map<String, List<String>>();
        Set<Id> addNewRecordButton = new Set<Id>();
        Set<Id> showSection = new Set<Id>();

        System.debug('quoteId:: '+ quoteId); 
        
        List<QuoteLineItem> quoteLineItems = DAL_QuoteLineItem.getProductTypeQLI(quoteId);
        System.debug('quoteLineItems:: '+ quoteLineItems);
        
        for(QuoteLineItem QLI : quoteLineItems){
            productIdwiseName.put(QLI.Product2Id, QLI.Product2.Name);
        }

        List<QuoteLineItem> childQuoteLineItems = DAL_QuoteLineItem.getProductTypeChildQLI(quoteId,quoteLineItems);
        
        for (QuoteLineItem childQuoteLine : childQuoteLineItems) {
            coverageDataMap.put(childQuoteLine.vlocity_ins__ParentItemId2__c + '||' + childQuoteLine.Product2Id, childQuoteLine.Id + '::' + childQuoteLine.vlocity_ins__AttributeSelectedValues__c);
            
            if(!parentChildQLIProductMap.containsKey(childQuoteLine.vlocity_ins__ParentItemId2__c)){
                parentChildQLIProductMap.put(childQuoteLine.vlocity_ins__ParentItemId2__c, new List<String>{childQuoteLine.Product2.Name});
            }
            else{
                parentChildQLIProductMap.get(childQuoteLine.vlocity_ins__ParentItemId2__c).add(childQuoteLine.Product2.Name);
            }
        }
        List<vlocity_ins__AttributeAssignment__c> DAL_AttributeDataList = DAL_QuoteLineItem.getProductAttributeData(productIdwiseName.keySet()); 
        for(vlocity_ins__AttributeAssignment__c attributeData : DAL_AttributeDataList)
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
        
        List<vlocity_ins__ProductChildItem__c> DAL_productchildItem = DAL_QuoteLineItem.getProductChildItem(productIdwiseName.keySet()); 
        for(vlocity_ins__ProductChildItem__c productchildItem : DAL_productchildItem)
        {
            if(productchildItem.vlocity_ins__ChildRecordType__c == 'InsuredItemSpec'){
                insuredItemSpecProductIds.add(productchildItem.vlocity_ins__ChildProductId__c);
            }
            if(productchildItem.vlocity_ins__ChildRecordType__c == 'CoverageSpec'){
                coverageSpecProductIds.add(productchildItem.vlocity_ins__ChildProductId__c);
            }
            productIdwiseName.put(productchildItem.vlocity_ins__ChildProductId__c, productchildItem.vlocity_ins__ChildProductName__c);
            childParentMap.put(productchildItem.vlocity_ins__ChildProductId__c, productchildItem.vlocity_ins__ParentProductId__c);

            if(!parentWiseChildMap.containsKey(productchildItem.vlocity_ins__ParentProductId__c)){
                parentWiseChildMap.put(productchildItem.vlocity_ins__ParentProductId__c, new List<Id>());
            }
            parentWiseChildMap.get(productchildItem.vlocity_ins__ParentProductId__c).add(productchildItem.vlocity_ins__ChildProductId__c);

            if(productchildItem.vlocity_ins__MaxQuantity__c != null && productchildItem.vlocity_ins__MaxQuantity__c != 0){
                addNewRecordButton.add(productchildItem.vlocity_ins__ChildProductId__c);
            }
            if(productchildItem.vlocity_ins__MinQuantity__c != null && productchildItem.vlocity_ins__MinQuantity__c != 0){
                showSection.add(productchildItem.vlocity_ins__ChildProductId__c);
            }
        }

        Map<String, List<vlocity_ins__AttributeAssignment__c>> coverageRelatedAttributesProductWise = new Map<String, List<vlocity_ins__AttributeAssignment__c>>();

        List<vlocity_ins__AttributeAssignment__c> DAL_ParentAttributeDataList = DAL_QuoteLineItem.getProductParentAttributeData(coverageSpecProductIds,insuredItemSpecProductIds); 
        for (vlocity_ins__AttributeAssignment__c attributeData : DAL_ParentAttributeDataList) {
            if(!coverageRelatedAttributesProductWise.containsKey(attributeData.vlocity_ins__ObjectId__c)){
                coverageRelatedAttributesProductWise.put(attributeData.vlocity_ins__ObjectId__c, new List<vlocity_ins__AttributeAssignment__c>());
            }
            coverageRelatedAttributesProductWise.get(attributeData.vlocity_ins__ObjectId__c).add(attributeData);
        }

        for (Id parentProductId : parentWiseChildMap.keySet()) {
            for (Id childProdId : parentWiseChildMap.get(parentProductId)) {
                if(!coverageRelatedAttributesProductWise.containsKey(childProdId)){
                    continue;
                }

                for (vlocity_ins__AttributeAssignment__c attributeData : coverageRelatedAttributesProductWise.get(childProdId)) {
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
                            System.debug(attributeData.vlocity_ins__ObjectId__c + '::' + productName);
                        }
                        coverageSpecChildItemMap.put(parentProductId, parentCategoryWiseAttributeRecs);
                        System.debug(parentProductId + ' :: ' + parentCategoryWiseAttributeRecs.values().size());
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
            }
        }
        
        quoteLineItemMapWrpper.productIdwiseName = productIdwiseName;
        quoteLineItemMapWrpper.coverageDataMap = coverageDataMap;
        quoteLineItemMapWrpper.quoteLineItems = quoteLineItems;
        quoteLineItemMapWrpper.quoteRelatedMetadata = quoteRelatedMetadata;
        quoteLineItemMapWrpper.coverageSpecChildItemMap = coverageSpecChildItemMap;
        quoteLineItemMapWrpper.insuredItemSpecChildItemMap = insuredItemSpecChildItemMap;
        quoteLineItemMapWrpper.parentChildQLIProductMap = parentChildQLIProductMap;
        quoteLineItemMapWrpper.addNewRecordButton = new List<Id>(addNewRecordButton);
        quoteLineItemMapWrpper.showSection = new List<Id>(showSection);
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
        QuoteLineItem qliRec = DAL_QuoteLineItem.getcloneQLI(quoteLineItemId);
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

        @AuraEnabled
        public List<Id> addNewRecordButton;

        @AuraEnabled
        public List<Id> showSection;
    }
}