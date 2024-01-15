# TASK BREAK DOWN

## Exercise 1

- [] Task 1: Steps to Install Nexus Repository Manager on Ubuntu 22.04 LTS
  - **Prerequisites:**
    - Ensure you have a clean Ubuntu 22.04 LTS server with sufficient resources (CPU, memory, disk space).
    - Install Java 8, as Nexus Repository Manager recommends Java 8 for compatibility.
      - `sudo apt update`
      - `sudo apt upgrade -y`
      - `sudo apt install openjdk-8-jdk`
    - Verify Java installation:
      - `java -version`
  - **Download Nexus Repository Manager:**
    - Visit the [Sonatype Nexus Download Page](https://help.sonatype.com/repomanager3/product-information/download) to find the link to the latest Nexus Repository Manager.
    - Copy the Unix archive download link for the latest version.
  - **Download and Extract:**
    - On your Ubuntu server, use `wget` or `curl` to download the Nexus tar.gz file. For example:
      - `wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz`
      - > Before using `wget`, make sure you are in the `/opt` directory.
    - Extract the downloaded archive:
      - `tar -xvzf latest-unix.tar.gz`
  - **Configure Nexus as a Service:**
    - Create a user for Nexus:
      - `sudo adduser --system --home=/opt/nexus --no-create-home --disabled-login --disabled-password --group nexus`
    - Ensure the Nexus user has the appropriate permissions:
      - `sudo chown -R nexus:nexus /opt/nexus`

## Exercise 2

## Exercise 3

## Exercise 4

## Exercise 5

## Exercise 6

## Exercise 7

## Exercise 8

## Exercise 9
