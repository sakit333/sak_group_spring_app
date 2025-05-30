# Stage 1: Build the Spring Boot app
FROM maven:3.8.7-openjdk-17 AS build

WORKDIR /app

# Copy pom.xml and download dependencies (cache)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the app
RUN mvn clean package -DskipTests

# Stage 2: Run the Spring Boot app
FROM openjdk:17-jdk-slim

WORKDIR /app

# Copy the jar from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose port as per your config (8081)
EXPOSE 8081

# Run the app
ENTRYPOINT ["java", "-jar", "app.jar"]
