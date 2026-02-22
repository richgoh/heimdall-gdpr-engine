/**
 * Mock for @salesforce/apex module
 * Allows testing @wire adapters without real Apex calls
 */
export function createApexTestWireAdapter() {
    return {
        emit: jest.fn(),
        getLastConfig: jest.fn(),
    };
}