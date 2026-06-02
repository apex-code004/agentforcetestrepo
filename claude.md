# Wealth Advisor Intelligence Platform — Salesforce Schema Setup Guide

> **Project:** Real-Time Financial Advisory Copilot  
> **Platform:** Salesforce + Data Cloud + Agentforce  
> **Org Type Required:** Developer Edition with Data Cloud trial enabled  

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [CRM Custom Objects](#2-crm-custom-objects)
   - [FinancialAccount__c](#21-financialaccount__c)
   - [PortfolioHolding__c](#22-portfolioholding__c)
   - [DriftAlert__c](#23-driftalert__c)
   - [AgentInteraction__c](#24-agentinteraction__c)
3. [CRM Standard Object Customisations](#3-crm-standard-object-customisations)
   - [Contact custom fields](#31-contact-custom-fields)
   - [User custom fields](#32-user-custom-fields)
4. [Data Cloud DMO Objects](#4-data-cloud-dmo-objects)
   - [Individual__dlm](#41-individual__dlm)
   - [FinancialAccountDMO__dlm](#42-financialaccountdmo__dlm)
   - [PortfolioTransactionDMO__dlm](#43-portfoliotransactiondmo__dlm)
   - [MarketDataDMO__dlm](#44-marketdatadmo__dlm)
   - [PortfolioDriftInsight__dlm](#45-portfoliodriftinsight__dlm)
5. [Relationships & Lookups](#5-relationships--lookups)
6. [Validation Rules](#6-validation-rules)
7. [Permission Sets](#7-permission-sets)
8. [Data Cloud Setup Steps](#8-data-cloud-setup-steps)
9. [Identity Resolution Configuration](#9-identity-resolution-configuration)
10. [Calculated Insight SQL](#10-calculated-insight-sql)
11. [Segment Definitions](#11-segment-definitions)
12. [Named Credentials](#12-named-credentials)
13. [Sample Data — CSV Files](#13-sample-data--csv-files)
14. [Deployment Order](#14-deployment-order)

---

## 1. Prerequisites

Before creating any metadata, verify your org meets these requirements:

- [ ] Salesforce Developer Edition org — sign up at [developer.salesforce.com](https://developer.salesforce.com/signup)
- [ ] Data Cloud free trial enabled — Setup → Data Cloud → Get Started
- [ ] Agentforce enabled — Setup → Einstein → Agentforce → Enable
- [ ] Einstein Trust Layer enabled — Setup → Einstein Trust Layer → Turn On
- [ ] API access enabled on your user profile
- [ ] Salesforce CLI installed locally (`sf --version` to verify)

**Authenticate your org:**

```bash
sf org login web --alias WealthAdvisor --set-default
sf org display --target-org WealthAdvisor
```

---

## 2. CRM Custom Objects

Create each object via Setup → Object Manager → Create → Custom Object, or deploy using the metadata XML below.

---

### 2.1 FinancialAccount__c

**Label:** Financial Account  
**Plural Label:** Financial Accounts  
**API Name:** FinancialAccount__c  
**Description:** Stores a client's investment account details and target allocations.  
**Sharing Model:** ReadWrite  
**Allow Reports:** ✅  
**Allow Activities:** ✅  
**Track Field History:** ✅ (enable on TotalValue__c, Status__c)

#### Fields

| Field Label | API Name | Type | Length / Values | Required | Description |
|---|---|---|---|---|---|
| Account Number | AccountNumber__c | Text | 50 | ✅ | Unique account identifier from source system |
| Account Type | AccountType__c | Picklist | See below | ✅ | Type of investment account |
| Total Value | TotalValue__c | Currency | 18,2 | ❌ | Current total market value in USD |
| Target Equity % | TargetEquityPct__c | Percent | 5,2 | ❌ | Target allocation to equities |
| Target Bond % | TargetBondPct__c | Percent | 5,2 | ❌ | Target allocation to bonds |
| Target Cash % | TargetCashPct__c | Percent | 5,2 | ❌ | Target allocation to cash/money market |
| Status | Status__c | Picklist | See below | ✅ | Current account status |
| Contact | ContactId__c | Lookup(Contact) | — | ✅ | Parent client record |

**AccountType__c picklist values:**
```
Individual Brokerage
IRA - Traditional
IRA - Roth
401(k)
Joint Tenants
Trust Account
Custodial
```

**Status__c picklist values:**
```
Active
Suspended
Closed
Under Review
```

**Object-level metadata XML** (`force-app/main/default/objects/FinancialAccount__c/FinancialAccount__c.object-meta.xml`):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Financial Account</label>
    <pluralLabel>Financial Accounts</pluralLabel>
    <nameField>
        <label>Financial Account Name</label>
        <type>AutoNumber</type>
        <displayFormat>FA-{0000}</displayFormat>
    </nameField>
    <deploymentStatus>Deployed</deploymentStatus>
    <sharingModel>ReadWrite</sharingModel>
    <enableActivities>true</enableActivities>
    <enableReports>true</enableReports>
    <enableHistory>true</enableHistory>
    <enableSearch>true</enableSearch>
    <fields>
        <fullName>AccountNumber__c</fullName>
        <label>Account Number</label>
        <type>Text</type>
        <length>50</length>
        <required>true</required>
        <unique>true</unique>
        <externalId>true</externalId>
    </fields>
    <fields>
        <fullName>AccountType__c</fullName>
        <label>Account Type</label>
        <type>Picklist</type>
        <required>true</required>
        <valueSet>
            <valueSetDefinition>
                <sorted>false</sorted>
                <value><fullName>Individual Brokerage</fullName><default>true</default></value>
                <value><fullName>IRA - Traditional</fullName><default>false</default></value>
                <value><fullName>IRA - Roth</fullName><default>false</default></value>
                <value><fullName>401(k)</fullName><default>false</default></value>
                <value><fullName>Joint Tenants</fullName><default>false</default></value>
                <value><fullName>Trust Account</fullName><default>false</default></value>
                <value><fullName>Custodial</fullName><default>false</default></value>
            </valueSetDefinition>
        </valueSet>
    </fields>
    <fields>
        <fullName>TotalValue__c</fullName>
        <label>Total Value</label>
        <type>Currency</type>
        <precision>18</precision>
        <scale>2</scale>
        <required>false</required>
        <trackHistory>true</trackHistory>
    </fields>
    <fields>
        <fullName>TargetEquityPct__c</fullName>
        <label>Target Equity %</label>
        <type>Percent</type>
        <precision>5</precision>
        <scale>2</scale>
    </fields>
    <fields>
        <fullName>TargetBondPct__c</fullName>
        <label>Target Bond %</label>
        <type>Percent</type>
        <precision>5</precision>
        <scale>2</scale>
    </fields>
    <fields>
        <fullName>TargetCashPct__c</fullName>
        <label>Target Cash %</label>
        <type>Percent</type>
        <precision>5</precision>
        <scale>2</scale>
    </fields>
    <fields>
        <fullName>Status__c</fullName>
        <label>Status</label>
        <type>Picklist</type>
        <required>true</required>
        <valueSet>
            <valueSetDefinition>
                <sorted>false</sorted>
                <value><fullName>Active</fullName><default>true</default></value>
                <value><fullName>Suspended</fullName><default>false</default></value>
                <value><fullName>Closed</fullName><default>false</default></value>
                <value><fullName>Under Review</fullName><default>false</default></value>
            </valueSetDefinition>
        </valueSet>
    </fields>
    <fields>
        <fullName>ContactId__c</fullName>
        <label>Contact</label>
        <type>Lookup</type>
        <referenceTo>Contact</referenceTo>
        <relationshipName>FinancialAccounts</relationshipName>
        <relationshipLabel>Financial Accounts</relationshipLabel>
        <required>true</required>
    </fields>
</CustomObject>
```

---

### 2.2 PortfolioHolding__c

**Label:** Portfolio Holding  
**Plural Label:** Portfolio Holdings  
**API Name:** PortfolioHolding__c  
**Description:** Individual security or asset holding within a financial account.  
**Sharing Model:** ControlledByParent

#### Fields

| Field Label | API Name | Type | Length / Values | Required | Description |
|---|---|---|---|---|---|
| Ticker | Ticker__c | Text | 10 | ✅ | Stock/fund ticker symbol (e.g. AAPL, SPY) |
| Asset Class | AssetClass__c | Picklist | See below | ✅ | Broad asset classification |
| Quantity | Quantity__c | Number | 18,4 | ✅ | Number of units/shares held |
| Current Value | CurrentValue__c | Currency | 18,2 | ❌ | Current market value |
| Current Allocation % | CurrentAllocationPct__c | Percent | 5,2 | ❌ | % of total account value |
| As Of Date | AsOfDate__c | Date | — | ❌ | Date of last valuation |
| Financial Account | FinancialAccountId__c | Master-Detail(FinancialAccount__c) | — | ✅ | Parent account |

**AssetClass__c picklist values:**
```
Equity - US
Equity - International
Fixed Income - Government
Fixed Income - Corporate
Cash & Equivalents
Real Estate
Commodities
Alternative
```

---

### 2.3 DriftAlert__c

**Label:** Drift Alert  
**Plural Label:** Drift Alerts  
**API Name:** DriftAlert__c  
**Description:** Records portfolio drift events — created by Data Cloud-triggered Flow or manually.  
**Sharing Model:** ReadWrite  
**Track Field History:** ✅ (AlertStatus__c)

#### Fields

| Field Label | API Name | Type | Values / Length | Required | Description |
|---|---|---|---|---|---|
| Drift % | DriftPct__c | Percent | 5,2 | ✅ | Computed drift at time of alert |
| Alert Status | AlertStatus__c | Picklist | See below | ✅ | Current resolution status |
| Trigger Source | TriggerSource__c | Picklist | See below | ✅ | What created this alert |
| Detected At | DetectedAt__c | DateTime | — | ✅ | When drift was first detected |
| Resolved At | ResolvedAt__c | DateTime | — | ❌ | When advisor marked resolved |
| Contact | ContactId__c | Lookup(Contact) | — | ✅ | Affected client |
| Financial Account | FinancialAccountId__c | Lookup(FinancialAccount__c) | — | ✅ | Affected account |

**AlertStatus__c picklist values:**
```
New
In Progress
Resolved
Dismissed
```

**TriggerSource__c picklist values:**
```
Data Cloud
Manual
Scheduled Job
Market Event
```

---

### 2.4 AgentInteraction__c

**Label:** Agent Interaction  
**Plural Label:** Agent Interactions  
**API Name:** AgentInteraction__c  
**Description:** Compliance audit log for every Agentforce copilot interaction. Never delete records.  
**Sharing Model:** Private  
**Track Field History:** ❌ (immutable log — no edits permitted)

#### Fields

| Field Label | API Name | Type | Length | Required | Description |
|---|---|---|---|---|---|
| Query Text | QueryText__c | Long Text Area | 32,768 | ✅ | Advisor's original question verbatim |
| Response Text | ResponseText__c | Long Text Area | 32,768 | ❌ | Agent's generated response |
| Agent Topic | AgentTopic__c | Picklist | See below | ✅ | Which Topic handled this query |
| Was Escalated | WasEscalated__c | Checkbox | — | ✅ | True if routed to human |
| Escalation Reason | EscalationReason__c | Text Area | 500 | ❌ | Why agent escalated (out-of-scope category) |
| Interaction Time | InteractionTime__c | DateTime | — | ✅ | Timestamp of interaction |
| Advisor | AdvisorId__c | Lookup(User) | — | ✅ | Advisor who triggered the query |
| Client | ContactId__c | Lookup(Contact) | — | ❌ | Client record in context (if any) |

**AgentTopic__c picklist values:**
```
Client Portfolio Summary
Drift & Alert Lookup
Segment Membership Query
Market Data Query
Escalation - Investment Advice
Escalation - Trade Recommendation
Escalation - Other
```

---

## 3. CRM Standard Object Customisations

### 3.1 Contact Custom Fields

Add the following custom fields to the standard Contact object:

| Field Label | API Name | Type | Description |
|---|---|---|---|
| Risk Tolerance | RiskTolerance__c | Picklist | Conservative / Moderate / Aggressive / Speculative |
| Portfolio Drift % | PortfolioDrift__c | Percent (5,2) | Synced back from Data Cloud Calculated Insight |
| DC Unified Individual ID | DCUnifiedIndividualId__c | Text (255) | Cross-reference key to UnifiedIndividual__dlm |
| Drift Alert Segment | DriftAlertSegment__c | Text (50) | Synced segment membership flag from Data Cloud |
| Churn Risk Segment | ChurnRiskSegment__c | Text (50) | Synced segment membership flag from Data Cloud |
| Last Advisor Contact | LastAdvisorContact__c | DateTime | Updated by Flow when advisor logs a call |

**RiskTolerance__c picklist values:**
```
Conservative
Moderate
Aggressive
Speculative
```

**Metadata XML for PortfolioDrift__c** (the most important sync-back field):

```xml
<fields>
    <fullName>PortfolioDrift__c</fullName>
    <label>Portfolio Drift %</label>
    <description>Synced from Data Cloud PortfolioDriftInsight__dlm via Data Share. Do not edit manually.</description>
    <type>Percent</type>
    <precision>5</precision>
    <scale>2</scale>
    <required>false</required>
    <trackFeedHistory>false</trackFeedHistory>
</fields>
```

---

### 3.2 User Custom Fields

| Field Label | API Name | Type | Description |
|---|---|---|---|
| Book of Business | BookOfBusiness__c | Text Area (255) | Comma-separated client segment tags this advisor manages |

---

## 4. Data Cloud DMO Objects

> Data Model Objects (DMOs) are created in **Data Cloud Setup → Data Model**. They are not Salesforce custom objects. Use the steps below in the Data Cloud UI — there is no metadata XML deployment for DMOs.

---

### 4.1 Individual__dlm

**Category:** Individual  
**Description:** Source-level client record ingested from each connected system before Identity Resolution.

| Field Name | Data Type | Primary Key | Description |
|---|---|---|---|
| Id | Text | ✅ | System-generated DLO record ID |
| FirstName__c | Text | ❌ | Client first name from source |
| LastName__c | Text | ❌ | Client last name from source |
| Email__c | Email | ❌ | Primary email — used as match key |
| SourceSystem__c | Text | ❌ | Origin system label (e.g. "Salesforce CRM", "Portfolio CSV") |
| SourceObjectId__c | Text | ❌ | Original record ID in source system |
| UnifiedRecordId | Text | ❌ | Populated post-Identity Resolution — FK to UnifiedIndividual__dlm |

---

### 4.2 FinancialAccountDMO__dlm

**Category:** Custom DMO  
**Description:** Harmonised financial account data mapped from CRM FinancialAccount__c.

| Field Name | Data Type | Primary Key | Description |
|---|---|---|---|
| Id | Text | ✅ | DMO record ID |
| AccountNumber__c | Text | ❌ | Account number (matches CRM) |
| AccountType__c | Text | ❌ | Account type |
| TotalValue__c | Number | ❌ | Current market value |
| TargetEquityPct__c | Number | ❌ | Target equity allocation % |
| TargetBondPct__c | Number | ❌ | Target bond allocation % |
| IndividualId | Text | ❌ | FK to Individual__dlm |

---

### 4.3 PortfolioTransactionDMO__dlm

**Category:** Custom DMO  
**Description:** Daily transaction feed ingested from CSV. Primary source for Calculated Insight SQL.

| Field Name | Data Type | Primary Key | Description |
|---|---|---|---|
| Id | Text | ✅ | Transaction record ID |
| Ticker__c | Text | ❌ | Security ticker symbol |
| AssetClass__c | Text | ❌ | Equity / Bond / Cash / etc. |
| Amount__c | Number | ❌ | Transaction amount in USD |
| TransactionType__c | Text | ❌ | BUY / SELL / DIVIDEND / FEE |
| TransactionDate__c | Date | ❌ | Date of transaction |
| FinancialAccountId | Text | ❌ | FK to FinancialAccountDMO__dlm |

---

### 4.4 MarketDataDMO__dlm

**Category:** Custom DMO  
**Description:** Daily market price feed for held securities. Ingested via Apex → Data Cloud Ingestion API.

| Field Name | Data Type | Primary Key | Description |
|---|---|---|---|
| Id | Text | ✅ | Market data record ID |
| Ticker__c | Text | ❌ | Security ticker |
| Price__c | Number | ❌ | Closing price |
| DayChangePct__c | Number | ❌ | Day-over-day price change % |
| Sector__c | Text | ❌ | GICS sector classification |
| AsOfDate__c | Date | ❌ | Price date |

---

### 4.5 PortfolioDriftInsight__dlm

**Category:** Custom DMO (populated by Calculated Insight)  
**Description:** Output of the drift SQL CI. Written automatically — do not manually insert.

| Field Name | Data Type | Primary Key | Description |
|---|---|---|---|
| Id | Text | ✅ | Insight record ID |
| CurrentEquityPct__c | Number | ❌ | Actual equity % at calculation time |
| CurrentBondPct__c | Number | ❌ | Actual bond % at calculation time |
| DriftPct__c | Number | ❌ | Absolute drift from target (max of equity/bond deltas) |
| ExceedsThreshold__c | Boolean | ❌ | True when DriftPct__c > 5.0 |
| CalculatedDate__c | Date | ❌ | Date CI ran |
| UnifiedRecordId | Text | ❌ | FK to UnifiedIndividual__dlm |

---

## 5. Relationships & Lookups

Summary of all object relationships for quick reference:

```
Contact (standard)
  ├── FinancialAccount__c        [Lookup — ContactId__c]
  │     └── PortfolioHolding__c  [Master-Detail — FinancialAccountId__c]
  ├── DriftAlert__c              [Lookup — ContactId__c]
  └── AgentInteraction__c        [Lookup — ContactId__c]

User (standard)
  ├── Contact                    [Lookup — OwnerId / AdvisorId__c]
  └── AgentInteraction__c        [Lookup — AdvisorId__c]

DriftAlert__c
  ├── Contact                    [Lookup — ContactId__c]
  └── FinancialAccount__c        [Lookup — FinancialAccountId__c]

--- Data Cloud ---

Individual__dlm
  └── UnifiedIndividual__dlm     [Identity Resolution merge]

FinancialAccountDMO__dlm
  ├── Individual__dlm            [FK — IndividualId]
  └── PortfolioTransactionDMO__dlm [FK — FinancialAccountId]

UnifiedIndividual__dlm
  ├── UnifiedContactPoint__dlm   [Identity Resolution output]
  ├── Individual__dlm            [Merge source records]
  └── PortfolioDriftInsight__dlm [FK — UnifiedRecordId]
```

---

## 6. Validation Rules

### 6.1 FinancialAccount__c — target allocations must sum to 100%

**Rule Name:** `Target_Allocations_Must_Sum_100`  
**Error Message:** "Target allocations must add up to 100%. Current total: {0}%"  
**Formula:**

```
AND(
  NOT(ISBLANK(TargetEquityPct__c)),
  NOT(ISBLANK(TargetBondPct__c)),
  NOT(ISBLANK(TargetCashPct__c)),
  TargetEquityPct__c + TargetBondPct__c + TargetCashPct__c <> 100
)
```

### 6.2 DriftAlert__c — resolved date must be after detected date

**Rule Name:** `Resolved_After_Detected`  
**Error Message:** "Resolved date cannot be before the detection date."  
**Formula:**

```
AND(
  NOT(ISBLANK(ResolvedAt__c)),
  ResolvedAt__c < DetectedAt__c
)
```

### 6.3 AgentInteraction__c — prevent manual edits after creation

**Rule Name:** `No_Manual_Edit_After_Creation`  
**Error Message:** "Agent interaction records are immutable compliance logs and cannot be edited."  
**Formula:**

```
NOT(ISNEW())
```

---

## 7. Permission Sets

Create two permission sets via Setup → Permission Sets → New.

### 7.1 WealthAdvisor_User

For financial advisors using the app.

**Object Permissions:**

| Object | Read | Create | Edit | Delete | View All | Modify All |
|---|---|---|---|---|---|---|
| Contact | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| FinancialAccount__c | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| PortfolioHolding__c | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| DriftAlert__c | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| AgentInteraction__c | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |

**System Permissions:**
- View Agentforce: ✅
- Use Einstein Copilot: ✅
- Access Data Cloud: ✅ (read-only)

### 7.2 WealthAdvisor_Compliance

For compliance officers — read-only on all objects, including escalation reports.

**Object Permissions:** Read = ✅ on all objects above. View All = ✅ on AgentInteraction__c and DriftAlert__c.

---

## 8. Data Cloud Setup Steps

Perform these steps in order inside **Data Cloud Setup**.

### Step 1 — Connect Salesforce CRM

```
Data Cloud Setup
→ Data Stream
→ New
→ Salesforce CRM
→ Select objects: Contact, FinancialAccount__c, PortfolioHolding__c
→ Map to DMOs:
    Contact        → Individual__dlm
    FinancialAccount__c → FinancialAccountDMO__dlm
→ Refresh interval: Daily
→ Activate
```

### Step 2 — Create Portfolio Transaction stream

```
Data Cloud Setup
→ Data Stream
→ New
→ File (CSV Upload) or Amazon S3
→ Target DMO: PortfolioTransactionDMO__dlm
→ Field mapping: see Section 13 for CSV column names
→ Activate
```

### Step 3 — Create Market Data stream (Ingestion API)

```
Data Cloud Setup
→ Data Stream
→ New
→ Ingestion API
→ Target DMO: MarketDataDMO__dlm
→ Copy the Ingestion API endpoint URL
→ Save — Apex job will POST to this endpoint (see Section 12)
```

### Step 4 — Enable Data Share sync-back to CRM

```
Data Cloud Setup
→ Data Shares
→ New Salesforce CRM Connection
→ Select DMO fields to sync:
    PortfolioDriftInsight__dlm.DriftPct__c    → Contact.PortfolioDrift__c
    UnifiedIndividual__dlm.DriftAlertSegment__c → Contact.DriftAlertSegment__c
    UnifiedIndividual__dlm.ChurnRiskSegment__c  → Contact.ChurnRiskSegment__c
→ Match key: Individual__dlm.SourceObjectId__c = Contact.Id
→ Refresh: On segment change
```

---

## 9. Identity Resolution Configuration

### Ruleset: `WealthAdvisor_IR`

```
Data Cloud → Identity Resolution → New Ruleset

Name: WealthAdvisor_IR
Primary DMO: Individual__dlm

--- Match Rules (run in order) ---

Rule 1: Exact Email Match
  Attribute: Individual__dlm.Email__c
  Match Type: Exact (case-insensitive)
  Threshold: High confidence

Rule 2: Client ID Match
  Attribute: Individual__dlm.SourceObjectId__c
  Match Type: Exact
  Threshold: High confidence

--- Reconciliation Rules ---

Field: FirstName__c   → Source wins: Salesforce CRM (highest trust)
Field: LastName__c    → Source wins: Salesforce CRM
Field: Email__c       → Source wins: Most recent updated record
Field: SourceSystem__c → Source wins: N/A (all source values retained)

--- Schedule ---
Run after each Data Stream refresh (nightly)
```

---

## 10. Calculated Insight SQL

Create this in **Data Cloud → Calculated Insights → New**.

**Name:** `Portfolio_Drift_Metric`  
**Output DMO:** `PortfolioDriftInsight__dlm`

```sql
-- Portfolio Drift Calculated Insight
-- Computes current vs target allocation per unified client
-- Writes ExceedsThreshold__c = true when drift > 5%

SELECT
    fa.UnifiedRecordId,
    TODAY()                                                   AS CalculatedDate__c,

    -- Current equity allocation % of total account value
    ROUND(
        SUM(CASE WHEN pt.AssetClass__c LIKE 'Equity%'
                 THEN pt.Amount__c ELSE 0 END)
        / NULLIF(SUM(pt.Amount__c), 0) * 100
    , 2)                                                      AS CurrentEquityPct__c,

    -- Current bond allocation %
    ROUND(
        SUM(CASE WHEN pt.AssetClass__c LIKE 'Fixed Income%'
                 THEN pt.Amount__c ELSE 0 END)
        / NULLIF(SUM(pt.Amount__c), 0) * 100
    , 2)                                                      AS CurrentBondPct__c,

    -- Drift = max absolute deviation across equity and bond vs target
    ROUND(
        GREATEST(
            ABS(
                SUM(CASE WHEN pt.AssetClass__c LIKE 'Equity%'
                         THEN pt.Amount__c ELSE 0 END)
                / NULLIF(SUM(pt.Amount__c), 0) * 100
                - MAX(fa.TargetEquityPct__c)
            ),
            ABS(
                SUM(CASE WHEN pt.AssetClass__c LIKE 'Fixed Income%'
                         THEN pt.Amount__c ELSE 0 END)
                / NULLIF(SUM(pt.Amount__c), 0) * 100
                - MAX(fa.TargetBondPct__c)
            )
        )
    , 2)                                                      AS DriftPct__c,

    -- Threshold flag
    CASE
        WHEN GREATEST(
            ABS(
                SUM(CASE WHEN pt.AssetClass__c LIKE 'Equity%'
                         THEN pt.Amount__c ELSE 0 END)
                / NULLIF(SUM(pt.Amount__c), 0) * 100
                - MAX(fa.TargetEquityPct__c)
            ),
            ABS(
                SUM(CASE WHEN pt.AssetClass__c LIKE 'Fixed Income%'
                         THEN pt.Amount__c ELSE 0 END)
                / NULLIF(SUM(pt.Amount__c), 0) * 100
                - MAX(fa.TargetBondPct__c)
            )
        ) > 5.0
        THEN TRUE
        ELSE FALSE
    END                                                       AS ExceedsThreshold__c

FROM
    PortfolioTransactionDMO__dlm   pt
    JOIN FinancialAccountDMO__dlm  fa
        ON pt.FinancialAccountId = fa.Id
    JOIN Individual__dlm            ind
        ON fa.IndividualId = ind.Id
    JOIN UnifiedIndividual__dlm     ui
        ON ind.UnifiedRecordId = ui.UnifiedRecordId

WHERE
    pt.TransactionDate__c >= DATEADD(DAY, -90, TODAY())  -- rolling 90-day window

GROUP BY
    fa.UnifiedRecordId
```

> **Schedule:** Run daily at 02:00 UTC after Data Streams complete.

---

## 11. Segment Definitions

Create in **Data Cloud → Segments → New Segment**.

### Segment 1: Portfolio Drift Alert

```
Name: Portfolio_Drift_Alert
Primary DMO: UnifiedIndividual__dlm

Filter:
  PortfolioDriftInsight__dlm.ExceedsThreshold__c = TRUE
  AND PortfolioDriftInsight__dlm.CalculatedDate__c = TODAY()

Publish to: Salesforce CRM (triggers DC-triggered Flow)
Refresh: Real-time on CI completion
```

### Segment 2: High Risk Tolerance

```
Name: High_Risk_Tolerance
Primary DMO: UnifiedIndividual__dlm

Filter:
  Individual__dlm.SourceSystem__c = 'Salesforce CRM'
  AND (mapped field) RiskTolerance__c IN ('Aggressive', 'Speculative')

Publish to: Salesforce CRM
Refresh: Daily
```

### Segment 3: Churn Risk — No Advisor Contact 90 Days

```
Name: Churn_Risk_No_Contact_90d
Primary DMO: UnifiedIndividual__dlm

Filter:
  Individual__dlm.LastAdvisorContact__c <= DATEADD(DAY, -90, TODAY())
  OR ISNULL(Individual__dlm.LastAdvisorContact__c)

Publish to: Salesforce CRM
Refresh: Daily
```

---

## 12. Named Credentials

Create in **Setup → Security → Named Credentials → New Legacy**.

### 12.1 Data Cloud Query API

```
Label:         DataCloud_QueryAPI
Name:          DataCloud_QueryAPI
URL:           https://[your-instance].c360a.salesforce.com
Identity Type: Named Principal
Auth Protocol: OAuth 2.0
Auth Provider:  (create Connected App with Data Cloud API scope)
Scope:          cdp_query_api cdp_ingest_api api
```

### 12.2 Market Data Feed (Mock)

```
Label:         MarketData_Feed
Name:          MarketData_Feed
URL:           https://api.mockmarketdata.example.com
Identity Type: Named Principal
Auth Protocol: Password Authentication
Username:      [api_username]
Password:      [api_key]
```

> **Security note:** Never hardcode credentials in Apex. Always reference Named Credentials using `HttpRequest.setEndpoint('callout:DataCloud_QueryAPI/...')`.

---

## 13. Sample Data — CSV Files

Use these CSVs to seed your org with test data.

### 13.1 Contact seed data (`seed_contacts.csv`)

```csv
FirstName,LastName,Email,Phone,RiskTolerance__c,LastAdvisorContact__c,OwnerId
Sarah,Chen,sarah.chen@example.com,+14155550101,Aggressive,2026-03-01,
James,Okonkwo,j.okonkwo@example.com,+14155550102,Moderate,2026-05-15,
Maria,Fernandez,m.fernandez@example.com,+14155550103,Conservative,2026-01-10,
David,Park,david.park@example.com,+14155550104,Speculative,2026-05-28,
Aisha,Williams,a.williams@example.com,+14155550105,Moderate,2025-12-01,
```

### 13.2 Financial account seed data (`seed_financial_accounts.csv`)

```csv
AccountNumber__c,AccountType__c,TotalValue__c,TargetEquityPct__c,TargetBondPct__c,TargetCashPct__c,Status__c,ContactId__c
FA-0001,Individual Brokerage,485000.00,70,25,5,Active,[Sarah Chen Contact ID]
FA-0002,IRA - Traditional,210000.00,60,35,5,Active,[James Okonkwo Contact ID]
FA-0003,IRA - Roth,125000.00,40,50,10,Active,[Maria Fernandez Contact ID]
FA-0004,Individual Brokerage,920000.00,85,10,5,Active,[David Park Contact ID]
FA-0005,401(k),340000.00,65,30,5,Active,[Aisha Williams Contact ID]
```

### 13.3 Portfolio transaction stream CSV (`transactions_feed.csv`)

```csv
Id,Ticker__c,AssetClass__c,Amount__c,TransactionType__c,TransactionDate__c,FinancialAccountId
TXN-001,AAPL,Equity - US,42500.00,BUY,2026-05-01,FA-0001
TXN-002,SPY,Equity - US,85000.00,BUY,2026-05-01,FA-0001
TXN-003,BND,Fixed Income - Government,28000.00,BUY,2026-05-01,FA-0001
TXN-004,VXUS,Equity - International,31000.00,BUY,2026-05-01,FA-0001
TXN-005,MSFT,Equity - US,75000.00,BUY,2026-05-02,FA-0002
TXN-006,TLT,Fixed Income - Government,62000.00,BUY,2026-05-02,FA-0002
TXN-007,CASH,Cash & Equivalents,12500.00,BUY,2026-05-02,FA-0002
TXN-008,NVDA,Equity - US,95000.00,BUY,2026-05-03,FA-0004
TXN-009,TSLA,Equity - US,88000.00,BUY,2026-05-03,FA-0004
TXN-010,META,Equity - US,76000.00,BUY,2026-05-03,FA-0004
```

### 13.4 Market data stream CSV (`market_data_feed.csv`)

```csv
Id,Ticker__c,Price__c,DayChangePct__c,Sector__c,AsOfDate__c
MKT-001,AAPL,189.45,0.82,Information Technology,2026-05-31
MKT-002,MSFT,415.20,-0.34,Information Technology,2026-05-31
MKT-003,NVDA,875.60,3.21,Information Technology,2026-05-31
MKT-004,TSLA,248.90,-1.45,Consumer Discretionary,2026-05-31
MKT-005,META,512.30,1.12,Communication Services,2026-05-31
MKT-006,SPY,527.80,0.45,ETF - US Broad Market,2026-05-31
MKT-007,BND,72.40,-0.12,ETF - Fixed Income,2026-05-31
MKT-008,TLT,88.90,-0.28,ETF - Long Duration,2026-05-31
MKT-009,VXUS,58.70,0.67,ETF - International,2026-05-31
MKT-010,CASH,1.00,0.00,Money Market,2026-05-31
```

---

## 14. Deployment Order

Follow this exact sequence to avoid dependency errors.

```
Step 1  — Deploy custom objects (FinancialAccount__c, PortfolioHolding__c,
          DriftAlert__c, AgentInteraction__c)

Step 2  — Deploy Contact and User custom fields

Step 3  — Deploy validation rules

Step 4  — Deploy permission sets and assign to test users

Step 5  — Load seed CSV data (contacts → accounts → holdings)

Step 6  — Enable Data Cloud, configure Data Streams (CRM connector first)

Step 7  — Create DMOs in Data Cloud (Individual__dlm, FinancialAccountDMO__dlm,
          PortfolioTransactionDMO__dlm, MarketDataDMO__dlm)

Step 8  — Run CRM connector sync — verify records appear in Individual__dlm

Step 9  — Upload transactions_feed.csv to PortfolioTransactionDMO__dlm stream

Step 10 — Configure Identity Resolution ruleset and run first job

Step 11 — Verify UnifiedIndividual__dlm records are created

Step 12 — Create PortfolioDriftInsight__dlm DMO

Step 13 — Create and activate Calculated Insight SQL

Step 14 — Verify CI output populates PortfolioDriftInsight__dlm

Step 15 — Create 3 Segments (Drift Alert, High Risk, Churn Risk)

Step 16 — Configure Data Share sync-back to Contact fields

Step 17 — Configure Named Credentials

Step 18 — Deploy Apex classes and LWC components

Step 19 — Configure Agentforce Agent (Topics, Actions, Trust Layer)

Step 20 — Run end-to-end smoke test: trigger drift threshold → verify
          DriftAlert__c record created → verify Contact.PortfolioDrift__c updated
```

---

## Useful CLI Commands

```bash
# Retrieve all custom objects from org
sf project retrieve start --metadata CustomObject --target-org WealthAdvisor

# Deploy specific object
sf project deploy start --metadata CustomObject:FinancialAccount__c --target-org WealthAdvisor

# Run all Apex tests
sf apex run test --target-org WealthAdvisor --code-coverage --result-format human

# Open org in browser
sf org open --target-org WealthAdvisor

# Query DriftAlert records via CLI
sf data query --query "SELECT Id, DriftPct__c, AlertStatus__c, TriggerSource__c FROM DriftAlert__c ORDER BY CreatedDate DESC LIMIT 10" --target-org WealthAdvisor
```

---




# Wealth Advisor Intelligence Platform — Implementation Guide

> **Purpose:** Step-by-step code implementation for all 7 application modules  
> **Prerequisite:** Complete `wealth_advisor_schema_setup.md` before starting this guide  
> **Stack:** Apex · LWC · Agentforce · Data Cloud · Flows · CRM Analytics  

---

## Table of Contents

1. [Module 1 — Advisor 360 Dashboard (LWC)](#module-1--advisor-360-dashboard-lwc)
2. [Module 2 — Agentforce Advisory Copilot](#module-2--agentforce-advisory-copilot)
3. [Module 3 — Proactive Drift Alert Engine](#module-3--proactive-drift-alert-engine)
4. [Module 4 — Book of Business Manager (LWC)](#module-4--book-of-business-manager-lwc)
5. [Module 5 — Portfolio Holdings Analyser (LWC)](#module-5--portfolio-holdings-analyser-lwc)
6. [Module 6 — Compliance & Audit Centre](#module-6--compliance--audit-centre)
7. [Module 7 — Data Ingestion Pipeline (Apex)](#module-7--data-ingestion-pipeline-apex)
8. [Apex Service Layer](#apex-service-layer)
9. [Lightning App & Navigation](#lightning-app--navigation)
10. [Testing Checklist](#testing-checklist)

---

## Module 1 — Advisor 360 Dashboard (LWC)

### Overview

Single-page record view for a Contact. One parent component makes one Apex wire call and distributes data to three child components via `@api`. No duplicate server calls.

### File Structure

```
force-app/main/default/
  lwc/
    advisorDashboard/           ← Parent container
      advisorDashboard.html
      advisorDashboard.js
      advisorDashboard.js-meta.xml
    portfolioSummaryCard/       ← Child 1
      portfolioSummaryCard.html
      portfolioSummaryCard.js
      portfolioSummaryCard.js-meta.xml
    riskScoreCard/              ← Child 2
      riskScoreCard.html
      riskScoreCard.js
      riskScoreCard.js-meta.xml
    alertFeed/                  ← Child 3
      alertFeed.html
      alertFeed.js
      alertFeed.js-meta.xml
  classes/
    AdvisorDashboardController.cls
    AdvisorDashboardController.cls-meta.xml
```

---

### Apex Controller

**`AdvisorDashboardController.cls`**

```apex
public with sharing class AdvisorDashboardController {

    /**
     * Single method called by parent LWC wire.
     * Returns all data needed by all three child components.
     * Enforces with sharing — advisors only see their own clients.
     */
    @AuraEnabled(cacheable=true)
    public static AdvisorDashboardData getDashboardData(Id contactId) {
        try {
            AdvisorDashboardData data = new AdvisorDashboardData();

            // 1. Client profile
            data.client = [
                SELECT Id, FirstName, LastName, Email, Phone,
                       RiskTolerance__c, PortfolioDrift__c,
                       DriftAlertSegment__c, ChurnRiskSegment__c,
                       LastAdvisorContact__c, OwnerId, Owner.Name
                FROM Contact
                WHERE Id = :contactId
                WITH USER_MODE
                LIMIT 1
            ];

            // 2. Financial accounts + aggregate AUM
            data.accounts = [
                SELECT Id, Name, AccountNumber__c, AccountType__c,
                       TotalValue__c, TargetEquityPct__c,
                       TargetBondPct__c, TargetCashPct__c, Status__c
                FROM FinancialAccount__c
                WHERE ContactId__c = :contactId
                WITH USER_MODE
                ORDER BY TotalValue__c DESC NULLS LAST
            ];

            // 3. Portfolio holdings (top 10 by value)
            Set<Id> accountIds = new Map<Id, FinancialAccount__c>(data.accounts).keySet();
            data.holdings = [
                SELECT Id, Ticker__c, AssetClass__c, Quantity__c,
                       CurrentValue__c, CurrentAllocationPct__c, AsOfDate__c,
                       FinancialAccountId__c
                FROM PortfolioHolding__c
                WHERE FinancialAccountId__c IN :accountIds
                WITH USER_MODE
                ORDER BY CurrentValue__c DESC NULLS LAST
                LIMIT 10
            ];

            // 4. Open drift alerts
            data.alerts = [
                SELECT Id, Name, DriftPct__c, AlertStatus__c,
                       TriggerSource__c, DetectedAt__c, FinancialAccountId__c,
                       FinancialAccountId__r.AccountNumber__c
                FROM DriftAlert__c
                WHERE ContactId__c = :contactId
                  AND AlertStatus__c IN ('New', 'In Progress')
                WITH USER_MODE
                ORDER BY DetectedAt__c DESC
                LIMIT 5
            ];

            // 5. Total AUM across all accounts
            AggregateResult[] agg = [
                SELECT SUM(TotalValue__c) totalAUM
                FROM FinancialAccount__c
                WHERE ContactId__c = :contactId
                  AND Status__c = 'Active'
                WITH USER_MODE
            ];
            data.totalAUM = (Decimal) agg[0].get('totalAUM');

            return data;

        } catch (Exception e) {
            throw new AuraHandledException('Failed to load dashboard data: ' + e.getMessage());
        }
    }

    /**
     * Called when advisor resolves a drift alert inline from the dashboard.
     */
    @AuraEnabled
    public static void resolveAlert(Id alertId) {
        try {
            DriftAlert__c alert = [
                SELECT Id, AlertStatus__c FROM DriftAlert__c
                WHERE Id = :alertId WITH USER_MODE LIMIT 1
            ];
            alert.AlertStatus__c = 'Resolved';
            alert.ResolvedAt__c   = DateTime.now();
            update as user alert;
        } catch (Exception e) {
            throw new AuraHandledException('Failed to resolve alert: ' + e.getMessage());
        }
    }

    /**
     * Wrapper class — single return object keeps wire call count to 1.
     */
    public class AdvisorDashboardData {
        @AuraEnabled public Contact client;
        @AuraEnabled public List<FinancialAccount__c> accounts;
        @AuraEnabled public List<PortfolioHolding__c> holdings;
        @AuraEnabled public List<DriftAlert__c>       alerts;
        @AuraEnabled public Decimal                   totalAUM;
    }
}
```

---

### Parent Component

**`advisorDashboard.html`**

```html
<template>
    <!-- Loading state -->
    <template if:true={isLoading}>
        <lightning-spinner alternative-text="Loading client data..." size="medium"></lightning-spinner>
    </template>

    <!-- Error state -->
    <template if:true={hasError}>
        <lightning-card title="Error">
            <div class="slds-p-around_medium">
                <p class="slds-text-color_error">{errorMessage}</p>
            </div>
        </lightning-card>
    </template>

    <!-- Dashboard -->
    <template if:true={hasData}>
        <div class="slds-grid slds-wrap slds-gutters">

            <!-- Row 1: Summary cards -->
            <div class="slds-col slds-size_1-of-1 slds-medium-size_4-of-12">
                <c-risk-score-card
                    client={dashboardData.client}
                    total-a-u-m={dashboardData.totalAUM}>
                </c-risk-score-card>
            </div>

            <div class="slds-col slds-size_1-of-1 slds-medium-size_5-of-12">
                <c-portfolio-summary-card
                    accounts={dashboardData.accounts}
                    holdings={dashboardData.holdings}>
                </c-portfolio-summary-card>
            </div>

            <div class="slds-col slds-size_1-of-1 slds-medium-size_3-of-12">
                <c-alert-feed
                    alerts={dashboardData.alerts}
                    onalertresolved={handleAlertResolved}>
                </c-alert-feed>
            </div>

        </div>
    </template>
</template>
```

**`advisorDashboard.js`**

```javascript
import { LightningElement, api, wire, track } from 'lwc';
import getDashboardData from '@salesforce/apex/AdvisorDashboardController.getDashboardData';
import resolveAlert from '@salesforce/apex/AdvisorDashboardController.resolveAlert';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class AdvisorDashboard extends LightningElement {

    @api recordId;   // Contact Id from record page context

    @track dashboardData;
    @track isLoading = true;
    @track errorMessage;

    _wiredResult;

    // Single wire call — data flows down to children via @api
    @wire(getDashboardData, { contactId: '$recordId' })
    wiredDashboard(result) {
        this._wiredResult = result;
        this.isLoading = false;
        if (result.data) {
            this.dashboardData = result.data;
            this.errorMessage  = null;
        } else if (result.error) {
            this.errorMessage = result.error.body?.message || 'Unknown error';
        }
    }

    get hasData()  { return !!this.dashboardData; }
    get hasError() { return !!this.errorMessage;  }

    async handleAlertResolved(event) {
        const alertId = event.detail.alertId;
        try {
            await resolveAlert({ alertId });
            this.dispatchEvent(new ShowToastEvent({
                title:   'Alert resolved',
                message: 'Drift alert has been marked as resolved.',
                variant: 'success'
            }));
            await refreshApex(this._wiredResult);
        } catch (e) {
            this.dispatchEvent(new ShowToastEvent({
                title:   'Error',
                message: e.body?.message || 'Could not resolve alert.',
                variant: 'error'
            }));
        }
    }
}
```

**`advisorDashboard.js-meta.xml`**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>62.0</apiVersion>
    <isExposed>true</isExposed>
    <targets>
        <target>lightning__RecordPage</target>
    </targets>
    <targetConfigs>
        <targetConfig targets="lightning__RecordPage">
            <objects>
                <object>Contact</object>
            </objects>
        </targetConfig>
    </targetConfigs>
</LightningComponentBundle>
```

---

### Child Component — Alert Feed

**`alertFeed.html`**

```html
<template>
    <lightning-card title="Drift Alerts" icon-name="utility:warning">
        <template if:true={hasAlerts}>
            <ul class="slds-list_dotted slds-p-around_small">
                <template for:each={alerts} for:item="alert">
                    <li key={alert.Id} class="slds-item slds-p-vertical_x-small">
                        <div class="slds-grid slds-grid_align-spread">
                            <div>
                                <span class={alertBadgeClass(alert.AlertStatus__c)}>
                                    {alert.AlertStatus__c}
                                </span>
                                <p class="slds-text-body_small slds-m-top_xx-small">
                                    Drift: <strong>{alert.DriftPct__c}%</strong>
                                    &nbsp;·&nbsp; {alert.TriggerSource__c}
                                </p>
                                <p class="slds-text-color_weak slds-text-body_small">
                                    {alert.FinancialAccountId__r.AccountNumber__c}
                                </p>
                            </div>
                            <lightning-button-icon
                                icon-name="utility:check"
                                title="Resolve"
                                onclick={handleResolve}
                                data-alert-id={alert.Id}
                                variant="border-filled"
                                size="small">
                            </lightning-button-icon>
                        </div>
                    </li>
                </template>
            </ul>
        </template>
        <template if:false={hasAlerts}>
            <div class="slds-p-around_medium slds-text-align_center">
                <lightning-icon icon-name="utility:check" size="small"
                    alternative-text="No alerts"></lightning-icon>
                <p class="slds-text-color_success slds-m-top_x-small">No open alerts</p>
            </div>
        </template>
    </lightning-card>
</template>
```

**`alertFeed.js`**

```javascript
import { LightningElement, api } from 'lwc';

export default class AlertFeed extends LightningElement {

    @api alerts = [];

    get hasAlerts() { return this.alerts && this.alerts.length > 0; }

    handleResolve(event) {
        const alertId = event.currentTarget.dataset.alertId;
        // Fire event UP to parent — child never calls Apex directly
        this.dispatchEvent(new CustomEvent('alertresolved', {
            detail: { alertId },
            bubbles: true,
            composed: true
        }));
    }
}
```

---

## Module 2 — Agentforce Advisory Copilot

### Overview

Agentforce Agent embedded on the Contact record page. Three Topics, four Actions. Trust Layer enabled. Out-of-scope queries escalate to human.

### Step 1 — Create the Agent

```
Setup → Einstein → Agentforce → Agents → New Agent

Name:        Wealth Advisory Copilot
API Name:    Wealth_Advisory_Copilot
Description: Assists financial advisors with client portfolio queries,
             drift analysis, and segment lookups. Does NOT give investment advice.
User-facing name: Advisory Copilot
```

### Step 2 — Configure Einstein Trust Layer

```
Setup → Einstein → Einstein Trust Layer

Enable:
  ✅ PII Masking (mask: Email, Phone, SSN patterns)
  ✅ Zero Data Retention (LLM provider does not store prompts)
  ✅ Toxicity Detection
  ✅ Grounding Audit Log
```

### Step 3 — Create Topics

**Topic 1: Client Portfolio Summary**

```
Name:         Client Portfolio Summary
API Name:     Client_Portfolio_Summary
Description:  Handles questions about a client's account balances, 
              total AUM, account types, and last advisor contact.
              Does NOT answer questions about trade recommendations.

Scope (instructions to LLM):
  You help financial advisors understand a client's portfolio summary.
  You may answer questions about: total AUM, account types, account balances,
  number of accounts, last advisor contact date, and risk tolerance profile.
  You MUST NOT recommend buying or selling any security.
  You MUST NOT provide investment advice of any kind.
  If asked for advice, immediately trigger the Escalate_To_Human action.
  Always cite the data source in your response.
```

**Topic 2: Drift & Alert Lookup**

```
Name:         Drift and Alert Lookup
API Name:     Drift_Alert_Lookup
Description:  Handles questions about portfolio drift, open alerts,
              allocation vs target, and drift history.

Scope:
  You help financial advisors understand portfolio drift for a specific client.
  You may answer: current drift %, which asset class is drifting, 
  open alert status, historical drift trends.
  You MUST NOT say whether the client should rebalance.
  You MUST NOT recommend any trades to address drift.
```

**Topic 3: Segment Membership Query**

```
Name:         Segment Membership Query
API Name:     Segment_Membership_Query
Description:  Handles questions about which Data Cloud segments a client
              belongs to and what criteria placed them there.

Scope:
  You help advisors understand which intelligence segments a client 
  has been assigned to by Data Cloud.
  You may explain: Drift Alert segment membership, High Risk segment,
  Churn Risk (no contact 90 days) segment.
  Explain the criteria that caused segment entry clearly.
```

### Step 4 — Create Agent Actions

**Action 1: Get Unified Client Profile**

```
Name:            Get Unified Client Profile
API Name:        Get_Unified_Client_Profile
Type:            Apex
Apex Class:      AgentActionController (method: getUnifiedProfile)
Topic:           Client Portfolio Summary
Input:           contactId (String) — from record context
Output:          clientProfile (String JSON)
Description:     Retrieves unified client profile from Data Cloud 
                 UnifiedIndividual__dlm including synced-back CRM fields.
```

**Action 2: Query Portfolio Holdings**

```
Name:            Query Portfolio Holdings
API Name:        Query_Portfolio_Holdings
Type:            Apex
Apex Class:      AgentActionController (method: queryHoldingsFromDC)
Topic:           Drift and Alert Lookup
Input:           contactId (String)
Output:          holdingsSummary (String JSON)
Description:     Calls Data Cloud Query API to fetch live PortfolioTransactionDMO__dlm
                 records. Returns current allocation breakdown by asset class.
```

**Action 3: Get Segment Membership**

```
Name:            Get Segment Membership
API Name:        Get_Segment_Membership
Type:            Apex
Apex Class:      AgentActionController (method: getSegmentMembership)
Topic:           Segment Membership Query
Input:           contactId (String)
Output:          segmentList (String)
Description:     Returns which of the 3 Data Cloud segments this client 
                 is currently a member of, and the reason for each.
```

**Action 4: Escalate To Human**

```
Name:            Escalate To Human Advisor
API Name:        Escalate_To_Human
Type:            Flow
Flow:            Agentforce_Escalation_Flow
Topic:           All Topics (available on any out-of-scope query)
Input:           contactId, queryText, escalationReason
Output:          caseNumber (String)
Description:     Creates a Case record and AgentInteraction__c log entry.
                 Routes to human advisor via Salesforce Messaging.
```

### Step 5 — Apex Actions Class

**`AgentActionController.cls`**

```apex
public with sharing class AgentActionController {

    /**
     * Action 1: Get unified profile (CRM data + synced DC fields)
     */
    @InvocableMethod(label='Get Unified Client Profile'
                     description='Returns unified client profile for Agentforce agent')
    public static List<String> getUnifiedProfile(List<String> contactIds) {
        List<String> results = new List<String>();
        for (String contactId : contactIds) {
            try {
                Contact c = [
                    SELECT Id, FirstName, LastName, RiskTolerance__c,
                           PortfolioDrift__c, DriftAlertSegment__c,
                           ChurnRiskSegment__c, LastAdvisorContact__c,
                           Owner.Name,
                           (SELECT TotalValue__c, AccountType__c, Status__c
                            FROM FinancialAccounts__r
                            WHERE Status__c = 'Active')
                    FROM Contact
                    WHERE Id = :contactId
                    WITH USER_MODE
                    LIMIT 1
                ];

                Map<String, Object> profile = new Map<String, Object>{
                    'name'               => c.FirstName + ' ' + c.LastName,
                    'riskTolerance'      => c.RiskTolerance__c,
                    'portfolioDriftPct'  => c.PortfolioDrift__c,
                    'driftAlertActive'   => String.isNotBlank(c.DriftAlertSegment__c),
                    'churnRiskActive'    => String.isNotBlank(c.ChurnRiskSegment__c),
                    'lastAdvisorContact' => c.LastAdvisorContact__c != null
                                           ? c.LastAdvisorContact__c.format()
                                           : 'Never',
                    'advisor'            => c.Owner.Name,
                    'activeAccountCount' => c.FinancialAccounts__r.size()
                };
                results.add(JSON.serialize(profile));
            } catch (Exception e) {
                results.add('{"error":"' + e.getMessage() + '"}');
            }
        }
        return results;
    }

    /**
     * Action 2: Query live holdings from Data Cloud Query API
     */
    @InvocableMethod(label='Query Portfolio Holdings from Data Cloud'
                     description='Calls DC Query API for real-time holding allocation')
    public static List<String> queryHoldingsFromDC(List<String> contactIds) {
        List<String> results = new List<String>();
        for (String contactId : contactIds) {
            results.add(DataCloudQueryService.getHoldingsSummary(contactId));
        }
        return results;
    }

    /**
     * Action 3: Return segment membership with plain-language explanation
     */
    @InvocableMethod(label='Get Segment Membership'
                     description='Returns Data Cloud segment membership for a client')
    public static List<String> getSegmentMembership(List<String> contactIds) {
        List<String> results = new List<String>();
        for (String contactId : contactIds) {
            try {
                Contact c = [
                    SELECT DriftAlertSegment__c, ChurnRiskSegment__c,
                           PortfolioDrift__c, LastAdvisorContact__c
                    FROM Contact WHERE Id = :contactId
                    WITH USER_MODE LIMIT 1
                ];

                List<String> segments = new List<String>();
                if (String.isNotBlank(c.DriftAlertSegment__c)) {
                    segments.add('DRIFT ALERT — Portfolio drift of '
                        + c.PortfolioDrift__c + '% exceeds 5% threshold.');
                }
                if (String.isNotBlank(c.ChurnRiskSegment__c)) {
                    String lastContact = c.LastAdvisorContact__c != null
                        ? c.LastAdvisorContact__c.format() : 'never';
                    segments.add('CHURN RISK — Last advisor contact: ' + lastContact + '.');
                }
                results.add(segments.isEmpty()
                    ? 'This client is not currently in any alert segment.'
                    : String.join(segments, '\n'));
            } catch (Exception e) {
                results.add('Error: ' + e.getMessage());
            }
        }
        return results;
    }
}
```

### Step 6 — Escalation Flow

Create a Flow named `Agentforce_Escalation_Flow` in Flow Builder.

```
Flow Type: Autolaunched Flow

Input Variables:
  contactId       (Text, Input)
  queryText       (Text, Input)
  escalationReason (Text, Input)

Output Variables:
  caseNumber      (Text, Output)

Nodes:

1. Create Records — AgentInteraction__c
   Fields:
     ContactId__c     = {$Flow.contactId}
     QueryText__c     = {$Flow.queryText}
     EscalationReason__c = {$Flow.escalationReason}
     WasEscalated__c  = TRUE
     AgentTopic__c    = "Escalation - Investment Advice"
     InteractionTime__c = {$Flow.CurrentDateTime}
     AdvisorId__c     = {$Flow.CurrentUser.Id}

2. Create Records — Case
   Fields:
     Subject         = "Advisor Escalation: Investment Query"
     Description     = {$Flow.queryText}
     ContactId       = {$Flow.contactId}
     Status          = "New"
     Origin          = "Agentforce"
     Priority        = "High"
   Store result ID in variable: newCaseId

3. Get Records — Case (to retrieve CaseNumber)
   Filter: Id = {newCaseId}
   Store in: caseRecord

4. Assignment
   caseNumber = {caseRecord.CaseNumber}
```

---

## Module 3 — Proactive Drift Alert Engine

### Overview

Fully automated pipeline: Calculated Insight (SQL) → Segment entry → Data Cloud-triggered Flow → `DriftAlert__c` record + Task + Custom Notification.

### Step 1 — Custom Notification Type

```
Setup → Custom Notifications → New

Name:     Portfolio Drift Alert
API Name: Portfolio_Drift_Alert
Channel:  Desktop and Mobile
```

### Step 2 — Data Cloud-Triggered Flow

Create in **Flow Builder → New Flow → Data Cloud-Triggered Flow**.

```
Flow Name:       DC_Drift_Alert_Flow
Trigger:         Segment membership — Portfolio_Drift_Alert (on entry)
Object Context:  UnifiedIndividual__dlm

Node 1 — Get CRM Contact
  Action:  Get Records (Contact)
  Filter:  DCUnifiedIndividualId__c = {UnifiedIndividual.UnifiedRecordId}
  Fields:  Id, OwnerId, FirstName, LastName, PortfolioDrift__c
  Store:   clientContact

Node 2 — Get Financial Account
  Action:  Get Records (FinancialAccount__c)
  Filter:  ContactId__c = {clientContact.Id}
           AND Status__c = 'Active'
  Sort:    TotalValue__c DESC
  First:   1 record only
  Store:   primaryAccount

Node 3 — Create DriftAlert__c
  Fields:
    ContactId__c          = {clientContact.Id}
    FinancialAccountId__c = {primaryAccount.Id}
    DriftPct__c           = {clientContact.PortfolioDrift__c}
    AlertStatus__c        = "New"
    TriggerSource__c      = "Data Cloud"
    DetectedAt__c         = {$Flow.CurrentDateTime}

Node 4 — Create Task for Advisor
  Fields:
    WhatId       = {clientContact.Id}
    OwnerId      = {clientContact.OwnerId}
    Subject      = "Review portfolio drift — " + {clientContact.FirstName} + " " + {clientContact.LastName}
    ActivityDate = {$Flow.CurrentDate} + 2 days (use Add Days formula)
    Priority     = "High"
    Status       = "Not Started"
    Description  = "Portfolio drift of " + {clientContact.PortfolioDrift__c} + "% detected by Data Cloud."

Node 5 — Send Custom Notification
  Action:       Send Custom Notification
  Type:         Portfolio_Drift_Alert
  Recipient:    {clientContact.OwnerId}
  Title:        "⚠️ Drift Alert — " + {clientContact.FirstName} + " " + {clientContact.LastName}
  Body:         "Portfolio drift of " + {clientContact.PortfolioDrift__c} + "% exceeds threshold."
  Target Page:  Contact record — {clientContact.Id}
```

---

## Module 4 — Book of Business Manager (LWC)

### Overview

App home page component. Advisor's full client list sorted by drift severity. Segment filter bar. Lightning Message Service for cross-component alerts.

### File Structure

```
lwc/
  bookOfBusiness/
    bookOfBusiness.html
    bookOfBusiness.js
    bookOfBusiness.js-meta.xml
  messageChannels/
    DriftAlertBroadcast.messageChannel-meta.xml
classes/
  BookOfBusinessController.cls
```

### Message Channel

**`DriftAlertBroadcast.messageChannel-meta.xml`**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<LightningMessageChannel xmlns="http://soap.sforce.com/2006/04/metadata">
    <masterLabel>DriftAlertBroadcast</masterLabel>
    <isExposed>true</isExposed>
    <description>Broadcasts drift alert events across unrelated LWC components on the same page.</description>
    <lightningMessageFields>
        <fieldName>contactId</fieldName>
        <description>Contact record ID of the affected client</description>
    </lightningMessageFields>
    <lightningMessageFields>
        <fieldName>driftPct</fieldName>
        <description>Drift percentage that triggered the alert</description>
    </lightningMessageFields>
</LightningMessageChannel>
```

### Apex Controller

**`BookOfBusinessController.cls`**

```apex
public with sharing class BookOfBusinessController {

    @AuraEnabled(cacheable=true)
    public static List<ClientSummary> getBookOfBusiness(String segmentFilter) {
        String query =
            'SELECT Id, FirstName, LastName, Email, ' +
            '       RiskTolerance__c, PortfolioDrift__c, ' +
            '       DriftAlertSegment__c, ChurnRiskSegment__c, ' +
            '       LastAdvisorContact__c, ' +
            '       (SELECT TotalValue__c FROM FinancialAccounts__r ' +
            '        WHERE Status__c = \'Active\') ' +
            'FROM Contact ' +
            'WHERE OwnerId = :currentUserId ';

        Id currentUserId = UserInfo.getUserId();

        if (segmentFilter == 'Drift Alert') {
            query += 'AND DriftAlertSegment__c != null ';
        } else if (segmentFilter == 'Churn Risk') {
            query += 'AND ChurnRiskSegment__c != null ';
        } else if (segmentFilter == 'High Risk') {
            query += 'AND RiskTolerance__c IN (\'Aggressive\', \'Speculative\') ';
        }

        query += 'ORDER BY PortfolioDrift__c DESC NULLS LAST LIMIT 200';

        List<Contact> contacts = Database.query(query);
        List<ClientSummary> summaries = new List<ClientSummary>();

        for (Contact c : contacts) {
            ClientSummary cs = new ClientSummary();
            cs.contactId         = c.Id;
            cs.fullName          = c.FirstName + ' ' + c.LastName;
            cs.email             = c.Email;
            cs.riskTolerance     = c.RiskTolerance__c;
            cs.driftPct          = c.PortfolioDrift__c;
            cs.driftAlertActive  = String.isNotBlank(c.DriftAlertSegment__c);
            cs.churnRiskActive   = String.isNotBlank(c.ChurnRiskSegment__c);
            cs.lastContact       = c.LastAdvisorContact__c;

            Decimal totalAUM = 0;
            for (FinancialAccount__c fa : c.FinancialAccounts__r) {
                totalAUM += fa.TotalValue__c != null ? fa.TotalValue__c : 0;
            }
            cs.totalAUM = totalAUM;
            summaries.add(cs);
        }
        return summaries;
    }

    public class ClientSummary {
        @AuraEnabled public Id      contactId;
        @AuraEnabled public String  fullName;
        @AuraEnabled public String  email;
        @AuraEnabled public String  riskTolerance;
        @AuraEnabled public Decimal driftPct;
        @AuraEnabled public Boolean driftAlertActive;
        @AuraEnabled public Boolean churnRiskActive;
        @AuraEnabled public Decimal totalAUM;
        @AuraEnabled public DateTime lastContact;
    }
}
```

### LWC

**`bookOfBusiness.html`**

```html
<template>
    <lightning-card title="My Book of Business" icon-name="standard:contact">

        <!-- Segment filter bar -->
        <div slot="actions">
            <lightning-button-group>
                <lightning-button label="All" value="All"
                    variant={allVariant} onclick={handleFilter}></lightning-button>
                <lightning-button label="Drift Alert" value="Drift Alert"
                    variant={driftVariant} onclick={handleFilter}></lightning-button>
                <lightning-button label="High Risk" value="High Risk"
                    variant={riskVariant} onclick={handleFilter}></lightning-button>
                <lightning-button label="Churn Risk" value="Churn Risk"
                    variant={churnVariant} onclick={handleFilter}></lightning-button>
            </lightning-button-group>
        </div>

        <!-- AUM summary bar -->
        <div class="slds-p-horizontal_medium slds-p-bottom_small">
            <p class="slds-text-body_small slds-text-color_weak">
                Total Book AUM:
                <strong><lightning-formatted-number
                    value={totalBookAUM}
                    format-style="currency"
                    currency-code="USD"
                    maximum-fraction-digits="0">
                </lightning-formatted-number></strong>
                &nbsp;·&nbsp; {clientCount} clients
            </p>
        </div>

        <!-- Client list -->
        <template if:true={clients}>
            <lightning-datatable
                key-field="contactId"
                data={clients}
                columns={columns}
                hide-checkbox-column
                onrowaction={handleRowAction}>
            </lightning-datatable>
        </template>

        <template if:true={isLoading}>
            <lightning-spinner size="small"></lightning-spinner>
        </template>

    </lightning-card>
</template>
```

**`bookOfBusiness.js`**

```javascript
import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { MessageContext, publish } from 'lightning/messageService';
import DriftAlertBroadcast from '@salesforce/messageChannel/DriftAlertBroadcast__c';
import getBookOfBusiness from '@salesforce/apex/BookOfBusinessController.getBookOfBusiness';

const COLUMNS = [
    { label: 'Client', fieldName: 'contactId', type: 'url',
      typeAttributes: { label: { fieldName: 'fullName' }, target: '_self' }},
    { label: 'Total AUM', fieldName: 'totalAUM', type: 'currency',
      typeAttributes: { currencyCode: 'USD', maximumFractionDigits: 0 },
      sortable: true },
    { label: 'Drift %', fieldName: 'driftPct', type: 'percent',
      typeAttributes: { maximumFractionDigits: 1 }, sortable: true },
    { label: 'Risk', fieldName: 'riskTolerance', type: 'text' },
    { label: 'Alerts', fieldName: 'driftAlertActive', type: 'boolean' },
    { label: 'Actions', type: 'action', typeAttributes: {
        rowActions: [
            { label: 'View 360', name: 'view' },
            { label: 'Log Call', name: 'logcall' }
        ]
    }}
];

export default class BookOfBusiness extends NavigationMixin(LightningElement) {

    @wire(MessageContext) messageContext;
    @track clients      = [];
    @track isLoading    = true;
    @track activeFilter = 'All';
    columns = COLUMNS;

    @wire(getBookOfBusiness, { segmentFilter: '$activeFilter' })
    wiredClients({ data, error }) {
        this.isLoading = false;
        if (data) {
            this.clients = data.map(c => ({
                ...c,
                contactId: '/lightning/r/Contact/' + c.contactId + '/view'
            }));
        }
    }

    get totalBookAUM() {
        return this.clients.reduce((sum, c) => sum + (c.totalAUM || 0), 0);
    }
    get clientCount() { return this.clients.length; }

    handleFilter(event) {
        this.activeFilter = event.target.value;
    }

    handleRowAction(event) {
        const action  = event.detail.action.name;
        const row     = event.detail.row;
        if (action === 'view') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: { recordId: row.contactId.split('/')[5], actionName: 'view' }
            });
        }
        if (action === 'logcall') {
            // Publish via LMS — unrelated components can listen
            publish(this.messageContext, DriftAlertBroadcast, {
                contactId: row.contactId,
                driftPct:  row.driftPct
            });
        }
    }

    get allVariant()   { return this.activeFilter === 'All'        ? 'brand' : 'neutral'; }
    get driftVariant() { return this.activeFilter === 'Drift Alert' ? 'brand' : 'neutral'; }
    get riskVariant()  { return this.activeFilter === 'High Risk'   ? 'brand' : 'neutral'; }
    get churnVariant() { return this.activeFilter === 'Churn Risk'  ? 'brand' : 'neutral'; }
}
```

---

## Module 5 — Portfolio Holdings Analyser (LWC)

### Data Cloud Query API — Apex Service

**`DataCloudQueryService.cls`**

```apex
public with sharing class DataCloudQueryService {

    private static final String DC_NAMED_CREDENTIAL = 'callout:DataCloud_QueryAPI';

    /**
     * Calls Data Cloud Query API to retrieve live transaction data.
     * Used by Agentforce Agent Action and Holdings Analyser LWC.
     */
    public static String getHoldingsSummary(String contactId) {
        try {
            // Step 1: get the DC Unified Individual ID from CRM
            Contact c = [
                SELECT DCUnifiedIndividualId__c
                FROM Contact WHERE Id = :contactId
                WITH USER_MODE LIMIT 1
            ];

            if (String.isBlank(c.DCUnifiedIndividualId__c)) {
                return '{"error":"No unified Data Cloud profile found for this client."}';
            }

            // Step 2: build DC SQL query
            String sql = 'SELECT AssetClass__c, ' +
                         'SUM(Amount__c) AS TotalValue, ' +
                         'COUNT(Id) AS TransactionCount ' +
                         'FROM PortfolioTransactionDMO__dlm pt ' +
                         'JOIN FinancialAccountDMO__dlm fa ON pt.FinancialAccountId = fa.Id ' +
                         'JOIN Individual__dlm ind ON fa.IndividualId = ind.Id ' +
                         'WHERE ind.UnifiedRecordId = \'' + c.DCUnifiedIndividualId__c + '\' ' +
                         'AND pt.TransactionDate__c >= DATEADD(DAY, -90, TODAY()) ' +
                         'GROUP BY AssetClass__c ' +
                         'ORDER BY TotalValue DESC';

            // Step 3: POST to Data Cloud Query API
            HttpRequest req = new HttpRequest();
            req.setEndpoint(DC_NAMED_CREDENTIAL + '/api/v1/query');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(new Map<String, String>{ 'sql' => sql }));
            req.setTimeout(10000);

            HttpResponse res = new Http().send(req);

            if (res.getStatusCode() == 200) {
                return res.getBody();
            } else {
                return '{"error":"DC Query API returned ' + res.getStatusCode() + '"}';
            }

        } catch (Exception e) {
            return '{"error":"' + e.getMessage() + '"}';
        }
    }

    /**
     * Fetches market data for tickers held by a client.
     * Uses sync-back CRM holdings — no extra DC call needed.
     */
    @AuraEnabled(cacheable=true)
    public static List<PortfolioHolding__c> getHoldingsWithMarketData(Id contactId) {
        // Get accounts
        List<Id> accountIds = new List<Id>();
        for (FinancialAccount__c fa : [
            SELECT Id FROM FinancialAccount__c
            WHERE ContactId__c = :contactId AND Status__c = 'Active'
            WITH USER_MODE
        ]) { accountIds.add(fa.Id); }

        return [
            SELECT Id, Ticker__c, AssetClass__c, Quantity__c,
                   CurrentValue__c, CurrentAllocationPct__c,
                   AsOfDate__c, FinancialAccountId__r.AccountNumber__c
            FROM PortfolioHolding__c
            WHERE FinancialAccountId__c IN :accountIds
            WITH USER_MODE
            ORDER BY CurrentValue__c DESC NULLS LAST
        ];
    }
}
```

### Holdings Analyser LWC

**`holdingsAnalyser.html`**

```html
<template>
    <lightning-card title="Portfolio Holdings" icon-name="utility:money">

        <!-- Allocation chart placeholder (use canvas or SLDS chart) -->
        <div class="slds-p-around_medium">
            <h3 class="slds-text-heading_small slds-m-bottom_small">
                Allocation vs Target
            </h3>
            <template for:each={allocationRows} for:item="row">
                <div key={row.assetClass} class="slds-grid slds-m-bottom_x-small">
                    <div class="slds-col slds-size_3-of-12">
                        <p class="slds-text-body_small">{row.assetClass}</p>
                    </div>
                    <div class="slds-col slds-size_6-of-12">
                        <!-- Progress bar: current allocation -->
                        <lightning-progress-bar
                            value={row.currentPct}
                            size="small"
                            variant={row.variant}>
                        </lightning-progress-bar>
                    </div>
                    <div class="slds-col slds-size_3-of-12 slds-text-align_right">
                        <p class="slds-text-body_small">
                            {row.currentPct}% / {row.targetPct}%
                        </p>
                    </div>
                </div>
            </template>
        </div>

        <!-- Holdings table -->
        <lightning-datatable
            key-field="Id"
            data={holdings}
            columns={holdingColumns}
            hide-checkbox-column>
        </lightning-datatable>

    </lightning-card>
</template>
```

**`holdingsAnalyser.js`**

```javascript
import { LightningElement, api, wire } from 'lwc';
import getHoldingsWithMarketData from '@salesforce/apex/DataCloudQueryService.getHoldingsWithMarketData';

const COLUMNS = [
    { label: 'Ticker',       fieldName: 'Ticker__c',              type: 'text'     },
    { label: 'Asset Class',  fieldName: 'AssetClass__c',          type: 'text'     },
    { label: 'Quantity',     fieldName: 'Quantity__c',            type: 'number',
      typeAttributes: { maximumFractionDigits: 2 } },
    { label: 'Market Value', fieldName: 'CurrentValue__c',        type: 'currency',
      typeAttributes: { currencyCode: 'USD' }, sortable: true },
    { label: 'Allocation %', fieldName: 'CurrentAllocationPct__c',type: 'percent',
      typeAttributes: { maximumFractionDigits: 1 } },
    { label: 'As Of',        fieldName: 'AsOfDate__c',            type: 'date'     }
];

export default class HoldingsAnalyser extends LightningElement {

    @api recordId;
    holdingColumns = COLUMNS;
    holdings = [];

    @wire(getHoldingsWithMarketData, { contactId: '$recordId' })
    wiredHoldings({ data }) {
        if (data) this.holdings = data;
    }

    get allocationRows() {
        const classes = ['Equity - US', 'Equity - International',
                         'Fixed Income - Government', 'Fixed Income - Corporate',
                         'Cash & Equivalents'];
        return classes.map(cls => {
            const holding = this.holdings.find(h => h.AssetClass__c === cls);
            const current = holding ? holding.CurrentAllocationPct__c || 0 : 0;
            return {
                assetClass: cls,
                currentPct: Math.round(current),
                targetPct:  0, // TODO: fetch from FinancialAccount__c target fields
                variant:    current > 75 ? 'warning' : 'base'
            };
        });
    }
}
```

---

## Module 6 — Compliance & Audit Centre

### CRM Analytics Dashboard

Create in **CRM Analytics Studio → Create → Dashboard**.

**Dataset 1: Agent Interactions**

```
Source: AgentInteraction__c
Fields:
  InteractionTime__c (Date)
  AgentTopic__c      (Dimension)
  WasEscalated__c    (Measure — count)
  EscalationReason__c (Dimension)
  AdvisorId__c       (Dimension — link to User.Name)
  ContactId__c       (Dimension)
```

**Dashboard Widgets:**

```
Widget 1 — KPI: Total Interactions (last 30 days)
  SAQL: q = load "AgentInteractions";
        q = filter q by date('InteractionTime__c') in ["30 days ago".."now"];
        q = group q by all;
        q = foreach q generate count() as 'Total';
        q = limit q 1;

Widget 2 — KPI: Escalation Rate %
  SAQL: q = load "AgentInteractions";
        q = group q by 'WasEscalated__c';
        q = foreach q generate 'WasEscalated__c',
            count() as 'Count';

Widget 3 — Bar Chart: Interactions by Topic
  SAQL: q = load "AgentInteractions";
        q = group q by 'AgentTopic__c';
        q = foreach q generate 'AgentTopic__c', count() as 'Count';
        q = order q by 'Count' desc;

Widget 4 — Table: Recent Escalations
  SAQL: q = load "AgentInteractions";
        q = filter q by 'WasEscalated__c' == "true";
        q = foreach q generate 'InteractionTime__c', 'QueryText__c',
            'EscalationReason__c', 'AdvisorId__c';
        q = order q by 'InteractionTime__c' desc;
        q = limit q 50;

Widget 5 — Bar Chart: Drift Alerts by Status (DriftAlert__c dataset)
  Source: DriftAlert__c
  SAQL: q = load "DriftAlerts";
        q = group q by 'AlertStatus__c';
        q = foreach q generate 'AlertStatus__c', count() as 'Count';
```

### Compliance Report — Apex

**`ComplianceReportController.cls`**

```apex
public with sharing class ComplianceReportController {

    /**
     * Returns all escalated agent interactions for a date range.
     * Used by compliance officers — enforces View All on AgentInteraction__c.
     */
    @AuraEnabled(cacheable=true)
    public static List<AgentInteraction__c> getEscalatedInteractions(
        Date startDate, Date endDate) {

        return [
            SELECT Id, QueryText__c, EscalationReason__c, AgentTopic__c,
                   InteractionTime__c,
                   AdvisorId__c, AdvisorId__r.Name,
                   ContactId__c, ContactId__r.Name
            FROM AgentInteraction__c
            WHERE WasEscalated__c = TRUE
              AND InteractionTime__c >= :DateTime.newInstance(startDate, Time.newInstance(0,0,0,0))
              AND InteractionTime__c <= :DateTime.newInstance(endDate, Time.newInstance(23,59,59,0))
            WITH USER_MODE
            ORDER BY InteractionTime__c DESC
            LIMIT 1000
        ];
    }

    /**
     * Returns drift alert history for a specific client.
     */
    @AuraEnabled(cacheable=true)
    public static List<DriftAlert__c> getDriftAlertHistory(Id contactId) {
        return [
            SELECT Id, DriftPct__c, AlertStatus__c, TriggerSource__c,
                   DetectedAt__c, ResolvedAt__c,
                   FinancialAccountId__r.AccountNumber__c
            FROM DriftAlert__c
            WHERE ContactId__c = :contactId
            WITH USER_MODE
            ORDER BY DetectedAt__c DESC
            LIMIT 50
        ];
    }
}
```

---

## Module 7 — Data Ingestion Pipeline (Apex)

### Market Data Scheduled Job

**`MarketDataIngestionJob.cls`**

```apex
/**
 * Scheduled Apex job that fetches market data and pushes to
 * Data Cloud via the Ingestion API.
 *
 * Schedule: daily at 01:00 UTC
 * sf apex schedule --name "MarketDataIngestion" --class-name "MarketDataIngestionJob"
 *   --cron-expression "0 0 1 * * ?"
 */
public class MarketDataIngestionJob implements Schedulable, Database.Batchable<String> {

    private static final String DC_INGEST_ENDPOINT =
        'callout:DataCloud_QueryAPI/api/v1/ingest/sources/MarketData_Feed/marketdata';

    private static final List<String> TICKERS =
        new List<String>{ 'AAPL','MSFT','NVDA','TSLA','META',
                          'SPY','BND','TLT','VXUS','CASH' };

    public void execute(SchedulableContext sc) {
        Database.executeBatch(this, 10);
    }

    public Iterable<String> start(Database.BatchableContext bc) {
        return TICKERS;
    }

    public void execute(Database.BatchableContext bc, List<String> tickers) {
        // Fetch prices from Named Credential mock endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:MarketData_Feed/quotes?symbols='
                        + String.join(tickers, ','));
        req.setMethod('GET');
        req.setTimeout(10000);

        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() != 200) return;

        List<Map<String, Object>> quotes =
            (List<Map<String, Object>>) JSON.deserializeUntyped(res.getBody());

        // Build Ingestion API payload
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        for (Map<String, Object> q : quotes) {
            records.add(new Map<String, Object>{
                'Id'             => 'MKT-' + q.get('symbol') + '-' + Date.today(),
                'Ticker__c'      => q.get('symbol'),
                'Price__c'       => q.get('price'),
                'DayChangePct__c'=> q.get('changePercent'),
                'Sector__c'      => q.get('sector'),
                'AsOfDate__c'    => String.valueOf(Date.today())
            });
        }

        // POST to Data Cloud Ingestion API
        HttpRequest ingestReq = new HttpRequest();
        ingestReq.setEndpoint(DC_INGEST_ENDPOINT);
        ingestReq.setMethod('POST');
        ingestReq.setHeader('Content-Type', 'application/json');
        ingestReq.setBody(JSON.serialize(new Map<String, Object>{
            'data' => records
        }));
        ingestReq.setTimeout(15000);
        new Http().send(ingestReq);
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('MarketDataIngestionJob complete: ' + DateTime.now());
    }
}
```

**Schedule the job:**

```apex
// Run in Developer Console → Execute Anonymous
String cronExpr = '0 0 1 * * ?';  // Every day at 01:00 UTC
System.schedule('Market Data Ingestion', cronExpr, new MarketDataIngestionJob());
```

---

## Apex Service Layer

### Test Classes

**`AdvisorDashboardControllerTest.cls`**

```apex
@IsTest
private class AdvisorDashboardControllerTest {

    @TestSetup
    static void makeData() {
        User advisor = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' LIMIT 1];

        Contact client = new Contact(
            FirstName          = 'Test',
            LastName           = 'Client',
            Email              = 'test.client@example.com',
            OwnerId            = advisor.Id,
            RiskTolerance__c   = 'Moderate',
            PortfolioDrift__c  = 7.5
        );
        insert client;

        FinancialAccount__c acct = new FinancialAccount__c(
            AccountNumber__c  = 'FA-TEST-001',
            AccountType__c    = 'Individual Brokerage',
            TotalValue__c     = 250000,
            TargetEquityPct__c = 60,
            TargetBondPct__c  = 35,
            TargetCashPct__c  = 5,
            Status__c         = 'Active',
            ContactId__c      = client.Id
        );
        insert acct;

        DriftAlert__c alert = new DriftAlert__c(
            ContactId__c          = client.Id,
            FinancialAccountId__c = acct.Id,
            DriftPct__c           = 7.5,
            AlertStatus__c        = 'New',
            TriggerSource__c      = 'Data Cloud',
            DetectedAt__c         = DateTime.now()
        );
        insert alert;
    }

    @IsTest
    static void testGetDashboardData_success() {
        Contact client = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        AdvisorDashboardController.AdvisorDashboardData data =
            AdvisorDashboardController.getDashboardData(client.Id);
        Test.stopTest();

        Assert.isNotNull(data.client,   'Client should be populated');
        Assert.isTrue(data.accounts.size() > 0, 'Should have accounts');
        Assert.isTrue(data.alerts.size() > 0,   'Should have open alerts');
        Assert.areEqual(250000, data.totalAUM,  'AUM should match');
    }

    @IsTest
    static void testResolveAlert() {
        DriftAlert__c alert = [SELECT Id FROM DriftAlert__c LIMIT 1];
        Test.startTest();
        AdvisorDashboardController.resolveAlert(alert.Id);
        Test.stopTest();

        DriftAlert__c updated = [SELECT AlertStatus__c FROM DriftAlert__c WHERE Id = :alert.Id];
        Assert.areEqual('Resolved', updated.AlertStatus__c, 'Status should be Resolved');
    }

    @IsTest
    static void testGetDashboardData_invalidId() {
        try {
            AdvisorDashboardController.getDashboardData(null);
            Assert.fail('Should have thrown AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Failed'), 'Should contain error message');
        }
    }
}
```

---

## Lightning App & Navigation

### App Definition

**`WealthAdvisor.app-meta.xml`**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomApplication xmlns="http://soap.sforce.com/2006/04/metadata">
    <defaultLandingTab>standard-home</defaultLandingTab>
    <description>Wealth Advisor Intelligence Platform</description>
    <isNavAutoTempTabsDisabled>false</isNavAutoTempTabsDisabled>
    <isNavPersonalizationDisabled>false</isNavPersonalizationDisabled>
    <label>Wealth Advisor</label>
    <tabs>standard-home</tabs>
    <tabs>standard-Contact</tabs>
    <tabs>FinancialAccount__c</tabs>
    <tabs>DriftAlert__c</tabs>
    <tabs>AgentInteraction__c</tabs>
    <utilityBar>WealthAdvisor_UtilityBar</utilityBar>
</CustomApplication>
```

### Contact Record Page Layout

Add these components to the Contact Lightning Record Page in App Builder:

```
Region: Left (70% width)
  - advisorDashboard (custom LWC)   ← spans full left column
  - holdingsAnalyser (custom LWC)   ← below dashboard

Region: Right (30% width)
  - einstein-copilot (standard base component)  ← Agentforce copilot
  - Activity Timeline (standard)

Page Assignment:
  App: Wealth Advisor
  Record Type: All
  Profile: WealthAdvisor_User
```

### App Home Page

Add to the Lightning App Page for the Wealth Advisor app:

```
Full-width region:
  - bookOfBusiness (custom LWC)
```

---

## Testing Checklist

Run through this checklist after deploying all components.

### Schema & Data

- [ ] All 4 custom objects visible in Object Manager
- [ ] Contact custom fields populated on seed data records
- [ ] `FinancialAccount__c` validation rule fires when allocations ≠ 100%
- [ ] Permission sets assigned to test advisor and compliance users

### Data Cloud

- [ ] CRM Data Stream syncing — `Individual__dlm` records exist
- [ ] Transaction CSV uploaded — `PortfolioTransactionDMO__dlm` records exist
- [ ] Identity Resolution ran — `UnifiedIndividual__dlm` records created
- [ ] `Contact.DCUnifiedIndividualId__c` populated for all seed clients
- [ ] Calculated Insight activated — `PortfolioDriftInsight__dlm` records exist
- [ ] At least one client has `ExceedsThreshold__c = TRUE`
- [ ] Segment `Portfolio_Drift_Alert` shows members
- [ ] Data Share syncing drift % back to `Contact.PortfolioDrift__c`

### Flows & Automation

- [ ] DC-triggered Flow fires when client enters drift segment
- [ ] `DriftAlert__c` record created with `TriggerSource__c = 'Data Cloud'`
- [ ] Task created and assigned to client's OwnerId
- [ ] Custom notification delivered to advisor

### LWC — Advisor 360

- [ ] Dashboard loads on Contact record page — no JS console errors
- [ ] Portfolio summary card shows holdings
- [ ] Drift gauge shows correct % from `PortfolioDrift__c`
- [ ] Alert feed shows open `DriftAlert__c` records
- [ ] "Resolve" button marks alert as Resolved and refreshes feed

### LWC — Book of Business

- [ ] App home page shows client list sorted by drift descending
- [ ] Segment filter buttons correctly filter the list
- [ ] Total AUM and client count update with filter changes

### Agentforce

- [ ] Copilot renders on Contact record page
- [ ] "What is this client's drift status?" returns grounded answer
- [ ] "Should my client sell their Apple stock?" triggers escalation
- [ ] Escalated query creates `AgentInteraction__c` with `WasEscalated__c = TRUE`
- [ ] Escalated query creates a Case record

### Compliance

- [ ] `AgentInteraction__c` records created for every agent conversation
- [ ] CRM Analytics dashboard shows interaction counts and escalation rate
- [ ] Compliance user (WealthAdvisor_Compliance perm set) can View All on `AgentInteraction__c`

---

## Useful Deploy Commands

```bash
# Deploy all LWC components
sf project deploy start --metadata LightningComponentBundle --target-org WealthAdvisor

# Deploy specific Apex class
sf project deploy start --metadata ApexClass:AdvisorDashboardController --target-org WealthAdvisor

# Deploy everything at once
sf project deploy start --source-dir force-app --target-org WealthAdvisor

# Run Apex tests with code coverage
sf apex run test --target-org WealthAdvisor --code-coverage --result-format human --wait 10

# Open specific record page for smoke test
sf org open --path /lightning/r/Contact/[ContactId]/view --target-org WealthAdvisor

# Check Data Cloud stream status via CLI
sf data query \
  --query "SELECT Name, Status__c FROM DataStream ORDER BY LastModifiedDate DESC LIMIT 5" \
  --target-org WealthAdvisor
```

---

*Last updated: June 2026 — Wealth Advisor Intelligence Platform v1.0 — Implementation Guide*

*Last updated: June 2026 — Wealth Advisor Intelligence Platform v1.0*
