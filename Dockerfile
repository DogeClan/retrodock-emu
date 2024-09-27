# Use a base image with the required dependencies
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    git \
    cmake \
    libx11-dev \
    libxext-dev \
    libxrender-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxcb1-dev \
    libxkbcommon-dev \
    libalsa-oss-dev \
    libpulse-dev \
    libgtk-3-dev \
    libglib2.0-dev \
    xvfb \
    novnc \
    websockify \
    supervisor \
    python3 \
    python3-pip \
    wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Clone RetroArch repository
RUN git clone --depth=1 https://github.com/libretro/RetroArch.git /retroarch

# Build RetroArch
RUN cd /retroarch && \
    ./configure --enable-x11 --enable-opengl --enable-alsa && \
    make -j$(nproc) && \
    make install

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
