public class DAL_QuoteLineItem {

    public static List<QuoteLineItem> getProductTypeQLI(string quoteId){
        return [SELECT Id, vlocity_ins__AdjustmentComments__c,Policy_Number__c,TotalPrice, vlocity_ins__AttributeSelectedValues__c,Stage__c, 
                                              Exposures__c, Subjectivities__c, Forms__c,State_Specific_Limits_Deductibles__c, Underlying_Policies__c,Experience_Modifications__c, LARGE_DEDUCTIBLES__c, SMALL_DEDUCTIBLES__c,
                                              Product2Id, Product2.Name,Send_to_Instec__c,Quote_Created__c FROM QuoteLineItem WHERE QuoteId = :quoteId AND 
                                              vlocity_ins__RecordTypeName__c = 'Product' ORDER BY CreatedDate DESC];
    }
    
    public static List<QuoteLineItem> getProductTypeChildQLI(string quoteId,List<QuoteLineItem> quoteLineItems){
        return [SELECT Id, vlocity_ins__AdjustmentComments__c,Policy_Number__c,TotalPrice, vlocity_ins__AttributeSelectedValues__c, Stage__c,
                                                    Exposures__c, Subjectivities__c, Forms__c, Underlying_Policies__c,State_Specific_Limits_Deductibles__c,Experience_Modifications__c, LARGE_DEDUCTIBLES__c, SMALL_DEDUCTIBLES__c,
                                                    Product2Id, Product2.Name, Product2.ProductCode, Send_to_Instec__c, vlocity_ins__ParentItemId2__c
                                                    FROM QuoteLineItem WHERE QuoteId = :quoteId AND 
                                                    vlocity_ins__ParentItemId2__c IN :quoteLineItems ORDER BY CreatedDate DESC];
    }
    
    public static List<vlocity_ins__AttributeAssignment__c> getProductAttributeData(Set<Id> productIdwiseName){ 
        return [SELECT Id, OwnerId, Name, vlocity_ins__AttributeCategorySubType__c, vlocity_ins__AttributeName__c, vlocity_ins__AttributeUniqueCode__c, 
                vlocity_ins__CategoryCode__c,vlocity_ins__ValueDataType__c,  vlocity_ins__CategoryName__c,vlocity_ins__IsHidden__c,
                vlocity_ins__ObjectId__c,vlocity_ins__IsConfigurable__c, vlocity_ins__ValidValuesData__c
                FROM vlocity_ins__AttributeAssignment__c WHERE vlocity_ins__ObjectId__c IN :productIdwiseName ORDER BY 
                vlocity_ins__CategoryDisplaySequence__c, vlocity_ins__DisplaySequence__c, vlocity_ins__AttributeDisplaySequence__c];
    }

	public static List<vlocity_ins__AttributeAssignment__c> getProductParentAttributeData(Set<Id> coverageSpecProductIds,Set<Id> insuredItemSpecProductIds){ 
        return [SELECT Id, OwnerId, Name, vlocity_ins__AttributeCategorySubType__c, vlocity_ins__AttributeName__c, vlocity_ins__AttributeUniqueCode__c,vlocity_ins__IsHidden__c, 
                vlocity_ins__CategoryCode__c,vlocity_ins__ValueDataType__c,  vlocity_ins__CategoryName__c, vlocity_ins__ObjectId__c,vlocity_ins__IsConfigurable__c, vlocity_ins__ValidValuesData__c
                FROM vlocity_ins__AttributeAssignment__c WHERE vlocity_ins__ObjectId__c IN :coverageSpecProductIds OR vlocity_ins__ObjectId__c IN :insuredItemSpecProductIds ORDER BY 
                vlocity_ins__CategoryDisplaySequence__c, vlocity_ins__DisplaySequence__c, vlocity_ins__AttributeDisplaySequence__c];
    }
    
    public static List<vlocity_ins__ProductChildItem__c> getProductChildItem(Set<Id> productIdwiseName){ 
        return [SELECT Id, Name, vlocity_ins__ChildProductId__c, vlocity_ins__ChildProductName__c, 
                vlocity_ins__ChildRecordType__c, vlocity_ins__CollapseHierarchy__c, 
                vlocity_ins__IsRootProductChildItem__c, vlocity_ins__ParentProductChildItemId__c, 
                vlocity_ins__ParentProductId__c, vlocity_ins__ParentProductName__c, vlocity_ins__ParentRecordType__c,
                vlocity_ins__MinQuantity__c, vlocity_ins__MaxQuantity__c  
                FROM vlocity_ins__ProductChildItem__c WHERE vlocity_ins__ParentProductId__c = :productIdwiseName AND (
                    vlocity_ins__ChildRecordType__c = 'InsuredItemSpec' OR vlocity_ins__ChildRecordType__c = 'CoverageSpec'
                ) ORDER BY vlocity_ins__SeqNumber__c];
    }
    
    public static QuoteLineItem getcloneQLI(String quoteLineItemId){
        return [SELECT Id, IsDeleted, LineNumber, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById,Stage__c, 
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
                                Instec_Created_Date__c, Forms__c, Exposures__c,State_Specific_Limits_Deductibles__c, Underlying_Policies__c,LARGE_DEDUCTIBLES__c, SMALL_DEDUCTIBLES__c, Subjectivities__c, Deductible__c, 
                                Experience_Modifications__c, Policy_Number__c, Policy_Number_Holder__c, Send_to_Instec__c, Instec_Sequance__c, 
                                InstecSequance__c, ProductName_Version__c FROM QuoteLineItem WHERE Id = :quoteLineItemId];
    }

    public static List<Rating_Container_Config__mdt> getAllActiveRatingContainerConfigs(){
        return [SELECT Id, MasterLabel, DeveloperName, 
        Additional_Item_Product_Name__c, Additional_Item_Product_Category__c, 
        Source_Field_Name__c, Is_Active__c FROM Rating_Container_Config__mdt 
        WHERE Is_Active__c = true];
    }
    
}