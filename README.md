# Healthcare Claims Processing — WSO2 Agent Demo

A demonstration of **multi-agent coordination** for healthcare claims processing built with [Ballerina](https://ballerina.io) and managed via **WSO2 Agent Manager**. This project showcases how a Coordinator Agent orchestrates two specialist agents — an Intake Agent and an Adjudication Agent — to automate claims decisions for a third-party administrator (TPA) such as Magnacare/Brighton.

---

## Overview

In a typical TPA operation, processing a healthcare claim involves multiple validation and adjudication steps handled manually across different teams and systems. This demo collapses that into an automated, agent-driven pipeline with intelligent escalation to a human examiner when needed.

```
Claim submitted (REST API)
        │
        ▼
┌─────────────────────┐
│   Intake Agent      │  Validates the claim — member, procedure code,
│   (claimsintake)    │  duplicate detection
└────────┬────────────┘
         │ passes if valid
         ▼
┌─────────────────────┐
│  Adjudication Agent │  Applies benefit rules — coverage, allowed
│  (adjudication)     │  amount, prior auth
└────────┬────────────┘
         │
         ▼
  ┌──────┴──────┐──────────────┐
  │             │              │
APPROVED     REJECTED    PENDING REVIEW
                          (human examiner)
```

---

## Repository Structure

```
claim-processing/
├── claimsintake/           # Agent 01 — Intake Agent
├── adjudication/           # Agent 02 — Adjudication Agent
├── claimsmcpservice/       # MCP server — claim data tools
├── membersmcpservice/      # MCP server — member and plan lookup tools
├── feeschedulemcpserver/   # MCP server — fee schedule and benefit rules tools
├── .wso2/                  # WSO2 Agent Manager configuration
├── Ballerina.toml          # Project configuration
└── README.md
```

### Component Descriptions

| Component | Type | Responsibility |
|---|---|---|
| `claimsintake` | Ballerina agent | Validates member ID, checks active coverage, validates CPT procedure code format, detects duplicates |
| `adjudication` | Ballerina agent | Checks coverage under the member's plan, compares billed vs allowed amount, flags prior auth, routes decision |
| `claimsmcpservice` | MCP server | Exposes claim submission and lookup tools to agents |
| `membersmcpservice` | MCP server | Exposes member record and plan lookup tools to agents |
| `feeschedulemcpserver` | MCP server | Exposes benefit rules and fee schedule lookup tools to agents |

---

## How It Works

### Agent 01 — Intake Agent

The Intake Agent is the first gate. A claim must pass all three checks before the Adjudication Agent is called. If any check fails, the claim is rejected immediately and no further processing occurs.

| Check | What it does |
|---|---|
| Patient details | Looks up member ID via `membersmcpservice`. Confirms the member exists and coverage status is `ACTIVE`. |
| Procedure code | Validates that the CPT code is a recognised, correctly formatted code (5 digits). |
| Duplicate detection | Queries `claimsmcpservice` for an existing paid claim with the same member, procedure code, and service date. |

### Agent 02 — Adjudication Agent

The Adjudication Agent only runs when the Intake Agent passes. It uses the member's `planId` (returned by the Intake Agent) to look up the correct benefit rules for that specific plan via `feeschedulemcpserver`.

| Check | What it does |
|---|---|
| Coverage check | Confirms the procedure code is covered under the member's plan. |
| Allowed amount | Compares the billed amount against the plan's allowed amount for that procedure. |
| Prior authorisation | Checks whether the procedure requires prior auth. If required and not on file, escalates. |
| Over-limit routing | If billed > allowed, routes to the human review queue rather than auto-denying. |

### Decision outcomes

| Outcome | Trigger |
|---|---|
| `APPROVED` | All intake and adjudication checks pass, billed ≤ allowed, no prior auth required |
| `REJECTED` | Intake check fails (unknown member, inactive, bad code, duplicate) or procedure not covered |
| `PENDING_REVIEW` | Billed amount exceeds allowed limit, or prior auth required but not provided |

---

## Data Model

The three MCP servers expose data from the following structure:

### Plans

| Plan ID | Plan Name | Type | Deductible | OOP Max |
|---|---|---|---|---|
| PLAN-GOLD | Magnacare Gold PPO | PPO | $500 | $3,000 |
| PLAN-SILVER | Magnacare Silver HMO | HMO | $1,500 | $6,000 |
| PLAN-BRONZE | Magnacare Bronze EPO | EPO | $4,000 | $9,000 |

### Members

| Member ID | Name | Plan | Status |
|---|---|---|---|
| M-1001 | John Hartley | Gold PPO | Active |
| M-1002 | Sarah Okonkwo | Silver HMO | Active |
| M-1003 | David Reyes | Bronze EPO | **Inactive** |
| M-1004 | Lisa Tran | Gold PPO | Active |
| M-1005 | Omar Hassan | Silver HMO | Active |

### Benefit Rules (plan × procedure code)

| CPT Code | Description | Gold Allowed | Silver Allowed | Bronze Allowed | Prior Auth |
|---|---|---|---|---|---|
| 99213 | Office visit — established | $150 | $120 | $95 | No |
| 99214 | Office visit — moderate | $220 | $185 | Not covered | No |
| 27447 | Total knee arthroplasty | $22,000 | $18,000 | Not covered | **Required** |
| 70553 | MRI brain with contrast | $1,400 | $1,100 | $900 | **Required** |

> Members on different plans receive different allowed amounts for the same procedure. The Intake Agent passes the member's `planId` to the Adjudication Agent so the correct benefit rule is applied.

---

## Test Scenarios

Twelve test claims cover every decision path. Use these with the claim submission API.

### Group A — Auto-approved

| Claim ID | Member | CPT | Billed | Allowed | Expected |
|---|---|---|---|---|---|
| CLM-A001 | M-1001 (Gold) | 99213 | $130 | $150 | ✅ APPROVED |
| CLM-A002 | M-1002 (Silver) | 99213 | $115 | $120 | ✅ APPROVED |
| CLM-A003 | M-1005 (Silver) | 99213 | $95 | $95 | ✅ APPROVED |

### Group B — Rejected by Intake Agent

| Claim ID | Member | Reason | Expected |
|---|---|---|---|
| CLM-B001 | M-9999 | Member not found in system | ❌ MEMBER_NOT_FOUND |
| CLM-B002 | M-1003 | Coverage inactive | ❌ MEMBER_INACTIVE |
| CLM-B003 | M-1001 | CPT code `9921X` invalid format | ❌ INVALID_PROCEDURE_CODE |
| CLM-B004 | M-1001 | Same as CLM-A001 — already paid | ❌ DUPLICATE_CLAIM |

### Group C — Rejected by Adjudication Agent

| Claim ID | Member | CPT | Reason | Expected |
|---|---|---|---|---|
| CLM-C001 | M-1005 (Silver) | 99214 | Not covered under Silver HMO | ❌ PROCEDURE_NOT_COVERED |

### Group D — Escalated to human review

| Claim ID | Member | CPT | Billed | Allowed | Reason | Expected |
|---|---|---|---|---|---|---|
| CLM-D001 | M-1001 (Gold) | 99214 | $280 | $220 | Billed exceeds allowed | ⚠️ PENDING_REVIEW |
| CLM-D002 | M-1004 (Gold) | 27447 | $20,000 | $22,000 | Prior auth required | ⚠️ PENDING_REVIEW |
| CLM-D003 | M-1002 (Silver) | 70553 | $1,600 | $1,100 | Over limit + prior auth required | ⚠️ PENDING_REVIEW |

---

## Prerequisites

- [Ballerina Swan Lake](https://ballerina.io/downloads/) (2201.8.0 or later)
- [WSO2 Agent Manager](https://wso2.com) — for agent registration, lifecycle management, and observability
- MySQL 8.0+ (for the seed data)
- VS Code with the [Ballerina extension](https://marketplace.visualstudio.com/items?itemName=WSO2.ballerina) (recommended)

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/mohanvive/claim-processing.git
cd claim-processing
```

### 2. Set up the database

Load the seed data into MySQL:

```bash
mysql -u youruser -p yourdb < db/claims_demo_mysql.sql
```

This creates and populates five tables: `plans`, `members`, `benefit_rules`, `claims`, and `review_queue`.

### 3. Start the MCP servers

Each MCP server exposes tools the agents call during processing. Start them in separate terminals:

```bash
# Members and plan lookup
cd membersmcpservice
bal run

# Fee schedule and benefit rules
cd feeschedulemcpserver
bal run

# Claim submission and lookup
cd claimsmcpservice
bal run
```

### 4. Start the agents

```bash
# Intake Agent
cd claimsintake
bal run

# Adjudication Agent
cd adjudication
bal run
```

### 5. Submit a test claim

```bash
curl -X POST http://localhost:8080/claims \
  -H "Content-Type: application/json" \
  -d '{
    "claimId":       "CLM-A001",
    "memberId":      "M-1001",
    "providerNpi":   "1234567890",
    "procedureCode": "99213",
    "diagnosisCode": "J06.9",
    "billedAmount":  130.00,
    "serviceDate":   "2024-05-10"
  }'
```

**Expected response (auto-approved):**

```json
{
  "claimId": "CLM-A001",
  "status": "APPROVED",
  "allowedAmount": 130.00,
  "memberLiability": 13.00,
  "planPays": 117.00,
  "agentDecisions": {
    "intakeAgent": "PASSED",
    "adjudicationAgent": "APPROVED"
  }
}
```

---

## Demo Walkthrough

Run these three claims in sequence to tell the complete story in under five minutes.

**Step 1 — Happy path (auto-approve)**

Submit `CLM-A001`. The audience sees both agents run sequentially, all checks pass, and the claim auto-approves in under two seconds.

**Step 2 — Early rejection (Intake Agent)**

Submit `CLM-B001` (unknown member). The Intake Agent rejects immediately. The Adjudication Agent is never called — the coordinator gates on Agent 01's result.

**Step 3 — Escalation (human review)**

Submit `CLM-D002` (knee surgery, prior auth required). Both agents run. The Adjudication Agent flags the missing prior authorisation. The claim routes to the human review queue.

---

## WSO2 Agent Manager

The `.wso2/` directory contains the agent configuration used by WSO2 Agent Manager. This enables:

- **Agent registration** — register the Intake and Adjudication agents with defined capabilities and tool access
- **Lifecycle management** — start, stop, version, and monitor agents from a central control plane
- **Observability** — trace the full claim journey across both agents, view confidence scores, processing time, and decision rationale
- **Human-in-the-loop** — manage the review queue, assign claims to examiners, and capture decisions

---

## MCP Tool Reference

### `membersmcpservice`

| Tool | Description |
|---|---|
| `getMember(memberId)` | Returns member record including name, status, and planId |
| `getPlan(planId)` | Returns plan details including deductible, co-pay, and OOP max |

### `feeschedulemcpserver`

| Tool | Description |
|---|---|
| `getBenefitRule(planId, procedureCode)` | Returns covered status, allowed amount, and prior auth flag for a plan × procedure combination |

### `claimsmcpservice`

| Tool | Description |
|---|---|
| `checkDuplicate(memberId, procedureCode, serviceDate)` | Returns existing claim if a match is found within the duplicate window |
| `submitClaim(claim)` | Persists the claim record with its final status |
| `getReviewQueue()` | Returns all claims pending human review |

---

## Project Context

This demo was built to showcase WSO2's enterprise agentic capabilities to third-party administrators in the healthcare space. The two-agent design is intentionally simple — the goal is to demonstrate agent coordination, MCP tool integration, and human-in-the-loop workflows using WSO2 Agent Manager, not to model a full production claims pipeline.

A production extension of this design would add a Medical Policy Agent for CPT/ICD clinical reasoning, integrate real-time X12 270/271 eligibility transactions, NCPDP pharmacy claim handling, and HL7 FHIR EHR data via WSO2 integration accelerators.

---

## Contributing

Pull requests are welcome. For significant changes, open an issue first to discuss the proposed change.

---

## Licence

[Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0)
