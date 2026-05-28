
// Plan record mapped from the plans table
type Plan record {|
    string planId;
    string planName;
    string planType;
    decimal deductible;
    decimal copayPrimary;
    decimal copaySpecialist;
    decimal coinsurance;
    decimal oopMax;
|};

// Member record mapped from the members table
type Member record {|
    string memberId;
    string fullName;
    string dateOfBirth;
    string policyNumber;
    string planId;
    string status;
|};

// Member with plan details joined
type MemberWithPlan record {|
    string memberId;
    string fullName;
    string dateOfBirth;
    string policyNumber;
    string memberStatus;
    string planId;
    string planName;
    string planType;
    decimal deductible;
    decimal copayPrimary;
    decimal copaySpecialist;
    decimal coinsurance;
    decimal oopMax;
|};

// Benefit rule record mapped from the benefit_rules table
type BenefitRule record {|
    int ruleId;
    string planId;
    string procedureCode;
    string description;
    boolean covered;
    decimal allowedAmount;
    boolean requiresAuth;
|};

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

// Eligibility response returned by the verifyMemberEligibility tool
type EligibilityResult record {|
    string memberId;
    string fullName;
    boolean eligible;
    string memberStatus;
    string? ineligibilityReason;
    string? planId;
    string? planName;
    string? planType;
    decimal? deductible;
    decimal? copayPrimary;
    decimal? copaySpecialist;
    decimal? coinsurance;
    decimal? oopMax;
|};
