#!/bin/bash

SERVICE_ACCOUNT_USER=myapp

# Update and upgrade packages, then install nodejs, npm, curl, and net-tools as a superuser
echo "Installing Node.js..."
sudo apt update && sudo apt upgrade -y; sudo apt install -y nodejs npm curl net-tools

echo -e "\n"

# Print the installed versions
echo "NodeJS version: $(node -v)"Y
echo "NPM version: $(npm -v)"

echo -e "\n"

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

echo -e "\n"

# Create myapp user 
echo "Creating 'myapp' user..."
sudo useradd -m -s /bin/bash $SERVICE_ACCOUNT_USER
# disable password for this user
sudo passwd -d $SERVICE_ACCOUNT_USER

echo -e "\n"

# Changing ownership of the log directory to $SERVICE_ACCOUNT_USER
echo "Setting permissions..."
sudo chown -R $SERVICE_ACCOUNT_USER "$LOG_DIRECTORY"

echo -e "\n"

# Download the artifact file using curl
echo "Downloading application code..."
sudo su - $SERVICE_ACCOUNT_USER -c "curl -L -O https://node-envvars-artifact.s3.eu-west-2.amazonaws.com/bootcamp-node-envvars-project-1.0.0.tgz"

echo -e "\n"

# Extract and decompress the project files into the myproject directory
echo "Extracting project files..."
sudo su - $SERVICE_ACCOUNT_USER -c "tar -xvzf ./bootcamp-node-envvars-project-1.0.0.tgz"

echo -e "\n"

# Set the environment variables and change into the unzipped package directory
sudo su - $SERVICE_ACCOUNT_USER -c "
  export APP_ENV=dev &&
  export DB_USER=myuser &&
  export DB_PWD=mysecret &&
  export LOG_DIR=$(realpath "$LOG_DIRECTORY") &&
  cd package && 
  npm install && 
  node server.js &"

echo -e "\n"

# Verify app is running as myapp user  
sudo netstat -lnpt | grep node
