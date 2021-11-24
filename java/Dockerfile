# docker build --build-arg JAR_FILE=mxsk-financing-server-platform/target/\*.jar  -t springio/gs-spring-boot-docker . 
FROM openjdk:11
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
