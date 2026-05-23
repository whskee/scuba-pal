FROM amazoncorretto:25 AS build

WORKDIR /workspace

RUN dnf install -y tar gzip && dnf clean all

COPY . .

RUN chmod +x ./mvnw && ./mvnw -DskipTests clean package


FROM amazoncorretto:25-alpine

WORKDIR /app

COPY --from=build /workspace/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
