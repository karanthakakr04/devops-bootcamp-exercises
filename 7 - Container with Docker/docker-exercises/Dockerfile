# Use the amazoncorretto base image
FROM amazoncorretto:21-alpine3.19-full

# Set the working directory inside the container
WORKDIR /app

# Copy the application JAR file to the container and rename it
COPY ./build/libs/docker-exercises-project-1.0-SNAPSHOT.jar /app/java-project.jar

# Expose the port on which the application runs
EXPOSE 8080

# Specify the entrypoint command to run when the container starts
ENTRYPOINT [ "java", "-jar", "java-project.jar" ]
