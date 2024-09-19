({
    getContacts : function(component, event, helper) {
        debugger;
        self = this;
        var recordId = component.get("v.recordId");
        
        var action = component.get("c.getContactRecords");
        action.setParams({
            accountId : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result != null && result != undefined && result != ''){
                    component.set("v.contacts", JSON.parse(result));
                }
                
            }else if(state === "ERROR"){
                self.showToast(component, event, helper, 'Error!!', 'ERROR', 'Something went Wrong !!')
            }
            self.hideSpinner(component, event, helper);
        });
        $A.enqueueAction(action);
    },
    
    handleSendEmail : function(component, event, helper) {
        debugger;
        self = this;
        
        var recordId = component.get("v.recordId");
        var contactId = component.find('selectContact').get('v.value');
        
        if(contactId == null || contactId == ''){
            self.showToast(component, event, helper, 'Warning!!', 'WARNING', 'Please Select Valid Contact !!');
            self.hideSpinner(component, event, helper);
            return;
        }
        var action = component.get("c.sendEmail");
        action.setParams({
            recordId : recordId,
            contactId : contactId,
            comment : component.find('comment').get('v.value')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                self.showToast(component, event, helper, 'Success!!', 'SUCCESS', 'Email Sent Sucessfully !!')
                
            }else if(state === "ERROR"){
                self.showToast(component, event, helper, 'Error!!', 'ERROR', 'Something went Wrong !!')
            }
            self.hideSpinner(component, event, helper);
            $A.get("e.force:closeQuickAction").fire();
        });
        $A.enqueueAction(action);
    },
    
    showToast: function(component, event, helper, title, type, msg){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title ,
            "type": type,
            "message":msg
        });
        toastEvent.fire();
    },
    
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){
        component.set("v.Spinner", false);
    }
})