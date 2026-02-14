ARG UBUNTU_RELEASE=24.04

FROM ubuntu:$UBUNTU_RELEASE
RUN apt update && apt full-upgrade -y && apt install -y libsqlite3-0 apache2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
