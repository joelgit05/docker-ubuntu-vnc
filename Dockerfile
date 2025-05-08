# Utilitza Ubuntu 24.04 com a base
FROM ubuntu:24.04

# Configura el mode no interactiu per a evitar preguntes durant la instal·lació
ENV DEBIAN_FRONTEND=noninteractive

# Actualitza i instal·la les dependències bàsiques, entorn gràfic, VNC, i altres utilitats
RUN apt update && apt upgrade -y && \
    apt install -y sudo wget gnupg2 curl git nano lsb-release net-tools unzip apt-transport-https software-properties-common openssh-server python3 python3-pip xfce4 xfce4-goodies x11vnc xvfb dbus-x11 tigervnc-standalone-server

# Instal·la Visual Studio Code
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' && \
    apt update && apt install -y code && \
    rm microsoft.gpg

# Configura un usuari per al contenidor
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

# Crea el directori .vnc i configura la contrasenya
RUN mkdir -p /home/docker/.vnc && \
    echo "docker" | vncpasswd -f > /home/docker/.vnc/passwd && \
    chmod 600 /home/docker/.vnc/passwd && \
    chown -R docker:docker /home/docker/.vnc

# Crea el fitxer de configuració per a VNC (iniciar XFCE)
RUN echo "#!/bin/bash\nstartxfce4 &" > /home/docker/.vnc/xstartup && \
    chmod +x /home/docker/.vnc/xstartup

# Exposa els ports per a VNC (5901) i SSH (22)
EXPOSE 5901 22

# Configura el servei SSH
RUN mkdir /var/run/sshd

# Copia el script d'inici
COPY start-vnc.sh /start-vnc.sh
RUN chmod +x /start-vnc.sh

# Configura el contenidor per executar el script d'inici quan arrenca
CMD /start-vnc.sh
