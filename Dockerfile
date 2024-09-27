# Start with a minimal Ubuntu base image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install RetroArch and other necessary packages
RUN apt-get update && \
    apt-get upgrade --yes && \
    apt-get install --yes \
    retroarch \
    xvfb \
    novnc \
    websockify \
    supervisor \
    python3 \
    python3-pip \
    libasound2-dev \  # Install only libasound2-dev for ALSA support
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directories for noVNC and RetroArch
RUN mkdir -p /usr/share/novnc /var/run/retroarch

# Add start script
RUN echo '#!/bin/bash\n\n\
# Start Xvfb\n\
Xvfb :1 -screen 0 1280x720x24 &\n\
sleep 2  # Give Xvfb time to start\n\
\n\
# Set the DISPLAY variable for RetroArch\n\
export DISPLAY=:1\n\
\n\
# Start RetroArch - replace with specific command line options you need\n\
retroarch &\n\
\n\
# Start noVNC\n\
websockify --web=/usr/share/novnc 6080 localhost:5901 &\n\
\n\
# Keep the script running\n\
wait -n' > /start.sh && chmod +x /start.sh

# Set working directory
WORKDIR /usr/share/novnc

# Expose the noVNC port
EXPOSE 6080

# Run the application
CMD ["/start.sh"]
