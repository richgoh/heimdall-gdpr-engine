/**
 * @description Selector class for Account standard object.
 *              Centralizes all Account SOQL queries following Selector Pattern.
 *              Enforces Field-Level Security (FLS) via WITH SECURITY_ENFORCED.
 *
 * @author      [Ton Nom]
 * @date        2026-02
 * @project     Heimdall GDPR Engine
 */
public with sharing class AccountsSelector {

    // ─────────────────────────────────────────
    // CONSTANTS
    // ─────────────────────────────────────────

    private static final Integer DEFAULT_LIMIT = 200;

    // ─────────────────────────────────────────
    // BASE FIELDS
    // ─────────────────────────────────────────

    /**
     * @description Returns base fields for Account queries.
     *              Includes PII fields relevant to GDPR processing.
     * @return List of field API names
     */
    private List<String> getBaseFields() {
        return new List<String>{
            'Id',
            'Name',
            'BillingCountry',
            'BillingCity',
            'BillingStreet',
            'Phone',
            'PersonEmail',
            'CreatedDate',
            'LastModifiedDate'
        };
    }

    // ─────────────────────────────────────────
    // QUERY METHODS
    // ─────────────────────────────────────────

    /**
     * @description Retrieves Accounts by a Set of IDs.
     *              Guard clause protects against empty Set queries.
     * @param accountIds Set of Account record IDs
     * @return List of Account records
     */
    public List<Account> selectById(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return new List<Account>();
        }

        String query = buildBaseQuery() +
                      ' WHERE Id IN :accountIds' +
                      ' WITH SECURITY_ENFORCED' +
                      ' ORDER BY Name ASC' +
                      ' LIMIT :DEFAULT_LIMIT';

        return Database.query(query);
    }

    /**
     * @description Retrieves Accounts filtered by BillingCountry.
     *              Used by the GDPR engine to find accounts per zone.
     * @param countries Set of country names (e.g., {'France', 'Germany'})
     * @return List of Account records
     */
    public List<Account> selectByCountry(Set<String> countries) {
        if (countries == null || countries.isEmpty()) {
            return new List<Account>();
        }

        String query = buildBaseQuery() +
                      ' WHERE BillingCountry IN :countries' +
                      ' WITH SECURITY_ENFORCED' +
                      ' ORDER BY BillingCountry ASC, Name ASC' +
                      ' LIMIT :DEFAULT_LIMIT';

        return Database.query(query);
    }

    /**
     * @description Retrieves Accounts modified within the last N days.
     *              Used for incremental GDPR processing jobs.
     * @param days Number of days to look back (minimum 1)
     * @return List of recently modified Account records
     */
    public List<Account> selectRecentlyModified(Integer days) {
        if (days == null || days < 1) {
            days = 7;
        }

        DateTime cutoffDate = DateTime.now().addDays(-days);

        String query = buildBaseQuery() +
                      ' WHERE LastModifiedDate >= :cutoffDate' +
                      ' WITH SECURITY_ENFORCED' +
                      ' ORDER BY LastModifiedDate DESC' +
                      ' LIMIT :DEFAULT_LIMIT';

        return Database.query(query);
    }

    // ─────────────────────────────────────────
    // PRIVATE HELPERS
    // ─────────────────────────────────────────

    /**
     * @description Builds base SELECT query for Account.
     * @return Base SOQL query string (without WHERE clause)
     */
    private String buildBaseQuery() {
        String fields = String.join(getBaseFields(), ', ');
        return 'SELECT ' + fields + ' FROM Account';
    }
}