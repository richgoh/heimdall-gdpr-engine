/**
 * Mock for lightning/navigation module
 * Provides stub implementations for navigation methods
 */
export const navigate = jest.fn();
export const generateUrl = jest.fn();

export const NavigationMixin = (Base) => {
    return class extends Base {
        navigate = navigate;
        generateUrl = generateUrl;
    };
};