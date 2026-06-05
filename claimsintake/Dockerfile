# Stage 1: Build JAR
FROM ballerina/ballerina:2201.13.4 AS build

WORKDIR /home/ballerina
COPY --chown=ballerina:troupe . .
RUN bal build

# Stage 2: Runtime
FROM eclipse-temurin:21-jre

LABEL maintainer="dev@wso2.com"

RUN groupadd -r ballerina && useradd -r -g ballerina ballerina

WORKDIR /home/ballerina

COPY --from=build /home/ballerina/target/bin/claimsintake.jar .
COPY --from=build /home/ballerina/Config.toml .
COPY --from=build /home/ballerina/entrypoint.sh .

RUN chown ballerina:ballerina claimsintake.jar Config.toml entrypoint.sh \
    && chmod +x entrypoint.sh

USER ballerina

EXPOSE 9090

# Required environment variables at runtime:
#
# Application config:
#   BAL_CONFIG_VAR_openAIKey
#
# Observability (ballerinax/amp → OTel collector):
#   AMP_OTEL_ENDPOINT=https://<otel-host>/v1/traces  (mapped to BAL_CONFIG_VAR_BALLERINAX_AMP_OTELENDPOINT)
#   AMP_AGENT_API_KEY=<api-key>                       (mapped to BAL_CONFIG_VAR_BALLERINAX_AMP_APIKEY)
#   BAL_CONFIG_VAR_ballerinax_amp_orgUid=<org-uid>
#   BAL_CONFIG_VAR_ballerinax_amp_projectUid=<project-uid>
#   BAL_CONFIG_VAR_ballerinax_amp_componentUid=<component-uid>
#   BAL_CONFIG_VAR_ballerinax_amp_environmentUid=<environment-uid>

ENTRYPOINT ["sh", "entrypoint.sh"]
