/**
 * @description Trigger on DataMigrationEvent__e to handle account data migration
 * @author      Richard GOH
 * @date        2026-02
 * @project     Heimdall GDPR Engine - Event Subscriber
 */
trigger DataMigrationEventTrigger on DataMigrationEvent__e (after insert) {
    
    // ═══════════════════════════════════════════════════
    // PROCESS DATA MIGRATION EVENTS
    // ═══════════════════════════════════════════════════
    
    Set<Id> accountIdsToAnonymize = new Set<Id>();
    
    for (DataMigrationEvent__e event : Trigger.new) {
        
        System.debug('═══ RECEIVED DATA MIGRATION EVENT ═══');
        System.debug('Account ID: ' + event.AccountId__c);
        System.debug('Old Country: ' + event.OldCountry__c);
        System.debug('New Country: ' + event.NewCountry__c);
        System.debug('Reason: ' + event.Reason__c);
        
        // Add account to anonymization queue
        accountIdsToAnonymize.add(event.AccountId__c);
    }
    
    // ═══════════════════════════════════════════════════
    // LAUNCH ANONYMIZATION QUEUE
    // ═══════════════════════════════════════════════════
    
    if (!accountIdsToAnonymize.isEmpty()) {
        
        try {
            // Launch asynchronous anonymization
            AnonymizationQueue job = new AnonymizationQueue(accountIdsToAnonymize);
            Id jobId = System.enqueueJob(job);
            
            System.debug('✅ Anonymization job launched: ' + jobId);
            System.debug('Accounts to process: ' + accountIdsToAnonymize.size());
            
        } catch (Exception e) {
            System.debug('❌ Error launching anonymization job: ' + e.getMessage());
            // In production, log to custom object for monitoring
        }
    }
}