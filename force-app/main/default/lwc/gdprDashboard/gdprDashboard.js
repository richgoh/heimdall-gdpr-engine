import { LightningElement, wire } from 'lwc';
import getZoneStatistics from '@salesforce/apex/GdprDashboardController.getZoneStatistics';
import getTotalAccountCount from '@salesforce/apex/GdprDashboardController.getTotalAccountCount';
import getEncryptedAccountCount from '@salesforce/apex/GdprDashboardController.getEncryptedAccountCount';

export default class GdprDashboard extends LightningElement {
    // ─────────────────────────────────────────
    // PROPERTIES
    // ─────────────────────────────────────────
    
    zoneStatsRaw = [];
    totalAccounts = 0;
    encryptedAccounts = 0;
    error;
    isLoading = true;

    // ─────────────────────────────────────────
    // WIRE ADAPTERS
    // ─────────────────────────────────────────

    @wire(getZoneStatistics)
    wiredZoneStats({ error, data }) {
        if (data) {
            this.zoneStatsRaw = data;
            this.error = undefined;
        } else if (error) {
            this.error = 'Error loading zone statistics: ' + this.getErrorMessage(error);
            this.zoneStatsRaw = [];
        }
        this.checkLoadingComplete();
    }

    @wire(getTotalAccountCount)
    wiredTotalAccounts({ error, data }) {
        if (data !== undefined) {
            this.totalAccounts = data;
            this.error = undefined;
        } else if (error) {
            this.error = 'Error loading total accounts: ' + this.getErrorMessage(error);
            this.totalAccounts = 0;
        }
        this.checkLoadingComplete();
    }

    @wire(getEncryptedAccountCount)
    wiredEncryptedAccounts({ error, data }) {
        if (data !== undefined) {
            this.encryptedAccounts = data;
            this.error = undefined;
        } else if (error) {
            this.error = 'Error loading encrypted accounts: ' + this.getErrorMessage(error);
            this.encryptedAccounts = 0;
        }
        this.checkLoadingComplete();
    }

    // ─────────────────────────────────────────
    // COMPUTED PROPERTIES
    // ─────────────────────────────────────────

    get encryptionRate() {
        if (this.totalAccounts === 0) {
            return 0;
        }
        return Math.round((this.encryptedAccounts / this.totalAccounts) * 100);
    }

    get hasZoneStats() {
        return this.zoneStats && this.zoneStats.length > 0;
    }

    get zoneStats() {
        if (!this.zoneStatsRaw || this.zoneStatsRaw.length === 0) {
            return [];
        }

        // Find max count for percentage calculation
        const maxCount = Math.max(...this.zoneStatsRaw.map(z => z.accountCount));
        
        // Add bar styling to each zone
        return this.zoneStatsRaw.map(zone => {
            const percentage = maxCount > 0 ? (zone.accountCount / maxCount) * 100 : 0;
            const color = this.getZoneColor(zone.zoneCode);
            
            return {
                ...zone,
                barStyle: `width: ${percentage}%; background-color: ${color};`
            };
        });
    }

    // ─────────────────────────────────────────
    // HELPER METHODS
    // ─────────────────────────────────────────

    checkLoadingComplete() {
        setTimeout(() => {
            this.isLoading = false;
        }, 500);
    }

    getErrorMessage(error) {
        if (error.body && error.body.message) {
            return error.body.message;
        } else if (error.message) {
            return error.message;
        }
        return 'Unknown error';
    }

    getZoneColor(zoneCode) {
        const colors = {
            'EU': '#2e844a',      // Green
            'US': '#0176d3',      // Blue
            'EMEA': '#ff9a00'     // Orange
        };
        return colors[zoneCode] || '#706e6b';
    }
}