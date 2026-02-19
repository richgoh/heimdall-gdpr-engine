/**
 * @description Apex Controller for gdpr-dashboard LWC
 *              Provides GDPR zone statistics and account distribution data
 *
 * @author      Richard B. GOH
 * @date        2026-02
 * @project     Heimdall GDPR Engine - LWC Dashboard
 */
public with sharing class GdprDashboardController {

    /**
     * @description Inner class to hold zone statistics
     */
    public class ZoneStats {
        @AuraEnabled public String zoneName { get; set; }
        @AuraEnabled public String zoneCode { get; set; }
        @AuraEnabled public Integer accountCount { get; set; }
        @AuraEnabled public Boolean requiresEncryption { get; set; }
        @AuraEnabled public String storageUrl { get; set; }
        
        public ZoneStats(String zoneName, String zoneCode, Integer accountCount, 
                        Boolean requiresEncryption, String storageUrl) {
            this.zoneName = zoneName;
            this.zoneCode = zoneCode;
            this.accountCount = accountCount;
            this.requiresEncryption = requiresEncryption;
            this.storageUrl = storageUrl;
        }
    }

    /**
     * @description Get statistics for all GDPR zones
     * @return List of ZoneStats with account counts per zone
     */
    @AuraEnabled(cacheable=true)
    public static List<ZoneStats> getZoneStatistics() {
        List<ZoneStats> stats = new List<ZoneStats>();
        
        try {
            // Get all active GDPR rules
            DataResidencyRulesSelector rulesSelector = new DataResidencyRulesSelector();
            List<DataResidencyRule__mdt> rules = rulesSelector.selectAllActive();
            
            // Get service to query accounts
            DataResidencyService service = new DataResidencyService();
            
            // For each zone, count accounts
            for (DataResidencyRule__mdt rule : rules) {
                List<Account> accounts = service.getAccountsByZone(rule.Zone_Code__c);
                
                stats.add(new ZoneStats(
                    rule.Label,
                    rule.Zone_Code__c,
                    accounts.size(),
                    rule.Requires_Encryption__c,
                    rule.External_Storage_URL__c
                ));
            }
            
            return stats;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving zone statistics: ' + e.getMessage());
        }
    }

    /**
     * @description Get total count of all accounts
     * @return Total number of accounts in the org
     */
    @AuraEnabled(cacheable=true)
    public static Integer getTotalAccountCount() {
        try {
            return [SELECT COUNT() FROM Account];
        } catch (Exception e) {
            throw new AuraHandledException('Error counting accounts: ' + e.getMessage());
        }
    }

    /**
     * @description Get count of accounts requiring encryption
     * @return Number of accounts in zones requiring encryption
     */
    @AuraEnabled(cacheable=true)
    public static Integer getEncryptedAccountCount() {
        try {
            DataResidencyService service = new DataResidencyService();
            
            // Get accounts from EU and EMEA zones (both require encryption)
            List<Account> euAccounts = service.getAccountsByZone('EU');
            List<Account> emeaAccounts = service.getAccountsByZone('EMEA');
            
            return euAccounts.size() + emeaAccounts.size();
            
        } catch (Exception e) {
            throw new AuraHandledException('Error counting encrypted accounts: ' + e.getMessage());
        }
    }

    /**
     * @description Get recent accounts modified in the last N days
     * @param days Number of days to look back
     * @return List of recently modified accounts with their zone info
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> getRecentAccounts(Integer days) {
        try {
            AccountsSelector selector = new AccountsSelector();
            return selector.selectRecentlyModified(days);
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving recent accounts: ' + e.getMessage());
        }
    }
}