ARG ALPINE_VERSION=3.14.1

# ╭――――――――――――――――-------------------------------------------------------――╮
# │                                                                         │
# │ STAGE 1: plantuml-container                                             │
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
# │ VERSION            │
# ╰――――――――――――――――――――╯
ARG PLANTUML_VERSION=1.2022.5
ARG PLANTUML_BRANCH=v"$PLANTUML_VERSION"

# ╭――――――――――――――――――――╮
# │ BUILD              │
# ╰――――――――――――――――――――╯
RUN /sbin/apk add --no-cache git java-common

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
ARG USER=plantuml
RUN /bin/mkdir -p /opt/$USER /var/backup /tmp/backup /opt/backup \
 && /usr/sbin/addgroup $USER \
 && /usr/sbin/adduser -D -s /bin/ash -G $USER $USER \
 && /usr/sbin/usermod -aG wheel $USER \
 && /bin/echo "$USER:$USER" | chpasswd \
 && /bin/chown $USER:$USER -R /opt/$USER /etc/backup /var/backup /tmp/backup /opt/backup
 
USER $USER
WORKDIR /home/$USER
VOLUME /opt/$USER



