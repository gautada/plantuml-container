ARG ALPINE_VERSION=3.14.1

# ╭――――――――――――――――-------------------------------------------------------――╮
# │                                                                         │
# │ STAGE 1: plantuml-container build the plantuml server from scratch      │
# │                                                                         │
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM gautada/alpine:$ALPINE_VERSION as plantuml-build

# ╭――――――――――――――――――――╮
# │ VERSION            │
# ╰――――――――――――――――――――╯
ARG PLANTUML_SERVER_VERSION=1.2022.7
ARG PLANTUML_SERVER_BRANCH=v"$PLANTUML_SERVER_VERSION"

# ╭――――――――――――――――――――╮
# │ PACKAGES           │
# ╰――――――――――――――――――――╯
RUN /sbin/apk add --no-cache git gradle maven openjdk17-jdk ttf-dejavu
# graphviz

# ╭――――――――――――――――――――╮
# │ SOURCE             │
# ╰――――――――――――――――――――╯
# Pull the  source code from github.
RUN git config --global advice.detachedHead false
# RUN git clone --branch $PLANTUML_BRANCH --depth 1 https://github.com/plantuml/plantuml.git
RUN git clone --branch $PLANTUML_SERVER_BRANCH --depth 1 https://github.com/plantuml/plantuml-server.git
COPY config.properties /plantuml-server/src/main/resources/config.properties
COPY index.jsp /plantuml-server/src/main/webapp/index.jsp
# RUN /bin/mkdir /plantuml-server/src/main/webapp/test
# COPY index.html /plantuml-server/src/main/webapp/test/index.html
# RUN git clone --depth 1 https://github.com/plantuml/plantuml-stdlib.git

# ╭――――――――――――――――――――╮
# │ BUILD              │
# ╰――――――――――――――――――――╯
# COPY sequenceDiagram.puml /sequenceDiagram.puml
# WORKDIR /plantuml-server
# RUN gradle --status
# WORKDIR /plantuml
# RUN /usr/bin/gradle jar
WORKDIR /plantuml-server
RUN mvn --batch-mode --define java.net.useSystemProxies=true -Dapache-jsp.scope=compile package


# ╭――――――――――――――――-------------------------------------------------------――╮
# │                                                                         │
# │ STAGE 2: plantuml-container                                             │
# │                                                                         │
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM gautada/alpine:$ALPINE_VERSION

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL source="https://github.com/gautada/plantuml-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="A plant uml server"

# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
RUN rm -v /etc/container/entrypoint
COPY entrypoint /etc/container/entrypoint

# ╭――――――――――――――――――――╮
# │ VERSION            │
# ╰――――――――――――――――――――╯
ARG TOMCAT_VERSION=10.0.27
ARG TOMCAT_BRANCH=v"$TOMCAT_VERSION"

# ╭――――――――――――――――――――╮
# │ PORTS              │
# ╰――――――――――――――――――――╯
EXPOSE 8080/tcp

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
COPY --from=plantuml-build /plantuml-server/target/plantuml.war /plantuml.war
# COPY --from=plantuml-build /plantuml/build/libs/*.jar /
RUN /sbin/apk add --no-cache font-noto-cjk graphviz openjdk17-jre
WORKDIR /opt
RUN wget https://dlcdn.apache.org/tomcat/tomcat-10/$TOMCAT_BRANCH/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz \
 && tar -zxf apache-tomcat-$TOMCAT_VERSION.tar.gz \
 && mv /opt/apache-tomcat-$TOMCAT_VERSION /opt/tomcat10 \
 && rm -rf /opt/apache-tomcat-10.0.22 /opt/tomcat10/webapps /opt/tomcat10/logs /opt/tomcat10/temp /opt/tomcat10/work \
 && mkdir /opt/tomcat10/webapps \
 && mv /plantuml.war /opt/tomcat10/webapps/ROOT.war \
 && ln -s /opt/plantuml/logs /opt/tomcat10/logs \
 && ln -s /opt/plantuml/temp /opt/tomcat10/temp \
 && ln -s /opt/plantuml/work /opt/tomcat10/work

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
ARG USER=plantuml
RUN /bin/mkdir -p /opt/$USER /var/backup /tmp/backup /opt/backup \
 && /usr/sbin/addgroup $USER \
 && /usr/sbin/adduser -D -s /bin/ash -G $USER $USER \
 && /usr/sbin/usermod -aG wheel $USER \
 && /bin/echo "$USER:$USER" | chpasswd \
 && /bin/chown $USER:$USER -R /opt/tomcat10 /opt/$USER
# /etc/backup /var/backup /tmp/backup /opt/backup
 
USER $USER
WORKDIR /home/$USER
VOLUME /opt/$USER



