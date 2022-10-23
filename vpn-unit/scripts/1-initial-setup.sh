#!/bin/bash

echo "Let's roll"
sudo apt update &&
sudo DEBIAN_FRONTEND=noninteractive apt install \
    docker.io \
    docker-compose \
    ncat \
    tor \
    torsocks \
    proxychains \
    nginx \
    python3 \
    python3-pip \
    python3-dev \
    docker.io \
    docker-compose \
    -y &&

sudo usermod -aG docker kali

### install additional tools
mkdir tools && cd tools &&
git clone https://github.com/cyberhexe/red-toolkit

sudo mkdir /root/vpn-unit
