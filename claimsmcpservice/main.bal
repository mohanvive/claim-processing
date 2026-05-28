
import ballerina/mcp;

listener mcp:Listener mcpListener = new (8081);

@mcp:ServiceConfig {
    info: {
        name: "MembersMCPService",
        version: "1.0.0"
    }
}
service mcp:Service /mcp on mcpListener {

    # Checks whether an APPROVED claim already exists for the same member and procedure code within the current calendar year.
    # This is the primary duplicate detection tool to prevent re-processing of already-approved claims.
    #
    # + memberId - The unique member identifier (e.g. M-1001)
    # + procedureCode - The CPT procedure code to check (e.g. 99213)
    # + return - Duplicate check result indicating whether a duplicate exists and the existing claim details
    @mcp:Tool {
        description: "Checks whether an APPROVED claim already exists for the same member and procedure code within the current calendar year. Returns isDuplicate flag and the existing claim details if found."
    }
    remote function checkDuplicateClaim(string memberId, string procedureCode) returns DuplicateCheckResult|error {
        return checkDuplicateApprovedClaim(memberId, procedureCode);
    }

    # Submits a new claim into the system with PENDING status.
    #
    # + submission - The claim details including member ID, provider NPI, procedure code, diagnosis code, billed amount, and service date
    # + return - Submission result with the assigned claim ID and status
    @mcp:Tool {
        description: "Submits a new claim into the system with PENDING status. Requires claimId, memberId, providerNpi, procedureCode, diagnosisCode, billedAmount, and serviceDate (YYYY-MM-DD)."
    }
    remote function submitClaim(ClaimSubmission submission) returns ClaimSubmissionResult|error {
        return insertClaim(submission);
    }

    # Retrieves the current status and full details of a specific claim by its claim ID.
    #
    # + claimId - The unique claim identifier (e.g. CLM-A001)
    # + return - Full claim details including status, amounts, and rejection reason if applicable
    @mcp:Tool {
        description: "Retrieves the current status and full details of a specific claim by its claim ID, including billed amount, allowed amount, member liability, and rejection reason."
    }
    remote function getClaimStatus(string claimId) returns Claim|error {
        return fetchClaimById(claimId);
    }

    # Returns all claims currently escalated to human review (PENDING_REVIEW status) along with their review queue entries.
    #
    # + return - List of claims in PENDING_REVIEW with escalation reasons and reviewer assignments
    @mcp:Tool {
        description: "Returns all claims currently escalated to human review (PENDING_REVIEW status), including escalation reasons, assigned examiner, and review queue details."
    }
    remote function getPendingReviewClaims() returns ClaimWithReview[]|error {
        return fetchPendingReviewClaims();
    }

    # Updates the status of a claim and optionally sets the allowed amount, member liability, or rejection reason.
    #
    # + updateData - The update payload containing claimId, newStatus, and optional rejectReason, allowedAmount, memberLiability
    # + return - Update result confirming the new status
    @mcp:Tool {
        description: "Updates the status of a claim (e.g. APPROVED, REJECTED, PENDING_REVIEW). Optionally sets rejectReason, allowedAmount, and memberLiability. Provide claimId and newStatus at minimum."
    }
    remote function updateClaimStatus(ClaimStatusUpdate updateData) returns ClaimUpdateResult|error {
        return updateClaimStatusInDb(updateData);
    }
}
