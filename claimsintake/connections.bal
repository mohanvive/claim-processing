import ballerina/ai;
import ballerinax/ai.openai;

// Members MCP toolkit — eligibility and member profile tools
final ai:McpToolKit membersMcpToolKit = check new ("http://localhost:8080/mcp", ["getMemberDetails", "verifyMemberEligibility"]);

// Claims MCP toolkit — duplicate detection and claim management tools
final ai:McpToolKit claimsMcpToolKit = check new ("http://localhost:8081/mcp");

final openai:ModelProvider openaiModelProvider = check new ("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", "gpt-4o-mini");
