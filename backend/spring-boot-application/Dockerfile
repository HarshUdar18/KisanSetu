FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

RUN addgroup -S kisansetu && adduser -S kisansetu -G kisansetu
USER kisansetu:kisansetu

COPY target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
