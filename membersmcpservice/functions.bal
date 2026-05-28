
import ballerina/sql;

// Fetch member with plan details by member ID
isolated function fetchMemberWithPlan(string memberId) returns MemberWithPlan|error {
    sql:ParameterizedQuery query = `
        SELECT
            m.member_id       AS memberId,
            m.full_name       AS fullName,
            m.date_of_birth   AS dateOfBirth,
            m.policy_number   AS policyNumber,
            m.status          AS memberStatus,
            p.plan_id         AS planId,
            p.plan_name       AS planName,
            p.plan_type       AS planType,
            p.deductible      AS deductible,
            p.copay_primary   AS copayPrimary,
            p.copay_specialist AS copaySpecialist,
            p.coinsurance     AS coinsurance,
            p.oop_max         AS oopMax
        FROM members m
        JOIN plans p ON m.plan_id = p.plan_id
        WHERE m.member_id = ${memberId}`;
    return dbClient->queryRow(query);
}

// Fetch all claims for a member
isolated function fetchMemberClaims(string memberId) returns Claim[]|error {
    sql:ParameterizedQuery query = `
        SELECT
            claim_id        AS claimId,
            member_id       AS memberId,
            provider_npi    AS providerNpi,
            procedure_code  AS procedureCode,
            diagnosis_code  AS diagnosisCode,
            billed_amount   AS billedAmount,
            service_date    AS serviceDate,
            submitted_at    AS submittedAt,
            status          AS status,
            reject_reason   AS rejectReason,
            allowed_amount  AS allowedAmount,
            member_liability AS memberLiability
        FROM claims
        WHERE member_id = ${memberId}
        ORDER BY submitted_at DESC`;
    stream<Claim, sql:Error?> resultStream = dbClient->query(query);
    Claim[] claimList = [];
    check from Claim claimRow in resultStream
        do {
            claimList.push(claimRow);
        };
    return claimList;
}

// Fetch benefit rules for a given plan
isolated function fetchBenefitRules(string planId) returns BenefitRule[]|error {
    sql:ParameterizedQuery query = `
        SELECT
            rule_id        AS ruleId,
            plan_id        AS planId,
            procedure_code AS procedureCode,
            description    AS description,
            covered        AS covered,
            allowed_amount AS allowedAmount,
            requires_auth  AS requiresAuth
        FROM benefit_rules
        WHERE plan_id = ${planId}
        ORDER BY procedure_code`;
    stream<BenefitRule, sql:Error?> resultStream = dbClient->query(query);
    BenefitRule[] ruleList = [];
    check from BenefitRule ruleRow in resultStream
        do {
            ruleList.push(ruleRow);
        };
    return ruleList;
}

// Fetch a single claim by claim ID
isolated function fetchClaimById(string claimId) returns Claim|error {
    sql:ParameterizedQuery query = `
        SELECT
            claim_id        AS claimId,
            member_id       AS memberId,
            provider_npi    AS providerNpi,
            procedure_code  AS procedureCode,
            diagnosis_code  AS diagnosisCode,
            billed_amount   AS billedAmount,
            service_date    AS serviceDate,
            submitted_at    AS submittedAt,
            status          AS status,
            reject_reason   AS rejectReason,
            allowed_amount  AS allowedAmount,
            member_liability AS memberLiability
        FROM claims
        WHERE claim_id = ${claimId}`;
    return dbClient->queryRow(query);
}

// Build eligibility result from member+plan data
isolated function buildEligibilityResult(MemberWithPlan memberData) returns EligibilityResult {
    string memberStatus = memberData.memberStatus;
    boolean isEligible = memberStatus == "ACTIVE";
    string? ineligibilityReason = isEligible ? () : "Member status is " + memberStatus;
    return {
        memberId: memberData.memberId,
        fullName: memberData.fullName,
        eligible: isEligible,
        memberStatus: memberStatus,
        ineligibilityReason: ineligibilityReason,
        planId: isEligible ? memberData.planId : (),
        planName: isEligible ? memberData.planName : (),
        planType: isEligible ? memberData.planType : (),
        deductible: isEligible ? memberData.deductible : (),
        copayPrimary: isEligible ? memberData.copayPrimary : (),
        copaySpecialist: isEligible ? memberData.copaySpecialist : (),
        coinsurance: isEligible ? memberData.coinsurance : (),
        oopMax: isEligible ? memberData.oopMax : ()
    };
}
