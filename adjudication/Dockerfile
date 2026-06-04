# Stage 1: Build
FROM ballerina/ballerina:2201.13.4 AS build

WORKDIR /home/ballerina
COPY --chown=ballerina:troupe . .
RUN bal build

# Stage 2: Runtime
FROM eclipse-temurin:21-jre

LABEL maintainer="dev@wso2.com"

RUN groupadd -r ballerina && useradd -r -g ballerina ballerina

WORKDIR /home/ballerina

COPY --from=build /home/ballerina/target/bin/adjudication.jar .
COPY --from=build /home/ballerina/config.toml .

RUN chown ballerina:ballerina adjudication.jar config.toml

USER ballerina

EXPOSE 9091

# Required environment variables at runtime:
#
# Application config:
#   BAL_CONFIG_VAR_openAIKey
#   BAL_CONFIG_VAR_gmailClientId
#   BAL_CONFIG_VAR_gmailClientSecret
#   BAL_CONFIG_VAR_gmailRefreshToken
#   BAL_CONFIG_VAR_reviewerEmail
#   BAL_CONFIG_VAR_senderEmail
#   BAL_CONFIG_VAR_membersMCP
#   BAL_CONFIG_VAR_feeScheduleMCP
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

CMD ["java", "-Dballerina.config=config.toml", "-jar", "adjudication.jar"]
