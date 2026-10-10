#!/bin/bash
# ==========================================
# Mini-Project 1: Manage Environment & Check Ports
# ==========================================
PORT=${PORT:-8080}
echo "[+] Checking if port $PORT is available..."
if lsof -i :"$PORT" > /dev/null 2>&1; then
    echo "[!] Port $PORT is BUSY:"
    lsof -i :"$PORT"
else
    echo "[✓] Port $PORT is FREE to use."
fi
