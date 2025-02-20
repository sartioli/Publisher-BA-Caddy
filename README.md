# Publisher-BA-Caddy
This repo contains instruction on how to deploy Caddy on a Publisher to manage Browser Applications that require custom URI and Redirections

# Disclaimer
This workaround must be considered "as is" and it's not directly supported by Netskope Technical Support.
The workaround revolves on the use of Caddy as a reverse proxy to perform some basic URL rewriting, Headers insertions and redirections.
The basic configurations provided should be enough to publish many Web Applications that otherwise can't be publisheed via Browser Access, but some Applications that may require much deeper Rewriting may still not work.

# Prerequisites
- A Netskope Publisher deployed
- The Netskope Publisher has access to the applications in terms of DNS resolutions and/or IP/Port access

# Installation
In order to deploy the Caddy container:
1) Exit the Publisher Wizard (generally key 7)
2) Run the following commands:
```
curl -L https://github.com/sartioli/Publisher-BA-Caddy/raw/refs/heads/main/caddy-deployment.sh -o $(eval echo ~$SUDO_USER)/caddy-deployment.sh
sudo chmod 777 $(eval echo ~$SUDO_USER)/caddy-deployment.sh
sudo $(eval echo ~$SUDO_USER)/caddy-deployment.sh
```
3) Reboot the Publisher when asked

# Flow to create the Browser NPA Application and serve it via Caddy

In order to create a NPA Browser Application and serve it via Caddy:

1) Create a NPA Browser Application that points to a dummy FQDN, such as ```application1.lan``` for protocol HTTPS on port 443, and assign to it the Publisher(s) where Caddy is deployed (and optionally assign to it the relative labels)
2) On ALL the Publishers that serve the application do the fllowing:
   - Exit the NPA Publisher Wizard (generally key 7)
   - Edit the /etc/hosts file (using ```sudo vi```) to add the dummy hostname (for example ```application1.lan```) to the ```127.0.0.1``` row
     ``` 127.0.0.1 testapp1.lan testapp2.lan testapp3.lan application1.lan ```
   - Edit the ./Caddyfile (using ```sudo vi```) adding the section for the dummy hostname ```application1.lan``` copying one of the examles method already present in the file, for instance (replace the ```<>``` sections with the right data)
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
3) Verify that on the NPA Applications UI after a while the ```Reachibility via Publisher``` for the Application shows a green mark for all the Publishers
4) Test the Application access whether using the Public Host URL or via the Netskope NPA Portal

# How to know what Caddy method to use
If you don't know at all how the application works start creating a Browser App that points directly to the Application, and then inspect the HAR. for instance:
- If the direct Application is completely unreachible it can be that the Application must be accessed via a specific URI, and on the root path there is no redirection to that URI. In this case you must check with the application administrators what is the correct URI we should point to, and then configure the Application in Caddy to use method 1 or 2 (1 is simpler, but 2 is more robust)
- If the direct Application responds with a Redirect (30x) to itself in a different URI consider using the method 3
- It is possible that we must use method 2 + 3 (both redirection AND Host header) in some Applications
- Once chosen a method configure it and test it, analysing the HAR to identify further possible issues

# Example
In this example I'm showing how I can publish a local Splunk using NPA Browser Access and Caddy, where Splunk UI heavily relies on 30x redirections:

https://github.com/user-attachments/assets/8e093cc6-0e8e-46a2-9288-adbc3595370a

