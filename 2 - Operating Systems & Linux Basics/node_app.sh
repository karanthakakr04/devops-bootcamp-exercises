#!/bin/bash

SERVICE_ACCOUNT_USER=myapp

# Update and upgrade packages, then install nodejs, npm, curl, and net-tools as a superuser
echo "Installing Node.js..."
sudo apt update && sudo apt upgrade -y; sudo apt install -y nodejs npm curl net-tools

echo -e "\n\n"

# Print the installed versions
echo "NodeJS version: $(node -v)"Y
echo "NPM version: $(npm -v)"

echo -e "\n\n"

# Get the log directory from the parameter input
LOG_DIRECTORY=$1

# Check if the log directory exists or not
if [ -d "$LOG_DIRECTORY" ]; then
  # Log directory exists
  echo "Log directory $LOG_DIRECTORY already exists."
else
  # Log directory does not exist
  echo "Log directory $LOG_DIRECTORY does not exist. Creating it now..."
  # Create the log directory
  mkdir -p $LOG_DIRECTORY
fi

echo -e "\n\n"

# Create myapp user 
echo "Creating 'myapp' user..."
sudo useradd -m -s /bin/bash $SERVICE_ACCOUNT_USER
# disable password for this user
sudo passwd -d $SERVICE_ACCOUNT_USER

echo -e "\n\n"

# Changing ownership of the log directory to $SERVICE_ACCOUNT_USER
echo "Setting permissions..."
sudo chown -R $SERVICE_ACCOUNT_USER "$LOG_DIRECTORY"

echo -e "\n\n"

# Switch to application user 
echo "Switching to 'myapp' user..."
su - myapp

echo -e "\n\n"

# Download the artifact file using curl
echo "Downloading application code..."
curl -L -O https://node-envvars-artifact.s3.eu-west-2.amazonaws.com/bootcamp-node-envvars-project-1.0.0.tgz

echo -e "\n\n"

# Create a directory to store app files
mkdir -p myproject

# Extract and decompress the project files into the myproject directory
echo "Extracting project files..."
tar -xvzpf bootcamp-node-envvars-project-1.0.0.tgz -C ~/myproject

echo -e "\n\n"

# Set the environment variables
export APP_ENV=dev
export DB_USER=myuser
export DB_PWD=mysecret

# Set the LOG_DIR environment variable to the absolute path of the log directory
export LOG_DIR=$(realpath "$LOG_DIRECTORY")

echo -e "\n\n"

# Change into the unzipped package directory
cd myproject

echo -e "\n\n"

# Install dependencies
echo "Installing node modules..."
npm install

echo -e "\n\n"

# Start application in background 
echo "Starting application..."
node server.js &

echo -e "\n\n"

# Get the process ID of the NodeJS application
pid=$!

# Wait for a few seconds to let the application start
echo "Waiting for application to start..."
sleep 10

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

# Log out from myapp user
exit
