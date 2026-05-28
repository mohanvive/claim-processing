
import ballerina/mcp;

listener mcp:Listener mcpListener = new (8082);

@mcp:ServiceConfig {
    info: {
        name: "FeeScheduleMCPServer",
        version: "1.0.0"
    }
}
service mcp:Service /mcp on mcpListener {

    # Returns the allowed amount and coverage details for a specific procedure under a given insurance plan.
    # Use this to determine how much the plan will pay for a procedure before processing a claim.
    #
    # + planId - The insurance plan identifier (e.g. PLAN-GOLD, PLAN-SILVER, PLAN-BRONZE)
    # + procedureCode - The CPT procedure code (e.g. 99213, 27447, 70553)
    # + return - Allowed amount, coverage status, and prior auth requirement, or an error if not found
    @mcp:Tool {
        description: "Returns the allowed amount and coverage details for a specific procedure code under a given insurance plan. Includes whether the procedure is covered, the allowed reimbursement amount, and whether prior authorization is required."
    }
    remote function getAllowedAmount(string planId, string procedureCode) returns AllowedAmountResult|error {
        return fetchAllowedAmount(planId, procedureCode);
    }

    # Returns the complete fee schedule for a given insurance plan — all covered and non-covered procedures with their allowed amounts.
    #
    # + planId - The insurance plan identifier (e.g. PLAN-GOLD, PLAN-SILVER, PLAN-BRONZE)
    # + return - List of all benefit rules for the plan including procedure codes, descriptions, allowed amounts, and prior auth flags
    @mcp:Tool {
        description: "Returns the full fee schedule for a given insurance plan, listing all procedures with their allowed amounts, coverage status, and prior authorization requirements."
    }
    remote function getPlanFeeSchedule(string planId) returns BenefitRule[]|error {
        return fetchPlanFeeSchedule(planId);
    }

    # Returns coverage and allowed amount details for a specific procedure code across all available insurance plans.
    # Useful for comparing how different plans handle the same procedure.
    #
    # + procedureCode - The CPT procedure code (e.g. 99213, 27447, 70553)
    # + return - List of coverage details per plan including plan name, plan type, allowed amount, and prior auth requirement
    @mcp:Tool {
        description: "Returns coverage and allowed amount details for a specific procedure code across all insurance plans. Useful for comparing reimbursement rates and coverage rules across plans."
    }
    remote function getProcedureCoverage(string procedureCode) returns ProcedureCoverage[]|error {
        return fetchProcedureCoverage(procedureCode);
    }

    # Returns the complete benefit rule record for a specific plan and procedure code combination.
    # Includes the rule ID, coverage flag, allowed amount, and prior authorization requirement.
    #
    # + planId - The insurance plan identifier (e.g. PLAN-GOLD, PLAN-SILVER, PLAN-BRONZE)
    # + procedureCode - The CPT procedure code (e.g. 99213, 27447, 70553)
    # + return - Full benefit rule record or an error if the combination is not found
    @mcp:Tool {
        description: "Returns the complete benefit rule for a specific plan and procedure code, including the rule ID, whether the procedure is covered, the allowed amount, and whether prior authorization is required."
    }
    remote function getBenefitRule(string planId, string procedureCode) returns BenefitRule|error {
        return fetchBenefitRule(planId, procedureCode);
    }
}
