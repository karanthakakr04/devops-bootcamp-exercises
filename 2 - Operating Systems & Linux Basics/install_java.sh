#!/bin/bash

# Define the available versions
version_17="openjdk-17-jdk"
version_21="openjdk-21-jdk"

# Get the user's choice
echo "Which version of Java do you want to install? (17/21)"
read choice

# Check the choice and set the package name accordingly
if [[ "$choice" = "17" ]]; then
  package=$version_17
elif [[ "$choice" = "21" ]]; then
  package=$version_21
else
  echo "Invalid input. Installing version 21 by default."
  package=$version_21
fi

# Install the package using apt-get
sudo apt update
sudo apt install -y $package

# Check the java version
  java -version

# Check the installation status
if [ $? -eq 0 ]; then
  # Java is installed
  echo "Java is installed."
  # Get the major version number
  version=$(java -version 2>&1 | head -n 1 | cut -d '"' -f 2 | cut -d '.' -f 1)
  # Check if the version is lower than 11
  if [ $version -lt 11 ]; then
    # Older version is installed
    echo "However, you have an older version of Java: $version. You need to update to version 11 or higher."
  else
    # Version 11 or higher is installed
    echo "You have the desired version of Java: $version. Installation was successful."
  fi
else
  # Java is not installed
  echo "Java is not installed. Please check the package name and the internet connection."
fi
