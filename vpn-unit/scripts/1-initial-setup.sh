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
    -y &&

sudo usermod -aG docker kali

### install additional tools
mkdir tools && cd tools &&
git clone https://github.com/cyberhexe/red-toolkit

pip3 install parrot-feeder
pip3 install twisted

sudo docker pull cyberhexe/packet-storm
