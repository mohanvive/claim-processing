
import ballerina/ai;
import ballerinax/googleapis.gmail;

// Input record for the escalation email tool
type EscalationEmailInput record {|
    string claimId;
    string memberId;
    string planName;
    string procedureCode;
    string procedureDescription;
    decimal billedAmount;
    decimal allowedAmount;
    string escalationReason;
|};

// Result returned after sending the escalation email
type EscalationEmailResult record {|
    boolean sent;
    string message;
|};

# Sends an escalation email to the review team when a claim is placed in PENDING_REVIEW status.
#
# + emailInput - Details of the escalated claim including member, procedure, amounts, and escalation reason
# + return - Result indicating whether the email was sent successfully
@ai:AgentTool {
    description: "Sends an escalation notification email to the claims review team when a claim decision is PENDING_REVIEW. Call this tool after determining the PENDING_REVIEW decision, providing the claimId, memberId, planName, procedureCode, procedureDescription, billedAmount, allowedAmount, and escalationReason."
}
isolated function sendEscalationEmail(EscalationEmailInput emailInput) returns EscalationEmailResult|error {
    string emailBody = string `
A claim has been escalated for human review. Please review the details below:

Claim ID        : ${emailInput.claimId}
Member ID       : ${emailInput.memberId}
Plan            : ${emailInput.planName}
Procedure Code  : ${emailInput.procedureCode}
Description     : ${emailInput.procedureDescription}
Billed Amount   : $${emailInput.billedAmount}
Allowed Amount  : $${emailInput.allowedAmount}
Escalation Reason: ${emailInput.escalationReason}

Please log in to the claims management system to review and action this claim.
`;

    gmail:MessageRequest emailMessage = {
        to: [reviewerEmail],
        'from: senderEmail,
        subject: string `[PENDING REVIEW] Claim ${emailInput.claimId} — ${emailInput.escalationReason}`,
        bodyInText: emailBody
    };

    gmail:Message _ = check gmailClient->/users/me/messages/send.post(emailMessage);
    return {
        sent: true,
        message: string `Escalation email sent to ${reviewerEmail} for claim ${emailInput.claimId}.`
    };
}
