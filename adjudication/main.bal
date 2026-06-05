
import ballerina/ai;
import ballerina/http;
import ballerinax/amp as _;

listener ai:Listener chatAgentListener = new (listenOn = check new http:Listener(9090));

service /adjudicationAgent on chatAgentListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string stringResult = check adjudicationAgent.run(request.message, request.sessionId);
        return {message: stringResult};
    }
}
