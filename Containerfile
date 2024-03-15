ARG ALPINE_VERSION=latest

FROM docker.io/gautada/alpine:$ALPINE_VERSION as src

# ╭――――――――――――――――――――╮
# │ VERSION            │
# ╰――――――――――――――――――――╯
ARG CONTAINER_VERSION="1.2022.7"
ARG PLANTUML_SERVER_VERSION="$CONTAINER_VERSION"
ARG PLANTUML_SERVER_BRANCH=v"$PLANTUML_SERVER_VERSION"

RUN /sbin/apk add --no-cache git gradle maven openjdk17-jdk ttf-dejavu
# graphviz

RUN git config --global advice.detachedHead false
RUN git clone --branch $PLANTUML_SERVER_BRANCH --depth 1 https://github.com/plantuml/plantuml-server.git
# COPY config.properties /plantuml-server/src/main/resources/config.properties
# COPY index.jsp /plantuml-server/src/main/webapp/index.jsp
WORKDIR /plantuml-server
RUN mvn package -Dapache-jsp.scope=compile
# RUN mvn --batch-mode --define java.net.useSystemProxies=true -Dapache-jsp.scope=compile package

# ╭―
# │                                                                         
# │ STAGE: container                                                        
# │                                                                         
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
FROM docker.io/gautada/alpine:$ALPINE_VERSION

# ╭―
# │ METADATA           
# ╰――――――――――――――――――――
LABEL source="https://github.com/gautada/plantuml-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="A plant uml server"

# ╭―
# │ USER
# ╰――――――――――――――――――――
ARG USER=plantuml
RUN /usr/sbin/usermod -l $USER alpine
RUN /usr/sbin/usermod -d /home/$USER -m $USER
RUN /usr/sbin/groupmod -n $USER alpine
RUN /bin/echo "$USER:$USER" | /usr/sbin/chpasswd

# ╭―
# │ PRIVILEGES
# ╰――――――――――――――――――――
COPY privileges /etc/container/privileges

# ╭―
# │ BACKUP
# ╰――――――――――――――――――――
# RUN /bin/rm -f /etc/periodic/hourly/container-backup
# COPY backup /etc/container/backup

# ╭―
# │ ENTRYPOINT
# ╰――――――――――――――――――――
COPY entrypoint /etc/container/entrypoint

# ╭―
# │ APPLICATION        
# ╰――――――――――――――――――――
ARG TOMCAT_VERSION=10.0.27
ARG TOMCAT_BRANCH=v"$TOMCAT_VERSION"

RUN /sbin/apk add --no-cache font-noto-cjk graphviz openjdk17-jre

WORKDIR /opt
RUN curl -s https://dlcdn.apache.org/tomcat/tomcat-10/$TOMCAT_BRANCH/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz --output tomcat.tar.gz

RUN tar -zxf tomcat.tar.gz
RUN rm tomcat.tar.gz
RUN mv /opt/apache-tomcat-$TOMCAT_VERSION /opt/tomcat10
RUN rm -rf /opt/apache-tomcat-10.0.22 

COPY --from=src /plantuml-server/target/plantuml.war /opt/tomcat10/webapps/plantuml.war


# ╭―
# │ CONFIGURATION
# ╰――――――――――――――――――――
RUN chown -R $USER:$USER /home/$USER /opt
USER $USER
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
VOLUME /mnt/volumes/secrets
EXPOSE 8080/tcp
WORKDIR /home/$USER
