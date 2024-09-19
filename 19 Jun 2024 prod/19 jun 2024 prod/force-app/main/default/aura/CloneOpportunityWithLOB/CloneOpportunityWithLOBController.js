({
	doInit : function(component, event, helper) {
        component.set("v.showSpinner", true);
		var action = component.get("c.cloneWithProducts");
        action.setParams({ 
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            component.set("v.showSpinner", false);
            if (state === "SUCCESS") {
                let response = a.getReturnValue();
                console.log(':: ' + response);

                if(response.startsWith("006")){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":"Success",
                        "title": "Success!",
                        "message": ""
                    });
                    toastEvent.fire();

                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": response
                    });
                    navEvt.fire();
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":"Error",
                        "title": "Error!",
                        "message": response
                    });
                    toastEvent.fire();
                }
            }
            else if (state === "ERROR") {
                var errors = a.getError();
                if (errors) {
                    if (errors[0] && errors[0].pageErrors && errors[0].pageErrors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type":"Error",
                            "title": "Error!",
                            "message": errors[0].pageErrors[0].message
                        });
                        toastEvent.fire();
                    }
                }
            }
            else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"Error",
                    "title": "Error!",
                    "message": "Something went wrong!"
                });
                toastEvent.fire();
            }
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        });
        $A.enqueueAction(action);
	}
})