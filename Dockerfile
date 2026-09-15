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

# EXPOSE the web port explicitly
EXPOSE 8080

# Create an optimized, paced startup script to protect CPU memory limits
RUN echo '#!/bin/bash\n\
echo "Starting Virtual Display Server..."\n\
Xvfb :1 -screen 0 1280x720x24 &\n\
sleep 3\n\
\n\
echo "Starting VNC Stream Engine..."\n\
x11vnc -display :1 -nopw -listen localhost -forever -shared &\n\
sleep 3\n\
\n\
echo "Fetching 3D game files from backup archive..."\n\
gdown --id 1ZEXSpme3gLxrY6uXMAECyiHtRdKCokNl -O game.zip\n\
\n\
echo "Extracting asset models (Paced CPU allocation)..."\n\
unzip -q game.zip -d ./fnaf_game\n\
sleep 3\n\
\n\
echo "Pre-rendering Wine 32-bit graphic hooks..."\n\
DISPLAY=:1 wine32 /app/fnaf_game/*.exe -opengl &\n\
sleep 5\n\
\n\
echo "Activating noVNC Routing Gateway..."\n\
websockify --web=/usr/share/novnc/ 8080 localhost:5900\n\
' > /app/start.sh && chmod +x /app/start.sh

CMD ["/app/start.sh"]
