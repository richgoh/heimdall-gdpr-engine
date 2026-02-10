/**
 * @description Selector class for DataResidencyRule__mdt Custom Metadata Type.
 *              Centralizes all SOQL queries following the Selector Pattern.
 *              
 * @author      [Ton Nom]
 * @date        2026-02
 * @project     Heimdall GDPR Engine
 */
public with sharing class DataResidencyRulesSelector {

    // ─────────────────────────────────────────
    // CONSTANTS
    // ─────────────────────────────────────────

    private static final String OBJECT_NAME = 'DataResidencyRule__mdt';

    // ─────────────────────────────────────────
    // BASE FIELDS
    // ─────────────────────────────────────────

    /**
     * @description Returns the base set of fields to query.
     *              Centralizes field selection for consistency.
     * @return List of field API names
     */
    private List<String> getBaseFields() {
        return new List<String>{
            'Id',
            'Label',
            'DeveloperName',
            'Zone_Code__c',
            'Countries__c',
            'External_Storage_URL__c',
            'Requires_Encryption__c',
            'Active__c'
        };
    }

    // ─────────────────────────────────────────
    // QUERY METHODS
    // ─────────────────────────────────────────

    /**
     * @description Retrieves ALL active Data Residency Rules.
     *              Use this for bulk processing or initialization.
     * @return List of active DataResidencyRule__mdt records
     */
    public List<DataResidencyRule__mdt> selectAllActive() {
        String query = buildBaseQuery() + ' WHERE Active__c = true ORDER BY Zone_Code__c ASC';
        return Database.query(query);
    }

    /**
     * @description Retrieves a single rule by Zone Code.
     *              Use this to find the rule for a specific country.
     * @param zoneCode The zone identifier (e.g., 'EU', 'US', 'APAC')
     * @return DataResidencyRule__mdt record or null if not found
     */
    public DataResidencyRule__mdt selectByZoneCode(String zoneCode) {
        if (String.isBlank(zoneCode)) {
            return null;
        }

        String query = buildBaseQuery() + 
                      ' WHERE Zone_Code__c = :zoneCode' +
                      ' AND Active__c = true' +
                      ' LIMIT 1';

        List<DataResidencyRule__mdt> results = Database.query(query);
        return results.isEmpty() ? null : results[0];
    }

    /**
     * @description Retrieves all rules (active AND inactive).
     *              Use this for admin/reporting purposes only.
     * @return List of all DataResidencyRule__mdt records
     */
    public List<DataResidencyRule__mdt> selectAll() {
        String query = buildBaseQuery() + ' ORDER BY Active__c DESC, Zone_Code__c ASC';
        return Database.query(query);
    }

    // ─────────────────────────────────────────
    // PRIVATE HELPERS
    // ─────────────────────────────────────────

    /**
     * @description Builds the base SELECT query string.
     *              Avoids repetition across query methods.
     * @return Base SOQL query string (without WHERE clause)
     */
    private String buildBaseQuery() {
        String fields = String.join(getBaseFields(), ', ');
        return 'SELECT ' + fields + ' FROM ' + OBJECT_NAME;
    }
}