# ---- Build stage ----
FROM eclipse-temurin:21-jdk AS builder
WORKDIR /app

# Install Maven
RUN apt-get update && \
    apt-get install -y maven && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Only copy pom first to leverage Docker layer caching
COPY pom.xml ./
RUN --mount=type=cache,target=/root/.m2 mvn -q -e -DskipTests dependency:go-offline || true

# Now copy the rest of the source
COPY src ./src

# Build the application (skip tests for faster image builds)
RUN --mount=type=cache,target=/root/.m2 mvn -q -DskipTests package

# ---- Runtime stage ----
FROM eclipse-temurin:21-jre
WORKDIR /app

# Copy the shaded/assembled jar (if multiple jars exist, take the main jar)
COPY --from=builder /app/target/*.jar /app/app.jar

# Non-root runtime user for better security
RUN useradd -r -u 1001 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8080

# Enable JVM container-friendly defaults
ENV JAVA_TOOL_OPTIONS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:InitialRAMPercentage=50.0 -XX:MinRAMPercentage=25.0"

ENTRYPOINT ["java","-jar","/app/app.jar"]
