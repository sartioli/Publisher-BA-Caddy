#!/bin/bash

# Define the hosts file entry
HOSTS_ENTRY="127.0.0.1 example.com"

# Check if the entry already exists to avoid duplicates
if grep -qF "$HOSTS_ENTRY" /etc/hosts; then
    echo "The entry already exists in /etc/hosts."
else
    echo "Adding the entry to /etc/hosts..."
    # Append the entry using tee and sudo
    echo "$HOSTS_ENTRY" | sudo tee -a /etc/hosts > /dev/null
    echo "Entry added successfully."
fi

if [ ! -f "Caddyfile" ]; then
  echo "Caddyfile not found. Downloading..."
  curl -o Caddyfile "https://example.com/path/to/Caddyfile"
else
  echo "Caddyfile already exists."
fi

#!/bin/bash

# Check if a container named "caddy" exists
if docker inspect caddy > /dev/null 2>&1; then
  echo "Container 'caddy' already exists."
else
  echo "Container 'caddy' does not exist. Creating it now..."
  docker run --net=host -d --restart unless-stopped --name caddy \
    -v "$(pwd)/Caddyfile:/etc/caddy/Caddyfile" \
    caddy:latest
fi


# Warn the user
echo "WARNING: The system must be rebooted! This action will reboot your computer."

# Ask for confirmation
read -p "Do you want to proceed? (y/N): " answer

# Check the answer (accept 'y' or 'Y')
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "Proceeding with the reboot..."
    sudo reboot
else
    echo "Operation cancelled."
    exit 0
fi
