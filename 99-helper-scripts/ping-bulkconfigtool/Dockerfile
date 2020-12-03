# Usage
# docker build -t ping-bulkexport-tools:latest .
# docker run -v $PWD/out:/out -v $PWD/in:/in ping-bulkexport-tools:latest /in/pf-config.json /out/pf-export.json /out/pingfederate/pf.env /out/pingfederate/requestBody.json.subst > ./out/pingfederate/export-convert.log 

FROM maven:3-adoptopenjdk-11 AS build
COPY ping-bulkexport-tools-project /usr/src/app
WORKDIR /usr/src/app
RUN mvn install

FROM adoptopenjdk/openjdk11:alpine
COPY --from=build /usr/src/app/target/ping-bulkexport-tools-0.0.1-SNAPSHOT-jar-with-dependencies.jar /usr/app/ping-bulkexport-tools-0.0.1-SNAPSHOT-jar-with-dependencies.jar
ENTRYPOINT ["java", "-jar", "/usr/app/ping-bulkexport-tools-0.0.1-SNAPSHOT-jar-with-dependencies.jar"]
