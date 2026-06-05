import ballerina/os;

configurable string openAIKey = os:getEnv("OPENAI_API_KEY");
configurable string membersMcpEndpoint = os:getEnv("MEMBERS_MCP_URL");
configurable string claimsMcpEndpoint = os:getEnv("CLAIMS_MCP_URL");
configurable string adjudicationAgentEndpoint = os:getEnv("ADJUDICATION_AGENT_ENDPOINT");
