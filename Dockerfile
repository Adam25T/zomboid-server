# Base image
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget curl ca-certificates unzip bzip2 gzip xz-utils file \
    lib32gcc-s1 lib32stdc++6 lib32stdc++-12-dev tmux \
    && rm -rf /var/lib/apt/lists/*

# Create linuxgsm user
RUN useradd -m linuxgsm

# Switch to linuxgsm
USER linuxgsm
WORKDIR /home/linuxgsm

# Download LinuxGSM script from GitHub
RUN wget -4 -O linuxgsm.sh https://raw.githubusercontent.com/linuxgsm/linuxgsm/master/linuxgsm.sh \
    && chmod +x linuxgsm.sh

# Increase curl timeout for all LGSM operations
ENV LGSM_CURL_OPTIONS="--connect-timeout 30 --max-time 300"

# Expose Project Zomboid ports
EXPOSE 8766-8767/udp 16261-16278/udp 27015/tcp

ENTRYPOINT ["/bin/bash"]
