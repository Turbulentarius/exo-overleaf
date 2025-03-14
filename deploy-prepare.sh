#!/bin/bash

OVERLEAF_DIR=./overleaf
OVERRIDE_FILE=./docker-compose.override.yml
REPO_URL="https://github.com/overleaf/overleaf.git"

if [ -d "$OVERLEAF_DIR" ]; then
    echo "Removing old Overleaf installation..."
    rm -rf "$OVERLEAF_DIR"
fi

echo "Cloning Overleaf repository..."
git clone "$REPO_URL" "$OVERLEAF_DIR"

cp "$OVERRIDE_FILE" "$OVERLEAF_DIR/"

if [ ! -f "/etc/systemd/system/overleaf.service" ]; then
    echo "Copying Overleaf service file to /etc/systemd/system/"
    sudo cp "./overleaf.service" "/etc/systemd/system/"
fi

echo "Reloading systemd and enabling service..."
sudo systemctl daemon-reload
sudo systemctl enable overleaf.service
# sudo systemctl start overleaf.service
