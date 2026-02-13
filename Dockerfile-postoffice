ARG UBUNTU_RELEASE=24.04

FROM ubuntu:$UBUNTU_RELEASE
RUN apt update && apt full-upgrade -y && apt install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
