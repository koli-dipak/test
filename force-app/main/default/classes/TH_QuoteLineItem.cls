public class TH_QuoteLineItem extends BaseTriggerHandler{
	private List<QuoteLineItem> newQuoteLineItemList;
    private List<QuoteLineItem> oldQuoteLineItemList;
    private Map<ID, QuoteLineItem> newQuoteLineItemMap;
    private Map<ID, QuoteLineItem> oldQuoteLineItemMap;
    
    public TH_QuoteLineItem()
    {
        oldQuoteLineItemList = (List<QuoteLineItem>)Trigger.old;
        newQuoteLineItemList = (List<QuoteLineItem>)Trigger.new;
        newQuoteLineItemMap = (Map<Id, QuoteLineItem>)Trigger.newMap;
        oldQuoteLineItemMap = (Map<Id, QuoteLineItem>)Trigger.oldMap;
    }
    
    protected override void beforeInsert() { 
        if(Trigger_PAD.canRun('TH_QuoteLineItemBeforeInsert')){
            proccesRecordBeforeInsertQuoteLineItem(newQuoteLineItemList);
        }
    } 
    
    
    protected override void afterUpdate()
    {
        if(Trigger_PAD.canRun('TH_QuoteLineItemAfterUpdate'))
        {
            proccesRecordAfterUpdateQuoteLineItem(newQuoteLineItemList, oldQuoteLineItemMap);
        }
    }
    
    
    public static void proccesRecordBeforeInsertQuoteLineItem(List<QuoteLineItem> newQuoteLineItemList)
    {
    }
    
    public static void proccesRecordAfterUpdateQuoteLineItem(List<QuoteLineItem> newQuoteLineItemList,Map<ID, QuoteLineItem> oldQuoteLineItemMap)
    {
        List<Subjectivitie__c> newSubjectivities = new List<Subjectivitie__c>();
        List<Id> qliWithNewSubjectivie = new List<Id>();
        for (QuoteLineItem qliRec : newQuoteLineItemList) {
            QuoteLineItem oldQLIRec = oldQuoteLineItemMap.get(qliRec.Id);

            if(String.isNotBlank(qliRec.Subjectivities__c) && qliRec.Subjectivities__c != oldQLIRec.Subjectivities__c){
                String subjectivities = qliRec.Subjectivities__c;
                if(qliRec.Subjectivities__c.startsWith('{')){
                    subjectivities = '[' + qliRec.Subjectivities__c + ']';
                }
                
                List<subjectivitieWrapper> qliSubjectivities = (List<subjectivitieWrapper>) JSON.deserialize(subjectivities, List<subjectivitieWrapper>.class);
                System.debug('qliSubjectivities:: ' + qliSubjectivities.size());
                for (subjectivitieWrapper qliSubjectivitie : qliSubjectivities) {
                    if(String.isNotBlank(qliSubjectivitie.Subj)){
                   		newSubjectivities.add(qliSubjectivitie.getSubjectivitieObject(qliRec.Id));
                    }
                }
                qliWithNewSubjectivie.add(qliRec.Id);
            }
        }

        List<Subjectivitie__c> subjectivitiesToDelete = [SELECT Id, Name, Quote_Line_Item__c FROM Subjectivitie__c WHERE Quote_Line_Item__c IN :qliWithNewSubjectivie];
        if(!subjectivitiesToDelete.isEmpty()){
            Delete subjectivitiesToDelete;
        }
        System.debug('newSubjectivities:: ' + newSubjectivities.size());
        if(!newSubjectivities.isEmpty()){
            Insert newSubjectivities;
        }
    }

    public Class subjectivitieWrapper{
        public String DueAt;
        public String Subj;
        public Date DueDate;
        public Date SubDueDate;
        public Boolean CanBeWaived;
        public Boolean CanBind;

        public Subjectivitie__c getSubjectivitieObject(String quoteLineId){
            return new Subjectivitie__c(
                Can_be_waived__c = this.CanBeWaived != null? this.CanBeWaived: false,
                Can_Bind__c = this.CanBind != null? this.CanBind: false,
                Due_At__c = this.DueAt,
                Due_Date__c = this.DueDate!=null?this.DueDate:this.SubDueDate,
                Description__c = this.Subj,
                Quote_Line_Item__c = quoteLineId
            );
        }
    }
}