#!/bin/bash
# Traefik Cert Dumper Install
docker compose -f cert-dumper/docker-compose.yml up -d
sleep 30

#Installs DDNS container to add DNS entries into Cloudflare
sb install ddns

# Get the domain, username, and password from the accounts.yml file
domain=$(awk '$1=="user:" {getline; while ($1!="domain:") {getline}; print $2}' /srv/git/saltbox/accounts.yml)
username=$(awk '$1=="user:" {getline; while ($1!="name:") {getline}; print $2}' /srv/git/saltbox/accounts.yml)
password=$(awk '/^user:/ {p=1} p && /^  pass:/ {print $2; exit}' /srv/git/saltbox/accounts.yml)

# Check if the domain, username, or password is empty
if [ -z "$domain" ] || [ -z "$username" ] || [ -z "$password" ]; then
    echo "Domain, username, or password not found in accounts.yml"
    exit 1
fi

# Update values in tactical-rmm .env file
sed -i "s/yourdomain.com/$domain/g" tactical-rmm/.env
sed -i "s/username/$username/g" tactical-rmm/.env
sed -i "s/password/$password/g" tactical-rmm/.env

# Update values in cert.sh file
sed -i "s/yourdomain.com/$domain/g" cert-dumper/cert.sh

# Update values in certsync docker compose file
sed -i "s/yourdomain.com/$domain/g" certsync/docker-compose.yml

echo "Updated values:"
cat tactical-rmm/.env
cat cert-dumper/cert.sh

# Copies Traefik rules over for sub domain forwarding with nginx
cp traefik/rmm.yml /opt/traefik/
sed -i "s/yourdomain.com/$domain/g" /opt/traefik/rmm.yml

# Updates .env file with exported cert information
sh cert-dumper/cert.sh

# Tactical-rmm docker compose install
docker compose -f tactical-rmm/docker-compose.yml up -d
sleep 40

# Updates mesh_data config.json file domain entries
dashdomain="dash.${domain}"
sed -i "s/172.50.0.200/$dashdomain/g" /opt/tactical-rmm/mesh_data/config.json

# Fix Permissions
sudo chown -R $username:$username /opt/tactical-rmm/
sudo chmod 755 -R /opt/tactical-rmm/

# Updates Mesh_data config.json file port number
sed -i 's/:4443\b/:443/g' "/opt/tactical-rmm/mesh_data/config.json"

# Creates CertSync container to update nginx certificates.
docker compose -f certsync/docker-compose.yml up -d

# Creates a cron job to run the container everyday at 2am
# The cron job command
cron_job="0 2 * * * /bin/bash -c 'container_id=\$(docker ps -aqf \"label=certsync=true\" --filter \"status=exited\"); if [ -n \"\$container_id\" ]; then docker start \$container_id; fi'"

# Add the cron job to the crontab
(crontab -l 2>/dev/null; echo "$cron_job") | crontab -

# Restarts mesh central container
docker restart trmm-meshcentral

# Function to add tactical_update function to .bashrc
add_tactical_update_to_bashrc() {
    local BASHRC_FILE="/home/$username/.bashrc"

    # Check if the .bashrc file exists for the user
    if [ ! -f "$BASHRC_FILE" ]; then
        echo ".bashrc file not found for user $username"
        return 1
    fi

    # Check if the function already exists in .bashrc
    if grep -q "tactical_update()" "$BASHRC_FILE"; then
        echo "tactical_update function already exists in .bashrc"
        return 0
    fi

    # Append the tactical_update function to .bashrc
    cat <<'EOF' >> "$BASHRC_FILE"

# Tactical updates #
tactical_update() {
    local DIR="/opt/tacticalrmm/tactical-rmm-saltbox/tactical-rmm"

    # Check if the directory exists, if not create it
    if [ ! -d "$DIR" ]; then
        echo "Directory not found! Creating directory..."
        sudo mkdir -p "$DIR" || { echo "Failed to create directory"; return 1; }
    fi

    cd "$DIR" || { echo "Failed to navigate to directory"; return 1; }

    # Check if docker-compose.yml exists before attempting to move it
    if [ -f docker-compose.yml ]; then
        sudo mv docker-compose.yml docker-compose.yml.old || { echo "Failed to move docker-compose.yml"; return 1; }
    else
        echo "docker-compose.yml not found!"
    fi

    # Download the correct docker-compose.yml file
    sudo wget https://raw.githubusercontent.com/falco1717/tactical-rmm-saltbox/main/tactical-rmm/docker-compose.yml -O docker-compose.yml || { echo "Failed to download docker-compose.yml"; return 1; }

    # Pull the latest Docker images
    sudo docker compose pull || { echo "docker compose pull failed"; return 1; }

    # Shut down the current Docker containers
    sudo docker compose down || { echo "docker compose down failed"; return 1; }

    # Start the new Docker containers and remove orphan containers
    sudo docker compose up -d --remove-orphans || { echo "docker compose up failed"; return 1; }
}
EOF

    echo "Added tactical_update function to $BASHRC_FILE"
}

# Call the function to add tactical_update to .bashrc
add_tactical_update_to_bashrc

# Generate a random key for rustdesk
RANDOM_KEY=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20)

# Write the random key to .env file
echo "SECRET_KEY=$RANDOM_KEY" > rustdesk/.env

#Install rustdesk Containers
docker compose -f rustdesk/docker-compose.yml up -d

