#!/bin/sh
set -e

# Map AMP_OTEL_ENDPOINT → BAL_CONFIG_VAR_BALLERINAX_AMP_OTELENDPOINT
# Strip trailing path components — Ballerina amp expects only the host (no /v1/... suffix)
if [ -n "$AMP_OTEL_ENDPOINT" ]; then
    BAL_CONFIG_VAR_BALLERINAX_AMP_OTELENDPOINT=$(echo "$AMP_OTEL_ENDPOINT" | sed 's|/v1/.*||')
    export BAL_CONFIG_VAR_BALLERINAX_AMP_OTELENDPOINT
fi

# Map AMP_AGENT_API_KEY → BAL_CONFIG_VAR_BALLERINAX_AMP_APIKEY
if [ -n "$AMP_AGENT_API_KEY" ]; then
    BAL_CONFIG_VAR_BALLERINAX_AMP_APIKEY="$AMP_AGENT_API_KEY"
    export BAL_CONFIG_VAR_BALLERINAX_AMP_APIKEY
fi

export BAL_CONFIG_FILES=/home/ballerina/Config.toml

exec java -jar claimsintake.jar
