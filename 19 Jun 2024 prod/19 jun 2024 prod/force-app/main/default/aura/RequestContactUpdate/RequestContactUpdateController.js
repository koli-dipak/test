({
    doInit : function(component, event, helper){
        helper.showSpinner(component, event, helper);
        helper.getContacts(component, event, helper);
    },
    
    handleSend : function(component, event, helper) {
        helper.showSpinner(component, event, helper);
        helper.handleSendEmail(component, event, helper);
    },
    
    handleClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
})