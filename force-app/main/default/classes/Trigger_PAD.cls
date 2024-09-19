public with sharing class Trigger_PAD {
    
    private static Trigger_PAD instance = null;
    private static Id currentUserId = null;
    public Map<String, Boolean> triggerStatus = null;
    public static boolean isBypassValidation= false;
    
    private void load() {
        currentUserId = UserInfo.getUserId();
        User  u = [SELECT ByPassTrigger__c,ByPassValidation__c FROM User 
                             WHERE Id = :UserInfo.getUserId() LIMIT 1];
        String bypassApex = u.ByPassTrigger__c;
        isBypassValidation = u.ByPassValidation__c;
        triggerStatus = new Map<String, Boolean>();                
        if (byPassApex != null) {
            List<String> triggerList = bypassApex.split(';');            
            for (String triggerName : triggerList) {
                if (triggerName != null && triggerName != '') {
                    triggerStatus.put(triggerName, false);
                }
            }
        }
    }
    
    public static Trigger_PAD getInstance() {
        if (instance == null) { 
            instance = new Trigger_PAD();
        }
        if (currentUserId != UserInfo.getUserId()) {
            instance.load();
        }
        return instance;
    }
    
    public static void deactivateTrigger(String name) {
        getInstance().triggerStatus.put(name, false);
    }
    
    public static void activateTrigger(String name) {
        getInstance().triggerStatus.put(name, true);
    }
    
    public static boolean canRun(String name) {
        if (getInstance().triggerStatus.containsKey(name)) {
            
            return (getInstance().triggerStatus.get(name));
        }
        return true;
    }    
}