# Publisher-BA-Caddy
This repo contains instruction on how to deploy Caddy on a Publisher to manage NPA Browser Applications that require custom URI and Redirections

# Disclaimer
This workaround must be considered "as is" and it's not directly supported by Netskope Technical Support. We are planning to have a "Community" type of support, and all the experience collected using this workaround will be used to implement the needed changes to the NPA Browser Access reverse proxy in the backend in future versions.
The workaround revolves on the use of Caddy as a reverse proxy to perform some basic Headers rewriting, Headers insertions and Redirections to specific URIs.
The basic configurations provided should be enough to publish many Web Applications that otherwise can't be publisheed via Browser Access, but some Applications that may require much deeper Rewriting may still not work.

# WARNING
Caddy can perform many reverse_proxy operations, but it's unable to rewrite the content of the HTML payload. It can only perform rewriting on Headers. Applications that require complex rewriting inside the HTLM code can't be published using this workaround too.

# Prerequisites
- A Netskope Publisher deployed and registered
- Console/SSH access to the Netskope Publisher
- The Netskope Publisher has access to the internal applications in terms of DNS resolutions and/or IP/Port access

# Notes on scalability and redundancy
While we couldn't perform stress tests on the Publisher with the Caddy workaround enabled, there are plenty of performance tests towards Caddy publicly accessible.
From the publicly available documentation of Caddy scalability, Caddy should be able to serve tens of thousands of connections simultaneously. The more connections the more CPU and RAM required.
For this reason we recommend:
- To deploy and configure at least one separate Publisher to serve the internal applications via the Caddy workaround
- To deploy and configure multiple Publishers with the same Caddy configuration for redundancy and scalability purposes
- To monitor CPU and RAM consumption after implementing the workaround, and crate new Publisher instances if the CUP/RAM consumption of the Publishers using the workaround increase too much

This workaround is designed to be easily deployed in multiple Publishers, using the exact same configuration in all of them, and associate all those Publishers to the same NPA Browser Application served via the workaround, so, due to the native round-robin Publisher selection in NPA Browser Access, we can share the load among several Publishers with Caddy with a minimal configuration.

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
- If the direct Application is completely unreachible on the root it can be that the Application must be accessed via a specific URI, and on the root path there is no redirection to that URI. In this case you must check with the application administrators what is the correct URI we should point to, and then configure the Application in Caddy to use method 1
- If the direct Application responds with a Redirect (30x) to itself in a different URI consider using the method 2
- It is possible that we must use method 1 + 2 (both redirection AND Host header) in some Applications
- If the Application is on HTTP and it perfroms redirections we must consider Method 3, which is based on method 2, but it must also rewrite the schema in this case
- Some Applications may be more complex to configure, such as the one described on Method 4
- Once chosen a method configure it and test it, analysing the HAR to identify further possible issues

# Example
In this example I'm showing how I can publish a local Splunk using NPA Browser Access and Caddy, where Splunk UI heavily relies on 30x redirections:

https://github.com/user-attachments/assets/8e093cc6-0e8e-46a2-9288-adbc3595370a

