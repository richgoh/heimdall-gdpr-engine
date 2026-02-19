import { LightningElement, wire } from 'lwc';
import getZoneStatistics from '@salesforce/apex/GdprDashboardController.getZoneStatistics';
import getTotalAccountCount from '@salesforce/apex/GdprDashboardController.getTotalAccountCount';
import getEncryptedAccountCount from '@salesforce/apex/GdprDashboardController.getEncryptedAccountCount';

export default class GdprDashboard extends LightningElement {
    // ─────────────────────────────────────────
    // PROPERTIES
    // ─────────────────────────────────────────
    
    zoneStats = [];
    totalAccounts = 0;
    encryptedAccounts = 0;
    error;
    isLoading = true;

    // ─────────────────────────────────────────
    // WIRE ADAPTERS (Auto data fetching)
    // ─────────────────────────────────────────

    /**
     * Wire adapter to get zone statistics
     */
    @wire(getZoneStatistics)
    wiredZoneStats({ error, data }) {
        if (data) {
            this.zoneStats = data;
            this.error = undefined;
        } else if (error) {
            this.error = 'Error loading zone statistics: ' + this.getErrorMessage(error);
            this.zoneStats = [];
        }
        this.checkLoadingComplete();
    }

    /**
     * Wire adapter to get total account count
     */
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

    /**
     * Wire adapter to get encrypted account count
     */
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
    // COMPUTED PROPERTIES (Getters)
    // ─────────────────────────────────────────

    /**
     * Calculate encryption rate percentage
     */
    get encryptionRate() {
        if (this.totalAccounts === 0) {
            return 0;
        }
        return Math.round((this.encryptedAccounts / this.totalAccounts) * 100);
    }

    /**
     * Check if zone stats are available
     */
    get hasZoneStats() {
        return this.zoneStats && this.zoneStats.length > 0;
    }

    // ─────────────────────────────────────────
    // HELPER METHODS
    // ─────────────────────────────────────────

    /**
     * Check if all wire adapters have completed
     */
    checkLoadingComplete() {
        // Simple approach: wait a bit for all wires to complete
        setTimeout(() => {
            this.isLoading = false;
        }, 500);
    }

    /**
     * Extract error message from error object
     */
    getErrorMessage(error) {
        if (error.body && error.body.message) {
            return error.body.message;
        } else if (error.message) {
            return error.message;
        }
        return 'Unknown error';
    }
}