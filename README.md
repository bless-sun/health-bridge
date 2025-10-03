# HealthBridge Protocol

**Decentralized Healthcare Data Marketplace on Bitcoin Layer 2**

HealthBridge Protocol is a **Stacks-based smart contract system** that transforms medical data into a secure, tradable digital asset. It empowers patients to monetize their health records while retaining **full control and privacy**, enabling researchers and institutions to access valuable datasets in a **compliant, transparent, and decentralized** manner.

Anchored to Bitcoin through Stacks, the protocol guarantees **immutability, auditability, and trustless economic settlement**, enabling a new era of **patient-driven healthcare data exchange**.

---

## 🌐 System Overview

The HealthBridge Protocol provides a marketplace where:

* **Patients** register health data records, control consent policies, and earn Bitcoin-backed rewards when their data is used.
* **Researchers** create research requests, allocate budgets, and purchase high-quality, consent-approved health data.
* **Assessors** verify the quality of uploaded data, ensuring marketplace integrity.
* **The Protocol** enforces HIPAA-aligned data governance, consent management, and automated payment distribution.

### Key Features

* 🔒 **Patient-Controlled Privacy** – granular, revocable consent mechanisms with temporal, geographic, and research-purpose restrictions.
* 📊 **Quality-Gated Marketplace** – minimum 60% quality requirement, verified by decentralized assessors.
* 💰 **Fair Compensation** – automated STX-based revenue distribution with a 20% platform fee.
* 🏥 **Research Compliance** – IRB approval tracking, researcher verification, and usage audits.
* ⛓️ **Bitcoin Security** – all records and transactions are anchored to Bitcoin for trustless immutability.

---

## 🏗️ Contract Architecture

The contract implements **modular data management** through **maps, variables, and access-controlled functions**.

### Core Components

1. **Patient Data Records (`patient-data-records`)**

   * Each record stores encrypted data hash, type, quality score, price, and metadata.
   * Usage count and total earnings are tracked.

2. **Consent Management (`patient-consents`)**

   * Patients grant, revoke, or update consent for specific data types.
   * Supports multi-purpose restrictions, geography rules, and expiration.

3. **Research Requests (`research-requests`)**

   * Researchers define their needs, allocate budgets, and enforce minimum quality thresholds.
   * Requests are time-bound and linked to verified institutions.

4. **Profiles**

   * `patient-profiles`: Tracks records, earnings, and KYC status.
   * `researcher-profiles`: Tracks purchases, spend, and reputation scores.

5. **Quality Assessment (`quality-assessments`)**

   * Data is scored across completeness, accuracy, timeliness, and consistency.
   * Records only become available if they meet the **60% minimum quality threshold**.

6. **Audit Trails (`data-usage-log`)**

   * Immutable record of all purchases, including anonymization level and usage type.

---

## 🔄 Data Flow

1. **Consent Setup**

   * Patient grants consent → consent stored in `patient-consents`.

2. **Data Registration**

   * Patient uploads encrypted health data hash → stored in `patient-data-records`.
   * Data is unavailable until quality is assessed.

3. **Quality Assessment**

   * Authorized assessor scores data → updates record availability.

4. **Research Request**

   * Researcher submits request with budget → funds locked in contract.

5. **Data Purchase**

   * Researcher purchases record → funds split into **patient payment + platform fee**.
   * Transaction logged in `data-usage-log`.

6. **Revenue Distribution**

   * Patients earn STX → tracked in `patient-profiles`.
   * Platform collects 20% fee → accumulated in `platform-revenue`.

---

## ⚙️ Economic Model

* **Platform Fee**: 20% of each transaction.
* **Minimum Payment**: 10 STX per record.
* **Quality Requirement**: ≥ 60% final score.
* **Usage Limit**: Max 10 times per record.
* **Tiered Pricing**: Based on data type and quality (e.g., genomic > imaging > EHR).

---

## 🔐 Security & Privacy

* ✅ On-chain **hashes only** (encrypted data stored off-chain).
* ✅ **Differential privacy & anonymization** supported.
* ✅ **Time-bound consent** (default 1 year).
* ✅ **Emergency Pause Mechanism** to halt marketplace operations.
* ✅ **KYC/IRB verification** for researchers.

---

## 📜 Public Functions

### Patients

* `register-patient-data` – Register encrypted health data for marketplace availability.
* `grant-consent` / `revoke-consent` – Manage consent policies.

### Researchers

* `create-research-request` – Create research project request with budget allocation.
* `purchase-data-record` – Purchase patient data within request constraints.

### Assessors

* `assess-data-quality` – Score health data and determine availability.

### Read-Only Views

* `get-data-record` / `get-research-request` / `get-consent-status`
* `get-patient-profile` / `get-researcher-profile`
* `get-usage-log` / `get-quality-assessment`
* `get-platform-stats` – Protocol-wide statistics.

---

## 📊 Example Use Case

1. A **patient** uploads anonymized genomic data.
2. A **quality assessor** verifies data completeness, granting a **92% score**.
3. A **researcher** creates a request for genomic data with a budget of **1,000 STX**.
4. The **researcher purchases** the patient’s data for **50 STX**.
5. Patient receives **40 STX**, platform retains **10 STX**.
6. Transaction is permanently logged on-chain with Bitcoin security.

---

## 🚀 Future Extensions

* Decentralized assessor network with staking and slashing.
* Tokenized reward multipliers for early patient adoption.
* Cross-chain healthcare data marketplace interoperability.
* Advanced **zero-knowledge proof (ZKP)**-based consent validation.

---

## 📄 License

MIT License. Free to use, modify, and distribute with attribution.
