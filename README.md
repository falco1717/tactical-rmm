# tactical-rmm
Tactical-rmm docker with traefik

# Cert Dumper
Run the cert dumper docker compose file first.
After running the cert dumper container run the following commands.

Replace **yourdomain.com.crt** and key with your domain. Example google.com.crt

`echo "CERT_PUB_KEY=$(sudo base64 -w 0 /opt/tactical-rmm/certs/certs/**yourdomain.com.crt**)" >> /opt/tacticalrmm/.env`

echo "CERT_PRIV_KEY=$(sudo base64 -w 0 /opt/tactical-rmm/certs/private/**yourdomain.com.key**)" >> /opt/tacticalrmm/.env

# Tactical-RMM Compose
Once you verify the .env file has your certs then you are good to start editing the tactical-rmm .env file.
You need to edit the username and passwords located in the .env file.
After you edit the username and passwords you will need to run the traefik cert dumper container and the echo commands to add the cert keys to the .env file.

After running the main docker-compose.yml you need to edit the mesh_data config.json
"tlsOffload": "dash.yourdomain.com",
"certUrl": "https://dash.yourdomain.com:443",

Restart the trmm-meshcentral container and you are good to go.
