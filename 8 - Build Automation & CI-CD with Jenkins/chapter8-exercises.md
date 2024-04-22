# TASK BREAKDOWN

## Prerequisites

### Option 1: Run Jenkins as a Docker Container

> [!NOTE]
> **After creating the droplet, ensure that you have a firewall rule configured to allow inbound traffic on port 22 (SSH) to enable SSH access to the remote server.**

- [x] Task 1: Install Docker (if not already installed)
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

    - Add the repository to `apt` sources:

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

- [x] Task 2: Run Jenkins as a Docker container
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

![Screenshot of Jenkins installation as a Docker container](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/49efa231-a4fb-4478-9465-1fef641ac406)

### Option 2: Install Jenkins Locally on the Remote Server

- [ ] Task 1: Clone the repository and copy the installation script
  - **Clone the repository:**
    - Open a terminal on your local machine.
    - Run the following command to clone the repository containing the `install_jenkins.sh` script:

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

## Additional Information: Jenkins Data Persistence

When setting up Jenkins, it's important to consider how the Jenkins data (configurations, plugins, jobs, etc.) is managed and persisted. The approach to data persistence differs when running Jenkins as a Docker container compared to installing it directly on the host machine.

### Running Jenkins as a Docker Container

When running Jenkins as a Docker container, it is recommended to use a Docker named volume (`-v jenkins_home:/var/jenkins_home`) to store the Jenkins data. This approach has several benefits:

1. **Data Persistence**: By mounting a named volume to the `/var/jenkins_home` directory inside the container, the Jenkins data persists even if the container is stopped, removed, or recreated. The data is stored on the host machine's filesystem, separate from the container's lifecycle.

2. **Easy Backup and Restore**: With a named volume, you can easily backup and restore the Jenkins data. You can use Docker commands to create a backup of the volume or copy the data to another location. This allows for quick recovery in case of any issues or when migrating to a different host.

3. **Separation of Concerns**: By using a named volume, you keep the Jenkins data separate from the container itself. This allows you to upgrade or replace the Jenkins container image without affecting the stored data. You can stop the container, pull a new Jenkins image version, and start a new container while still preserving the existing data.

### Installing Jenkins Directly on the Host Machine

When installing Jenkins using the provided script (`install_jenkins.sh`), the Jenkins data is typically stored directly on the host machine's filesystem, usually under the `/var/lib/jenkins` directory. In this case:

1. **Data Persistence**: The Jenkins data is still persisted on the host machine's filesystem, but it is not managed by Docker. As long as the host machine's filesystem remains intact, the Jenkins data will persist.

2. **Manual Backup and Restore**: Without using Docker volumes, you need to manually manage the backup and restore process of the Jenkins data. You can use traditional file backup tools or create scripts to backup and restore the `/var/lib/jenkins` directory.

3. **Upgrade and Maintenance**: When installing Jenkins directly on the host machine, upgrading Jenkins or performing maintenance tasks requires more manual steps. You need to stop the Jenkins service, update the package, and start the service again. This process is not as streamlined as updating a Docker container image.

The choice between running Jenkins as a container with a named volume or installing it directly on the host machine depends on your specific requirements, infrastructure setup, and personal preferences. Using Docker provides a more portable and easily manageable solution, while installing Jenkins directly offers more control over the host machine's filesystem and integration with existing systems.

Ultimately, both approaches have their merits, and the decision should be based on factors such as scalability, ease of maintenance, and alignment with your overall deployment strategy.

## Jenkins Initialization

After installing Jenkins (either as a container or locally), you need to perform some initial setup steps to access and configure Jenkins. Follow the steps below to initialize Jenkins:

### Access Jenkins Web UI

- [x] Task 1: Configure firewall rules
  - If you are using a cloud provider like DigitalOcean, you need to configure firewall rules to allow access to the Jenkins web UI.
  - After completing the Jenkins installation, open the DigitalOcean control panel and navigate to the "Networking" section.
  - Click on "Firewalls" and update the existing rule configured for Jenkins to also include an inbound rule for port 8080 (or the specific port you're using for Jenkins), alongside the previously established rule for SSH access.
  - Save the inbound firewall rule.

![Screenshot of firewall configuration on DigitalOcean](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/a31aeb80-6ce0-488d-9862-ff3bd26b1018)

- [x] Task 2: Access Jenkins web UI
  - Open a web browser and enter the URL: `http://<remote-server-ip>:8080`
  - Replace `<remote-server-ip>` with the IP address of your remote server. In this case, it is port 8080 (you can enter the port that you are running on).
  - You should see the Jenkins "Getting Started" page.

![Screenshot of Jenkins web interface "Getting Started" page](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/cf87e17f-952d-4367-9eff-5d2c68484c8e)

### Retrieve Initial Admin Password

- [x] Task 1: Retrieve the initial admin password
  - **If Jenkins is running as a container:**
    - SSH into your remote server.
    - Run the following command to enter the Jenkins container:

      ```bash
      docker exec -it <container-id> bash
      ```

    - Replace `<container-id>` with the ID of your Jenkins container.
    - Once inside the container, run the following command to retrieve the initial admin password:

      ```bash
      cat /var/jenkins_home/secrets/initialAdminPassword
      ```

    ![Retrieve the initial admin password](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/a5f74901-71d9-40c2-9825-1aaaf0f2ff4c)

  - **If Jenkins is installed locally:**
    - SSH into your remote server.
    - Switch to the Jenkins user:

      ```bash
      sudo su - jenkins
      ```

    - Run the following command to retrieve the initial admin password:

      ```bash
      cat /var/lib/jenkins/secrets/initialAdminPassword
      ```

- [ ] Task 2: Enter the initial admin password
  - Copy the retrieved password.
  - Paste the password into the "Administrator password" field on the Jenkins "Getting Started" page.
  - Click "Continue" to proceed.

> [!TIP]
> **You can also find the initial admin password on the host machine's filesystem at the mount point of the `jenkins_home` volume.**

![Retrieve the initial admin password from mount point on the host machine](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/47a1021e-ce82-40f1-b1af-813c8e4cff73)

### Customize Jenkins

- [x] Task 1: Install plugins
  - On the "Customize Jenkins" page, you can choose to install suggested plugins or select specific plugins.
  - If you are unsure, you can go with the suggested plugins option.
  - Click on the desired option to begin the plugin installation process.

- [x] Task 2: Create the first admin user
  - After the plugin installation is complete, you will be prompted to create the first admin user.
  - Fill in the required information in the "Create First Admin User" form:
    - Username
    - Password
    - Confirm password
    - Full name
    - Email address
  - Click "Save and Continue" to create the admin user.

- [x] Task 3: Instance configuration
  - On the next page, you can configure the Jenkins URL.
  - Leave the default URL as is, or modify it if necessary.
  - Click "Save and Finish" to complete the configuration.

- [x] Task 4: Start using Jenkins
  - Click on "Start using Jenkins" to access the Jenkins dashboard.
  - Jenkins is now ready to use!

### Install Build Tools for Jenkins

#### Option 1: Install build tools as Plugins in Jenkins

- [x] Task 1: Install build tools directly from the Jenkins web UI (if available)
  - **Check if the desired build tool is available in the Jenkins web UI:**
    - Navigate to the Jenkins web UI.
    - Go to "Manage Jenkins" > Under "System Configuration" > click on "Plugins".
    - On the right side, click on "Available plugins" and in the search bar type the build tool that you want to install (e.g., NodeJS).
    - If the build tool is available, proceed to configure and install it directly from the Jenkins web UI.

#### Option 2: Install build tools directly on the server where Jenkins is running

- [x] Task 1: Install build tools directly on the server where Jenkins is running (if not available in the Jenkins web UI or running Jenkins as a container)
  - **Access the Jenkins container as root user:**
    - If your Jenkins is running as a container, use the following command to enter the container terminal as root user:

      ```bash
      docker exec -u 0 -it <container-id> bash
      ```

    - Replace `<container-id>` with the ID of your Jenkins container.

  - **Identify the distribution of the container's operating system:**
    - Once inside the container as root, use one of the following commands to determine the distribution of the operating system:

      ```bash
      cat /etc/issue
      ```

      or

      ```bash
      cat /etc/os-release
      ```

    - Take note of the distribution information, as it will be important for installing compatible versions of the build tools.

  - **Install NodeJS as a build tool (example):**
    - If you require NodeJS as a build tool for your pipelines, you can install it using the following commands:

      ```bash
      curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
      apt-get install nodejs -y
      ```

    - This will install NodeJS in your Jenkins container.

  - **Verify the installation:**
    - After installing the build tools, verify that they are properly installed and accessible within the Jenkins container.
    - You can run version commands or check the installation paths to ensure the tools are set up correctly.

> [!IMPORTANT]
> **The specific steps and commands for installing build tools may vary depending on the operating system and the tools you require. Make sure to refer to the [official documentation](https://docs.nodesource.com/nsolid/5.0/docs#nsolid-runtime) or reliable sources for the correct installation procedures.**

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
