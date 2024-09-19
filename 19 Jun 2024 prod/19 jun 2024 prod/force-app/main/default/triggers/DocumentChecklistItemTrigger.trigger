trigger DocumentChecklistItemTrigger on DocumentChecklistItem (after update, before update, before delete) {
      new TH_DocumentChecklistItem().run();
}