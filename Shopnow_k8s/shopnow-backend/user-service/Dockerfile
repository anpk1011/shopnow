# Stage 1: Build the application
FROM openjdk:17-jdk-slim AS builder

WORKDIR /app
COPY . .
RUN ./mvnw clean package -DskipTests

# Stage 2: Run the application
FROM openjdk:17-jdk-slim

# Install the minimum tool to download/extract agent when running
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl unzip ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/target/user-service-0.0.1-SNAPSHOT.war /app/user-service.war

# Copy Script booted with Seeker Agent
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 5865
# Allow added JWM opts
ENV JAVA_OPTS=""
ENTRYPOINT ["/bin/sh", "run.sh"]
