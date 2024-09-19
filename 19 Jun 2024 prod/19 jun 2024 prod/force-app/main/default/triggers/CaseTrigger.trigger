trigger CaseTrigger on Case (before insert, before update,after insert,after update) {
    new TH_Case().run();
}