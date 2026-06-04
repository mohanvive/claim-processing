import ballerina/os;

configurable string gmailClientId = os:getEnv("GMAIL_CLIENT_ID");
configurable string gmailClientSecret = os:getEnv("GMAIL_CLIENT_SECRET");
configurable string gmailRefreshToken = os:getEnv("GMAIL_REFRESH_TOKEN");
configurable string reviewerEmail = os:getEnv("REVIEWER_EMAIL");
configurable string senderEmail = os:getEnv("SENDER_EMAIL");
configurable string openAIKey = os:getEnv("OPENAI_API_KEY");
configurable string membersMCP = os:getEnv("MEMBERS_MCP_URL");
configurable string feeScheduleMCP = os:getEnv("FEE_SCHEDULE_MCP_URL");
