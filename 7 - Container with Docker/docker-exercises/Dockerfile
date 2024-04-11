# Use OpenJDK 17 as the base image
FROM 21-alpine3.19-jdk

# Set the working directory
WORKDIR /app

# Copy the application files
COPY target/your-application.jar app.jar
COPY application.properties ./

# Specify the command to run your application
CMD ["java", "-jar", "app.jar"]