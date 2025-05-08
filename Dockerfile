FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Actualitza paquets i instal·la dependències bàsiques
RUN apt update && apt upgrade -y && \
    apt install -y sudo wget gnupg2 curl git nano lsb-release net-tools unzip apt-transport-https software-properties-common openssh-server python3 python3-pip xfce4 xfce4-goodies x11vnc xvfb dbus-x11 tigervnc-standalone-server

# Instal·la VS Code
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' && \
    apt update && apt install -y code && \
    rm microsoft.gpg

# Configura usuari
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

# Configura VNC
RUN mkdir -p /home/docker/.vnc && \
    echo "docker" | vncpasswd -f > /home/docker/.vnc/passwd && \
    chmod 600 /home/docker/.vnc/passwd && \
    chown -R docker:docker /home/docker/.vnc

# Escriu el fitxer de configuració de VNC
RUN echo "#!/bin/bash\nstartxfce4 &" > /home/docker/.vnc/xstartup && \
    chmod +x /home/docker/.vnc/xstartup

# Exposa ports: VNC (5901) i SSH (22)
EXPOSE 5901 22

# Configura servei SSH
RUN mkdir /var/run/sshd

# L’entrada del contenidor arrenca VNC i SSH
CMD /usr/sbin/sshd && su - docker -c "vncserver :1 -geometry 1280x800 -depth 24 && tail -f /dev/null"
