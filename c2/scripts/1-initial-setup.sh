#!/bin/bash

echo "Let's roll"
sudo apt update &&
#sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y &&
sudo DEBIAN_FRONTEND=noninteractive apt install docker.io -y &&


### install additional tools
mkdir tools && cd tools &&
git clone https://github.com/cyberhexe/packet-storm &&
git clone https://github.com/cyberhexe/microsocks &&

### start remote metasploit
sudo msfdb init &&
msfd -a 127.0.0.1 -p 1337 &&
echo "OK"
