/**
 * @description Trigger on Account to publish DataMigrationEvent when BillingCountry changes
 * @author      Richard GOH
 * @date        2026-02
 * @project     Heimdall GDPR Engine - Event-Driven Architecture
 */
trigger AccountTrigger on Account (after update) {
    
    // ═══════════════════════════════════════════════════
    // DETECT BILLING COUNTRY CHANGES
    // ═══════════════════════════════════════════════════
    
    List<DataMigrationEvent__e> events = new List<DataMigrationEvent__e>();
    
    for (Account newAccount : Trigger.new) {
        Account oldAccount = Trigger.oldMap.get(newAccount.Id);
        
        // Check if BillingCountry has changed
        if (newAccount.BillingCountry != oldAccount.BillingCountry) {
            
            // Create Platform Event
            DataMigrationEvent__e event = new DataMigrationEvent__e(
                AccountId__c = newAccount.Id,
                OldCountry__c = oldAccount.BillingCountry,
                NewCountry__c = newAccount.BillingCountry,
                Reason__c = 'Country Change - Automatic Detection'
            );
            
            events.add(event);
            
            System.debug('═══ DATA MIGRATION EVENT DETECTED ═══');
            System.debug('Account ID: ' + newAccount.Id);
            System.debug('Old Country: ' + oldAccount.BillingCountry);
            System.debug('New Country: ' + newAccount.BillingCountry);
        }
    }
    
    // ═══════════════════════════════════════════════════
    // PUBLISH EVENTS
    // ═══════════════════════════════════════════════════
    
    if (!events.isEmpty()) {
        List<Database.SaveResult> results = EventBus.publish(events);
        
        // Log results
        for (Database.SaveResult result : results) {
            if (result.isSuccess()) {
                System.debug('✅ Event published successfully');
            } else {
                for (Database.Error error : result.getErrors()) {
                    System.debug('❌ Event publish failed: ' + error.getMessage());
                }
            }
        }
        
        System.debug('Total events published: ' + events.size());
    }
}