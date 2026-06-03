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

COPY --from=build /app/target/bin/claimsintake.jar .

RUN chown ballerina:ballerina claimsintake.jar

USER ballerina

EXPOSE 9090

# Required environment variables at runtime:
# BAL_CONFIG_VAR_openAIKey

CMD ["java", "-jar", "claimsintake.jar"]
