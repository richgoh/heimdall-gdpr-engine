# 🏛️ Heimdall - GDPR Data Residency Engine

Enterprise-grade Salesforce solution for automated GDPR compliance, data residency management, and PII anonymization.

## 🎯 Business Case

European scale-ups lose deals due to unclear GDPR data handling. Heimdall automates data routing and anonymization based on legal residency requirements, ensuring compliance across EU, US, and EMEA Africa zones.

## 🌍 Geographic Coverage

| Zone | Countries | Encryption | Storage Region |
|------|-----------|------------|----------------|
| **EU** | France, Germany, Belgium, Luxembourg, Switzerland, Netherlands, Austria, Italy, Spain, Portugal | ✅ Required | AWS eu-central-1 |
| **US** | United States | ❌ Optional | AWS us-east-1 |
| **EMEA Africa** | South Africa, Nigeria, Kenya, Egypt, Morocco, Tunisia, Ghana, Ivory Coast, Senegal, Cameroon, Uganda, Tanzania, Ethiopia, Angola | ✅ Required | AWS af-south-1 |

## 🏗️ Architecture
```
┌─────────────────────────────────────────────────────────┐
│  LAYER 1: Configuration (Custom Metadata)               │
│  • DataResidencyRule__mdt (3 zones, 25+ countries)      │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  LAYER 2: Data Access (Selector Pattern)                │
│  • DataResidencyRulesSelector                           │
│  • AccountsSelector (WITH SECURITY_ENFORCED)            │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  LAYER 3: Business Logic (Service Layer)                │
│  • DataResidencyService (O(1) routing via Map)          │
│  • ResidencyResult (Structured output)                  │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  LAYER 4: Async Processing (Queueable)                  │
│  • AnonymizationQueue (Chaining for 10K+ records)       │
│  • PII Anonymization (Name, Phone, Address)             │
└─────────────────────────────────────────────────────────┘
```

## ✨ Key Features

### 🔄 Automated Data Routing
- Real-time zone detection based on `BillingCountry`
- Configurable rules via Custom Metadata (no code changes)
- Supports unlimited zones and countries

### 🔒 GDPR Compliance
- **Article 17**: Right to be Forgotten (PII anonymization)
- **Article 32**: Security of Processing (zone-specific encryption)
- Audit trail via structured logging

### ⚡ Performance Optimized
- **Map O(1)** country lookup (vs O(n×m) nested loops)
- **Queueable chaining** for unlimited record processing
- **Batch size**: 200 accounts per job
- **Governor Limits**: 60s CPU, 12MB Heap (async)

### 🌍 African Market Support
- First-class EMEA Africa zone
- 14 African countries configured
- Supports POPIA (South Africa), NDPR (Nigeria), Kenya DPA

## 🚀 Quick Start

### Prerequisites
- Salesforce Developer Edition or Sandbox
- Salesforce CLI (`sf` CLI v2.x)
- Git
- VS Code with Salesforce Extension Pack

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/richgoh/heimdall-gdpr-engine.git
cd heimdall-gdpr-engine
```

2. **Authenticate to your Salesforce org**
```bash
sf org login web --alias heimdall-dev
```

3. **Deploy the metadata**
```bash
sf project deploy start --source-dir force-app
```

4. **Verify Custom Metadata records**
- Setup → Custom Metadata Types → Data Residency Rule → Manage Records
- You should see 3 records: EU Zone, US Zone, EMEA Africa Zone

### Usage Example
```apex
// Route accounts to their GDPR zones
DataResidencyService service = new DataResidencyService();
Set<Id> accountIds = new Set<Id>{'001abc...', '001def...'};

List<DataResidencyService.ResidencyResult> results = service.processAccounts(accountIds);

for (DataResidencyService.ResidencyResult result : results) {
    System.debug('Account: ' + result.accountName);
    System.debug('Zone: ' + result.detectedZone);
    System.debug('Encryption Required: ' + result.requiresEncryption);
    System.debug('Storage URL: ' + result.storageUrl);
}

// Anonymize accounts (Queueable)
AnonymizationQueue job = new AnonymizationQueue(accountIds);
System.enqueueJob(job);
```

## 📊 Project Stats

| Metric | Value |
|--------|-------|
| **Lines of Code** | ~850 |
| **Apex Classes** | 4 |
| **Custom Metadata Types** | 1 |
| **Custom Fields** | 5 |
| **Zones Configured** | 3 |
| **Countries Supported** | 25+ |
| **Test Coverage** | In progress (Target: 90%+) |
| **API Version** | 65.0 |

## 🛠️ Tech Stack

- **Backend**: Apex (Selector Pattern, Service Layer, Queueable)
- **Data**: Custom Metadata Types, SOQL
- **Security**: WITH SECURITY_ENFORCED (FLS)
- **Performance**: Map O(1), Chaining
- **DevOps**: SFDX, SF CLI, Git

## 📅 Roadmap

- [x] Phase 1: Configuration & Selectors
- [x] Phase 2: Service Layer (GDPR Routing)
- [x] Phase 3: Queueable Apex (Anonymization)
- [ ] Phase 4: Platform Events (Event-Driven Architecture)
- [ ] Phase 5: LWC Dashboard (Visual Monitoring)
- [ ] Phase 6: Einstein Copilot Action (AI Integration)
- [ ] Phase 7: Unit Tests (90%+ Coverage)

## 🤝 Contributing

This is a portfolio project. Feedback and suggestions are welcome via Issues.

## 📄 License

MIT License - See LICENSE file for details

## 👤 Author

**Richard GOH**
- GitHub: [@richgoh](https://github.com/richgoh)
- LinkedIn: [Your LinkedIn Profile]
- Location: Abidjan, Côte d'Ivoire
- Target Market: France, Switzerland, Luxembourg (Remote/Relocation)

## 🙏 Acknowledgments

- Inspired by real-world GDPR challenges in European scale-ups
- Built for the growing African Salesforce ecosystem
- Demonstrates metadata-driven architecture patterns

---

**⭐ If this project helps you understand GDPR or Salesforce architecture, please star it!**