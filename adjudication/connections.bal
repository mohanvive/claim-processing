
import ballerina/ai;
import ballerinax/ai.openai;
import ballerinax/googleapis.gmail;

// Members MCP toolkit — benefit rules and member profile tools
final ai:McpToolKit membersMcpToolKit = check new ("http://localhost:8080/mcp", ["getMemberDetails", "verifyMemberEligibility", "getBenefitRules"]);

// Fee Schedule MCP toolkit — allowed amounts per procedure per plan
final ai:McpToolKit feeScheduleMcpToolKit = check new ("http://localhost:8082/mcp", ["getAllowedAmount"]);

final openai:ModelProvider openaiModelprovider = check new ("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", "gpt-4o-mini");

// Gmail client for sending escalation notifications
final gmail:Client gmailClient = check new ({
    auth: {
        clientId: gmailClientId,
        clientSecret: gmailClientSecret,
        refreshToken: gmailRefreshToken,
        refreshUrl: "https://oauth2.googleapis.com/token"
    }
});
