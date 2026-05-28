
// Claim record mapped from the claims table
type Claim record {|
    string claimId;
    string memberId;
    string providerNpi;
    string procedureCode;
    string diagnosisCode;
    decimal billedAmount;
    string serviceDate;
    string submittedAt;
    string status;
    string? rejectReason;
    decimal? allowedAmount;
    decimal? memberLiability;
|};

// Review queue entry mapped from the review_queue table
type ReviewQueueEntry record {|
    int reviewId;
    string claimId;
    string escalationReason;
    string? assignedTo;
    string reviewStatus;
    string createdAt;
    string? decidedAt;
    string? examinerNotes;
|};

// Claim with its review queue entry for pending review queries
type ClaimWithReview record {|
    string claimId;
    string memberId;
    string providerNpi;
    string procedureCode;
    string diagnosisCode;
    decimal billedAmount;
    string serviceDate;
    string claimStatus;
    int reviewId;
    string escalationReason;
    string? assignedTo;
    string reviewStatus;
    string createdAt;
|};

// Result returned by the duplicate claim check tool
type DuplicateCheckResult record {|
    string memberId;
    string procedureCode;
    boolean isDuplicate;
    string? existingClaimId;
    string? existingClaimStatus;
    string? existingServiceDate;
    string? message;
|};

// Input for submitting a new claim
type ClaimSubmission record {|
    string claimId;
    string memberId;
    string providerNpi;
    string procedureCode;
    string diagnosisCode;
    decimal billedAmount;
    string serviceDate;
|};

// Result returned after submitting a claim
type ClaimSubmissionResult record {|
    string claimId;
    string status;
    string message;
|};

// Input for updating a claim's status
type ClaimStatusUpdate record {|
    string claimId;
    string newStatus;
    string? rejectReason;
    decimal? allowedAmount;
    decimal? memberLiability;
|};

// Result returned after updating a claim status
type ClaimUpdateResult record {|
    string claimId;
    string updatedStatus;
    string message;
|};
