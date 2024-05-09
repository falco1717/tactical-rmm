#!/bin/bash

# updates tactical-rmm.env file with cert info
echo "CERT_PUB_KEY=$(sudo base64 -w 0 /opt/tactical-rmm/certs/certs/yourdomain.com.crt)" >> tactical-rmm/.env
echo "CERT_PRIV_KEY=$(sudo base64 -w 0 /opt/tactical-rmm/certs/private/yourdomain.com.key)" >> tactical-rmm/.env
