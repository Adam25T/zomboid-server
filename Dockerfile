# Base image
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf && \
    apt-get update && \
    apt-get install -y \
        wget curl ca-certificates unzip bzip2 gzip xz-utils file \
        lib32gcc-s1 lib32stdc++6 lib32stdc++-12-dev tmux \
        && rm -rf /var/lib/apt/lists/*

# Create LGSM user
RUN useradd -m linuxgsm
USER linuxgsm
WORKDIR /home/linuxgsm

# Download LinuxGSM script
RUN wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh

# Expose default Project Zomboid ports
EXPOSE 8766-8767/udp 16261-16278/udp 27015/tcp

# Use bash as entrypoint
ENTRYPOINT ["/bin/bash"]
