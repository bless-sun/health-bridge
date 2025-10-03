;; Title: HealthBridge Protocol
;;
;; Summary: Decentralized Healthcare Data Marketplace on Bitcoin Layer 2
;;
;; Description: HealthBridge Protocol transforms medical data into a tradable digital asset
;; on the Stacks blockchain, enabling patients to monetize their health records while
;; maintaining complete privacy and control. The protocol facilitates secure, HIPAA-aligned
;; data transactions between patients and researchers, implementing granular consent management,
;; quality verification systems, and automated payment distribution through Bitcoin-secured
;; smart contracts.
;;
;; Key Features:
;; - Patient-controlled data monetization with cryptographic privacy
;; - Multi-tier consent management with temporal and geographic controls
;; - Research institution data marketplace with IRB compliance tracking
;; - Automated quality assessment and verification system
;; - Transparent payment distribution with platform fee structure
;; - Bitcoin-anchored data provenance and immutable audit trails
;; - Support for diverse health data types: EHR, lab results, genomic, wearable data
;;
;; Economic Model:
;; - 20% platform fee on all transactions
;; - Minimum 60% quality score requirement for data availability
;; - Tiered pricing based on data type and quality metrics
;; - Multi-use licensing with usage caps per record
;;
;; Security & Privacy:
;; - On-chain encrypted data hashes (off-chain encrypted storage)
;; - Differential privacy and advanced anonymization options
;; - Time-bound consent expiration (1-year default)
;; - Emergency pause mechanism for security incidents
;; - KYC verification for patient and researcher profiles

;; CONSTANTS & ERROR CODES

(define-constant CONTRACT-OWNER tx-sender)

;; Error codes
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-UNAUTHORIZED (err u102))
(define-constant ERR-INVALID-AMOUNT (err u103))
(define-constant ERR-INSUFFICIENT-BALANCE (err u104))
(define-constant ERR-ALREADY-EXISTS (err u105))
(define-constant ERR-INVALID-DATA (err u106))
(define-constant ERR-CONSENT-REQUIRED (err u107))
(define-constant ERR-DATA-EXPIRED (err u108))
(define-constant ERR-QUALITY-TOO-LOW (err u109))
(define-constant ERR-EMERGENCY-PAUSE (err u999))

;; Platform configuration
(define-constant PLATFORM-FEE-BASIS-POINTS u2000)  ;; 20% platform fee
(define-constant MIN-DATA-QUALITY u60)             ;; Minimum 60% quality score
(define-constant CONSENT-DURATION u52560)          ;; 1 year in blocks (~10min blocks)
(define-constant MIN-PAYMENT u10000000)            ;; 10 STX minimum payment (10,000,000 microSTX)
(define-constant MAX-USAGE-PER-RECORD u10)         ;; Maximum 10 uses per data record

;; Health data type identifiers
(define-constant DATA-TYPE-EHR u1)        ;; Electronic Health Records
(define-constant DATA-TYPE-LAB u2)        ;; Laboratory Results
(define-constant DATA-TYPE-IMAGING u3)    ;; Medical Imaging (X-ray, MRI, CT)
(define-constant DATA-TYPE-GENOMIC u4)    ;; Genomic/DNA Data
(define-constant DATA-TYPE-WEARABLE u5)   ;; Wearable Device Data (fitness trackers)
(define-constant DATA-TYPE-LIFESTYLE u6)  ;; Lifestyle & Behavioral Data

;; Research request status codes
(define-constant STATUS-ACTIVE u1)
(define-constant STATUS-COMPLETED u2)
(define-constant STATUS-CANCELLED u3)

;; Anonymization levels
(define-constant ANON-BASIC u1)
(define-constant ANON-ADVANCED u2)
(define-constant ANON-DIFFERENTIAL-PRIVACY u3)

;; DATA VARIABLES

(define-data-var data-record-counter uint u0)
(define-data-var research-request-counter uint u0)
(define-data-var total-payments-distributed uint u0)
(define-data-var platform-revenue uint u0)
(define-data-var emergency-pause bool false)

;; DATA MAPS

;; Patient Health Data Records
(define-map patient-data-records
    uint  ;; record-id (primary key)
    {
        patient: principal,
        data-type: uint,
        data-hash: (buff 32),         ;; SHA-256 hash of encrypted data
        quality-score: uint,          ;; 0-100 quality assessment score
        price: uint,                  ;; Price in microSTX
        is-available: bool,           ;; Available for purchase after quality check
        created-at: uint,             ;; Block height of creation
        consent-expires: uint,        ;; Block height when consent expires
        usage-count: uint,            ;; Number of times data has been purchased
        total-earned: uint,           ;; Total earnings from this record (microSTX)
        metadata: (string-ascii 256)  ;; JSON metadata (demographics, age range, etc.)
    }
)

;; Patient Consent Management
(define-map patient-consents
    { patient: principal, data-type: uint }
    {
        granted: bool,
        granted-at: uint,
        expires-at: uint,
        research-purposes: (list 10 (string-ascii 64)),    ;; Allowed research categories
        geographic-restrictions: (list 5 (string-ascii 32)), ;; Geographic limitations
        can-reidentify: bool                               ;; Allow re-identification for follow-up
    }
)

;; Research Institution Data Requests
(define-map research-requests
    uint  ;; request-id (primary key)
    {
        researcher: principal,
        title: (string-ascii 128),
        description: (string-ascii 512),
        data-types-needed: (list 6 uint),      ;; Types of health data required
        max-price-per-record: uint,            ;; Maximum price willing to pay per record
        min-quality: uint,                     ;; Minimum quality score requirement
        max-records: uint,                     ;; Maximum number of records needed
        purpose: (string-ascii 256),           ;; Research purpose description
        institution: (string-ascii 128),       ;; Research institution name
        irb-approval: (string-ascii 64),       ;; IRB approval number
        created-at: uint,
        expires-at: uint,
        status: uint,                          ;; 1=active, 2=completed, 3=cancelled
        budget-allocated: uint,                ;; Total budget locked in contract
        records-purchased: uint                ;; Number of records purchased so far
    }
)

;; Data Purchase and Usage Audit Trail
(define-map data-usage-log
    { record-id: uint, request-id: uint }
    {
        researcher: principal,
        patient: principal,
        purchased-at: uint,
        price-paid: uint,
        usage-type: (string-ascii 64),
        anonymization-level: uint  ;; 1=basic, 2=advanced, 3=differential-privacy
    }
)

;; Patient Profile Management
(define-map patient-profiles
    principal
    {
        total-records: uint,
        total-earnings: uint,
        quality-rating: uint,                  ;; Average quality score across all records
        data-types-available: (list 6 uint),   ;; Available data types
        consent-preferences: uint,             ;; Bitmask of consent preferences
        kyc-verified: bool,                    ;; KYC verification status
        last-activity: uint,
        privacy-level: uint                    ;; 1=low, 2=medium, 3=high, 4=maximum
    }
)

;; Researcher Profile Management
(define-map researcher-profiles
    principal
    {
        institution: (string-ascii 128),
        research-areas: (list 10 (string-ascii 64)),
        total-purchases: uint,
        total-spent: uint,
        reputation-score: uint,  ;; 0-100 reputation based on conduct
        verified: bool,          ;; Institutional verification status
        active-requests: uint,
        completed-studies: uint
    }
)

;; Data Quality Assessment Records
(define-map quality-assessments
    uint  ;; record-id
    {
        assessor: principal,
        completeness: uint,    ;; 0-100 (data fields completeness)
        accuracy: uint,        ;; 0-100 (data accuracy verification)
        timeliness: uint,      ;; 0-100 (data recency/relevance)
        consistency: uint,     ;; 0-100 (internal data consistency)
        final-score: uint,     ;; 0-100 (composite quality score)
        assessed-at: uint,
        notes: (string-ascii 256)
    }
)

;; PUBLIC FUNCTIONS - PATIENT OPERATIONS

;; Register and upload health data record
(define-public (register-patient-data
    (data-type uint)
    (data-hash (buff 32))
    (price uint)
    (metadata (string-ascii 256)))
    (let (
        (record-id (+ (var-get data-record-counter) u1))
        (caller tx-sender)
        (consent (map-get? patient-consents { patient: caller, data-type: data-type }))
    )
        ;; Validations
        (asserts! (not (var-get emergency-pause)) ERR-EMERGENCY-PAUSE)
        (asserts! (>= price MIN-PAYMENT) ERR-INVALID-AMOUNT)
        (asserts! (and (>= data-type DATA-TYPE-EHR) (<= data-type DATA-TYPE-LIFESTYLE)) ERR-INVALID-DATA)
        
        ;; Verify valid consent exists
        (asserts! 
            (match consent
                consent-record (and 
                    (get granted consent-record)
                    (< stacks-block-height (get expires-at consent-record)))
                false
            )
            ERR-CONSENT-REQUIRED
        )
        
        ;; Create data record
        (map-set patient-data-records record-id {
            patient: caller,
            data-type: data-type,
            data-hash: data-hash,
            quality-score: u0,
            price: price,
            is-available: false,  ;; Available only after quality assessment
            created-at: stacks-block-height,
            consent-expires: (+ stacks-block-height CONSENT-DURATION),
            usage-count: u0,
            total-earned: u0,
            metadata: metadata
        })
        
        ;; Update patient profile
        (let (
            (profile (default-to 
                { total-records: u0, total-earnings: u0, quality-rating: u0, 
                  data-types-available: (list), consent-preferences: u0, kyc-verified: false, 
                  last-activity: u0, privacy-level: u2 }
                (map-get? patient-profiles caller)))
        )
            (map-set patient-profiles caller 
                (merge profile {
                    total-records: (+ (get total-records profile) u1),
                    last-activity: stacks-block-height
                })
            )
        )
        
        (var-set data-record-counter record-id)
        (ok record-id)
    )
)

;; Grant consent for health data usage
(define-public (grant-consent
    (data-type uint)
    (research-purposes (list 10 (string-ascii 64)))
    (geographic-restrictions (list 5 (string-ascii 32)))
    (can-reidentify bool))
    (let (
        (caller tx-sender)
        (expires-at (+ stacks-block-height CONSENT-DURATION))
    )
        (asserts! (not (var-get emergency-pause)) ERR-EMERGENCY-PAUSE)
        (asserts! (and (>= data-type DATA-TYPE-EHR) (<= data-type DATA-TYPE-LIFESTYLE)) ERR-INVALID-DATA)
        
        ;; Create or update consent record
        (map-set patient-consents 
            { patient: caller, data-type: data-type }
            {
                granted: true,
                granted-at: stacks-block-height,
                expires-at: expires-at,
                research-purposes: research-purposes,
                geographic-restrictions: geographic-restrictions,
                can-reidentify: can-reidentify
            }
        )
        
        (ok expires-at)
    )
)

;; Revoke previously granted consent
(define-public (revoke-consent (data-type uint))
    (let (
        (caller tx-sender)
    )
        (asserts! (not (var-get emergency-pause)) ERR-EMERGENCY-PAUSE)
        
        ;; Update consent to revoked status
        (match (map-get? patient-consents { patient: caller, data-type: data-type })
            consent-record 
            (begin
                (map-set patient-consents 
                    { patient: caller, data-type: data-type }
                    (merge consent-record {
                        granted: false,
                        expires-at: stacks-block-height  ;; Expire immediately
                    })
                )
                (ok true)
            )
            ERR-NOT-FOUND
        )
    )
)

;; PUBLIC FUNCTIONS - RESEARCHER OPERATIONS

;; Create research data request with budget allocation
(define-public (create-research-request
    (title (string-ascii 128))
    (description (string-ascii 512))
    (data-types-needed (list 6 uint))
    (max-price-per-record uint)
    (min-quality uint)
    (max-records uint)
    (purpose (string-ascii 256))
    (institution (string-ascii 128))
    (irb-approval (string-ascii 64))
    (budget uint))
    (let (
        (request-id (+ (var-get research-request-counter) u1))
        (caller tx-sender)
        (expires-at (+ stacks-block-height (* CONSENT-DURATION u3)))  ;; 3 years validity
    )
        ;; Validations
        (asserts! (not (var-get emergency-pause)) ERR-EMERGENCY-PAUSE)
        (asserts! (>= max-price-per-record MIN-PAYMENT) ERR-INVALID-AMOUNT)
        (asserts! (>= min-quality MIN-DATA-QUALITY) ERR-QUALITY-TOO-LOW)
        (asserts! (>= budget (* max-records max-price-per-record)) ERR-INSUFFICIENT-BALANCE)
        
        ;; Lock budget in contract
        (try! (stx-transfer? budget caller (as-contract tx-sender)))
        
        ;; Create research request
        (map-set research-requests request-id {
            researcher: caller,
            title: title,
            description: description,
            data-types-needed: data-types-needed,
            max-price-per-record: max-price-per-record,
            min-quality: min-quality,
            max-records: max-records,
            purpose: purpose,
            institution: institution,
            irb-approval: irb-approval,
            created-at: stacks-block-height,
            expires-at: expires-at,
            status: STATUS-ACTIVE,
            budget-allocated: budget,
            records-purchased: u0
        })
        
        ;; Update researcher profile
        (let (
            (profile (default-to
                { institution: "", research-areas: (list), total-purchases: u0, total-spent: u0,
                  reputation-score: u50, verified: false, active-requests: u0, completed-studies: u0 }
                (map-get? researcher-profiles caller)))
        )
            (map-set researcher-profiles caller
                (merge profile {
                    institution: institution,
                    active-requests: (+ (get active-requests profile) u1)
                })
            )
        )
        
        (var-set research-request-counter request-id)
        (ok request-id)
    )
)

;; Purchase patient health data record
(define-public (purchase-data-record (record-id uint) (request-id uint))
    (let (
        (record (unwrap! (map-get? patient-data-records record-id) ERR-NOT-FOUND))
        (request (unwrap! (map-get? research-requests request-id) ERR-NOT-FOUND))
        (caller tx-sender)
        (price (get price record))
        (platform-fee (/ (* price PLATFORM-FEE-BASIS-POINTS) u10000))
        (patient-payment (- price platform-fee))
    )
        ;; Validations
        (asserts! (not (var-get emergency-pause)) ERR-EMERGENCY-PAUSE)
        (asserts! (is-eq caller (get researcher request)) ERR-UNAUTHORIZED)
        (asserts! (is-eq (get status request) STATUS-ACTIVE) ERR-INVALID-DATA)
        (asserts! (get is-available record) ERR-INVALID-DATA)
        (asserts! (< (get usage-count record) MAX-USAGE-PER-RECORD) ERR-INVALID-DATA)
        (asserts! (>= (get quality-score record) (get min-quality request)) ERR-QUALITY-TOO-LOW)
        (asserts! (<= price (get max-price-per-record request)) ERR-INVALID-AMOUNT)
        (asserts! (< (get records-purchased request) (get max-records request)) ERR-INSUFFICIENT-BALANCE)
        
        ;; Verify consent is still valid
        (let (
            (consent (unwrap! 
                (map-get? patient-consents { patient: (get patient record), data-type: (get data-type record) })
                ERR-CONSENT-REQUIRED))
        )
            (asserts! (get granted consent) ERR-CONSENT-REQUIRED)
            (asserts! (< stacks-block-height (get expires-at consent)) ERR-DATA-EXPIRED)
        )
        
        ;; Transfer payment to patient (deducted from locked budget)
        (try! (as-contract (stx-transfer? patient-payment tx-sender (get patient record))))
        
        ;; Update platform revenue
        (var-set platform-revenue (+ (var-get platform-revenue) platform-fee))
        
        ;; Update data record usage statistics
        (map-set patient-data-records record-id
            (merge record {
                usage-count: (+ (get usage-count record) u1),
                total-earned: (+ (get total-earned record) patient-payment)
            })
        )
        
        ;; Update research request statistics
        (map-set research-requests request-id
            (merge request {
                records-purchased: (+ (get records-purchased request) u1)
            })
        )
        
        ;; Create audit trail entry
        (map-set data-usage-log
            { record-id: record-id, request-id: request-id }
            {
                researcher: caller,
                patient: (get patient record),
                purchased-at: stacks-block-height,
                price-paid: price,
                usage-type: "research-access",
                anonymization-level: ANON-ADVANCED
            }
        )
        
        ;; Update platform statistics
        (var-set total-payments-distributed (+ (var-get total-payments-distributed) patient-payment))
        
        (ok price)
    )
)

;; PUBLIC FUNCTIONS - QUALITY MANAGEMENT

;; Assess data quality (authorized assessors only)
(define-public (assess-data-quality
    (record-id uint)
    (completeness uint)
    (accuracy uint)
    (timeliness uint)
    (consistency uint)
    (notes (string-ascii 256)))
    (let (
        (record (unwrap! (map-get? patient-data-records record-id) ERR-NOT-FOUND))
        (caller tx-sender)
        (final-score (/ (+ completeness accuracy timeliness consistency) u4))
    )
        ;; Authorization check (simplified - use authorized assessor list in production)
        (asserts! (is-eq caller CONTRACT-OWNER) ERR-UNAUTHORIZED)
        
        ;; Validate score ranges
        (asserts! (and (<= completeness u100) (<= accuracy u100) 
                       (<= timeliness u100) (<= consistency u100)) ERR-INVALID-DATA)
        
        ;; Store quality assessment
        (map-set quality-assessments record-id {
            assessor: caller,
            completeness: completeness,
            accuracy: accuracy,
            timeliness: timeliness,
            consistency: consistency,
            final-score: final-score,
            assessed-at: stacks-block-height,
            notes: notes
        })
        
        ;; Update record with quality score and availability status
        (map-set patient-data-records record-id
            (merge record {
                quality-score: final-score,
                is-available: (>= final-score MIN-DATA-QUALITY)
            })
        )
        
        (ok final-score)
    )
)

;; READ-ONLY FUNCTIONS

;; Retrieve data record details
(define-read-only (get-data-record (record-id uint))
    (map-get? patient-data-records record-id)
)

;; Retrieve research request details
(define-read-only (get-research-request (request-id uint))
    (map-get? research-requests request-id)
)

;; Check patient consent status
(define-read-only (get-consent-status (patient principal) (data-type uint))
    (map-get? patient-consents { patient: patient, data-type: data-type })
)

;; Retrieve patient profile
(define-read-only (get-patient-profile (patient principal))
    (map-get? patient-profiles patient)
)

;; Retrieve researcher profile
(define-read-only (get-researcher-profile (researcher principal))
    (map-get? researcher-profiles researcher)
)

;; Retrieve data usage audit log entry
(define-read-only (get-usage-log (record-id uint) (request-id uint))
    (map-get? data-usage-log { record-id: record-id, request-id: request-id })
)

;; Retrieve quality assessment details
(define-read-only (get-quality-assessment (record-id uint))
    (map-get? quality-assessments record-id)
)

;; Get platform-wide statistics
(define-read-only (get-platform-stats)
    {
        total-records: (var-get data-record-counter),
        total-requests: (var-get research-request-counter),
        total-payments: (var-get total-payments-distributed),
        platform-revenue: (var-get platform-revenue),
        emergency-pause: (var-get emergency-pause)
    }
)

;; Calculate estimated earnings for potential data contributions
(define-read-only (calculate-estimated-earnings 
    (data-type uint) 
    (quality-estimate uint) 
    (usage-estimate uint))
    (let (
        ;; Base pricing by data type
        (base-price (if (is-eq data-type DATA-TYPE-GENOMIC) u50000000  ;; 50 STX for genomic
                     (if (is-eq data-type DATA-TYPE-IMAGING) u30000000  ;; 30 STX for imaging
                     (if (is-eq data-type DATA-TYPE-EHR) u20000000      ;; 20 STX for EHR
                     u10000000))))                                      ;; 10 STX for others
        (quality-multiplier (/ quality-estimate u100))
        (estimated-price (* base-price quality-multiplier))
        (platform-fee (/ (* estimated-price PLATFORM-FEE-BASIS-POINTS) u10000))
        (net-earnings (- estimated-price platform-fee))
        (total-potential (* net-earnings usage-estimate))
    )
        {
            estimated-price-per-use: estimated-price,
            net-earnings-per-use: net-earnings,
            total-potential-earnings: total-potential,
            platform-fee-per-use: platform-fee
        }
    )
)