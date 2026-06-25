
import ballerina/ai;
import ballerinax/googleapis.gmail;

// Result returned after sending the escalation email
type EscalationEmailResult record {|
    boolean sent;
    string message;
|};

# Sends an escalation email to the review team when a claim is placed in PENDING_REVIEW status.
#
# + claimId - The unique claim identifier
# + memberId - The unique member identifier
# + planName - The name of the member's insurance plan
# + procedureCode - The CPT procedure code
# + procedureDescription - The description of the procedure
# + billedAmount - The amount billed by the provider
# + allowedAmount - The allowed reimbursement amount under the plan
# + escalationReason - Concise summary of escalation reasons (e.g. "PRIOR_AUTH_REQUIRED | AMOUNT_EXCEEDS_ALLOWED")
# + return - Result indicating whether the email was sent successfully
@ai:AgentTool {
    description: "Sends an escalation notification email to the claims review team when a claim decision is PENDING_REVIEW. Provide claimId, memberId, planName, procedureCode, procedureDescription, billedAmount, allowedAmount, and escalationReason as individual arguments."
}
isolated function sendEscalationEmail(string claimId, string memberId, string planName, string procedureCode,
        string procedureDescription, decimal billedAmount, decimal allowedAmount,
        string escalationReason) returns EscalationEmailResult|error {
    string emailBody = string `
A claim has been escalated for human review. Please review the details below:

Claim ID        : ${claimId}
Member ID       : ${memberId}
Plan            : ${planName}
Procedure Code  : ${procedureCode}
Description     : ${procedureDescription}
Billed Amount   : ${billedAmount}
Allowed Amount  : ${allowedAmount}
Escalation Reason: ${escalationReason}

Please log in to the claims management system to review and action this claim.
`;

    gmail:MessageRequest emailMessage = {
        to: [reviewerEmail],
        'from: senderEmail,
        subject: string `[PENDING REVIEW] Claim ${claimId} - ${escalationReason}`,
        bodyInText: emailBody
    };

    gmail:Message _ = check gmailClient->/users/me/messages/send.post(emailMessage);
    return {
        sent: true,
        message: string `Escalation email sent to ${reviewerEmail} for claim ${claimId}.`
    };
}
