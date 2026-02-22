import { createElement } from 'lwc';
import GdprDashboard from 'c/gdprDashboard';

describe('c-gdpr-dashboard', () => {
    afterEach(() => {
        // Clean up the DOM after each test
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    // ═══════════════════════════════════════════════════
    // TEST 1: Component Renders Successfully
    // ═══════════════════════════════════════════════════

    it('renders lightning-card with correct title', () => {
        const element = createElement('c-gdpr-dashboard', {
            is: GdprDashboard,
        });
        document.body.appendChild(element);

        const card = element.shadowRoot.querySelector('lightning-card');
        expect(card).not.toBeNull();
        expect(card.title).toBe('GDPR Data Residency Dashboard');
    });

    // ═══════════════════════════════════════════════════
    // TEST 2: Loading Spinner Exists
    // ═══════════════════════════════════════════════════

    it('contains loading spinner element', () => {
        const element = createElement('c-gdpr-dashboard', {
            is: GdprDashboard,
        });
        document.body.appendChild(element);

        const spinner = element.shadowRoot.querySelector('lightning-spinner');
        expect(spinner).not.toBeNull();
    });

    // ═══════════════════════════════════════════════════
    // TEST 3: Shadow DOM is Accessible
    // ═══════════════════════════════════════════════════

    it('has accessible shadow root', () => {
        const element = createElement('c-gdpr-dashboard', {
            is: GdprDashboard,
        });
        document.body.appendChild(element);

        expect(element.shadowRoot).not.toBeNull();
        expect(element.shadowRoot.querySelector('*')).not.toBeNull();
    });

    // ═══════════════════════════════════════════════════
    // TEST 4: Component Contains Template Content
    // ═══════════════════════════════════════════════════

    it('renders template with content', () => {
        const element = createElement('c-gdpr-dashboard', {
            is: GdprDashboard,
        });
        document.body.appendChild(element);

        const templates = element.shadowRoot.querySelectorAll('*');
        expect(templates.length).toBeGreaterThan(0);
    });

    // ═══════════════════════════════════════════════════
    // TEST 5: SLDS Classes Applied
    // ═══════════════════════════════════════════════════

    it('uses Salesforce Lightning Design System classes', () => {
        const element = createElement('c-gdpr-dashboard', {
            is: GdprDashboard,
        });
        document.body.appendChild(element);

        // Verify SLDS classes are present
        const sldsElements = element.shadowRoot.querySelectorAll('[class*="slds-"]');
        expect(sldsElements.length).toBeGreaterThan(0);
    });

    // ═══════════════════════════════════════════════════
    // TEST 6: Component Icon Configured
    // ═══════════════════════════════════════════════════

    it('lightning-card has icon configured', () => {
        const element = createElement('c-gdpr-dashboard', {
            is: GdprDashboard,
        });
        document.body.appendChild(element);

        const card = element.shadowRoot.querySelector('lightning-card');
        expect(card.iconName).toBe('standard:dashboard');
    });

    // ═══════════════════════════════════════════════════
    // TEST 7: Responsive Grid Structure
    // ═══════════════════════════════════════════════════

    it('renders multiple child elements', () => {
    const element = createElement('c-gdpr-dashboard', {
        is: GdprDashboard,
    });
    document.body.appendChild(element);

    // Verify component has multiple elements
    const allElements = element.shadowRoot.querySelectorAll('*');
    expect(allElements.length).toBeGreaterThan(1);
});

    // ═══════════════════════════════════════════════════
    // TEST 8: Component Can Be Created
    // ═══════════════════════════════════════════════════

    it('can be instantiated without errors', () => {
        const element = createElement('c-gdpr-dashboard', {
            is: GdprDashboard,
        });
        
        expect(element).not.toBeNull();
        expect(element.tagName.toLowerCase()).toBe('c-gdpr-dashboard');
    });
});