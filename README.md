# Tactical-RMM for Saltbox
This script will install tactical-rmm and utilize the certs already created by Traefik and pass the traffic over to nginx.

# Install
Run the install.sh file 

```Sudo Bash install.sh```

The script will then create the cert dumper container and start converting the acme.json located at /opt/treafik/acme.json

upon converting the certs it will wait for 30 seconds to ensure the files are generated and then copy the domain cert data to the .env file

User input will taken for domain name, username, and password entries inside the .env file

Finally the Tactical-RMM docker containers will be built out.

Once the containers are built it will update the mesh-central config file and restart the container.

