/**
 * @description Test Data Factory for creating test records across all test classes.
 *              Centralizes test data creation to avoid duplication and ensure consistency.
 *
 * @author      Richard B. GOH
 * @date        2026-02
 * @project     Heimdall GDPR Engine - Test Infrastructure
 */
@isTest
public class TestDataFactory {

    // ─────────────────────────────────────────
    // ACCOUNT FACTORY METHODS
    // ─────────────────────────────────────────

    /**
     * @description Creates a single Account with specified country
     * @param country BillingCountry value
     * @return Account record (not inserted)
     */
    public static Account createAccount(String country) {
        return new Account(
            Name = 'Test Account ' + country,
            BillingCountry = country,
            BillingCity = 'Test City',
            BillingStreet = '123 Test Street',
            Phone = '+33600000000'
        );
    }

    /**
     * @description Creates a single Account with specified country and inserts it
     * @param country BillingCountry value
     * @return Inserted Account record
     */
    public static Account createAndInsertAccount(String country) {
        Account acc = createAccount(country);
        insert acc;
        return acc;
    }

    /**
     * @description Creates multiple Accounts with different countries
     * @param countries List of BillingCountry values
     * @return List of Account records (not inserted)
     */
    public static List<Account> createAccounts(List<String> countries) {
        List<Account> accounts = new List<Account>();
        
        for (String country : countries) {
            accounts.add(createAccount(country));
        }
        
        return accounts;
    }

    /**
     * @description Creates and inserts multiple Accounts with different countries
     * @param countries List of BillingCountry values
     * @return List of inserted Account records
     */
    public static List<Account> createAndInsertAccounts(List<String> countries) {
        List<Account> accounts = createAccounts(countries);
        insert accounts;
        return accounts;
    }

    /**
     * @description Creates multiple Accounts for bulk testing (same country)
     * @param country BillingCountry value
     * @param count Number of accounts to create
     * @return List of Account records (not inserted)
     */
    public static List<Account> createBulkAccounts(String country, Integer count) {
        List<Account> accounts = new List<Account>();
        
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(
                Name = 'Bulk Test ' + country + ' ' + i,
                BillingCountry = country,
                BillingCity = 'City ' + i,
                BillingStreet = 'Street ' + i,
                Phone = '+336000' + String.valueOf(i).leftPad(5, '0')
            ));
        }
        
        return accounts;
    }

    // ─────────────────────────────────────────
    // MOCK DATA RESIDENCY RULES
    // ─────────────────────────────────────────

    /**
     * @description Creates mock EU zone rule for testing
     *              Note: Custom Metadata cannot be inserted in tests,
     *              so this is for mocking purposes only
     * @return Mock DataResidencyRule__mdt for EU
     */
    public static DataResidencyRule__mdt createMockEURule() {
        // Note: In real tests, we'll mock the Selector response
        // This method is here for documentation purposes
        
        DataResidencyRule__mdt mockRule = new DataResidencyRule__mdt();
        // Custom Metadata fields can't be set in memory like this
        // This is just a placeholder for understanding
        
        return mockRule;
    }
}