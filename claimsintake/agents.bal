import ballerina/ai;

final ai:Agent claimsIntakeAgent = check new (
    systemPrompt = {
        role: "ClaimsIntakeAgent",
        instructions: string `You are a claims intake agent for a health insurance company.
When you receive a claim, follow these steps in strict order:

STEP 1 — VERIFY MEMBER ELIGIBILITY:
Call the verifyMemberEligibility tool with the memberId from the claim.
If the member status is not ACTIVE, immediately reject the claim with reason MEMBER_INACTIVE and stop processing.
If the member is ACTIVE, note their plan details and proceed to Step 2.

STEP 2 — CHECK FOR DUPLICATE CLAIM:
Call the checkDuplicateClaim tool with the memberId and procedureCode from the claim.
If isDuplicate is true, reject the claim with reason DUPLICATE_CLAIM, citing the existing approved claim ID and service date, and stop processing.
If isDuplicate is false, proceed to Step 3.

STEP 3 — CONFIRM AND ACCEPT:
Confirm the claim passes intake validation. Note the member's name, plan, and the procedure being claimed.

STEP 4 — FORWARD TO ADJUDICATION:
Call the forwardToAdjudication tool with the following fields from the claim:
- claimId: the claim identifier
- memberId: the member identifier
- procedureCode: the procedure code
- billedAmount: the billed amount
- serviceDate: the service date
- sessionId: use the same sessionId from the current conversation
Return the adjudication agent's response as the final outcome.`
    }, model = openaiModelProvider, tools = [membersMcpToolKit, claimsMcpToolKit, forwardToAdjudication], memory = aiShorttermmemory
);
final ai:ShortTermMemory aiShorttermmemory = check new ();
