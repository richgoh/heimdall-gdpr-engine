/**
 * @description Test class for DataResidencyService
 *              Validates GDPR routing logic and zone detection
 *              Target: 90%+ code coverage
 *
 * @author      Richard B. GOH
 * @date        2026-02
 * @project     Heimdall GDPR Engine - Test Suite
 */
@isTest
private class DataResidencyServiceTest {

    // ═══════════════════════════════════════════════════
    // TEST : processAccounts() - EU Zone
    // ═══════════════════════════════════════════════════

    @isTest
    static void testProcessAccounts_France_ShouldRouteToEU() {
        // ARRANGE : Créer un compte français
        Account frenchAccount = TestDataFactory.createAndInsertAccount('France');
        
        // ACT : Tester le routing
        Test.startTest();  // ← VOICI startTest() !
        
        DataResidencyService service = new DataResidencyService();
        List<DataResidencyService.ResidencyResult> results = 
            service.processAccounts(new Set<Id>{frenchAccount.Id});
        
        Test.stopTest();  // ← VOICI stopTest() !
        
        // ASSERT : Vérifier que le compte est routé vers EU
        System.assertEquals(1, results.size(), 'Should return 1 result');
        System.assertEquals('EU', results[0].detectedZone, 'France should route to EU zone');
        System.assertEquals(true, results[0].requiresEncryption, 'EU zone requires encryption');
        System.assertEquals('SUCCESS', results[0].status, 'Status should be SUCCESS');
        System.assertNotEquals(null, results[0].storageUrl, 'Storage URL should be set');
    }

    @isTest
    static void testProcessAccounts_Germany_ShouldRouteToEU() {
        // ARRANGE
        Account germanAccount = TestDataFactory.createAndInsertAccount('Germany');
        
        // ACT
        Test.startTest();
        
        DataResidencyService service = new DataResidencyService();
        List<DataResidencyService.ResidencyResult> results = 
            service.processAccounts(new Set<Id>{germanAccount.Id});
        
        Test.stopTest();
        
        // ASSERT
        System.assertEquals('EU', results[0].detectedZone);
        System.assertEquals(true, results[0].requiresEncryption);
    }

    // ═══════════════════════════════════════════════════
    // TEST : processAccounts() - US Zone
    // ═══════════════════════════════════════════════════

    @isTest
    static void testProcessAccounts_USA_ShouldRouteToUS() {
        // ARRANGE
        Account usAccount = TestDataFactory.createAndInsertAccount('United States');
        
        // ACT
        Test.startTest();
        
        DataResidencyService service = new DataResidencyService();
        List<DataResidencyService.ResidencyResult> results = 
            service.processAccounts(new Set<Id>{usAccount.Id});
        
        Test.stopTest();
        
        // ASSERT
        System.assertEquals(1, results.size());
        System.assertEquals('US', results[0].detectedZone, 'USA should route to US zone');
        System.assertEquals(false, results[0].requiresEncryption, 'US zone does not require encryption');
        System.assertEquals('SUCCESS', results[0].status);
    }

    // ═══════════════════════════════════════════════════
    // TEST : processAccounts() - EMEA Zone
    // ═══════════════════════════════════════════════════

    @isTest
    static void testProcessAccounts_Nigeria_ShouldRouteToEMEA() {
        // ARRANGE
        Account nigerianAccount = TestDataFactory.createAndInsertAccount('Nigeria');
        
        // ACT
        Test.startTest();
        
        DataResidencyService service = new DataResidencyService();
        List<DataResidencyService.ResidencyResult> results = 
            service.processAccounts(new Set<Id>{nigerianAccount.Id});
        
        Test.stopTest();
        
        // ASSERT
        System.assertEquals('EMEA', results[0].detectedZone, 'Nigeria should route to EMEA zone');
        System.assertEquals(true, results[0].requiresEncryption, 'EMEA zone requires encryption');
    }

    @isTest
    static void testProcessAccounts_IvoryCoast_ShouldRouteToEMEA() {
        // ARRANGE
        Account ivoirianAccount = TestDataFactory.createAndInsertAccount('Ivory Coast');
        
        // ACT
        Test.startTest();
        
        DataResidencyService service = new DataResidencyService();
        List<DataResidencyService.ResidencyResult> results = 
            service.processAccounts(new Set<Id>{ivoirianAccount.Id});
        
        Test.stopTest();
        
        // ASSERT
        System.assertEquals('EMEA', results[0].detectedZone, 'Ivory Coast should route to EMEA zone');
    }

    // ═══════════════════════════════════════════════════
    // TEST : processAccounts() - Multiple Accounts
    // ═══════════════════════════════════════════════════

    @isTest
    static void testProcessAccounts_MultipleCountries_ShouldRouteCorrectly() {
        // ARRANGE : Créer des comptes dans différents pays
        List<Account> accounts = TestDataFactory.createAndInsertAccounts(
            new List<String>{'France', 'United States', 'Nigeria', 'Germany', 'Kenya'}
        );
        
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        
        // ACT
        Test.startTest();
        
        DataResidencyService service = new DataResidencyService();
        List<DataResidencyService.ResidencyResult> results = service.processAccounts(accountIds);
        
        Test.stopTest();
        
        // ASSERT
        System.assertEquals(5, results.size(), 'Should return 5 results');
        
        // Compter par zone
        Integer euCount = 0;
        Integer usCount = 0;
        Integer emeaCount = 0;
        
        for (DataResidencyService.ResidencyResult result : results) {
            if (result.detectedZone == 'EU') euCount++;
            if (result.detectedZone == 'US') usCount++;
            if (result.detectedZone == 'EMEA') emeaCount++;
        }
        
        System.assertEquals(2, euCount, 'Should have 2 EU accounts (France, Germany)');
        System.assertEquals(1, usCount, 'Should have 1 US account');
        System.assertEquals(2, emeaCount, 'Should have 2 EMEA accounts (Nigeria, Kenya)');
    }

    // ═══════════════════════════════════════════════════
    // TEST : processAccounts() - Edge Cases
    // ═══════════════════════════════════════════════════

    @isTest
    static void testProcessAccounts_NullInput_ShouldReturnEmptyList() {
        // ARRANGE : Pas de données
        
        // ACT
        Test.startTest();
        
        DataResidencyService service = new DataResidencyService();
        List<DataResidencyService.ResidencyResult> results = service.processAccounts(null);
        
        Test.stopTest();
        
        // ASSERT : Guard clause devrait retourner liste vide
        System.assertEquals(0, results.size(), 'Null input should return empty list');
    }

    @isTest
    static void testProcessAccounts_EmptySet_ShouldReturnEmptyList() {
        // ARRANGE
        Set<Id> emptySet = new Set<Id>();
        
        // ACT
        Test.startTest();
        
        DataResidencyService service = new DataResidencyService();
        List<DataResidencyService.ResidencyResult> results = service.processAccounts(emptySet);
        
        Test.stopTest();
        
        // ASSERT
        System.assertEquals(0, results.size(), 'Empty Set should return empty list');
    }

    @isTest
    static void testProcessAccounts_NoCountry_ShouldReturnError() {
        // ARRANGE : Créer un compte SANS pays
        Account accountWithoutCountry = new Account(
            Name = 'No Country Account',
            BillingCountry = null
        );
        insert accountWithoutCountry;
        
        // ACT
        Test.startTest();
        
        DataResidencyService service = new DataResidencyService();
        List<DataResidencyService.ResidencyResult> results = 
            service.processAccounts(new Set<Id>{accountWithoutCountry.Id});
        
        Test.stopTest();
        
        // ASSERT : Devrait retourner un résultat avec status ERROR
        System.assertEquals(1, results.size());
        System.assertEquals('ERROR', results[0].status, 'No country should result in ERROR status');
        System.assertEquals('UNKNOWN', results[0].detectedZone);
        System.assert(results[0].message.contains('No BillingCountry'), 'Error message should mention missing country');
    }

    @isTest
    static void testProcessAccounts_UnknownCountry_ShouldReturnError() {
        // ARRANGE : Créer un compte avec un pays non configuré
        Account unknownCountryAccount = TestDataFactory.createAndInsertAccount('Antarctica');
        
        // ACT
        Test.startTest();
        
        DataResidencyService service = new DataResidencyService();
        List<DataResidencyService.ResidencyResult> results = 
            service.processAccounts(new Set<Id>{unknownCountryAccount.Id});
        
        Test.stopTest();
        
        // ASSERT
        System.assertEquals('ERROR', results[0].status, 'Unknown country should result in ERROR');
        System.assertEquals('UNKNOWN', results[0].detectedZone);
        System.assert(results[0].message.contains('No GDPR rule found'), 'Should mention no rule found');
    }

    // ═══════════════════════════════════════════════════
    // TEST : getAccountsByZone()
    // ═══════════════════════════════════════════════════

    @isTest
    static void testGetAccountsByZone_EU_ShouldReturnEUAccounts() {
        // ARRANGE : Créer des comptes dans différentes zones
        TestDataFactory.createAndInsertAccounts(
            new List<String>{'France', 'Germany', 'United States', 'Nigeria'}
        );
        
        // ACT
        Test.startTest();
        
        DataResidencyService service = new DataResidencyService();
        List<Account> euAccounts = service.getAccountsByZone('EU');
        
        Test.stopTest();
        
        // ASSERT
        System.assertEquals(2, euAccounts.size(), 'Should return 2 EU accounts');
        
        // Vérifier que tous sont bien des pays EU
        for (Account acc : euAccounts) {
            System.assert(
                acc.BillingCountry == 'France' || acc.BillingCountry == 'Germany',
                'All accounts should be from EU countries'
            );
        }
    }

    @isTest
    static void testGetAccountsByZone_US_ShouldReturnUSAccounts() {
        // ARRANGE
        TestDataFactory.createAndInsertAccounts(
            new List<String>{'France', 'United States', 'Nigeria'}
        );
        
        // ACT
        Test.startTest();
        
        DataResidencyService service = new DataResidencyService();
        List<Account> usAccounts = service.getAccountsByZone('US');
        
        Test.stopTest();
        
        // ASSERT
        System.assertEquals(1, usAccounts.size(), 'Should return 1 US account');
        System.assertEquals('United States', usAccounts[0].BillingCountry);
    }

    @isTest
    static void testGetAccountsByZone_EMEA_ShouldReturnEMEAAccounts() {
        // ARRANGE
        TestDataFactory.createAndInsertAccounts(
            new List<String>{'France', 'Nigeria', 'Kenya', 'Ivory Coast'}
        );
        
        // ACT
        Test.startTest();
        
        DataResidencyService service = new DataResidencyService();
        List<Account> emeaAccounts = service.getAccountsByZone('EMEA');
        
        Test.stopTest();
        
        // ASSERT
        System.assertEquals(3, emeaAccounts.size(), 'Should return 3 EMEA accounts');
    }

    @isTest
    static void testGetAccountsByZone_InvalidZone_ShouldReturnEmptyList() {
        // ARRANGE
        TestDataFactory.createAndInsertAccount('France');
        
        // ACT
        Test.startTest();
        
        DataResidencyService service = new DataResidencyService();
        List<Account> results = service.getAccountsByZone('INVALID_ZONE');
        
        Test.stopTest();
        
        // ASSERT
        System.assertEquals(0, results.size(), 'Invalid zone should return empty list');
    }

    @isTest
    static void testGetAccountsByZone_NullZone_ShouldReturnEmptyList() {
        // ARRANGE
        TestDataFactory.createAndInsertAccount('France');
        
        // ACT
        Test.startTest();
        
        DataResidencyService service = new DataResidencyService();
        List<Account> results = service.getAccountsByZone(null);
        
        Test.stopTest();
        
        // ASSERT : Guard clause devrait retourner liste vide
        System.assertEquals(0, results.size(), 'Null zone should return empty list');
    }

    @isTest
    static void testGetAccountsByZone_EmptyZone_ShouldReturnEmptyList() {
        // ARRANGE
        TestDataFactory.createAndInsertAccount('France');
        
        // ACT
        Test.startTest();
        
        DataResidencyService service = new DataResidencyService();
        List<Account> results = service.getAccountsByZone('');
        
        Test.stopTest();
        
        // ASSERT
        System.assertEquals(0, results.size(), 'Empty zone should return empty list');
    }
}