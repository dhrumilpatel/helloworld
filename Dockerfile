FROM openjdk:8-jre-alpine
COPY ./target/spring-boot-complete-0.0.1-SNAPSHOT.jar /my-app-hello-world.jar
CMD java -jar /my-app-hello-world.jar
