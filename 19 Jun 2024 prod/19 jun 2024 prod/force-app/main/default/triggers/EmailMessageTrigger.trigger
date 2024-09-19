trigger EmailMessageTrigger on EmailMessage (before insert) {
	new TH_EmailMessage().run();
}