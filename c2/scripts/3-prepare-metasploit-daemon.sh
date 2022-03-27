#!/bin/bash

MSFD_IP="$1"
MSFD_PORT="$2"

if [ -z "$MSFD_IP" ]; then
  echo "Setting 127.0.0.1 as default IP address"
  MSFD_IP="127.0.0.1"
fi
if [ -z "$MSFD_PORT" ]; then
  echo "Setting 1337 as default TCP port"
  MSFD_PORT=1337
fi

sudo msfdb init &&
msfd -a "$MSFD_IP" -p "$MSFD_PORT"

echo "db_status" |ncat "$MSFD_IP" "$MSFD_PORT"
