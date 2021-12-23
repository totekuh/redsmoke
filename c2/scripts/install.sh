#!/bin/bash

echo "Let's roll"

sudo apt update &&
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y &&
sudo apt install nginx &&
echo "OK"