import ballerina/ai;
import ballerina/http;
import ballerinax/amp as _;

listener ai:Listener chatAgentListener = new (listenOn = check http:getDefaultListener());

service /claimsIntakeAgent on chatAgentListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string stringResult = check claimsIntakeAgent.run(request.message, request.sessionId);
        return {message: stringResult};
    }
}
