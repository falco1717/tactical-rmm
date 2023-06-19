#!/bin/bash
# Traefik Cert Dumper Install
docker compose -f cert-dumper/docker-compose.yml up -d
sleep 30

# user input to update domain names in tactical-rmm .env file and cert.sh
echo "input needed for domain customization, please include full domain. example yourdomain.com"
read -p "Enter your domain name: " domain
sed -i "s/yourdomain.com/$domain/g" tactical-rmm/.env
sed -i "s/yourdomain.com/$domain/g" cert-dumper/cert.sh
echo "Updated values:"
cat tactical-rmm/.env
cat cert-dumper/cert.sh

# Copies Traefik rules ovwr for sub domain forwarding with nginx
cp traefik/rmm.yml /opt/traefik/
sed -i "s/yourdomain.com/$domain/g" /opt/traefik/rmm.yml

# Updates .env fike with exported cert information
sh cert-dumper/cert.sh

# User input to update username in tactical-rmm .env file
read -p "Enter your username: " username
sed -i "s/username/$username/g" tactical-rmm/.env
echo "Updated values:"
cat tactical-rmm/.env

# User input to uodate password in tactical-rmm .env file
read -p "Enter your password: " password
sed -i "s/password/$password/g" tactical-rmm/.env
echo "Updated values:"
cat tactical-rmm/.env

# Tactical-rmm docker compose install
docker compose -f tactical-rmm/docker-compose.yml up -d 
sleep 40

# Updates mesh_data config.json file domain entries
dashdomain="dash.${domain}"
sed -i "s/172.50.0.200/$dashdomain/g" /opt/tactical-rmm/mesh_data/config.json

# Updates Mesh_data config.json file port number
sed -i 's/:4443\b/:443/g' "/opt/tactical-rmm/mesh_data/config.json"

# Restarts mesh central containee
docker restart trmm-meshcentral
