trigger AccountTrigger on Account (before insert,before Update,after update) {
    new TH_Account().run();
}