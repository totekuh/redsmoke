#!/bin/bash

cp /tmp/docker-compose.yml /root/vpn-unit/docker-compose.yml
cd /root/vpn-unit
docker-compose up --build --force-recreate --detach
