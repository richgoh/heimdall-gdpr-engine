/**
 * @description Queueable Apex class for asynchronous Account anonymization.
 *              Implements GDPR "Right to be Forgotten" by replacing PII with generic values.
 *              Supports chaining to process unlimited records (200 at a time).
 *
 * @author      [Richard GOH]
 * @date        2026-02
 * @project     Heimdall GDPR Engine
 */
public class AnonymizationQueue implements Queueable {

    // ─────────────────────────────────────────
    // CONSTANTS
    // ─────────────────────────────────────────

    private static final Integer BATCH_SIZE = 200;
    private static final String ANON_EMAIL_DOMAIN = '@anonymized.gdpr';
    private static final String ANON_PHONE = '+00000000000';

    // ─────────────────────────────────────────
    // INSTANCE VARIABLES
    // ─────────────────────────────────────────

    private Set<Id> accountIds;
    private Integer processedCount;

    // ─────────────────────────────────────────
    // CONSTRUCTOR
    // ─────────────────────────────────────────

    /**
     * @description Constructor for initial job
     * @param accountIds Set of Account IDs to anonymize
     */
    public AnonymizationQueue(Set<Id> accountIds) {
        this.accountIds = accountIds;
        this.processedCount = 0;
    }

    /**
     * @description Constructor for chained jobs (tracks progress)
     * @param accountIds Remaining Account IDs
     * @param processedCount Number of accounts already processed
     */
    public AnonymizationQueue(Set<Id> accountIds, Integer processedCount) {
        this.accountIds = accountIds;
        this.processedCount = processedCount;
    }

    // ─────────────────────────────────────────
    // QUEUEABLE INTERFACE
    // ─────────────────────────────────────────

    /**
     * @description Main execution method called by Salesforce
     * @param context QueueableContext provided by Salesforce
     */
    public void execute(QueueableContext context) {
        System.debug('═══════════════════════════════════════════════════');
        System.debug('AnonymizationQueue STARTED');
        System.debug('Job ID: ' + context.getJobId());
        System.debug('Total accounts to process: ' + accountIds.size());
        System.debug('Already processed: ' + processedCount);
        System.debug('═══════════════════════════════════════════════════');

        if (accountIds == null || accountIds.isEmpty()) {
            System.debug('⚠️  No accounts to process. Exiting.');
            return;
        }

        // Step 1: Select a batch of accounts (max 200)
        List<Id> currentBatch = new List<Id>();
        List<Id> remainingIds = new List<Id>(accountIds);

        Integer batchLimit = Math.min(BATCH_SIZE, remainingIds.size());

        for (Integer i = 0; i < batchLimit; i++) {
            currentBatch.add(remainingIds[i]);
        }

        System.debug('Current batch size: ' + currentBatch.size());

        // Step 2: Anonymize the current batch
        Integer anonymizedCount = anonymizeAccounts(new Set<Id>(currentBatch));

        // Step 3: Prepare remaining IDs for next job
        Set<Id> remainingSet = new Set<Id>();
        for (Integer i = batchLimit; i < remainingIds.size(); i++) {
            remainingSet.add(remainingIds[i]);
        }

        Integer newProcessedCount = processedCount + anonymizedCount;

        System.debug('──────────────────────────────────────────────────');
        System.debug('Batch complete:');
        System.debug('  Anonymized: ' + anonymizedCount);
        System.debug('  Total processed: ' + newProcessedCount);
        System.debug('  Remaining: ' + remainingSet.size());
        System.debug('──────────────────────────────────────────────────');

        // Step 4: Chain next job if there are remaining accounts
        if (!remainingSet.isEmpty()) {
            System.debug('🔄 Chaining next job...');
            AnonymizationQueue nextJob = new AnonymizationQueue(remainingSet, newProcessedCount);
            System.enqueueJob(nextJob);
        } else {
            System.debug('✅ ALL ACCOUNTS ANONYMIZED!');
            System.debug('Total processed: ' + newProcessedCount);
        }

        System.debug('═══════════════════════════════════════════════════');
    }

    // ─────────────────────────────────────────
    // PRIVATE METHODS
    // ─────────────────────────────────────────

    /**
     * @description Anonymizes a batch of Account records
     * @param accountIds Set of Account IDs to anonymize
     * @return Number of accounts successfully anonymized
     */
    private Integer anonymizeAccounts(Set<Id> accountIds) {
        AccountsSelector selector = new AccountsSelector();
        List<Account> accounts = selector.selectById(accountIds);

        if (accounts.isEmpty()) {
            return 0;
        }

        List<Account> accountsToUpdate = new List<Account>();

        for (Account acc : accounts) {
            Account anonymized = new Account(Id = acc.Id);

            // Anonymize Name
            anonymized.Name = 'Anonymized Account ' + acc.Id.to15();

            // Anonymize Phone (if present)
            if (String.isNotBlank(acc.Phone)) {
                anonymized.Phone = ANON_PHONE;
            }

            // Anonymize Address fields
            if (String.isNotBlank(acc.BillingStreet)) {
                anonymized.BillingStreet = '[REDACTED]';
            }

            if (String.isNotBlank(acc.BillingCity)) {
                anonymized.BillingCity = '[REDACTED]';
            }

            accountsToUpdate.add(anonymized);

            System.debug('Anonymized: ' + acc.Name + ' → ' + anonymized.Name);
        }

        // Update accounts
        try {
            update accountsToUpdate;
            System.debug('✅ Successfully anonymized ' + accountsToUpdate.size() + ' accounts');
            return accountsToUpdate.size();
        } catch (Exception e) {
            System.debug('❌ ERROR anonymizing accounts: ' + e.getMessage());
            return 0;
        }
    }
}