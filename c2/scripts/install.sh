#!/bin/bash

echo "Let's roll"
CURRENT_DIR="$(pwd)"

sudo apt update &&
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y &&
sudo DEBIAN_FRONTEND=noninteractive apt install docker.io -y &&


### install additional tools
mkdir tools && cd tools &&
git clone https://github.com/cyberhexe/packet-storm &&
git clone https://github.com/cyberhexe/microsocks &&
echo "OK"