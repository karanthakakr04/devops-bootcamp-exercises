FROM amazoncorretto:21-alpine3.19-full

WORKDIR /app

COPY ./build/libs/docker-exercises-project-1.0-SNAPSHOT.jar app.jar

EXPOSE 8080

ENTRYPOINT [ "java", "-jar", "app.jar" ]
