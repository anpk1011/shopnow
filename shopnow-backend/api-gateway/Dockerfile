# Stage 1: Build the application
FROM openjdk:17-jdk-slim AS builder

WORKDIR /app
COPY . .
RUN ./mvnw clean package -DskipTests

# Stage 2: Run the application
FROM openjdk:17-jdk-slim

WORKDIR /app
COPY --from=builder /app/target/api-gateway-0.0.1-SNAPSHOT.war /app/api-gateway.war

ENV SEEKER_SERVER_URL="http(s)://{host:port}"
# Download Seeker Agent from the Server
RUN curl -v -k -o /tmp/seeker-agent.zip "${SEEKER_SERVER_URL}/rest/api/latest/installers/agents/binaries/JAVA"
# Extract to /tmp/seeker
RUN mkdir -p /tmp/seeker && unzip -d /tmp/seeker /tmp/seeker-agent.zip


EXPOSE 5860
ENTRYPOINT exec java -jar /app/api-gateway.war --spring.config.location=/app/src/main/resources/application.properties
