#!/bin/bash

echo "Let's roll"
sudo apt update &&
sudo DEBIAN_FRONTEND=noninteractive apt install docker.io ncat -y &&


### install additional tools
mkdir tools && cd tools &&
git clone https://github.com/cyberhexe/packet-storm &&
git clone https://github.com/cyberhexe/microsocks &&

