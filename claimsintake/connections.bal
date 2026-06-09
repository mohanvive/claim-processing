import ballerina/ai;
import ballerinax/ai.openai;

// Members MCP toolkit — eligibility and member profile tools
final ai:McpToolKit membersMcpToolKit = check new (membersMcpEndpoint, ["getMemberDetails", "verifyMemberEligibility"]);

// Claims MCP toolkit — duplicate detection and claim management tools
final ai:McpToolKit claimsMcpToolKit = check new (claimsMcpEndpoint);

// Adjudication agent client — forwards accepted claims for adjudication
final ai:ChatClient adjudicationAgentClient = check new (adjudicationAgentEndpoint);

final openai:ModelProvider openaiModelProvider = check new ("", "gpt-4o-mini", "https://apigateway-wc-019e6fc7-b5ee1ae9.us-east-2.cloud.wso2.com/claim-llm");
