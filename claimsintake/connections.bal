import ballerina/ai;
import ballerinax/ai.openai;

// Members MCP toolkit — eligibility and member profile tools
final ai:McpToolKit membersMcpToolKit = check new ("http://localhost:8080/mcp", ["getMemberDetails", "verifyMemberEligibility"]);

// Claims MCP toolkit — duplicate detection and claim management tools
final ai:McpToolKit claimsMcpToolKit = check new ("http://localhost:8081/mcp");

// Adjudication agent client — forwards accepted claims for adjudication
final ai:ChatClient adjudicationAgentClient = check new ("http://localhost:9091/adjudicationAgent");

final openai:ModelProvider openaiModelProvider = check new (string `${openAIKey}`, "gpt-4o-mini");
