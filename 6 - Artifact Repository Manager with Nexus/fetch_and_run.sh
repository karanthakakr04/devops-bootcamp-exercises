#!/bin/bash

# Set variables
NEXUS_IP="<nexus-ip>"
NEXUS_REPO="<node-repo>"
BEARER_TOKEN="<bearer-token>"

# Function to check if Node.js and npm are installed
check_node_npm() {
  if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
    echo "Node.js and/or npm are not installed. Installing..."
    curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
    sudo apt-get install -y nodejs
  fi
}

# Function to fetch the download URL of the latest artifact
fetch_download_url() {
  echo "Fetching download URL for the latest artifact..."
  curl -s -H "Authorization: Bearer $BEARER_TOKEN" -X GET "http://$NEXUS_IP:8081/service/rest/v1/components?repository=$NEXUS_REPO&sort=version" | jq "." > artifact.json
  ARTIFACT_DOWNLOAD_URL=$(jq -r '.items[].assets[].downloadUrl' artifact.json)
  rm artifact.json
}

# Function to download the artifact
download_artifact() {
  echo "Downloading the latest artifact..."
  curl -s -H "Authorization: Bearer $BEARER_TOKEN" -L -O "$ARTIFACT_DOWNLOAD_URL"
  ARTIFACT_FILENAME=$(basename "$ARTIFACT_DOWNLOAD_URL")
}

# Function to extract the artifact
extract_artifact() {
  echo "Extracting the artifact..."
  tar -xzf "$ARTIFACT_FILENAME"
  rm "$ARTIFACT_FILENAME"
  APP_DIRECTORY=$(find . -maxdepth 1 -type d ! -name . | head -n 1)
}

# Function to run the NodeJS app
run_app() {
  echo "Running the NodeJS app..."
  cd "$APP_DIRECTORY"
  npm install
  npm start
}

# Main script
check_node_npm
fetch_download_url
download_artifact
extract_artifact
run_app