
import ballerina/sql;

// Fetch the allowed amount and coverage details for a specific plan + procedure combination
isolated function fetchAllowedAmount(string planId, string procedureCode) returns AllowedAmountResult|error {
    sql:ParameterizedQuery query = `
        SELECT
            b.plan_id        AS planId,
            b.procedure_code AS procedureCode,
            b.description    AS description,
            b.covered        AS covered,
            b.allowed_amount AS allowedAmount,
            b.requires_auth  AS requiresAuth
        FROM benefit_rules b
        WHERE b.plan_id        = ${planId}
          AND b.procedure_code = ${procedureCode}`;

    BenefitRule|sql:Error result = dbClient->queryRow(query);
    if result is sql:NoRowsError {
        return error("No benefit rule found for plan '" + planId + "' and procedure code '" + procedureCode + "'.");
    }
    if result is sql:Error {
        return result;
    }
    string? notCoveredReason = result.covered ? () : "Procedure " + procedureCode + " is not covered under plan " + planId + ".";
    return {
        planId: result.planId,
        procedureCode: result.procedureCode,
        description: result.description,
        covered: result.covered,
        allowedAmount: result.allowedAmount,
        requiresAuth: result.requiresAuth,
        notCoveredReason: notCoveredReason
    };
}

// Fetch the full fee schedule (all benefit rules) for a given plan
isolated function fetchPlanFeeSchedule(string planId) returns BenefitRule[]|error {
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

// Fetch coverage details for a procedure code across all plans (joined with plan info)
isolated function fetchProcedureCoverage(string procedureCode) returns ProcedureCoverage[]|error {
    sql:ParameterizedQuery query = `
        SELECT
            b.procedure_code AS procedureCode,
            b.description    AS description,
            b.plan_id        AS planId,
            p.plan_name      AS planName,
            p.plan_type      AS planType,
            b.covered        AS covered,
            b.allowed_amount AS allowedAmount,
            b.requires_auth  AS requiresAuth
        FROM benefit_rules b
        JOIN plans p ON b.plan_id = p.plan_id
        WHERE b.procedure_code = ${procedureCode}
        ORDER BY b.plan_id`;
    stream<ProcedureCoverage, sql:Error?> resultStream = dbClient->query(query);
    ProcedureCoverage[] coverageList = [];
    check from ProcedureCoverage coverageRow in resultStream
        do {
            coverageList.push(coverageRow);
        };
    return coverageList;
}

// Fetch the complete benefit rule for a specific plan + procedure combination
isolated function fetchBenefitRule(string planId, string procedureCode) returns BenefitRule|error {
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
        WHERE plan_id        = ${planId}
          AND procedure_code = ${procedureCode}`;
    return dbClient->queryRow(query);
}
