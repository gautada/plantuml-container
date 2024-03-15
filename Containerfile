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
COPY config.properties /plantuml-server/src/main/resources/config.properties
COPY index.jsp /plantuml-server/src/main/webapp/index.jsp
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
RUN /sbin/apk add --no-cache font-noto-cjk graphviz openjdk17-jdk
RUN /sbin/apk add --no-cache jetty-runner
ARG JETTY_VERSION=12.0.7

RUN /usr/bin/curl -s https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-home/$JETTY_VERSION/jetty-home-$JETTY_VERSION.zip --output /jetty-home.zip

WORKDIR /opt
RUN /usr/bin/unzip /jetty-home.zip
RUN /bin/rm -f /jetty-home.zip
RUN /bin/ln -fsv /opt/jetty-home-$JETTY_VERSION /opt/jetty-home
WORKDIR /opt/jetty-home

RUN /usr/bin/java -jar start.jar jetty.base=/home/$USER/jetty-base --add-module=server,http,deploy
# COPY --from=src /plantuml-server /home/$USER/plantuml-server

# RUN /bin/mkdir /home/$USER/jetty-base/webapps
COPY --from=src /plantuml-server/target/plantuml.war /home/$USER/jetty-base/webapps/plantuml.war

# COPY ROOT.xml /home/$USER/ROOT.xml
# /home/$USER/jetty-base/webapps/ROOT.xml

# ╭―
# │ CONFIGURATION
# ╰――――――――――――――――――――
RUN chown -R $USER:$USER /home/$USER
USER $USER

VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
VOLUME /mnt/volumes/secrets
EXPOSE 8080/tcp
WORKDIR /opt/jetty-home
