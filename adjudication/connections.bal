import ballerina/ai;
import ballerinax/ai.openai;
import ballerinax/googleapis.gmail;

// Members MCP toolkit — benefit rules and member profile tools
final ai:McpToolKit membersMcpToolKit = check new (string `${membersMCP}`, ["getMemberDetails", "verifyMemberEligibility", "getBenefitRules"]);

// Fee Schedule MCP toolkit — allowed amounts per procedure per plan
final ai:McpToolKit feeScheduleMcpToolKit = check new (string `${feeScheduleMCP}`, ["getAllowedAmount"]);

final openai:ModelProvider openaiModelprovider = check new (string `${openAIKey}`, "gpt-4o-mini");

// Gmail client for sending escalation notifications
final gmail:Client gmailClient = check new ({
    auth: {
        clientId: gmailClientId,
        clientSecret: gmailClientSecret,
        refreshToken: gmailRefreshToken,
        refreshUrl: "https://oauth2.googleapis.com/token"
    }
});
