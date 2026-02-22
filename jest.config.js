const { jestConfig } = require('@salesforce/sfdx-lwc-jest/config');

module.exports = {
    ...jestConfig,
    
    // Ignore localdevserver (existant)
    modulePathIgnorePatterns: ['<rootDir>/.localdevserver'],
    
    // Mock modules (nouveaux)
    moduleNameMapper: {
        '^@salesforce/apex$': '<rootDir>/force-app/test/jest-mocks/apex',
        '^lightning/navigation$': '<rootDir>/force-app/test/jest-mocks/lightning/navigation',
    },
    
    // Ignore patterns (nouveaux)
    testPathIgnorePatterns: [
        '<rootDir>/node_modules/',
        '<rootDir>/.sfdx/',
        '<rootDir>/.localdevserver/',
    ],
};