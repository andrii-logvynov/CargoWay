List<Low_Ink__e> inkEvents = new List<Low_Ink__e>();
inkEvents.add(new Low_Ink__e(Printer_Model__c='XZO-5', Current_Ink_Level__c=0.2));
inkEvents.add(new Low_Ink__e(Printer_Model__c='MN-123', Current_Ink_Level__c=0.15));

for (Integer i = 0; i < 151; i++) {
    EventBus.publish(inkEvents);
}

