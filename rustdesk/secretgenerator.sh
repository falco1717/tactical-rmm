#!/bin/bash

# Generate a random key
RANDOM_KEY=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20)

# Write the random key to .env file
echo "SECRET_KEY=$RANDOM_KEY" > .env
