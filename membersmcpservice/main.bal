
import ballerina/mcp;

listener mcp:Listener mcpListener = new (8080);

@mcp:ServiceConfig {
    info: {
        name: "MembersMCPService",
        version: "1.0.0"
    }
}
service mcp:Service /mcp on mcpListener {

    # Retrieves full member profile including name, date of birth, policy number, and enrolled plan details for a given member ID.
    #
    # + memberId - The unique member identifier (e.g. M-1001)
    # + return - Member profile with plan details or an error
    @mcp:Tool {
        description: "Retrieves full member profile including name, date of birth, policy number, and enrolled plan details for a given member ID."
    }
    remote function getMemberDetails(string memberId) returns MemberWithPlan|error {
        return fetchMemberWithPlan(memberId);
    }

    # Verifies whether a member is currently eligible for benefits.
    #
    # + memberId - The unique member identifier (e.g. M-1001)
    # + return - Eligibility result with plan details for active members or an error
    @mcp:Tool {
        description: "Verifies whether a member is currently eligible for benefits. Returns eligibility status, reason for ineligibility if applicable, and plan details for active members."
    }
    remote function verifyMemberEligibility(string memberId) returns EligibilityResult|error {
        MemberWithPlan memberData = check fetchMemberWithPlan(memberId);
        return buildEligibilityResult(memberData);
    }

    # Returns all claims submitted by a member.
    #
    # + memberId - The unique member identifier (e.g. M-1001)
    # + return - List of claims with status, amounts, and rejection reasons or an error
    @mcp:Tool {
        description: "Returns all claims submitted by a member, including claim status, billed amount, allowed amount, member liability, and any rejection reasons."
    }
    remote function getMemberClaims(string memberId) returns Claim[]|error {
        return fetchMemberClaims(memberId);
    }

    # Returns the benefit rules for a member's enrolled plan.
    #
    # + memberId - The unique member identifier (e.g. M-1001)
    # + return - List of benefit rules with covered procedures and allowed amounts or an error
    @mcp:Tool {
        description: "Returns the benefit rules for a member's enrolled plan, including covered procedure codes, allowed amounts, and whether prior authorization is required."
    }
    remote function getBenefitRules(string memberId) returns BenefitRule[]|error {
        MemberWithPlan memberData = check fetchMemberWithPlan(memberId);
        string planId = memberData.planId;
        return fetchBenefitRules(planId);
    }

    # Retrieves the full details of a specific claim by claim ID.
    #
    # + claimId - The unique claim identifier (e.g. CLM-A001)
    # + return - Claim details including adjudication outcome or an error
    @mcp:Tool {
        description: "Retrieves the full details of a specific claim by claim ID, including adjudication outcome, allowed amount, member liability, and rejection reason if applicable."
    }
    remote function getClaimDetails(string claimId) returns Claim|error {
        return fetchClaimById(claimId);
    }
}
