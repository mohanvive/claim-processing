# Stage 1: Build
FROM ballerina/ballerina:2201.13.4 AS build

WORKDIR /home/ballerina
COPY --chown=10001:10001 . .
RUN bal build

# Stage 2: Runtime
FROM eclipse-temurin:21-jre

LABEL maintainer="dev@wso2.com"

RUN groupadd -r ballerina && useradd -r -g ballerina ballerina

WORKDIR /home/ballerina

COPY --from=build /home/ballerina/target/bin/claimsintake.jar .

RUN chown ballerina:ballerina claimsintake.jar

USER ballerina

EXPOSE 9090

# Required environment variables at runtime:
#
# Application config:
#   BAL_CONFIG_VAR_openAIKey
#
# Observability (ballerinax/amp → OTel collector):
#   BAL_CONFIG_VAR_ballerina_observe_tracingEnabled=true
#   BAL_CONFIG_VAR_ballerina_observe_tracingProvider=amp
#   BAL_CONFIG_VAR_ballerinax_amp_otelEndpoint=http://<otel-collector-host>:22893/otel
#   BAL_CONFIG_VAR_ballerinax_amp_apiKey=<api-key>
#   BAL_CONFIG_VAR_ballerinax_amp_orgUid=<org-uid>
#   BAL_CONFIG_VAR_ballerinax_amp_projectUid=<project-uid>
#   BAL_CONFIG_VAR_ballerinax_amp_componentUid=<component-uid>
#   BAL_CONFIG_VAR_ballerinax_amp_environmentUid=<environment-uid>

CMD ["java", "-jar", "claimsintake.jar"]
