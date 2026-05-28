
import ballerina/sql;
import ballerina/time;

// Approved claim row used for duplicate detection
type ApprovedClaimRow record {|
    string claimId;
    string claimStatus;
    string serviceDate;
|};

// Check if an APPROVED claim already exists for the same member + procedure code in the current year
isolated function checkDuplicateApprovedClaim(string memberId, string procedureCode) returns DuplicateCheckResult|error {
    time:Utc utcNow = time:utcNow();
    time:Civil civilNow = time:utcToCivil(utcNow);
    int currentYear = civilNow.year;
    string yearStart = currentYear.toString() + "-01-01";
    string yearEnd = currentYear.toString() + "-12-31";

    sql:ParameterizedQuery query = `
        SELECT
            claim_id   AS claimId,
            status     AS claimStatus,
            service_date AS serviceDate
        FROM claims
        WHERE member_id      = ${memberId}
          AND procedure_code = ${procedureCode}
          AND status         = 'APPROVED'
          AND service_date  BETWEEN ${yearStart} AND ${yearEnd}
        LIMIT 1`;

    ApprovedClaimRow|sql:Error result = dbClient->queryRow(query);
    if result is sql:NoRowsError {
        return {
            memberId: memberId,
            procedureCode: procedureCode,
            isDuplicate: false,
            existingClaimId: (),
            existingClaimStatus: (),
            existingServiceDate: (),
            message: "No approved claim found for this member and procedure code in the current year."
        };
    }
    if result is sql:Error {
        return result;
    }
    return {
        memberId: memberId,
        procedureCode: procedureCode,
        isDuplicate: true,
        existingClaimId: result.claimId,
        existingClaimStatus: result.claimStatus,
        existingServiceDate: result.serviceDate,
        message: "An approved claim already exists for this member and procedure code in the current year."
    };
}

// Fetch a single claim by claim ID
isolated function fetchClaimById(string claimId) returns Claim|error {
    sql:ParameterizedQuery query = `
        SELECT
            claim_id         AS claimId,
            member_id        AS memberId,
            provider_npi     AS providerNpi,
            procedure_code   AS procedureCode,
            diagnosis_code   AS diagnosisCode,
            billed_amount    AS billedAmount,
            service_date     AS serviceDate,
            submitted_at     AS submittedAt,
            status           AS status,
            reject_reason    AS rejectReason,
            allowed_amount   AS allowedAmount,
            member_liability AS memberLiability
        FROM claims
        WHERE claim_id = ${claimId}`;
    return dbClient->queryRow(query);
}

// Insert a new claim with PENDING status
isolated function insertClaim(ClaimSubmission submission) returns ClaimSubmissionResult|error {
    sql:ParameterizedQuery query = `
        INSERT INTO claims
            (claim_id, member_id, provider_npi, procedure_code, diagnosis_code, billed_amount, service_date, status)
        VALUES
            (${submission.claimId}, ${submission.memberId}, ${submission.providerNpi},
             ${submission.procedureCode}, ${submission.diagnosisCode}, ${submission.billedAmount},
             ${submission.serviceDate}, 'PENDING')`;
    sql:ExecutionResult execResult = check dbClient->execute(query);
    int? affectedRows = execResult.affectedRowCount;
    if affectedRows is int && affectedRows > 0 {
        return {
            claimId: submission.claimId,
            status: "PENDING",
            message: "Claim submitted successfully."
        };
    }
    return {
        claimId: submission.claimId,
        status: "FAILED",
        message: "Claim submission failed. No rows were inserted."
    };
}

// Fetch all claims currently in PENDING_REVIEW with their review queue entries
isolated function fetchPendingReviewClaims() returns ClaimWithReview[]|error {
    sql:ParameterizedQuery query = `
        SELECT
            c.claim_id         AS claimId,
            c.member_id        AS memberId,
            c.provider_npi     AS providerNpi,
            c.procedure_code   AS procedureCode,
            c.diagnosis_code   AS diagnosisCode,
            c.billed_amount    AS billedAmount,
            c.service_date     AS serviceDate,
            c.status           AS claimStatus,
            r.review_id        AS reviewId,
            r.escalation_reason AS escalationReason,
            r.assigned_to      AS assignedTo,
            r.status           AS reviewStatus,
            r.created_at       AS createdAt
        FROM claims c
        JOIN review_queue r ON c.claim_id = r.claim_id
        WHERE c.status = 'PENDING_REVIEW'
        ORDER BY r.created_at ASC`;
    stream<ClaimWithReview, sql:Error?> resultStream = dbClient->query(query);
    ClaimWithReview[] claimList = [];
    check from ClaimWithReview claimRow in resultStream
        do {
            claimList.push(claimRow);
        };
    return claimList;
}

// Update a claim's status, reject reason, allowed amount, and member liability
isolated function updateClaimStatusInDb(ClaimStatusUpdate updateData) returns ClaimUpdateResult|error {
    sql:ParameterizedQuery query = `
        UPDATE claims
        SET
            status           = ${updateData.newStatus},
            reject_reason    = ${updateData.rejectReason},
            allowed_amount   = ${updateData.allowedAmount},
            member_liability = ${updateData.memberLiability}
        WHERE claim_id = ${updateData.claimId}`;
    sql:ExecutionResult execResult = check dbClient->execute(query);
    int? affectedRows = execResult.affectedRowCount;
    if affectedRows is int && affectedRows > 0 {
        return {
            claimId: updateData.claimId,
            updatedStatus: updateData.newStatus,
            message: "Claim status updated successfully."
        };
    }
    return {
        claimId: updateData.claimId,
        updatedStatus: updateData.newStatus,
        message: "Update failed. Claim not found or no changes applied."
    };
}
