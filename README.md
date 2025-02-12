# Publisher-BA-Caddy
This repo contains instruction on how to deploy Caddy on a Publisher to manage Browser Applications that require URIand Redirections

# Prerequisites
- A Netskope Publisher deployed
- The Netskope Publisher has access to the applications in terms of DNS resolutions and/or IP/Port access

# Installation
In order to deploy the Caddy container:
1- Exit the Publisher Wizard (generally key 7)
2- Run the following commands:
```
curl -L https://github.com/sartioli/Publisher-BA-Caddy/raw/refs/heads/main/caddy-deployment.sh -o caddy-deployment.sh
sudo chmod 777 caddy-deployment.sh
sudo ./caddy-deployment.sh
```
3- Reboot the Publisher when asked
