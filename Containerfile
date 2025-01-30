FROM docker.io/ubuntu:24.04 as build

RUN /usr/bin/apt-get update
  
RUN /usr/bin/apt-get install --yes git

# Need to download jdk-25 from https://jdk.java.net/25/
ADD https://download.java.net/java/early_access/jdk25/7/GPL/openjdk-25-ea+7_linux-aarch64_bin.tar.gz jdk-25.tgz
ADD https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz maven.tgz

RUN /usr/bin/tar zxf jdk-25.tgz \
 && /usr/bin/tar zxf maven.tgz \
 && /usr/bin/ln -fsv apache-maven-3.9.9 maven

ARG CONTAINER_VERSION="1.2025.0"
ARG PLANTUML_SERVER_VERSION="$CONTAINER_VERSION"
ARG PLANTUML_SERVER_BRANCH=v"$PLANTUML_SERVER_VERSION"

ENV JAVA_HOME=/jdk-25
ENV PATH=$PATH:/jdk-25/bin:/maven/bin 
RUN git config --global advice.detachedHead false
RUN git clone --branch $PLANTUML_SERVER_BRANCH --depth 1 https://github.com/plantuml/plantuml-server.git
WORKDIR /plantuml-server
RUN /maven/bin/mvn package -Dapache-jsp.scope=compile

FROM docker.io/ubuntu:24.04

RUN /usr/bin/apt-get update \
 && /usr/bin/apt-get upgrade --yes
 
RUN /usr/bin/apt-get install --yes fonts-noto-cjk graphviz

WORKDIR /opt
COPY --from=build /jdk-25.tgz /opt/jdk-25.tgz
RUN /usr/bin/tar zxf jdk-25.tgz \
 && /usr/bin/mv jdk-25 jdk \
 && /usr/bin/rm jdk-25.tgz

ARG TOMCAT_VERSION=10.1.34
ARG TOMCAT_URL="https://dlcdn.apache.org/tomcat/tomcat-10/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz"
ADD $TOMCAT_URL tomcat.tgz
RUN /usr/bin/tar zxf tomcat.tgz \
 && /usr/bin/mv /opt/apache-tomcat-$TOMCAT_VERSION /opt/tomcat10 \
 && rm tomcat.tgz

COPY --from=build /plantuml-server/target/plantuml.war /opt/tomcat10/webapps/plantuml.war
# COPY --from=build /plantuml-server/target/plantuml.war /opt/plantuml/plantuml.war

ARG USER=puml
RUN /usr/sbin/useradd -m ${USER} 
RUN /usr/bin/chown -R puml:puml /opt
USER $USER

ENTRYPOINT ["/opt/tomcat10/bin/catalina.sh", "run"]