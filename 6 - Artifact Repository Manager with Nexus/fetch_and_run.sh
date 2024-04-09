#!/bin/bash

set -x

# Check if the required arguments are provided
if [ $# -ne 3 ]; then
  echo "Usage: $0 <nexus-ip> <node-repo> <bearer-token>"
  exit 1
fi

# Set variables from command-line arguments
NEXUS_IP="$1"
NEXUS_REPO="$2"
BEARER_TOKEN="$3"

# Function to check if Node.js, npm, and jq are installed
check_dependencies() {
  if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
    echo "Node.js and/or npm are not installed. Installing..."
    # Install NVM (Node Version Manager)
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    # Load NVM
    source ~/.bashrc
    # Install the latest LTS version of Node.js
    nvm install --lts
  else
    echo "Node.js and npm are already installed."
  fi

  if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing..."
    sudo apt install -y jq
  else
    echo "jq is already installed."
  fi
}

# Function to fetch the download URL of the latest artifact
fetch_download_url() {
  echo "Fetching download URL for the latest artifact..."
  response=$(curl -s -H "Authorization: Bearer $BEARER_TOKEN" -X GET "http://$NEXUS_IP:8081/service/rest/v1/components?repository=$NEXUS_REPO&sort=version")
  if [ $? -ne 0 ]; then
    echo "Failed to fetch the download URL. Please check the Nexus IP, repository name, and bearer token."
    exit 1
  fi
  echo "$response" > artifact.json
  ARTIFACT_DOWNLOAD_URL=$(jq -r '.items[].assets[].downloadUrl' artifact.json)
  rm artifact.json
  echo "Download URL: $ARTIFACT_DOWNLOAD_URL"
}

download_artifact() {
  echo "Downloading the latest artifact..."
  output=$(curl -s -H "Authorization: Bearer $BEARER_TOKEN" -L -O "$ARTIFACT_DOWNLOAD_URL" 2>&1)
  if [ $? -eq 0 ]; then
    ARTIFACT_FILENAME=$(basename "$ARTIFACT_DOWNLOAD_URL")
    echo "Artifact downloaded: $ARTIFACT_FILENAME"
  else
    echo "Failed to download the artifact. Output: $output"
    exit 1
  fi
}

# Function to extract the artifact
extract_artifact() {
  if [ -f "$ARTIFACT_FILENAME" ]; then
    echo "Extracting the artifact..."
    tar -xzf "$ARTIFACT_FILENAME"
    rm "$ARTIFACT_FILENAME"
    
    # Find the extracted directory containing the package.json file
    APP_DIRECTORY=$(find . -maxdepth 2 -type f -name "package.json" -printf "%h\n" | head -n 1)
    
  if [ -z "$APP_DIRECTORY" ]; then
        echo "Extracted directory not found. Exiting..."
        exit 1
    else
        echo "Extracted directory: $APP_DIRECTORY"
    fi
  else
      echo "Artifact file not found. Skipping extraction..."
  fi
}

# Function to run the NodeJS app
run_app() {
  if [ -d "$APP_DIRECTORY" ]; then
    echo "Running the Node.js app..."
    cd "$APP_DIRECTORY"
    if [ -f "package.json" ]; then
      echo "Installing dependencies..."
      npm_install_output=$(npm install 2>&1)
      if [ $? -ne 0 ]; then
        echo "Failed to install dependencies. Output: $npm_install_output"
        exit 1
      fi
      echo "Starting the app..."
      npm_start_output=$(npm start 2>&1 &)
      if [ $? -ne 0 ]; then
        echo "Failed to start the app. Output: $npm_start_output"
        exit 1
      fi
      echo "App started successfully."
    else
      echo "package.json file not found. Skipping npm commands..."
    fi
  else
    echo "App directory not found. Skipping running the app..."
  fi
}

# Main script
check_dependencies
fetch_download_url
download_artifact
extract_artifact
run_app