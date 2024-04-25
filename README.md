# Tactical-RMM for Saltbox
This script will install tactical-rmm and utilize the certs already created by Traefik and pass the traffic over to nginx.

# Install
Run the install.sh file 

```Sudo Bash install.sh```

The script will then create the cert dumper container and start converting the acme.json located at /opt/treafik/acme.json

upon converting the certs it will wait for 30 seconds to ensure the files are generated and then copy the domain cert data to the .env file

The script will then grab the domain, username, and password for your system from /srv/git/saltbox/accounts.yml

Finally the Tactical-RMM docker containers will be built out.

another container called certsync will be created with a cron job to start it at 2am everyday to ensure that the ssl certs are updated in nginx.

Once the containers are built it will update the mesh-central config file and restart the container.

# Linux Agents
By default the linux agents require you to pay for code-signing but thanks to Netvolt's script you can add linux agents without code signing. 
https://github.com/netvolt/LinuxRMM-Script

# Download Script
```wget https://raw.githubusercontent.com/falco1717/tactical-rmm-saltbox/main/linux-agent/rmmagent-linux.sh```


# Install Agent
To install agent launch the script with this arguement:

```./rmmagent-linux.sh install 'System type' 'Mesh agent' 'API URL' 'Client ID' 'Site ID' 'Auth Key' 'Agent Type'```

The compiling can be quite long, don't panic and wait few minutes... USE THE 'SINGLE QUOTES' IN ALL FIELDS!

The arguments are:

1. System type

  Type of system. Can be 'amd64' 'x86' 'arm64' 'armv6'  

2. Mesh agent

  The url given by mesh for installing new agent.
  Go to mesh.fqdn.com > Add agent > Installation Executable Linux / BSD / macOS > **Select the good system type**
  Copy **ONLY** the URL with the quote.
  
3. API URL

  Your api URL for agent communication usually https://api.yourdomain.com.
  
4. Client ID

  The ID of the client in wich agent will be added.
  Can be view by hovering the name of the client in the dashboard.
  
5. Site ID

  The ID of the site in wich agent will be added.
  Can be view by hovering the name of the site in the dashboard.
  
6. Auth Key

  Authentification key given by dashboard by going to dashboard > Agents > Install agent (Windows) > Select manual and show
  Copy **ONLY** the key after *--auth*.
  
7. Agent Type

  Can be *server* or *workstation* and define the type of agent.
  
# Example
```./rmmagent-linux.sh install 'System type' 'Mesh agent' 'API URL' 'Client ID' 'Site ID' 'Auth Key' 'Agent Type'```
