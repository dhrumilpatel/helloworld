FROM openjdk:8-jre-alpine
COPY ./target/hello-world-spring-boot-0.0.1-SNAPSHOT.jar /my-app-hello-world.jar
CMD java -jar /my-app-hello-world.jar
