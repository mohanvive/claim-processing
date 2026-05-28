
// Full benefit rule record mapped from the benefit_rules table
type BenefitRule record {|
    int ruleId;
    string planId;
    string procedureCode;
    string description;
    boolean covered;
    decimal allowedAmount;
    boolean requiresAuth;
|};

// Allowed amount lookup result for a specific plan + procedure combination
type AllowedAmountResult record {|
    string planId;
    string procedureCode;
    string description;
    boolean covered;
    decimal allowedAmount;
    boolean requiresAuth;
    string? notCoveredReason;
|};

// Coverage details for a procedure across all plans
type ProcedureCoverage record {|
    string procedureCode;
    string description;
    string planId;
    string planName;
    string planType;
    boolean covered;
    decimal allowedAmount;
    boolean requiresAuth;
|};
