# Start with a minimal Ubuntu base image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV XDG_RUNTIME_DIR=/tmp/runtime-dir

# Create the XDG_RUNTIME_DIR
RUN mkdir -p ${XDG_RUNTIME_DIR}

# Update package list and install required packages
RUN apt-get update && \
    apt-get install --yes \
    retroarch \
    xvfb \
    novnc \
    websockify \
    supervisor \
    python3 \
    python3-pip \
    libasound2-dev \
    x11vnc \ 
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directories for noVNC and RetroArch
RUN mkdir -p /usr/share/novnc /var/run/retroarch

# Create start script
RUN echo '#!/bin/bash\n\n\
# Start Xvfb\n\
Xvfb :1 -screen 0 1280x720x24 -extension RANDR &\n\
sleep 2  # Give Xvfb time to start\n\
\n\
# Set the DISPLAY variable for RetroArch\n\
export DISPLAY=:1\n\
\n\
# Start x11vnc to export the Xvfb display to VNC\n\
x11vnc -display :1 -nopw -forever -many -listen localhost -rfbport 5901 &\n\
\n\
# Start RetroArch - replace with specific command line options you need\n\
retroarch &\n\
\n\
# Start noVNC with a longer timeout\n\
websockify --web=/usr/share/novnc 6080 localhost:5901 --timeout=3600 &\n\
\n\
# Keep the script running\n\
wait -n' > /start.sh && chmod +x /start.sh

# Set the working directory
WORKDIR /usr/share/novnc

# Expose the noVNC port
EXPOSE 6080

# Run the application
CMD ["/start.sh"]
