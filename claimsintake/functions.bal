
import ballerina/ai;

// Input for forwarding a validated claim to the adjudication agent
type AdjudicationRequest record {|
    string claimId;
    string memberId;
    string procedureCode;
    decimal billedAmount;
    string serviceDate;
    string sessionId;
|};

# Forwards a validated claim to the adjudication agent for benefit coverage and fee schedule checks.
#
# + adjudicationRequest - The claim details to forward for adjudication
# + return - The adjudication agent's response message or an error
@ai:AgentTool {
    description: "Forwards a validated claim to the adjudication agent after member eligibility is confirmed and no duplicate is found. Provide claimId, memberId, procedureCode, billedAmount, serviceDate, and sessionId."
}
isolated function forwardToAdjudication(AdjudicationRequest adjudicationRequest) returns string|error {
    string adjudicationMessage = string `Adjudicate claim ${adjudicationRequest.claimId} for member ${adjudicationRequest.memberId}, procedure ${adjudicationRequest.procedureCode}, billed amount $${adjudicationRequest.billedAmount}, service date ${adjudicationRequest.serviceDate}.`;
    ai:ChatReqMessage chatRequest = {
        sessionId: adjudicationRequest.sessionId,
        message: adjudicationMessage
    };
    ai:ChatRespMessage adjudicationResponse = check adjudicationAgentClient->/chat.post(chatRequest);
    return adjudicationResponse.message;
}
