/**
 * @description Service class implementing the core GDPR Data Residency logic.
 *              Orchestrates zone routing and encryption decisions for Account records.
 *
 *              ARCHITECTURE :
 *              This class sits between Triggers/Batch jobs and the Selector layer.
 *              It contains ALL business logic - no SOQL here, only processing.
 *
 * @author      [Ton Nom]
 * @date        2026-02
 * @project     Heimdall GDPR Engine
 */
public with sharing class DataResidencyService {

    // ─────────────────────────────────────────
    // INNER CLASS : Result Object
    // ─────────────────────────────────────────

    /**
     * @description Represents the GDPR routing result for a single Account.
     *              Wraps all decisions made by the engine for one record.
     */
    public class ResidencyResult {
        public Id         accountId         { get; private set; }
        public String     accountName       { get; private set; }
        public String     detectedZone      { get; private set; }
        public Boolean    requiresEncryption { get; private set; }
        public String     storageUrl        { get; private set; }
        public String     status            { get; private set; }
        public String     message           { get; private set; }

        /**
         * @description Constructor for a successful routing result
         */
        public ResidencyResult(
            Id accountId,
            String accountName,
            DataResidencyRule__mdt rule
        ) {
            this.accountId          = accountId;
            this.accountName        = accountName;
            this.detectedZone       = rule.Zone_Code__c;
            this.requiresEncryption = rule.Requires_Encryption__c;
            this.storageUrl         = rule.External_Storage_URL__c;
            this.status             = 'SUCCESS';
            this.message            = 'Account routed to zone: ' + rule.Zone_Code__c;
        }

        /**
         * @description Constructor for a failed routing result
         */
        public ResidencyResult(Id accountId, String accountName, String errorMessage) {
            this.accountId          = accountId;
            this.accountName        = accountName;
            this.detectedZone       = 'UNKNOWN';
            this.requiresEncryption = false;
            this.storageUrl         = null;
            this.status             = 'ERROR';
            this.message            = errorMessage;
        }
    }

    // ─────────────────────────────────────────
    // INSTANCE VARIABLES
    // ─────────────────────────────────────────

    private DataResidencyRulesSelector rulesSelector;
    private AccountsSelector           accountsSelector;

    // ─────────────────────────────────────────
    // CONSTRUCTORS
    // ─────────────────────────────────────────

    /**
     * @description Default constructor.
     *              Creates its own selector instances.
     */
    public DataResidencyService() {
        this.rulesSelector    = new DataResidencyRulesSelector();
        this.accountsSelector = new AccountsSelector();
    }

    /**
     * @description Injectable constructor for unit testing.
     *              Allows mocking of selectors in tests.
     * @param rulesSelector    Injected DataResidencyRulesSelector
     * @param accountsSelector Injected AccountsSelector
     */
    public DataResidencyService(
        DataResidencyRulesSelector rulesSelector,
        AccountsSelector accountsSelector
    ) {
        this.rulesSelector    = rulesSelector;
        this.accountsSelector = accountsSelector;
    }

    // ─────────────────────────────────────────
    // PUBLIC METHODS
    // ─────────────────────────────────────────

    /**
     * @description Determines the GDPR zone for a list of Account IDs.
     *              Main entry point for the residency engine.
     * @param accountIds Set of Account IDs to process
     * @return List of ResidencyResult (one per Account)
     */
    public List<ResidencyResult> processAccounts(Set<Id> accountIds) {
        List<ResidencyResult> results = new List<ResidencyResult>();

        if (accountIds == null || accountIds.isEmpty()) {
            return results;
        }

        // Step 1 : Load active GDPR rules
        List<DataResidencyRule__mdt> activeRules = rulesSelector.selectAllActive();

        if (activeRules.isEmpty()) {
            return results;
        }

        // Step 2 : Build a map of countries to rules (for fast lookup)
        Map<String, DataResidencyRule__mdt> countryToRuleMap = buildCountryToRuleMap(activeRules);

        // Step 3 : Load accounts
        List<Account> accounts = accountsSelector.selectById(accountIds);

        // Step 4 : Process each account
        for (Account acc : accounts) {
            ResidencyResult result = routeAccount(acc, countryToRuleMap);
            results.add(result);
        }

        return results;
    }

    /**
     * @description Finds all Accounts in a specific GDPR zone.
     * @param zoneCode Zone identifier (e.g., 'EU', 'US')
     * @return List of Accounts belonging to the zone
     */
    public List<Account> getAccountsByZone(String zoneCode) {
        if (String.isBlank(zoneCode)) {
            return new List<Account>();
        }

        // Step 1 : Get the rule for this zone
        DataResidencyRule__mdt rule = rulesSelector.selectByZoneCode(zoneCode);

        if (rule == null || String.isBlank(rule.Countries__c)) {
            return new List<Account>();
        }

        // Step 2 : Parse countries from the rule
        Set<String> countries = parseCountries(rule.Countries__c);

        // Step 3 : Return accounts in those countries
        return accountsSelector.selectByCountry(countries);
    }

    // ─────────────────────────────────────────
    // PRIVATE HELPERS
    // ─────────────────────────────────────────

    /**
     * @description Routes a single Account to its GDPR zone.
     * @param acc            The Account to route
     * @param countryToRuleMap Map of country names to their rules
     * @return ResidencyResult with routing decision
     */
    private ResidencyResult routeAccount(
        Account acc,
        Map<String, DataResidencyRule__mdt> countryToRuleMap
    ) {
        // Guard : Account has no billing country
        if (String.isBlank(acc.BillingCountry)) {
            return new ResidencyResult(
                acc.Id,
                acc.Name,
                'No BillingCountry set. Cannot determine GDPR zone.'
            );
        }

        // Find the rule for this account's country
        DataResidencyRule__mdt matchingRule = countryToRuleMap.get(acc.BillingCountry);

        // No rule found for this country
        if (matchingRule == null) {
            return new ResidencyResult(
                acc.Id,
                acc.Name,
                'No GDPR rule found for country: ' + acc.BillingCountry
            );
        }

        // Success : rule found, return routing result
        return new ResidencyResult(acc.Id, acc.Name, matchingRule);
    }

    /**
     * @description Builds a Map<Country, Rule> from a list of rules.
     *              Enables O(1) lookup instead of O(n) loop.
     * @param rules List of active DataResidencyRule__mdt records
     * @return Map of country name to its rule
     */
    private Map<String, DataResidencyRule__mdt> buildCountryToRuleMap(
        List<DataResidencyRule__mdt> rules
    ) {
        Map<String, DataResidencyRule__mdt> countryMap = new Map<String, DataResidencyRule__mdt>();

        for (DataResidencyRule__mdt rule : rules) {
            if (String.isBlank(rule.Countries__c)) {
                continue;
            }

            Set<String> countries = parseCountries(rule.Countries__c);
            for (String country : countries) {
                countryMap.put(country, rule);
            }
        }

        return countryMap;
    }

    /**
     * @description Parses a comma-separated country string into a Set.
     *              Trims whitespace from each country name.
     * @param countriesString Comma-separated string (e.g., "France,Germany,Belgium")
     * @return Set of trimmed country names
     */
    private Set<String> parseCountries(String countriesString) {
        Set<String> countries = new Set<String>();

        if (String.isBlank(countriesString)) {
            return countries;
        }

        for (String country : countriesString.split(',')) {
            String trimmed = country.trim();
            if (String.isNotBlank(trimmed)) {
                countries.add(trimmed);
            }
        }

        return countries;
    }
}