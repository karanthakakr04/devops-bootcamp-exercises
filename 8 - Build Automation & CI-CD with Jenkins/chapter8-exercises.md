# TASK BREAKDOWN

## Prerequisites

This section outlines the initial steps required to set up the environment for running Jenkins, either as a Docker container or installed locally on a remote server. The tasks include setting up Docker, which is a common prerequisite for both installation options, ensuring you have the necessary tools and configurations in place to proceed with the Jenkins setup.

> [!NOTE]
> **After creating the droplet, ensure that you have a firewall rule configured to allow inbound traffic on port 22 (SSH) to enable SSH access to the remote server.**

### Install Docker (if not already installed)

1. **Check if Docker is installed:**
   - SSH into the remote server.
     - Run the following command to check if Docker is already installed:

       ```bash
       docker --version
       ```

     - If Docker is installed, the command will display the Docker version. Proceed to the next step.
     - If Docker is not installed, continue with the installation steps.

2. **Set up Docker's apt repository:**
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

3. **Update the package lists:**
   - Run the following command to update the package lists:

     ```bash
     sudo apt update
     ```

4. **Install Docker:**
   - Run the following command to install the latest version of Docker:

     ```bash
     sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
     ```

### Jenkins Installation Options

This section presents two primary methods for installing Jenkins, allowing you to choose the best approach based on your infrastructure and specific requirements.

#### Method 1: Run Jenkins as a Docker Container

- [x] Task 1: Run Jenkins as a Docker container
  - **Start the Jenkins container:**
    - Run the following command on the remote server to start a Jenkins container:

      ```bash
      docker run --name jenkins -p 8080:8080 -p 50000:50000 -d -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts-jdk17
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

#### Method 2: Install Jenkins Locally on the Remote Server

- [ ] Task 1: Clone the repository and copy the installation script
  - **Clone the repository:**
    - Open a terminal on your local machine.
    - Run the following command to clone the repository containing the `install_jenkins.sh` script:

      ```bash
      git clone <repository-url>
      ```

    - Replace `<repository-url>` with the actual URL of this repository.

  - **Copy the installation script to the remote server:**
    - Use the `scp` command with the SSH key to securely copy the `install_jenkins.sh` script from your local machine to the remote server:

      ```bash
      scp -i <path-to-ssh-key> path/to/install_jenkins.sh <username>@<remote-server-ip>:/path/on/remote/server
      ```

    - Replace `<path-to-ssh-key>` with the actual path to your SSH key file.
    - Replace `path/to/install_jenkins.sh` with the actual path to the script on your local machine.
    - Replace `<username>` with your username on the remote server.
    - Replace `<remote-server-ip>` with the IP address or hostname of the remote server.
    - Replace `/path/on/remote/server` with the desired destination path on the remote server.

    - The `-i` option in the `scp` command specifies the path to the SSH key file that should be used for authentication when copying the file to the remote server.
    - You can also use `-v` flag to enable verbose mode, which displays detailed information about the SSH connection process. It can be helpful for debugging purposes or understanding what's happening during the connection establishment.

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

### Additional Information: Jenkins Data Persistence

When setting up Jenkins, it's important to consider how the Jenkins data (configurations, plugins, jobs, etc.) is managed and persisted. The approach to data persistence differs when running Jenkins as a Docker container compared to installing it directly on the host machine.

#### Running Jenkins as a Docker Container

When running Jenkins as a Docker container, it is recommended to use a Docker named volume (`-v jenkins_home:/var/jenkins_home`) to store the Jenkins data. This approach has several benefits:

1. **Data Persistence:** By mounting a named volume to the `/var/jenkins_home` directory inside the container, the Jenkins data persists even if the container is stopped, removed, or recreated. The data is stored on the host machine's filesystem, separate from the container's lifecycle.

2. **Easy Backup and Restore:** With a named volume, you can easily backup and restore the Jenkins data. You can use Docker commands to create a backup of the volume or copy the data to another location. This allows for quick recovery in case of any issues or when migrating to a different host.

3. **Separation of Concerns:** By using a named volume, you keep the Jenkins data separate from the container itself. This allows you to upgrade or replace the Jenkins container image without affecting the stored data. You can stop the container, pull a new Jenkins image version, and start a new container while still preserving the existing data.

#### Installing Jenkins Directly on the Host Machine

When installing Jenkins using the provided script (`install_jenkins.sh`), the Jenkins data is typically stored directly on the host machine's filesystem, usually under the `/var/lib/jenkins` directory. In this case:

1. **Data Persistence:** The Jenkins data is still persisted on the host machine's filesystem, but it is not managed by Docker. As long as the host machine's filesystem remains intact, the Jenkins data will persist.

2. **Manual Backup and Restore:** Without using Docker volumes, you need to manually manage the backup and restore process of the Jenkins data. You can use traditional file backup tools or create scripts to backup and restore the `/var/lib/jenkins` directory.

3. **Upgrade and Maintenance:** When installing Jenkins directly on the host machine, upgrading Jenkins or performing maintenance tasks requires more manual steps. You need to stop the Jenkins service, update the package, and start the service again. This process is not as streamlined as updating a Docker container image.

The choice between running Jenkins as a container with a named volume or installing it directly on the host machine depends on your specific requirements, infrastructure setup, and personal preferences. Using Docker provides a more portable and easily manageable solution, while installing Jenkins directly offers more control over the host machine's filesystem and integration with existing systems.

Ultimately, both approaches have their merits, and the decision should be based on factors such as scalability, ease of maintenance, and alignment with your overall deployment strategy.

### Jenkins Initialization

After installing Jenkins (either as a container or locally), you need to perform some initial setup steps to access and configure Jenkins. Follow the steps below to initialize Jenkins:

#### Access Jenkins Web UI

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

#### Retrieve Initial Admin Password

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
      cat /var/jenkins_home/secrets/initialAdminPassword; echo
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
      cat /var/lib/jenkins/secrets/initialAdminPassword; echo
      ```

- [x] Task 2: Enter the initial admin password
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

#### Method 1: Install build tools as Plugins in Jenkins

- [x] Task 1: Install build tools directly from the Jenkins web UI (if available)
  - **Check if the desired build tool is available in the Jenkins web UI:**
    - Navigate to the Jenkins web UI.
    - Go to "Manage Jenkins" > Under "System Configuration" > click on "Plugins".
    - On the right side, click on "Available plugins" and in the search bar type the build tool that you want to install (e.g., Maven).
    - If the build tool is available, proceed to configure and install it directly from the Jenkins web UI.

##### Further Reading

Choosing to install Node.js directly on a Jenkins container rather than relying on a Jenkins plugin involves several considerations. Here are some reasons why direct installation might be preferred:

1. **Control and Flexibility**: Installing Node.js directly in the Jenkins container gives you full control over the Node.js environment. This means you can select the specific version of Node.js that is compatible with your projects, manage updates, and configure it exactly to your needs without being restricted by the capabilities or limitations of a plugin.

2. **Performance and Compatibility**: By managing the Node.js installation yourself, you ensure that the runtime environment is optimally configured for your build processes, potentially improving build performance. This is especially important for projects that might have specific dependencies or require certain build tools available in Node.js.

3. **Reduced Complexity in Jenkins**: Plugins can add complexity to Jenkins. Each plugin increases the potential for conflicts or issues during Jenkins upgrades. By reducing reliance on plugins and handling dependencies externally, you can simplify Jenkins management and make your build process more stable.

4. **Up-to-Date Software**: Plugins may not always keep up with the latest releases of their respective tools. By installing Node.js directly, you can quickly adopt new features, performance improvements, and security patches as soon as they are released, rather than waiting for the plugin to be updated.

5. **Avoiding Plugin Limitations**: Some Jenkins plugins might not expose all features of Node.js or might implement them in ways that don't meet specific requirements of your projects. Direct installation avoids these limitations.

6. **Custom Scripts and Tooling**: Installing Node.js directly allows for the use of npm (Node Package Manager) and other Node.js-based tools within your Jenkins jobs without additional overhead or configuration complexities that might arise from using a plugin.

7. **Consistency Across Environments**: If your development and production environments use specific versions of Node.js, mirroring this setup in your CI/CD pipeline reduces the risk of "works on my machine" issues. Direct installation ensures consistency across all environments.

However, the choice between direct installation and using a plugin should be based on your specific needs, the scale of your projects, and your team's familiarity with managing Jenkins and its environments. Plugins can offer convenience and easier setup for teams that prefer a more integrated approach within the Jenkins UI. On the other hand, direct installation offers more control and flexibility, which can be crucial for complex projects.

#### Method 2: Install build tools directly on the server where Jenkins is running

##### Option 2.1: Install build tools in a Jenkins container

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

    - Take note of the distribution information, as it will be important for installing compatible versions of the build tools. In this case, it is a Debian based distribution.

    ![Find out the distribution of this container OS](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/4767b189-dec8-4d79-907b-cbeff7457305)

  - **Install NodeJS as a build tool:**
    - If you require NodeJS as a build tool for your pipelines, you can install it using the following commands:

      ```bash
      curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
      apt-get install nodejs -y
      ```

    - This will install NodeJS in your Jenkins container.
    - _Please note that this installation process is for Debian based distributions._

    ![Install Nodejs Part 1](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/4daed4c3-14c1-4158-858e-81c36a6c1059)

    ![Install Nodejs Part 2](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/3912d457-77cb-4dbe-863e-6ca9a466aad2)

  - **Verify the installation:**
    - After installing the build tools, verify that they are properly installed and accessible within the Jenkins container.
    - You can run version commands or check the installation paths to ensure the tools are set up correctly.

    ![Verify installation](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/1db7dfce-d71b-47b0-9b41-a997e32d81cb)

> [!IMPORTANT]
> **The specific steps and commands for installing build tools may vary depending on the operating system and the tools you require. Make sure to refer to the [official documentation](https://docs.nodesource.com/nsolid/5.0/docs#nsolid-runtime) or [reliable sources](https://nodejs.org/en/download/package-manager) for the correct installation procedures.**

##### Option 2.2: Install build tools on a server with local Jenkins installation

- [ ] Task 1: Install build tools on a server with local Jenkins installation
  - **SSH into the server:**
    - Open a terminal and SSH into the server where Jenkins is installed locally.

  - **Install NodeJS using NVM (Node Version Manager):**
    - Install NVM by running the following command:

      ```bash
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
      ```

    - Download and install the desired Node.js version (e.g., v20):

      ```bash
      nvm install 20
      ```

    - Verify the Node.js version:

      ```bash
      node -v # should print `v20.12.2`
      ```

    - Verify the NPM version:

      ```bash
      npm -v # should print `10.5.0`
      ```

> [!NOTE]
> **Since Node.js is installed directly on the server, Jenkins will have access to it without any additional configuration.**

### Configure Jenkins to Access Git Repository

- [x] Task 1: Create a personal access token on GitHub
  - **Navigate to GitHub settings:**
    - Click on your profile picture in the top-right corner of the GitHub page.
    - From the dropdown menu, click on "Settings".

  - **Access the Developer settings:**
    - In the left sidebar, scroll down and click on "Developer settings" at the bottom.

  - **Generate a new token:**
    - Under "Personal access tokens", you will see two options: "Fine-grained tokens" and "Tokens (classic)".
    - GitHub recommends using fine-grained personal access tokens instead of personal access tokens (classic).
    - Click on either "Fine-grained tokens" or "Tokens (classic)" based on your preference.
    - Click on the "Generate new token" button.
    - If prompted, enter your password to proceed.

  - **Configure token settings:**
    - If you selected "Fine-grained tokens":
      - Provide a name for the token.
      - Select the appropriate permissions for the token based on your requirements and repository security.
      - Click on the "Generate token" button.
    - If you selected "Tokens (classic)":
      - Provide a note for the token to identify its purpose.
      - Select the appropriate scopes for the token based on your requirements and repository security.
      - Click on the "Generate token" button.

  - **Save the generated token:**
    - Once the token is generated, make sure to copy and save it in a secure location.
    - Note that after this step, you won't be able to see the token again on the GitHub interface.

- [x] Task 2: Configure Jenkins to use the personal access token
  - **Open the Jenkins Credentials page:**
    - In the Jenkins dashboard, click on "Manage Jenkins" in the left sidebar.
    - Click on "Manage Credentials" under the "Security" section.

  - **Add a new credential:**
    - Click on the "Jenkins" store (or the appropriate domain) to expand it.
    - Click on "Global credentials (unrestricted)".
    - Click on the "Add Credentials" link in the left sidebar.

  - **Enter the GitHub token details:**
    - From the "Kind" dropdown, select "Username with password".
    - In the "Username" field, enter your GitHub username.
    - In the "Password" field, paste the personal access token you generated on GitHub.
    - In the "ID" field, provide a unique identifier for this credential (e.g., "GitHub-token").
    - In the "Description" field, provide a description for the credential (optional).
    - Click on the "Create" button to save the credential.

- [x] Task 3: Configure the Jenkins job to use the GitHub token
  - **Open the Jenkins job configuration:**
    - Navigate to the Jenkins job you want to configure.
    - Click on "Configure" in the left sidebar.

  - **Configure the Git repository:**
    - Scroll down to the "Source Code Management" section.
    - Select "Git" as the source code management tool.
    - In the "Repository URL" field, enter the URL of your GitHub repository.
    - From the "Credentials" dropdown, select the GitHub token credential you created earlier.

  - **Save the job configuration:**
    - Click on the "Save" button to apply the changes.

### Docker-in-Docker (dind) Setup

#### Method 1: Docker-in-Docker via Docker Socket Mounting

To enable Docker-in-Docker functionality in a Jenkins container using the privileged mode, follow these detailed tasks:

- [ ] Task 1: Run the Jenkins container with Docker socket
  - Use the following command to start a Jenkins container that includes mounting the Docker socket, allowing it to access the host's Docker daemon:

    ```bash
    docker run --name jenkins -p 8080:8080 -p 50000:50000 -d -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins:lts-jdk17
    ```

  - `-p 8080:8080 -p 50000:50000`: Maps the container's ports to the host's ports for accessing the Jenkins web interface and enabling agent communication.
  - `-d`: Runs the container in detached mode.
  - `-v jenkins_home:/var/jenkins_home`: Mounts a volume for persisting Jenkins data.
  - `-v /var/run/docker.sock:/var/run/docker.sock`: Mounts the host's Docker socket inside the container, allowing the container to communicate with the host's Docker daemon.

- [ ] Task 2: Access the Jenkins container
  - Gain root access inside the running Jenkins container to perform administrative tasks:

    ```bash
    docker exec -u 0 -it <container-id> bash
    ```

  - Replace `<container-id>` with the ID of your running Jenkins container.

- [ ] Task 3: Install Docker inside the Jenkins container
  - Install Docker in the container to enable Docker command functionality internally:

    ```bash
    curl https://get.docker.com/ > dockerinstall && chmod 777 dockerinstall && ./dockerinstall
    ```

  - This command is executed to install Docker inside the container. It downloads the installation script from `https://get.docker.com/`, saves it to a file named `dockerinstall`, makes the file executable (`chmod 777 dockerinstall`), and then runs the installation script (`./dockerinstall`).

- [ ] Task 4: Adjust Docker socket permissions
  - Modify the permissions of the Docker socket to allow the Jenkins user to execute Docker commands:

    ```bash
    chmod 666 /var/run/docker.sock
    ```

  - Persistence of Docker Socket Permissions:
    - When running Jenkins in a container and allowing it to access the Docker daemon on the host system, you may encounter an issue with the persistence of the Docker socket (`/var/run/docker.sock`) permissions.
    - If you modify the permissions of the `docker.sock` file inside the Jenkins container using the `chmod` command, the changes will not persist when the container is stopped and restarted. This is because the `/var/run/docker.sock` file is a Unix domain socket created and managed by the Docker daemon on the host system. When the Jenkins container starts, it mounts the `docker.sock` file from the host into the container, and the permissions of the mounted file are determined by the host system, not the container.
    - To address this issue, you need to modify the permissions of the Docker socket (`/var/run/docker.sock`) inside the Jenkins container **again** to allow Jenkins to access the Docker daemon. Note that you will require root permissions inside the container to do it.

##### Considerations

1. **Simplicity**: Installing Docker inside the Jenkins container using the installation script is straightforward and requires fewer steps compared to setting up a separate Docker-in-Docker container.

2. **Security**: By mounting the host's Docker socket (`/var/run/docker.sock`) inside the Jenkins container, the container gains full access to the host's Docker daemon. This means that if the Jenkins container is compromised, an attacker could potentially control the host's Docker environment. It's important to secure the Jenkins container and restrict access to the Docker socket.

3. **Isolation**: With this approach, the Jenkins container and the Docker daemon share the same Docker environment. This means that any containers or images created by Jenkins will be visible to the host's Docker environment and vice versa. There is less isolation compared to using a separate Docker-in-Docker container.

4. **Compatibility**: Installing Docker inside the Jenkins container ensures that the version of Docker used by Jenkins is compatible with the installation script. However, it's important to note that the version of Docker installed inside the container may differ from the version running on the host.

> [!WARNING]
> **Granting Jenkins container access to the host's Docker daemon can lead to significant security vulnerabilities, including potential for privilege escalation and unauthorized host access. It is crucial to evaluate the security implications carefully. For production environments, consider more isolated methods and ensure that access to the Docker socket is tightly controlled and monitored.**

#### Method 2: Docker-in-Docker Using Privileged Containers

This method involves setting up Docker-in-Docker (DinD) functionality using privileged containers, which allows one Docker container to control another Docker instance entirely.

There are two ways to implement this setup:

1. **Using Individual Docker Commands:** This approach involves manually running each Docker command to set up and connect the containers.
2. **Using Docker Compose:** This method utilizes a Docker Compose file to manage the containers, simplifying the process by defining all configurations in a single file.

##### Setup Using Individual Docker Commands

- [ ] Task 1: Create a Docker network
  - Run the command to create a dedicated Docker network for container communication:

    ```bash
    docker network create jenkins
    ```

- [ ] Task 2: Start the Docker-in-Docker container
  - Pull and run the Docker-in-Docker image in privileged mode:

    ```bash
    docker run --name jenkins-docker --rm --detach \
      --privileged --network jenkins --network-alias docker \
      --volume jenkins-data:/var/jenkins_home \
      --publish 2376:2376 \
      docker:26.1.0-dind-alpine3.19 \
      --storage-driver overlay2
    ```

    - `--name jenkins-docker`: Assigns a name to the container for easier management.
    - `--rm`: Ensures the container is removed upon exit.
    - `--detach`: Runs the container in the background.
    - `--privileged`: Grants additional permissions for managing Docker.
    - `--network jenkins`: Connects the container to the 'jenkins' network.
    - `--network-alias docker`: Allows referring to this container by the alias 'docker'.
    - `--volume jenkins-data:/var/jenkins_home`: Maps a volume for persistent data.
    - `--publish 2376:2376`: Exposes the Docker daemon port to the host.

- [ ] Task 3: Create a custom Jenkins image
  - Create a Dockerfile with the following content:

     ```dockerfile
     FROM jenkins/jenkins:lts-jdk17
     USER root
     RUN apt-get update && apt-get install -y lsb-release
     RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
         https://download.docker.com/linux/debian/gpg
     RUN echo "deb [arch=$(dpkg --print-architecture) \
               signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
               https://download.docker.com/linux/debian \
               $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
     RUN apt-get update && apt-get install -y docker-ce-cli
     # RUN usermod -aG docker jenkins
     USER jenkins
     RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
     ```

  - Build the custom Jenkins image:

     ```bash
     docker build -t jenkins-blueocean .
     ```

- [ ] Task 4: Run the Jenkins container
  - Start Jenkins and configure it to communicate with the Docker-in-Docker service:

    ```bash
    docker run --name jenkins-blueocean --rm --detach \
      --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
      --publish 8080:8080 --publish 50000:50000 \
      --volume jenkins-data:/var/jenkins_home \
      jenkins-blueocean
    ```

    - `--name jenkins-blueocean`: Sets the name of the Jenkins container.
    - `--env DOCKER_HOST=tcp://docker:2376`: Configures Jenkins to use the Docker daemon running in the DinD container.
    - `--publish 8080:8080` and `--publish 50000:50000`: Exposes Jenkins web and agent ports.

- [ ] Task 5: Verify the setup
  - Check that both containers are running and communicating correctly:
    - Use `docker ps` to ensure both containers are listed as running.
    - Access Jenkins via `http://<remote-server-ip>:8080` and verify that it can launch Docker containers.

##### Setup Using Docker Compose

Alternatively, you can use Docker Compose to manage the setup, which simplifies the management of multiple containers. Here is the `compose.yaml` file for setting up Jenkins with Docker-in-Docker without TLS:

```yaml
version: '3.8'
services:
  jenkins:
    image: jenkins/jenkins:lts-jdk17
    privileged: true
    user: root
    ports:
      - 8080:8080
      - 50000:50000
    container_name: jenkins
    volumes:
      - jenkins_home:/var/jenkins_home
    networks:
      - jenkins
    environment:
      - DOCKER_HOST=tcp://docker:2376

  docker:
    image: docker:26.1.0-dind-alpine3.19
    privileged: true
    container_name: jenkins-docker
    ports:
      - 2376:2376
    volumes:
      - jenkins_data:/var/jenkins_home
    networks:
      - jenkins
    command: --storage-driver overlay2

volumes:
  jenkins_home:
  jenkins_data:

networks:
  jenkins:
```

- [ ] Task 1: Deploy using Docker Compose
  - Navigate to the directory containing the `compose.yaml` file:

    ```bash
    cd path/to/compose.yaml
    ```

  - Run the following command to start the containers in detached mode:

    ```bash
    docker compose up -d
    ```

##### Security Considerations

1. **Docker-in-Docker with Privileged Mode:** Running containers in privileged mode poses significant security risks, such as the potential for privileged escalation and unauthorized access to the host machine.

2. **Communication Security:** The communication between the Jenkins container and the Docker-in-Docker container in this setup does not use TLS, meaning it is not encrypted. For learning and experimentation purposes, this may be acceptable, but it is strongly recommended to implement Docker TLS in production environments to ensure secure communication between containers.

> [!CAUTION]
> **Running Jenkins in Docker with [privileged mode](https://docs.docker.com/reference/cli/docker/container/run/#privileged) and wide-open socket permissions poses security risks, including potential for privilege escalation and unauthorized access to the host system. This setup is not recommended for production environments without additional security measures.**

#### Method 3: Docker-in-Docker with Sysbox (Recommended)

- [ ] Task 1: Install Sysbox on the host system
  - Follow the installation instructions provided in the [Sysbox documentation](https://github.com/nestybox/sysbox/blob/master/docs/user-guide/install.md) for your specific operating system.

- [ ] Task 2: Create a custom Jenkins image with Java 17, Jenkins, and Docker preinstalled
  - Create a new directory for your custom image and navigate to it:

    ```bash
    mkdir jenkins-docker-image
    cd jenkins-docker-image
    ```

  - Create a Dockerfile inside the directory with the following content:

    ```dockerfile
    FROM ubuntu:22.04

    # Install Java 17
    RUN apt update && \
        apt install -y openjdk-17-jdk

    # Install Jenkins
    RUN apt install -y wget && \
        wget -O /usr/share/keyrings/jenkins-keyring.asc \
        https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key && \
        echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
        https://pkg.jenkins.io/debian-stable binary/" | tee \
        /etc/apt/sources.list.d/jenkins.list > /dev/null && \
        apt update && \
        apt install -y jenkins

    # Install Docker
    RUN apt install -y ca-certificates curl && \
        install -m 0755 -d /etc/apt/keyrings && \
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
        chmod a+r /etc/apt/keyrings/docker.asc && \
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
        https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null && \
        apt update && \
        apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Expose the Jenkins port
    EXPOSE 8080
    ```

  - With this Dockerfile, when you build the image and run a container from it, the Jenkins service will automatically start as a daemon, listening on port 8080, based on the configuration set up by the installation script.
  - You can access the Jenkins web interface by opening a browser and navigating to `http://<remote-server-ip>:8080` if you have mapped the container's port to the host

- [ ] Task 3: Build the custom Jenkins image
  - Choose a concise and descriptive name for your custom image, such as `jenkins-docker-bundle:1.0`.
  - Build the image using the following command:

    ```bash
    docker build -t jenkins-docker-bundle:1.0 .
    ```

- [ ] Task 4: Run the custom Jenkins container with Docker-in-Docker using Sysbox

  ```bash
  docker run --runtime=sysbox-runc -d --name jenkins-docker -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins-docker-bundle:1.0
  ```

- [ ] Task 5: Access Jenkins by opening a web browser and navigating to `http://<your-remote-server-ip>:8080`

- [ ] Task 6: Follow the Jenkins setup wizard to complete the initial configuration and customize Jenkins according to your needs.

## Exercise 1

`docker init` is a command introduced in Docker v20.10.0 that helps you quickly create a Dockerfile, docker-compose.yaml, and .dockerignore file for your application. It simplifies the process of containerizing your application by generating a Dockerfile with best practices and sensible defaults based on your project's language and framework.

- [ ] Task 1: Use `docker init` to generate a Dockerfile for the NodeJS application
  - Open a terminal and navigate to the root directory of your NodeJS application.
  - Run the following command:

    ```bash
    docker init
    ```

  - Docker will ask you a series of questions to gather information about your application. Here's an example of how the interaction might look:

    ![docker init command screenshot](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/bf778393-591f-4f98-9434-a58bf9a1c78e)

    In this example:
    - The application platform is Node.
    - The desired Node version is 20.12.2.
    - The package manager is npm.
    - The command to start the application is `npm start`.
    - The server listens on port 3000.

  - After answering the questions, `docker init` will generate the following files:
    - `.dockerignore`: Lists files and directories that should be excluded from the Docker build context.
    - `Dockerfile`: Contains the instructions to build your NodeJS application as a Docker image.
    - `compose.yaml`: Defines services, networks, and volumes for running your application using Docker Compose.
    - `README.Docker.md`: Provides information about using the generated files.

- [ ] Task 2: Review the generated Dockerfile to understand its contents and ensure it aligns with the application's requirements
  - Here is what the generated Dockerfile looks like for our Node.js project:

    ```dockerfile
    # syntax=docker/dockerfile:1

    ARG NODE_VERSION=20.12.2

    FROM node:${NODE_VERSION}-alpine

    ENV NODE_ENV production

    WORKDIR /usr/src/app

    RUN --mount=type=bind,source=package.json,target=package.json \
        --mount=type=bind,source=package-lock.json,target=package-lock.json \
        --mount=type=cache,target=/root/.npm \
        npm ci --omit=dev

    USER node

    COPY . .

    EXPOSE 3000

    CMD ["npm", "start"]
    ```

  - This Dockerfile follows best practices and includes the following:
    - Use of the official Node.js Alpine base image for a smaller image size.
    - Setting the `NODE_ENV` environment variable to `production` for optimized performance.
    - Copying only the necessary files to the image.
    - Installing production dependencies using `npm ci` for faster and reproducible builds.
    - Running the application as a non-root user for improved security.
    - Exposing the port on which the application listens.
    - Specifying the command to start the application.

> [!IMPORTANT]
> It's important to note that the `docker init` command may generate a Dockerfile with `CMD npm start` instead of `CMD ["npm", "start"]`. While both forms are valid, there is a difference in how they are executed by the Docker container.
>
> - `CMD ["npm", "start"]` (exec form):
>   - This form specifies the command as a JSON array, where each element is a separate string.
>   - The command is executed directly, without invoking a shell.
>   - It is the recommended form for executing commands in Docker as it avoids shell interpretation and potential command injection vulnerabilities.
>
> - `CMD npm start` (shell form):
>   - This form specifies the command as a plain string.
>   - The command is executed using the default shell (`/bin/sh -c`) inside the container.
>   - Using the shell form can be useful when you need shell features like environment variable expansion or command chaining.
>
> In most cases, it is recommended to use the exec form (`CMD ["npm", "start"]`) for clarity, control, and security. However, if the generated Dockerfile uses the shell form, it is important to review and modify it to ensure it aligns with your application's requirements and best practices.

### Pipeline and Repository Storage in Jenkins Volume

Inside the Jenkins volume, you can find the files related to your pipeline in the following directory:

```plaintext
/var/jenkins_home/jobs/<job-name>/builds/<build-number>/
```

Here's a breakdown of the directory structure:

- `/var/jenkins_home/jobs/`: This directory contains subdirectories for each Jenkins job or pipeline.
- `<job-name>/`: Replace this with the name of your specific job or pipeline.
- `builds/`: This directory contains subdirectories for each build of the job.
- `<build-number>/`: Replace this with the specific build number.

Inside the `<build-number>` directory, you'll find various files and directories related to that particular build of your pipeline, such as:

- `build.xml`: Contains information about the build, including the build number, timestamp, and status.
- `log`: Contains the console output of the build.
- `workflow/`: Contains files related to the pipeline execution, such as the pipeline script and stage information.

When you configure your pipeline to fetch code from a Git repository, Jenkins typically clones the repository inside a workspace directory within the build directory. The location of the cloned repository inside the container volume would be:

```plaintext
/var/jenkins_home/workspace/<job-name>
```

Here's a breakdown of the directory structure:

- `/var/jenkins_home/workspace/`: This directory contains subdirectories for each job's workspace.
- `<job-name>/`: Replace this with the name of your specific job or pipeline.

Inside the `<job-name>` directory, you'll find the cloned Git repository that Jenkins fetched during the build process. The repository files and directories will be available in this location.

It's important to note that the workspace directory is typically used as a temporary location for each build. By default, Jenkins doesn't persist the workspace across builds unless explicitly configured to do so. If you need to persist the workspace data, you can use Jenkins plugins like "Workspace Cleanup" or manually configure the job to archive the necessary files.

To access these directories and files, you can use the `docker exec` command to enter the running Jenkins container and navigate to the respective paths. For example:

```bash
docker exec -it <container-id-or-name> /bin/bash
```

Once inside the container, you can use common Linux commands like `cd`, `ls`, and `cat` to explore and view the contents of the directories and files.

Remember that the actual paths and directory names may vary depending on your Jenkins configuration and job setup. The examples provided above are based on typical Jenkins conventions.

### Docker Login for Different Registries

When using the `docker login` command to authenticate with a Docker registry that isn't Docker Hub, you must specify the hostname of the repository. This is because Docker defaults to Docker Hub if no server is specified. Here's how you do it for various registries like Nexus or AWS ECR:

1. **Nexus Repository as Docker Registry**
   - If you are using Nexus as your Docker registry, you need to specify the Nexus repository URL in your `docker login` command. The command format is:

     ```bash
     docker login [nexus-repository-url]
     ```

   - Example:

     ```bash
     docker login nexus.yourcompany.com
     ```

   - You will then be prompted to enter the username and password for your Nexus Docker registry unless you provide them directly in the command.

2. **AWS Elastic Container Registry (ECR)**
   - For AWS ECR, the process involves using the `aws` CLI to get the login password and then piping it to a `docker login` command. You also need to specify the AWS region.
   - First, retrieve the authentication token using the AWS CLI, then use it to log in:

     ```bash
     aws ecr get-login-password --region your-region | docker login --username AWS --password-stdin your-aws-account-id.dkr.ecr.region.amazonaws.com
     ```

   - Example for region us-east-1:

     ```bash
     aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
     ```

#### Why Specify the Hostname?

- **Targeting the Correct Registry**: Specifying the hostname ensures that the Docker client knows exactly which registry to authenticate against. Without the hostname, Docker would default to Docker Hub, which might not be intended.
- **Security**: This prevents accidentally sending your credentials to the wrong registry. Ensuring you're logging into the correct registry is crucial, especially in environments where security and data privacy are paramount.

#### Using Docker Configurations

For ease of use, especially if you regularly interact with a non-Docker Hub registry, you can configure your Docker client to manage multiple registry logins. This involves setting up a `config.json` file in your Docker directory (typically `~/.docker/config.json`), where you can store encoded credentials for each registry. However, managing credentials in plaintext or encoded form in configuration files should be handled cautiously from a security perspective.

## Exercise 2

- [ ] Task 1: Set up the Jenkins pipeline
  - Open the Jenkins web interface.
  - Click on "New Item" in the left sidebar.
  - Enter a name for your pipeline (e.g., "nodejs-app-pipeline") and select "Pipeline" as the item type.
  - Click "OK" to create the pipeline.

- [ ] Task 2: Configure the pipeline
  - In the pipeline configuration page, scroll down to the "Pipeline" section.
  - Select "Pipeline script from SCM" as the pipeline definition.
  - Choose "Git" as the SCM.
  - Enter the repository URL for your NodeJS application.
  - Specify the branch to build (e.g., "_/main" or "_/master").
  - Leave the script path as "Jenkinsfile" (assuming you have a Jenkinsfile in your repository root).

- [ ] Task 2: Configure the Jenkins job to access the GitHub repository
  - **Open the Jenkins job configuration:**
    - Navigate to the Jenkins job you want to configure.
    - Click on "Configure" in the left sidebar.

  - **Configure the Pipeline:**
    - Scroll down to the "Pipeline" section.
    - In the "Definition" field, select "Pipeline script from SCM".
    - In the "SCM" field, select "Git".

  - **Configure the Git repository:**
    - In the "Repository URL" field, enter the URL of your GitHub repository:
      `https://github.com/karanthakakr04/devops-bootcamp-exercises.git`
    - In the "Credentials" dropdown, select the GitHub token credential you created earlier.
    - In the "Branch Specifier" field, enter the branch name you want to build (e.g., `*/main`).
    - In the "Script Path" field, provide the relative path to the `Jenkinsfile` within the repository:
      `8 - Build Automation & CI-CD with Jenkins/jenkins-exercises/Jenkinsfile`

  - **Save the job configuration:**
    - Click on the "Save" button to apply the changes.

- [ ] Task 3: Verify the configuration
  - **Run the Jenkins job:**
    - Navigate to the Jenkins job.
    - Click on "Build Now" to trigger a new build.

  - **Check the build log:**
    - Once the build starts, click on the build number to view its details.
    - Click on the "Console Output" to view the build log.
    - Verify that Jenkins is able to access the GitHub repository and locate the `Jenkinsfile`.

- [ ] Task 4: Create the Jenkinsfile
  - In your local development environment, create a new file named "Jenkinsfile" in the root directory of your NodeJS application repository.
  - Open the Jenkinsfile in a text editor.

- [ ] Task 4: Define the pipeline stages
  - Begin the Jenkinsfile with the `pipeline` block:

    ```groovy
    pipeline {
      agent any

      stages {
        // Pipeline stages will be defined here
      }
    }
    ```

  - Add the following stages to the pipeline:

    ```groovy
    stage('Increment Version') {
      steps {
        script {
          // Increment the application version
          // You can use a npm package like 'npm-version' or write a custom script to increment the version
          // Example: sh 'npm run version:increment'
        }
      }
    }

    stage('Run Tests') {
      steps {
        script {
          // Run tests for the application
          // Example: sh 'npm test'
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          // Build the Docker image with the incremented version
          // Example: sh 'docker build -t myapp:${version} .'
        }
      }
    }

    stage('Push Docker Image') {
      steps {
        script {
          // Push the Docker image to a registry
          // Example: sh 'docker push myapp:${version}'
        }
      }
    }

    stage('Commit Version') {
      steps {
        script {
          // Commit the version increment to Git
          // Example:
          // sh 'git add package.json'
          // sh 'git commit -m "Increment version to ${version}"'
          // sh 'git push origin main'
        }
      }
    }
    ```

  - Customize the steps within each stage according to your specific application and requirements.

- [ ] Task 5: Implement version incrementing
  - In the "Increment Version" stage, add the necessary steps to increment your application's version.
  - You can use a npm package like 'npm-version' or write a custom script to increment the version based on your versioning strategy (e.g., semantic versioning).
  - Example:

    ```groovy
    stage('Increment Version') {
      steps {
        script {
          def currentVersion = sh(returnStdout: true, script: 'npm run get-version').trim()
          def nextVersion = incrementVersion(currentVersion)
          sh "npm version ${nextVersion} --no-git-tag-version"
          env.VERSION = nextVersion
        }
      }
    }
    ```

- [ ] Task 6: Run tests
  - In the "Run Tests" stage, add the step to run tests for your NodeJS application.
  - Use the appropriate command to run your tests (e.g., `npm test`).
  - Example:

    ```groovy
    stage('Run Tests') {
      steps {
        script {
          sh 'npm test'
        }
      }
    }
    ```

- [ ] Task 7: Build Docker image
  - In the "Build Docker Image" stage, add the step to build the Docker image for your application.
  - Use the `docker build` command to build the image, tagging it with the incremented version.
  - Example:

    ```groovy
    stage('Build Docker Image') {
      steps {
        script {
          sh "docker build -t myapp:${env.VERSION} ."
        }
      }
    }
    ```

- [ ] Task 8: Push Docker image
  - In the "Push Docker Image" stage, add the step to push the built Docker image to a registry.
  - Use the `docker push` command to push the image to your desired registry.
  - Example:

    ```groovy
    stage('Push Docker Image') {
      steps {
        script {
          sh "docker push myapp:${env.VERSION}"
        }
      }
    }
    ```

- [ ] Task 9: Commit version changes
  - In the "Commit Version" stage, add the steps to commit the version increment to your Git repository.
  - Use Git commands to stage, commit, and push the changes.
  - Example:

    ```groovy
    stage('Commit Version') {
      steps {
        script {
          sh 'git add package.json'
          sh "git commit -m 'Increment version to ${env.VERSION}'"
          sh 'git push origin main'
        }
      }
    }
    ```

> [!TIP]
> You can enhance the pipeline further by adding error handling, notifications, or additional stages based on your specific requirements.

- [ ] Task 10: Save and run the pipeline
  - Save the Jenkinsfile and commit it to your Git repository.
  - In the Jenkins web interface, navigate to your pipeline.
  - Click on "Build Now" to trigger the pipeline execution.
  - Monitor the pipeline stages and verify that each stage runs successfully.

> [!NOTE]
> Make sure you have the necessary plugins installed in Jenkins to support the pipeline steps (e.g., Docker, Git).
