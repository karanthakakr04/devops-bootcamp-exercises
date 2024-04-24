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

### Additional Information: Jenkins Data Persistence

When setting up Jenkins, it's important to consider how the Jenkins data (configurations, plugins, jobs, etc.) is managed and persisted. The approach to data persistence differs when running Jenkins as a Docker container compared to installing it directly on the host machine.

#### Running Jenkins as a Docker Container

When running Jenkins as a Docker container, it is recommended to use a Docker named volume (`-v jenkins_home:/var/jenkins_home`) to store the Jenkins data. This approach has several benefits:

1. **Data Persistence**: By mounting a named volume to the `/var/jenkins_home` directory inside the container, the Jenkins data persists even if the container is stopped, removed, or recreated. The data is stored on the host machine's filesystem, separate from the container's lifecycle.

2. **Easy Backup and Restore**: With a named volume, you can easily backup and restore the Jenkins data. You can use Docker commands to create a backup of the volume or copy the data to another location. This allows for quick recovery in case of any issues or when migrating to a different host.

3. **Separation of Concerns**: By using a named volume, you keep the Jenkins data separate from the container itself. This allows you to upgrade or replace the Jenkins container image without affecting the stored data. You can stop the container, pull a new Jenkins image version, and start a new container while still preserving the existing data.

#### Installing Jenkins Directly on the Host Machine

When installing Jenkins using the provided script (`install_jenkins.sh`), the Jenkins data is typically stored directly on the host machine's filesystem, usually under the `/var/lib/jenkins` directory. In this case:

1. **Data Persistence**: The Jenkins data is still persisted on the host machine's filesystem, but it is not managed by Docker. As long as the host machine's filesystem remains intact, the Jenkins data will persist.

2. **Manual Backup and Restore**: Without using Docker volumes, you need to manually manage the backup and restore process of the Jenkins data. You can use traditional file backup tools or create scripts to backup and restore the `/var/lib/jenkins` directory.

3. **Upgrade and Maintenance**: When installing Jenkins directly on the host machine, upgrading Jenkins or performing maintenance tasks requires more manual steps. You need to stop the Jenkins service, update the package, and start the service again. This process is not as streamlined as updating a Docker container image.

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

    - Take note of the distribution information, as it will be important for installing compatible versions of the build tools.

    ![Find out the distribution of this container OS](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/4767b189-dec8-4d79-907b-cbeff7457305)

  - **Install NodeJS as a build tool:**
    - If you require NodeJS as a build tool for your pipelines, you can install it using the following commands:

      ```bash
      curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
      apt-get install nodejs -y
      ```

    - This will install NodeJS in your Jenkins container.

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

#### Method 1: Docker-in-Docker with Privileged Mode

To enable Docker-in-Docker functionality in a Jenkins container using the privileged mode, follow these detailed tasks:

- [x] **Task 1: Run the Jenkins container with Docker socket**
  - Use the following command to start a Jenkins container that includes mounting the Docker socket, allowing it to access the host's Docker daemon:

    ```bash
    docker run -p 8080:8080 -p 50000:50000 -d -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins:lts
    ```

  - `-p 8080:8080 -p 50000:50000`: Maps the container's ports to the host's ports for accessing the Jenkins web interface and enabling agent communication.
  - `-d`: Runs the container in detached mode.
  - `-v jenkins_home:/var/jenkins_home`: Mounts a volume for persisting Jenkins data.
  - `-v /var/run/docker.sock:/var/run/docker.sock`: Mounts the host's Docker socket inside the container, allowing the container to communicate with the host's Docker daemon.

- [x] **Task 2: Access the Jenkins container**
  - Gain root access inside the running Jenkins container to perform administrative tasks:

    ```bash
    docker exec -u 0 -it <container-id> bash
    ```

  - Replace `<container-id>` with the ID of your running Jenkins container.

- [x] **Task 3: Install Docker inside the Jenkins container**
  - Install Docker in the container to enable Docker command functionality internally:

    ```bash
    curl https://get.docker.com/ > dockerinstall && chmod 777 dockerinstall && ./dockerinstall
    ```

  - This command is executed to install Docker inside the container. It downloads the installation script from `https://get.docker.com/`, saves it to a file named `dockerinstall`, makes the file executable (`chmod 777 dockerinstall`), and then runs the installation script (`./dockerinstall`).

- [x] **Task 4: Adjust Docker socket permissions**
  - Modify the permissions of the Docker socket to allow the Jenkins user to execute Docker commands:

    ```bash
    chmod 666 /var/run/docker.sock
    ```

##### Considerations

1. **Simplicity**: Installing Docker inside the Jenkins container using the installation script is straightforward and requires fewer steps compared to setting up a separate Docker-in-Docker container.

2. **Security**: By mounting the host's Docker socket (`/var/run/docker.sock`) inside the Jenkins container, the container gains full access to the host's Docker daemon. This means that if the Jenkins container is compromised, an attacker could potentially control the host's Docker environment. It's important to secure the Jenkins container and restrict access to the Docker socket.

3. **Isolation**: With this approach, the Jenkins container and the Docker daemon share the same Docker environment. This means that any containers or images created by Jenkins will be visible to the host's Docker environment and vice versa. There is less isolation compared to using a separate Docker-in-Docker container.

4. **Compatibility**: Installing Docker inside the Jenkins container ensures that the version of Docker used by Jenkins is compatible with the installation script. However, it's important to note that the version of Docker installed inside the container may differ from the version running on the host.

> [!WARNING]
> Running Jenkins in Docker with privileged mode and wide-open socket permissions poses security risks, including potential for privilege escalation and unauthorized access to the host system. This setup is not recommended for production environments without additional security measures.

#### Method 2: Docker-in-Docker with docker:dind Image

- [ ] Task 1: Create a Docker network for communication between containers

  ```bash
  docker network create jenkins
  ```

- [ ] Task 2: Run the Docker-in-Docker container

  ```bash
  docker run --name jenkins-docker --rm --detach \
    --privileged --network jenkins --network-alias docker \
    --env DOCKER_TLS_CERTDIR=/certs \
    --volume jenkins-docker-certs:/certs/client \
    --volume jenkins-data:/var/jenkins_home \
    --publish 2376:2376 \
    docker:dind --storage-driver overlay2
  ```

- [ ] Task 3: Run the Jenkins container

  ```bash
  docker run --name jenkins-blueocean --rm --detach \
    --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
    --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
    --volume jenkins-data:/var/jenkins_home \
    --volume jenkins-docker-certs:/certs/client:ro \
    --publish 8080:8080 --publish 50000:50000 jenkins/jenkins:lts
  ```

  - Pros:
    - Uses the official `docker:dind` image, which is specifically designed for running Docker-in-Docker.
    - Provides a clean and isolated Docker environment for Jenkins.
    - Supports using the `overlay2` storage driver for better performance and compatibility.
  - Cons:
    - Requires additional setup steps compared to the privileged mode approach.
    - Involves creating a separate Docker network for communication between containers.
    - May have some performance overhead due to the additional abstraction layer.

#### Method 3: Docker-in-Docker with Sysbox (Recommended)

- [ ] Task 1: Install Sysbox on the host system
  - Follow the installation instructions provided in the [Sysbox documentation](https://github.com/nestybox/sysbox/blob/master/docs/user-guide/install.md) for your specific operating system.

- [ ] Task 2: Run the Jenkins container with Docker-in-Docker using Sysbox

  ```bash
  docker run --runtime=sysbox-runc -d --name jenkins-docker -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts
  ```

- [ ] Task 3: Install Docker inside the Jenkins container

  ```bash
  docker exec -it jenkins-docker bash
  apt-get update
  apt-get install docker.io
  ```

- [ ] Task 4: Start Docker inside the Jenkins container

  ```bash
  dockerd &
  ```

  - Pros:
    - Provides a secure and isolated environment for running Docker-in-Docker.
    - Eliminates the need for privileged mode or exposing the host's Docker socket.
    - Offers a virtual machine-like experience inside the container.
    - Supports running systemd and other system-level processes inside the container.
  - Cons:
    - Requires the installation of Sysbox on the host system.
    - May have some additional overhead compared to running Jenkins directly on the host.
