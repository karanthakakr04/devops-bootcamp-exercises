#!/bin/bash

# Install NodeJS and NPM using apt-get
sudo apt-get update
sudo apt-get install nodejs npm

# Print the installed versions
echo "NodeJS version: $(node -v)"
echo "NPM version: $(npm -v)"

# Download the artifact file using curl
curl -O https://node-envvars-artifact.s3.eu-west-2.amazonaws.com/bootcamp-node-envvars-project-1.0.0.tgz

# Unzip the downloaded file
tar -xvzf bootcamp-node-envvars-project-1.0.0.tgz

# Set the environment variables
export APP_ENV=dev
export DB_USER=myuser
export DB_PWD=mysecret

# Change into the unzipped package directory
cd bootcamp-node-envvars-project

# Run the NodeJS application in the background
npm install
node server.js &
