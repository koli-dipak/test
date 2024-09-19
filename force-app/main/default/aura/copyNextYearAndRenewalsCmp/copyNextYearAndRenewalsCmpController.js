({
    doInit : function(component, event, helper) {
        
        var recordId = component.get("v.recordId");
        var action = component.get("c.processNextYearAndRenewal");
        
        action.setParams({ opportunityId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var responseData = response.getReturnValue();
                console.log('@@responseData:: ', response);
                //var urlString = window.location.href;
                //var baseURL = urlString.substring(0, urlString.indexOf("/r"));
                
                //window.close(baseURL +'/r/LOB_Management__c/'+ recordId+'/view');
                //window.open(baseURL +'/r/Opportunity/'+ responseData+'/view');
                
               
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": responseData
                });
                navEvt.fire();
                 var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
               /* var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": baseURL +'/r/Opportunity/'+ responseData+'/view'
                });
                urlEvent.fire();*/
                
            } else if (state === 'ERROR') {
                var errors = response.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
       
    }
})