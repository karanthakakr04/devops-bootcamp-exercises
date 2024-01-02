#!/bin/bash

SERVICE_ACCOUNT_USER=myapp

# Install NodeJS and NPM using apt-get
sudo apt update
sudo apt install nodejs npm

# Get the log directory from the parameter input
LOG_DIRECTORY=$1

# Check if the log directory exists or not
if [ -d "$LOG_DIRECTORY" ]; then
  # Log directory exists
  echo "Log directory $LOG_DIRECTORY already exists."
else
  # Log directory does not exist
  echo "Log directory $LOG_DIRECTORY does not exist. Creating it now."
  # Create the log directory
  mkdir -p $LOG_DIRECTORY
fi

# Print the installed versions
echo "NodeJS version: $(node -v)"
echo "NPM version: $(npm -v)"

# Create myapp user 
sudo adduser --system --create-home $SERVICE_ACCOUNT_USER

# Set ownership of the log directory to myapp user
sudo chown -R $SERVICE_ACCOUNT_USER $LOG_DIRECTORY

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

# Set the LOG_DIR environment variable to the absolute path of the log directory
export LOG_DIR=$(realpath $LOG_DIRECTORY)

# Run the NodeJS application in the background
npm install
node server.js &

# Get the process ID of the NodeJS application
pid=$!

# Wait for a few seconds to let the application start
sleep 5

# Check if the process is still running
if ps -p $pid > /dev/null; then
  # Process is running
  echo "Node app is running with PID: $pid"
  # Get the port number from the server.js file
  port=$(grep -oP 'app.listen\(\K\d+' server.js)
  # Print the port number
  echo "Node app is listening on port: $port"
else
  # Process is not running
  echo "Node app is not running. Please check the logs for errors."
fi
