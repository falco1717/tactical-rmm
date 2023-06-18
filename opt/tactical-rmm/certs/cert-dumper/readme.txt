# Repleace **yourdomain.com.crt** and key with your domain. Example google.com.crt
echo "CERT_PUB_KEY=$(sudo base64 -w 0 /opt/tactical-rmm/certs/certs/**yourdomain.com.crt**)" >> /opt/tacticalrmm/.env
echo "CERT_PRIV_KEY=$(sudo base64 -w 0 /opt/tactical-rmm/certs/private/**yourdomain.com.key**)" >> /opt/tacticalrmm/.env
