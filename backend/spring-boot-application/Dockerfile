# Multi-stage Docker build for KisanSetu Spring Boot Modular Monolith
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /workspace/app

# Copy maven wrapper and pom.xml first for caching layers
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

RUN chmod +x ./mvnw
RUN ./mvnw dependency:go-offline -B

# Copy source code and build jar
COPY src src
RUN ./mvnw clean package -DskipTests

# Runtime image
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

RUN addgroup -S kisansetu && adduser -S kisansetu -G kisansetu
USER kisansetu:kisansetu

COPY --from=builder /workspace/app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
