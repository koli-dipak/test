trigger TaskTrigger on Task (before insert,before update, after insert, after update) {
    new TH_Task().run();
}