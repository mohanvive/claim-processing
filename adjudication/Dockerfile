# Stage 1: Build
FROM ballerina/ballerina:2201.13.4 AS build

WORKDIR /app
COPY . .
RUN bal build

# Stage 2: Runtime
FROM ballerina/jvm-runtime:1.0

LABEL maintainer="dev@wso2.com"

RUN addgroup -S ballerina && adduser -S -G ballerina ballerina

WORKDIR /home/ballerina

COPY --from=build /app/target/bin/adjudication.jar .

RUN chown ballerina:ballerina adjudication.jar

USER ballerina

EXPOSE 9091

# Required environment variables at runtime:
# BAL_CONFIG_VAR_openAIKey
# BAL_CONFIG_VAR_gmailClientId
# BAL_CONFIG_VAR_gmailClientSecret
# BAL_CONFIG_VAR_gmailRefreshToken
# BAL_CONFIG_VAR_reviewerEmail
# BAL_CONFIG_VAR_senderEmail

CMD ["java", "-jar", "adjudication.jar"]
