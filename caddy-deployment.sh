#!/bin/bash

# Define the hosts file entry
HOSTS_ENTRY="127.0.0.1 testapp1.lan testapp2.lan testapp3.lan"

# Check if the "caddy" container exists
if ! docker ps -a --format "{{.Names}}" | grep -q "^caddy$"; then
    echo "Caddy container not found. The script will install everything."
else
    echo "Caddy container already exists ! Do you want to re-install Caddy (this will remove also any previous CaddyFile configuration !"
    # Ask for confirmation
    read -p "Do you want to proceed? (y/N): " answer
    # Check the answer (accept 'y' or 'Y')
    if [[ "$answer" =~ ^[Yy]$ ]]; then
       echo "Proceeding with the re-installation..."
    else
       echo "Operation cancelled. Caddy has not been re-installed !"
       exit 0
    fi
fi

# Check if the entry already exists to avoid duplicates
if grep -qF "$HOSTS_ENTRY" /etc/hosts; then
    echo "The entry already exists in /etc/hosts."
else
    echo "Adding the entry to /etc/hosts..."
    # Append the entry using tee and sudo
    echo "$HOSTS_ENTRY" | sudo tee -a /etc/hosts > /dev/null
    echo "Entry added successfully."
fi

HOME_DIR=$(eval echo ~$SUDO_USER)
cd "$HOME_DIR"

# Removing the CaddyFile if present
rm -f ./Caddyfile
curl -L -o ./Caddyfile "https://github.com/sartioli/Publisher-BA-Caddy/raw/refs/heads/main/Caddyfile"

# Removing the Caddy container if present
docker rm -f caddy
docker run --net=host -d --restart unless-stopped --name caddy -v "./Caddyfile:/etc/caddy/Caddyfile" caddy:latest

# Warn the user
echo "WARNING: The system must be rebooted! This action will reboot your computer."

# Ask for confirmation
read -p "Do you want to proceed? (y/N): " answer

# Check the answer (accept 'y' or 'Y')
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "Proceeding with the reboot..."
    sudo reboot
else
    echo "Operation cancelled. Reboot the machine manually to apply the cnhanges !"
    exit 0
fi
