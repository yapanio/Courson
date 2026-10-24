# Stage 1: Build file .war bằng Maven + JDK 17
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /build

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Chạy trên Tomcat
FROM tomcat:10.1-jdk17-temurin-jammy
WORKDIR /usr/local/tomcat

RUN rm -rf webapps/*
COPY --from=build /build/target/*.war webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]