# Use OpenJDK 17 as the base image
FROM openjdk:17-jdk-slim

# Set the working directory
WORKDIR /app

# Copy the application files
COPY target/your-application.jar app.jar
COPY application.properties ./

# Specify the command to run your application
CMD ["java", "-jar", "app.jar"]