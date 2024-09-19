trigger LocationTrigger on Location (before insert , before update) {   
   new TH_Location().run();
}