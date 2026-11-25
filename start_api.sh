#!/bin/bash
ip route del default
ip route add default via 192.168.145.254
if [ ! -f /cert.pem ]; then
    openssl req -x509 -newkey rsa:4096 -keyout /key.pem -out /cert.pem -days 365 -nodes -subj "/CN=GameStateServer"
fi
uvicorn main:app --host 0.0.0.0  --port 8000 --ssl-keyfile /key.pem --ssl-certfile /cert.pem