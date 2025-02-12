# Publisher-BA-Caddy
This repo contains instruction on how to deploy Caddy on a Publisher to manage Browser Applications that require URIand Redirections

# Prerequisites
- A Netskope Publisher deployed
- The Netskope Publisher has access to the applications in terms of DNS resolutions and/or IP/Port access

# Installation
In order to deploy the Caddy container:
1) Exit the Publisher Wizard (generally key 7)
2) Run the following commands:
```
curl -L https://github.com/sartioli/Publisher-BA-Caddy/raw/refs/heads/main/caddy-deployment.sh -o caddy-deployment.sh
sudo chmod 777 caddy-deployment.sh
sudo ./caddy-deployment.sh
```
3) Reboot the Publisher when asked

# Flow to create the Browser NPA Application and serve it via Caddy

In order to create a NPA Browser Application and serve it via Caddy:

1) Create a NPA Browser Application that points to a dummy FQDN, such as ```application1.lan``` for protocol HTTPS on port 443, and assign to it the Publisher(s) where Caddy is deployed (and optionally assign to it the relative labels)
2) On ALL the Publishers that serve the application do the fllowing:
   - Exit the NPA Publisher Wizard (generally key 7)
   - Edit the /etc/hosts file (using ```sudo vi```) to add the dummy hostname (for example ```application1.lan```) to the ```127.0.0.1``` row
     ``` 127.0.0.1 testapp1.lan testapp2.lan testapp3.lan application1.lan ```
   - Edit the ./Caddyfile (using ```sudo vi```) adding the section for the dummy hostname ```application1.lan``` copying one of the examles method already present in the file, for instance
     ```
     application1.lan {
        tls internal
        log {
        output file /var/log/caddy/caddy.log
        }
        reverse_proxy  <https or http>://<real internal fqdn or IP of the application>:<port> {
           transport http {
               tls
               tls_insecure_skip_verify
           }
           header_up Host <FQDN without "https" of the NPA Browser Access Public host coped from the UI>
        }
     }
     ```
   - Restart the Publisher (for the hosts file to be replicated on the Publisher Container and for Caddy to take the cnanges)
   - Verify that on the NPA Applications UI after a while the ```Reachibility via Publisher``` for the Application shows a green mark for all the Publishers
   - Test the Application access whether using the Public Host URL or via the Netskope NPA Portal
