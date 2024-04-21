# TASK BREAKDOWN

## Prerequisites

### Install or Check Docker on the Remote Server

- [ ] Task 1: Install Docker (if not already installed)
  - **Check if Docker is installed:**
    - SSH into the remote server.
    - Run the following command to check if Docker is already installed:

      ```bash
      docker --version
      ```

    - If Docker is installed, the command will display the Docker version. Proceed to Task 2.
    - If Docker is not installed, continue with the installation steps.

  - **Set up Docker's apt repository:**
    - Add Docker's official GPG key:

      ```bash
      sudo apt update
      sudo apt install ca-certificates curl
      sudo install -m 0755 -d /etc/apt/keyrings
      sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
      sudo chmod a+r /etc/apt/keyrings/docker.asc
      ```

    - Add the repository to Apt sources:

      ```bash
      echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      ```

  - **Update the package lists:**
    - Run the following command to update the package lists:

      ```bash
      sudo apt update
      ```

  - **Install Docker:**
    - Run the following command to install the latest version of Docker:

      ```bash
      sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      ```

- [ ] Task 2: Check the Docker version (if already installed)
  - **Check the Docker version:**
    - SSH into the remote server.
    - Run the following command to check the Docker version:

      ```bash
      docker --version
      ```

    - The command will display the installed Docker version.
    - Ensure that you have a compatible Docker version installed (e.g., Docker 20.10 or later).

### Option 1: Run Jenkins as a Docker Container

- [ ] Task 1: Run Jenkins as a Docker container
  - **Start the Jenkins container:**
    - Run the following command on the remote server to start a Jenkins container:

      ```bash
      docker run -p 8080:8080 -p 50000:50000 -d -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts-jdk17
      ```

    - This command starts a Jenkins container with the following configurations:
      - Maps the container's port 8080 to the host's port 8080 for accessing the Jenkins web interface.
      - Maps the container's port 50000 to the host's port 50000 for Jenkins agent communication.
  - **Understand the purpose of port 50000:**
    - Port 50000 is used for communication between the Jenkins master and Jenkins slaves (agents or worker nodes) in a Jenkins cluster setup.
    - When you have a Jenkins master and one or more slaves, the slaves use port 50000 to establish a connection with the master.
    - The communication over port 50000 includes:
      - Sending build jobs from the master to the slaves for execution.
      - Receiving build results and status updates from the slaves back to the master.
      - Exchanging other relevant information and commands between the master and slaves.
    - By mapping port 50000 from the container to the host, you allow the Jenkins master inside the container to communicate with any separately set up Jenkins slaves.
  - **Other container configurations:**
    - Runs the container in detached mode (`-d`).
    - Mounts a volume named `jenkins_home` to persist Jenkins data.
    - Uses the `jenkins/jenkins:lts-jdk17` image, which includes Jenkins with JDK 17.

### Option 2: Install Jenkins Locally on the Remote Server

- [ ] Task 1: Clone the repository and copy the installation script
  - **Clone the repository:**
    - Open a terminal on your local machine.
    - Run the following command to clone this repository containing the `install_jenkins.sh` script:

      ```bash
      git clone <repository-url>
      ```

    - Replace `<repository-url>` with the actual URL of this repository.
  - **Copy the installation script to the remote server:**
    - Use the `scp` command to securely copy the `install_jenkins.sh` script from your local machine to the remote server:

      ```bash
      scp path/to/install_jenkins.sh <username>@<remote-server-ip>:/path/on/remote/server
      ```

    - Replace `path/to/install_jenkins.sh` with the actual path to the script on your local machine.
    - Replace `<username>` with your username on the remote server.
    - Replace `<remote-server-ip>` with the IP address or hostname of the remote server.
    - Replace `/path/on/remote/server` with the desired destination path on the remote server.

- [ ] Task 2: Use the provided script to install Jenkins locally
  - **Make the script executable:**
    - SSH into the remote server.
    - Navigate to the directory where you copied the `install_jenkins.sh` script.
    - Make the script executable by running:

      ```bash
      chmod +x install_jenkins.sh
      ```

  - **Execute the installation script:**
    - Execute the script with sudo privileges:

      ```bash
      sudo ./install_jenkins.sh
      ```

    - The script will perform the following steps:
      - Update the system and install necessary dependencies.
      - Install Java 17.
      - Add the Jenkins repository.
      - Install Jenkins.
      - Start the Jenkins service.

## Exercise 1: Dockerize your NodeJS App

- [ ] Task 1: Configure your NodeJS application to be built as a Docker image
  - **Create a Dockerfile:**
    - Create a `Dockerfile` in the root directory of your NodeJS application.
    - Add the necessary instructions to the `Dockerfile` to build your application as a Docker image.
    - Example `Dockerfile`:

      ```Dockerfile
      # Use an official Node.js runtime as a parent image
      FROM node:14

      # Set the working directory to /app
      WORKDIR /app

      # Copy package.json and package-lock.json to the working directory
      COPY package*.json ./

      # Install dependencies
      RUN npm install

      # Copy the rest of the application code
      COPY . .

      # Expose the port on which the app will run
      EXPOSE 3000

      # Define the command to run the app
      CMD ["npm", "start"]
      ```

    - Customize the `Dockerfile` based on your application's requirements.

- [ ] Task 2: Build the Docker image
  - **Navigate to the Dockerfile directory:**
    - Open a terminal and navigate to the directory containing the `Dockerfile`.
  - **Build the Docker image:**
    - Run the following command to build the Docker image:

      ```bash
      docker build -t your-app-name:v1 .
      ```

    - Replace `your-app-name` with a suitable name for your application.

- [ ] Task 3: Test the Docker image
  - **Start a container from the built image:**
    - Run the following command to start a container from the built image:

      ```bash
      docker run -p 3000:3000 your-app-name:v1
      ```

  - **Access the application:**
    - Access your application by opening a web browser and visiting `http://localhost:3000`.
    - Verify that your application is running correctly inside the Docker container.
