({
	doInit : function(component, event, helper) {
        var action = component.get("c.sendToInstec");
        action.setParams({ recordId : component.get("v.recordId") });

        action.setCallback(this, function(a) {
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                if(a.getReturnValue()==""){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":"Success",
                        "title": "Success!",
                        "message": "Send to instec successfully."
                    });
                    toastEvent.fire();
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":"Error",
                        "title": "Error!",
                        "message": a.getReturnValue()
                    });
                    toastEvent.fire();
                }
                
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"Error",
                    "title": "Error!",
                    "message": "Error occured while processing."
                });
                toastEvent.fire();
            }
            $A.get('e.force:refreshView').fire();
            $A.get("e.force:closeQuickAction").fire()
        });
        $A.enqueueAction(action);
	},
    
})