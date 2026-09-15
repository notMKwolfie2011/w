FROM ubuntu:22.04

# Stop interactive prompts during setup
ENV DEBIAN_FRONTEND=noninteractive

# Update and install 32-bit architecture + desktop components + noVNC tools
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    x11vnc \
    xvfb \
    wine32 \
    winetricks \
    unzip \
    python3 \
    python3-pip \
    novnc \
    websockify \
    && rm -rf /var/lib/apt/lists/*

# Install Google Drive downloader
RUN pip3 install gdown

WORKDIR /app

# EXPOSE the web port Render will use to connect to you
EXPOSE 8080

# Create a startup script to link the servers together automatically
RUN echo '#!/bin/bash\n\
Xvfb :1 -screen 0 1280x720x24 &\n\
sleep 2\n\
x11vnc -display :1 -nopw -listen localhost -forever &\n\
sleep 2\n\
gdown --id 1ZEXSpme3gLxrY6uXMAECyiHtRdKCokNl -O game.zip\n\
unzip game.zip -d ./fnaf_game\n\
websockify --web=/usr/share/novnc/ 8080 localhost:5900\n\
' > /app/start.sh && chmod +x /app/start.sh

CMD ["/app/start.sh"]
