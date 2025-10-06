FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LGSM_CURL_OPTIONS="--connect-timeout 30 --max-time 300"

# Install dependencies including jq
RUN apt-get update && apt-get install -y \
    wget curl ca-certificates unzip bzip2 gzip xz-utils file \
    lib32gcc-s1 lib32stdc++6 lib32stdc++-12-dev tmux jq \
    && rm -rf /var/lib/apt/lists/*

# Create linuxgsm user
RUN useradd -m linuxgsm

USER linuxgsm
WORKDIR /home/linuxgsm

# Download LinuxGSM script
RUN wget -4 -O linuxgsm.sh https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/master/linuxgsm.sh \
    && chmod +x linuxgsm.sh

EXPOSE 8766-8767/udp 16261-16278/udp 27015/tcp
ENTRYPOINT ["/bin/bash"]
