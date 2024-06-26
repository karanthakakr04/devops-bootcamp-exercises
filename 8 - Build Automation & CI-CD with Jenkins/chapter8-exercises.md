# TASK BREAKDOWN

## Prerequisites

This section outlines the initial steps required to set up the environment for running Jenkins, either as a Docker container or installed locally on a remote server. The tasks include setting up Docker, which is a common prerequisite for both installation options, ensuring you have the necessary tools and configurations in place to proceed with the Jenkins setup.

> [!NOTE]
> **After creating the droplet, ensure that you have a firewall rule configured to allow inbound traffic on port 22 (SSH) to enable SSH access to the remote server.**

### Install Docker (if not already installed)

1. **Check the operating system:**
   - SSH into the remote server.
   - Run the following command to determine the operating system:

     ```bash
     cat /etc/os-release
     ```

   - If the output indicates that the operating system is Ubuntu, proceed with step 2 provided below.
   - If the output indicates that the operating system is Amazon Linux 2, refer to the official AWS documentation for installing Docker on Amazon Linux 2:
     - [Installing Docker on Amazon Linux 2](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html#install_docker)

2. **Check if Docker is installed:**
   - SSH into the remote server.
     - Run the following command to check if Docker is already installed:

       ```bash
       docker --version
       ```

     - If Docker is installed, the command will display the Docker version. Proceed to *Jenkins installation*.
     - If Docker is not installed, continue with the installation steps provided below.

3. **Set up Docker's apt repository:**
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

4. **Update the package lists:**
   - Run the following command to update the package lists:

     ```bash
     sudo apt update
     ```

5. **Install Docker:**
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

- [x] Task 1: Clone the repository and copy the installation script
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

- [x] Task 2: Use the provided script to install Jenkins locally
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
    - *Please note that this installation process is for Debian based distributions.*

    ![Install Nodejs Part 1](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/4daed4c3-14c1-4158-858e-81c36a6c1059)

    ![Install Nodejs Part 2](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/3912d457-77cb-4dbe-863e-6ca9a466aad2)

  - **Verify the installation:**
    - After installing the build tools, verify that they are properly installed and accessible within the Jenkins container.
    - You can run version commands or check the installation paths to ensure the tools are set up correctly.

    ![Verify installation](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/1db7dfce-d71b-47b0-9b41-a997e32d81cb)

> [!IMPORTANT]
> **The specific steps and commands for installing build tools may vary depending on the operating system and the tools you require. Make sure to refer to the [official documentation](https://docs.nodesource.com/nsolid/5.0/docs#nsolid-runtime) or [reliable sources](https://nodejs.org/en/download/package-manager) for the correct installation procedures.**

##### Option 2.2: Install build tools on a server with local Jenkins installation

- [x] Task 1: Install build tools on a server with local Jenkins installation
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
    - Check the "Treat username as a secret" checkbox to ensure the username is stored securely (optional).
    - In the "Password" field, paste the personal access token you generated on GitHub.
    - In the "ID" field, provide a unique identifier for this credential (e.g., "GitHub-token").
    - In the "Description" field, provide a description for the credential.
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

#### Additional Benefits of the GitHub Plugin in Jenkins

When you install the GitHub plugin in Jenkins, you gain access to additional features and options that are not available with the default Git plugin. Here are some of the key benefits:

- **GitHub-Specific Behaviors:**
  - The GitHub plugin allows you to configure specific behaviors for branches, pull requests from origin, and pull requests from forks. This provides more granular control over how your Jenkins jobs interact with your GitHub repository.
  - You can define strategies for discovering branches and pull requests, such as excluding branches that are also filed as pull requests or selecting the current pull request revision.

- **Enhanced Integration:**
  - The plugin provides better integration with GitHub, allowing for seamless CI/CD workflows. For example, you can automatically trigger Jenkins jobs based on GitHub events like pushes, pull requests, and tags.
  - It supports GitHub webhooks, which enable real-time notifications and job triggers, ensuring that your Jenkins jobs are always up-to-date with the latest changes in your repository.

- **Additional Configuration Options:**
  - With the GitHub plugin, you have more configuration options available in the Jenkins job settings. This includes the ability to set up property strategies, which allow you to define properties for different branches or pull requests.
  - You can also leverage the GitHub API for advanced automation and integration scenarios, making it easier to manage your Jenkins jobs and GitHub repositories programmatically.

These additional features and options provided by the GitHub plugin can significantly enhance your Jenkins setup, making it more flexible, powerful, and tailored to your specific CI/CD needs.

![GitHub Plugin Install](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/60b6c4ba-273e-4394-aa2f-f706eca6cd30)

![GitHub Plugin Install](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/a0ea98e6-dc64-4297-b6df-2572f99c070f)

### Docker-in-Docker (dind) Setup

#### Method 1: Docker-in-Docker via Docker Socket Mounting

To enable Docker-in-Docker functionality in a Jenkins container using the privileged mode, follow these detailed tasks:

- [x] Task 1: Run the Jenkins container with Docker socket
  - Use the following command to start a Jenkins container that includes mounting the Docker socket, allowing it to access the host's Docker daemon:

    ```bash
    docker run --name jenkins -p 8080:8080 -p 50000:50000 -d -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins:lts-jdk17
    ```

  - `-p 8080:8080 -p 50000:50000`: Maps the container's ports to the host's ports for accessing the Jenkins web interface and enabling agent communication.
  - `-d`: Runs the container in detached mode.
  - `-v jenkins_home:/var/jenkins_home`: Mounts a volume for persisting Jenkins data.
  - `-v /var/run/docker.sock:/var/run/docker.sock`: Mounts the host's Docker socket inside the container, allowing the container to communicate with the host's Docker daemon.

- [x] Task 2: Access the Jenkins container
  - Gain root access inside the running Jenkins container to perform administrative tasks:

    ```bash
    docker exec -u 0 -it <container-id> bash
    ```

  - Replace `<container-id>` with the ID of your running Jenkins container.

- [x] Task 3: Install Docker inside the Jenkins container
  - Install Docker in the container to enable Docker command functionality internally:

    ```bash
    curl https://get.docker.com/ > dockerinstall && chmod 777 dockerinstall && ./dockerinstall
    ```

  - This command is executed to install Docker inside the container. It downloads the installation script from `https://get.docker.com/`, saves it to a file named `dockerinstall`, makes the file executable (`chmod 777 dockerinstall`), and then runs the installation script (`./dockerinstall`).

- [x] Task 4: Adjust Docker socket permissions
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

- [x] Task 1: Create a Docker network
  - Run the command to create a dedicated Docker network for container communication:

    ```bash
    docker network create jenkins
    ```

- [x] Task 2: Start the Docker-in-Docker container
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

- [x] Task 3: Create a custom Jenkins image
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

- [x] Task 4: Run the Jenkins container
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

- [x] Task 5: Verify the setup
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

- [x] Task 1: Deploy using Docker Compose
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

- [x] Task 1: Install Sysbox on the host system
  - Follow the installation instructions provided in the [Sysbox documentation](https://github.com/nestybox/sysbox/blob/master/docs/user-guide/install.md) for your specific operating system.

- [x] Task 2: Create a custom Jenkins image with Java 17, Jenkins, and Docker preinstalled
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

- [x] Task 3: Build the custom Jenkins image
  - Choose a concise and descriptive name for your custom image, such as `jenkins-docker-bundle:1.0`.
  - Build the image using the following command:

    ```bash
    docker build -t jenkins-docker-bundle:1.0 .
    ```

- [x] Task 4: Run the custom Jenkins container with Docker-in-Docker using Sysbox

  ```bash
  docker run --runtime=sysbox-runc -d --name jenkins-docker -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins-docker-bundle:1.0
  ```

- [x] Task 5: Access Jenkins by opening a web browser and navigating to `http://<your-remote-server-ip>:8080`

- [x] Task 6: Follow the Jenkins setup wizard to complete the initial configuration and customize Jenkins according to your needs.

## Exercise 1

- [x] Task 1: Manually create a Dockerfile for the NodeJS application
  - Open a text editor and create a new file named `Dockerfile` in the root directory of your NodeJS application.
  - Copy the following content into the `Dockerfile`:

    ```dockerfile
    # Use an official Node runtime as a parent image
    FROM node:20.12.2-alpine

    # Set the working directory
    WORKDIR /usr/src/app

    # Copy the package.json and package-lock.json files
    COPY app/package.json ./

    # Install dependencies
    RUN npm install --omit=dev

    # Copy the rest of the application code
    COPY app/ ./

    # Expose the port the app runs on
    EXPOSE 3000

    # Define the command to run the app
    CMD ["npm", "start"]
    ```

  - Save the `Dockerfile`.

  This `Dockerfile` includes the following steps:
  - Uses the official Node.js Alpine base image with version 20.12.2.
  - Sets the working directory to `/usr/src/app` inside the container.
  - Copies the `package.json` and `package-lock.json` files from the `app` directory to the working directory.
  - Runs `npm install --omit=dev` to install dependencies, excluding development dependencies.
  - Copies the rest of the application code from the `app` directory to the working directory.
  - Exposes port 3000, which is the port the application runs on.
  - Specifies the command to run the application using `CMD ["npm", "start"]`.

- [x] Task 2: Review the manually created Dockerfile
  - Ensure that the `Dockerfile` includes the necessary steps to build and run your NodeJS application.
  - Verify that the base image, working directory, dependencies installation, and application code copying are correctly specified.
  - Check that the exposed port matches the port your application listens on.
  - Confirm that the command to start the application is correctly defined using the exec form (`CMD ["npm", "start"]`).

- [x] Task 3: Create a `docker-compose.yml` file
  - Open a text editor and create a new file named `docker-compose.yml` in the root directory of your NodeJS application.
  - Copy the following content into the `docker-compose.yml` file:

    ```yaml
    version: '3.8'

    services:
      app:
        build:
          context: .
          dockerfile: 8 - Build Automation & CI-CD with Jenkins/jenkins-exercises/Dockerfile
        ports:
          - "3000:3000"
        environment:
          NODE_ENV: development
    ```

  - Save the `docker-compose.yml` file.

  This `docker-compose.yml` file defines a service named `app` with the following configuration:
  - Builds the Docker image using the `Dockerfile` located at `8 - Build Automation & CI-CD with Jenkins/jenkins-exercises/Dockerfile`.
  - Maps port 3000 from the container to port 3000 on the host machine.
  - Sets the `NODE_ENV` environment variable to `development`.

  > [!NOTE]
  > The `volumes` section from the previous `docker-compose.yml` file has been removed to avoid potential conflicts with the files copied by the Dockerfile. If you need to persist specific data or directories, you can add volume mappings for those specific paths.

- [x] Task 4: Review the `docker-compose.yml` file
  - Verify that the `docker-compose.yml` file is structured correctly and includes the necessary configuration for your NodeJS application.
  - Ensure that the `build` section correctly references the Dockerfile path relative to the build context.
  - Check that the `ports` section maps the appropriate port from the container to the desired port on the host machine.
  - Review the `environment` section and ensure that any required environment variables are properly defined.

- [x] Task 5: Build and run the Docker container using Docker Compose
  - Open a terminal and navigate to the directory containing the `docker-compose.yml` file.
  - Run the following command to build the Docker image and start the container:

    ```bash
    docker-compose up -d
    ```

  - Docker Compose will build the image based on the `Dockerfile` and start the container in detached mode (`-d` flag).

- [x] Task 6: Verify the running container
  - Run the following command to list the running containers:

    ```bash
    docker ps
    ```

  - Verify that the container for your NodeJS application is listed and running.
  - Open a web browser and visit `http://localhost:3000` to ensure that your application is accessible.

> [!IMPORTANT]
> **It's important to note that the `docker init` command may generate a Dockerfile with `CMD npm start` instead of `CMD ["npm", "start"]`. While both forms are valid, there is a difference in how they are executed by the Docker container.**
>
> - **`CMD ["npm", "start"]` (exec form):**
>   - **This form specifies the command as a JSON array, where each element is a separate string.**
>   - **The command is executed directly, without invoking a shell.**
>   - **It is the recommended form for executing commands in Docker as it avoids shell interpretation and potential command injection vulnerabilities.**
>
> - **`CMD npm start` (shell form):**
>   - **This form specifies the command as a plain string.**
>   - **The command is executed using the default shell (`/bin/sh -c`) inside the container.**
>   - **Using the shell form can be useful when you need shell features like environment variable expansion or command chaining.**
>
> **In most cases, it is recommended to use the exec form (`CMD ["npm", "start"]`) for clarity, control, and security. However, if the generated Dockerfile uses the shell form, it is important to review and modify it to ensure it aligns with your application's requirements and best practices.**

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

### Configure Jenkins to Access Docker Hub Repository

- [x] Task 1: Create credentials for Docker Hub in Jenkins
  - Open the Jenkins web interface.
  - Go to "Manage Jenkins" > "Manage Credentials".
  - Click on "Global" or the appropriate domain.
  - Click on "Add Credentials".
  - Select "Username with password" as the kind.
  - Enter your Docker Hub username and password.
  - Check the "Treat username as a secret" checkbox to ensure the username is stored securely. (optional)
  - Provide an ID for the credentials (e.g., "dockerhub-credentials").
  - In the "Description" field, provide a description for the credential.
  - Click "OK" to save the credentials.

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

### Configuring Environment Variables in Jenkins Pipeline

To use the environment variables (`DOCKERHUB_REPO`, `DOCKERHUB_USERNAME`, `GITHUB_REPO_URL`) defined in the `environment` block of the Jenkinsfile, you need to create corresponding credential entries in Jenkins. Follow these steps to configure the environment variables:

- [x] Task 1: Open the Jenkins web interface and navigate to the credentials page
  - In the Jenkins dashboard, click on "Manage Jenkins" in the left sidebar.
  - Click on "Manage Credentials" under the "Security" section.
  - Click on "Jenkins" under "Stores scoped to Jenkins".
  - Click on "Global credentials (unrestricted)".
  - Click on the "Add Credentials" link on the right side.

- [x] Task 2: Create credential entries for each environment variable
  - For `DOCKERHUB_REPO`:
    - Kind: Select "Secret text".
    - Scope: Select "Global".
    - Secret: Enter the value for your Docker Hub repository name.
    - ID: Enter "DOCKERHUB_REPO".
    - Description: Provide a meaningful description for the credential, such as "Docker Hub repository name for the NodeJS application".
    - Click on the "Create" button to save the credential.

  - For `DOCKERHUB_USERNAME`:
    - Kind: Select "Secret text".
    - Scope: Select "Global".
    - Secret: Enter the value for your Docker Hub username.
    - ID: Enter "DOCKERHUB_USERNAME".
    - Description: Provide a meaningful description for the credential, such as "Docker Hub username for publishing the NodeJS application image".
    - Click on the "Create" button to save the credential.

  - For `GITHUB_REPO_URL`:
    - Kind: Select "Secret text".
    - Scope: Select "Global".
    - Secret: Enter the URL of your GitHub repository.
    - ID: Enter "GITHUB_REPO_URL".
    - Description: Provide a meaningful description for the credential, such as "GitHub repository URL for the NodeJS application source code".
    - Click on the "Create" button to save the credential.

- [x] Task 3: Use the configured credentials in the Jenkinsfile
  - In the Jenkinsfile, you can access the values of the environment variables using the `credentials()` function with the respective credential IDs. For example:

    ```groovy
    environment {
      DOCKERHUB_REPO = credentials('DOCKERHUB_REPO')
      DOCKERHUB_USERNAME = credentials('DOCKERHUB_USERNAME')
      GITHUB_REPO_URL = credentials('GITHUB_REPO_URL')
    }
    ```

  - Jenkins will retrieve the corresponding values from the configured credentials and assign them to the environment variables during the pipeline execution.

> [!NOTE]
> **Make sure to replace the placeholders (Docker Hub repository name, Docker Hub username and password, GitHub repository URL) with your actual values when creating the credentials.**

## Exercise 2

- [x] Task 1: Create the Jenkinsfile
  - In your local development environment, create a new file named "Jenkinsfile" in the root directory of your NodeJS application repository.
  - Open the Jenkinsfile in an IDE or text editor.
  
- [x] Task 2: Define the pipeline stages
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
          echo 'Increment the application version...'
          // Increment the application version
          // You can use a npm package like 'npm-version' or write a custom script to increment the version
          // Example: sh 'npm run version:increment'
        }

      }

    }

    stage('Run Tests') {

      steps {

        script {
          echo 'Run tests for the application...'
          // Run tests for the application
          // Example: sh 'npm test'
        }

      }

    }

    stage('Build Image') {

      steps {

        script {
          echo 'Build the Docker image with the incremented version...'
          // Build the Docker image with the incremented version
          // Example: sh 'docker build -t myapp:${version} .'
        }

      }

    }

    stage('Push Image') {

      steps {

        script {
          echo 'Push the Docker image to a registry...'
          // Push the Docker image to a registry
          // Example: sh 'docker push myapp:${version}'
        }

      }

    }

    stage('Commit Version') {

      steps {

        script {
          echo 'Commit the version increment to Git...'
          // Commit the version increment to Git
          // Example:
          // sh 'git add package.json'
          // sh 'git commit -m "Increment version to ${version}"'
          // sh 'git push origin main'
        }

      }
      
    }
    ```

  - We will customize the steps within each stage according to the specific requirements in the exercise.

- [x] Task 3: Set up the Jenkins pipeline
  - Open the Jenkins web interface.
  - Click on "New Item" in the left sidebar.
  - Enter a name for your pipeline (e.g., "nodejs-app-pipeline") and select "Pipeline" as the item type.
  - Click "OK" to create the pipeline.

- [x] Task 4: Configure the Jenkins job to access the GitHub repository
  - **Open the Jenkins job configuration:**
    - Navigate to the Jenkins job you want to configure.
    - Click on "Configure" in the left sidebar.

  - **Configure the Pipeline:**
    - Scroll down to the "Pipeline" section.
    - In the "Definition" field, select "Pipeline script from SCM".
    - In the "SCM" field, select "Git".

  - **Configure the Git repository:**
    - In the "Repository URL" field, enter the URL of your GitHub repository. In this case:
      `https://github.com/karanthakakr04/devops-bootcamp-exercises.git`
    - In the "Credentials" dropdown, select the GitHub token credential you created earlier (e.g., "username/******").
    - Leave the "Branch Specifier" field as "*/main" or change to whatever branch you want to use.

  - **Configure the script path:**
    - In the "Script Path" field, provide the relative path to the `Jenkinsfile` within the repository. In this case, it is:
      `8 - Build Automation & CI-CD with Jenkins/jenkins-exercises/Jenkinsfile`

  - **Enable lightweight checkout (optional):**
    - If desired, you can enable the "Lightweight checkout" option to optimize the checkout process.

  - **Save the job configuration:**
    - Click on the "Save" button to apply the changes.

- [x] Task 5: Verify the configuration
  - **Run the Jenkins job:**
    - Navigate to the Jenkins job.
    - Click on "Build Now" to trigger a new build.

  - **Check the build log:**
    - Once the build starts, click on the build number to view its details.
    - Click on the "Console Output" to view the build log.
    - Verify that Jenkins is able to access the GitHub repository and locate the `Jenkinsfile`.

    ![Pipeline Configuration](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/109099be-5381-4c93-9ad1-6c7ae66c1d9a)

- [x] Task 6: Implement version incrementing
  - Update the `Increment Version` stage in the Jenkinsfile to include the following steps:
    - Change the current directory to the `8 - Build Automation & CI-CD with Jenkins/jenkins-exercises/app` folder using the `dir` command. This is necessary because the `package.json` file, which contains the version information, is located inside the `app` folder.

      ```groovy
      dir('8 - Build Automation & CI-CD with Jenkins/jenkins-exercises/app') {
        // Version increment steps will be added here
      }
      ```

    - Add a check to verify if the `package.json` file exists in the `app` directory. If the file is not found, throw an error and stop the pipeline execution.

      ```groovy
      if (fileExists('package.json')) {
        // Version increment steps
      } else {
        error "package.json file not found in the app directory"
      }
      ```

    - Prompt the user to select the version increment type (patch, minor, or major) using the `input` function. This allows for flexibility in choosing the appropriate version increment based on the changes made to the application.
      - Use the `id` parameter to provide a unique identifier for the input prompt.
      - Use the `message` parameter to display a message to the user, indicating what they need to select.
      - Use the `ok` parameter to customize the label of the "OK" button in the input prompt.
      - Use the `parameters` parameter to define the available version increment types as a choice parameter. The user will be presented with a dropdown menu to select from the available options.

      ```groovy
      def versionType = input(
        id: 'versionType',
        message: 'Select the version increment type:',
        ok: 'Increment',
        parameters: [
          choice(
            name: 'type', 
            choices: [
              'patch', 
              'minor', 
              'major'
            ], 
            description: 'Version increment type'
          )
        ]
      )
      ```

    - Store the selected version increment type in the `versionType` variable. This variable will be used later to increment the version using the `npm version` command.
    - Execute the `npm version` command with the selected `versionType` to increment the version in the `package.json` file. The `npm version` command automatically updates the `version` field in `package.json` based on the specified increment type.

      ```groovy
      sh "npm version ${versionType}"
      ```

    - Read the updated `package.json` file using the `readJSON` function from the Pipeline Utility Steps plugin. This function parses the JSON content of `package.json` and returns it as a Groovy object.
      - Make sure you have the "Pipeline Utility Steps" plugin installed in Jenkins. You can check this by going to "Manage Jenkins" > "Manage Plugins" and searching for the plugin.

      ```groovy
      def packageJson = readJSON file: 'package.json'
      ```

    - Extract the incremented application version from `packageJson.version` and store it in the `appVersion` variable. This variable will be used to create the image version.
    - Retrieve the current build number using the `env.BUILD_NUMBER` variable. Jenkins automatically assigns a unique build number to each build, which can be accessed through this environment variable.
    - Construct the image version by combining the `appVersion` and `buildNumber` in the format `"${appVersion}-${buildNumber}"`. This ensures that each image version includes both the application version and the unique build number.
    - Store the constructed image version in the `env.IMAGE_VERSION` environment variable. This variable will be used in subsequent stages, such as building the Docker image.

      ```groovy
      def appVersion = packageJson.version
      def buildNumber = env.BUILD_NUMBER
      def imageVersion = "${appVersion}-${buildNumber}"
      env.IMAGE_VERSION = imageVersion
      ```

  - Best practices:
    - Use meaningful names for variables and environment variables to enhance code readability. For example, `appVersion`, `buildNumber`, and `imageVersion` clearly indicate what each variable represents.
    - Parameterize the pipeline by allowing user input for the version increment type. This makes the pipeline more flexible and reusable, as the version can be incremented based on the specific requirements of each build.
    - Store important values like the application version and image version in environment variables (`env.IMAGE_VERSION`). This allows easy access to these values across different stages of the pipeline.
    - Use the `dir` command to change the directory context when necessary. This ensures that commands are executed in the correct location, such as the `app` folder where the `package.json` file and Dockerfile are located.
    - Utilize ***Pipeline Utility Steps*** plugin functions like `readJSON` and `writeJSON` to read and write JSON files. These functions simplify file manipulations and make the code more readable.

     ![Pipeline Utility Plugin Install](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/e0a96828-03d9-41f1-9cef-7525f821c112)

  - Add the `tools` block in the pipeline to specify the Node.js installation:
    - The `tools` block is used to define the tools and their versions required for the pipeline.
    - In this case, we specify the Node.js installation by adding `nodejs 'node'` inside the `tools` block.
  - Add the `environment` block in the pipeline to define environment variables:
    - The `environment` block is used to define environment variables that can be accessed throughout the pipeline.
    - In this case, we use the `credentials()` function to securely retrieve the values of `DOCKERHUB_REPO`, `DOCKERHUB_USERNAME`, and `GITHUB_REPO_URL` from Jenkins credentials and assign them to environment variables.
  - Make sure you have the Node.js plugin installed in Jenkins and a Node.js installation configured with the name 'node' in the Jenkins Global Tool Configuration.

    ```groovy
    pipeline {
        agent any
        
        tools {
            nodejs 'node' // Specify the Node.js installation name configured in Jenkins
        }
        
        environment {
            DOCKERHUB_REPO = credentials('DOCKERHUB_REPO') // Define environment variable for Docker Hub repository
            DOCKERHUB_USERNAME = credentials('DOCKERHUB_USERNAME') // Define environment variable for Docker Hub username
            GITHUB_REPO_URL = credentials('GITHUB_REPO_URL') // Define environment variable for GitHub repository URL
        }
        
        stages {
            // ...
            
            stage('Increment Version') {
                steps {
                    script {
                        dir('8 - Build Automation & CI-CD with Jenkins/jenkins-exercises/app') {
                            // ...
                        }
                    }
                }
            }
            
            // ...
        }
    }
    ```

    ![Node.js Plugin Installation](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/3e51dc7d-c321-44ab-b36e-3c45f15fa2f2)

    ![Jenkins Global Tools Configuration](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/b7a347a9-f0a1-48e5-a7d6-cf7e305eb7b1)

  - Jenkinsfile configuration for `stage('Increment Version')`:

    ```groovy
    pipeline {
      agent any

      tools {
        nodejs 'node'
      }

      environment {
        DOCKERHUB_REPO = credentials('DOCKERHUB_REPO')
        DOCKERHUB_USERNAME = credentials('DOCKERHUB_USERNAME')
        GITHUB_REPO_URL = credentials('GITHUB_REPO_URL')
      }

      stages {
        // ...

        stage('Increment Version') {
            steps {
                script {
                    echo 'Increment the application version...'
                    dir('8 - Build Automation & CI-CD with Jenkins/jenkins-exercises/app') {
                        if (fileExists('package.json')) {
                            def versionType = input(
                                id: 'versionType',
                                message: 'Select the version increment type:',
                                ok: 'Increment',
                                parameters: [
                                    choice(
                                        name: 'type',
                                        choices: ['patch', 'minor', 'major'],
                                        description: 'Version increment type'
                                    )
                                ]
                            )
                            sh "npm version ${versionType}"
                            def packageJson = readJSON file: 'package.json'
                            def appVersion = packageJson.version
                            def buildNumber = env.BUILD_NUMBER
                            def imageVersion = "${appVersion}-${buildNumber}"
                            env.IMAGE_VERSION = imageVersion
                        } else {
                            error "package.json file not found in the app directory"
                        }
                    }
                }
            }
        }

        // ...
      }

    }
    ```

- [x] Task 7: Run tests
  - Update the Jenkinsfile to include a new stage for running tests:
    - Add a new stage called "Run Tests" after the "Increment Version" stage.
    - Inside the "Run Tests" stage, use the `steps` block to define the steps for running tests.
    - Use the `script` block to write Groovy code for executing shell commands and handling directory navigation.

      ```groovy
      stage('Run Tests') {
        steps {
          script {
            // Test execution steps will be added here
          }
        }
      }
      ```

  - Navigate to the `8 - Build Automation & CI-CD with Jenkins/jenkins-exercises/app` directory:
    - Use the `dir` command to change the current working directory to the `8 - Build Automation & CI-CD with Jenkins/jenkins-exercises/app` folder.
    - This is necessary because the `package.json` file, which contains the dependencies and test scripts, is located inside the `app` folder.

      ```groovy
      dir('8 - Build Automation & CI-CD with Jenkins/jenkins-exercises/app') {
        // Package installation and test execution steps will be added here
      }
      ```

  - Install the project dependencies:
    - Use the `sh` command to execute the `npm install` command.
    - This command reads the `package.json` file and installs all the required dependencies listed in the `dependencies` and `devDependencies` sections.
    - Installing the dependencies ensures that all the necessary packages are available for running tests and building the application.

      ```groovy
      sh 'npm install'
      ```

  - Run the tests and handle test failures:
    - Use the `catchError` block to have a `buildResult` of `'SUCCESS'` and a `stageResult` of `'FAILURE'` wrap the test execution command.
    - Inside the `catchError` block, use a `script` block to execute the `npm test` command with the `--detectOpenHandles` flag. Store the exit status of the command in a variable named `testResult`.
    - Check the value of `testResult`. If it is not equal to 0 (indicating test failures), throw an error with an appropriate message.
    - Use the `error` command inside the `catchError` block to mark the build as failed and provide an appropriate error message.
    - The `error` command will abort the pipeline and prevent further execution of subsequent stages.

      ```groovy
      catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
        script {
          def testResult = sh(script: 'npm test -- --detectOpenHandles', returnStatus: true)
          if (testResult != 0) {
            error "Tests failed. Please fix the failing tests and rerun the pipeline."
          }
        }
      }
      ```

  - Best practices:
    - Use the `dir` command to navigate to the correct directory before executing commands. This ensures that the commands are run in the appropriate context and avoids issues related to incorrect file paths.
    - Run the tests before building the Docker image. This allows for early detection of test failures and prevents building and deploying a faulty application.
    - Use the `catchError` block to handle test failures gracefully. If the tests fail, the pipeline will be aborted, and an appropriate error message will be displayed.
    - Consider running tests in parallel if you have a large test suite. This can significantly reduce the overall execution time of the pipeline. You can use Jenkins plugins like "Parallel Test Executor" to achieve this.

  - Jenkinsfile configuration for `stage('Run Tests')`:

    ```groovy
    stage('Run Tests') {
      steps {
        script {
          echo 'Run tests for the application...'
          dir('8 - Build Automation & CI-CD with Jenkins/jenkins-exercises/app') {
            sh 'npm install'
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              script {
                def testResult = sh(script: 'npm test -- --detectOpenHandles', returnStatus: true)
                if (testResult != 0) {
                  error "Tests failed. Please fix the failing tests and rerun the pipeline."
                }
              }
            }
          }
        }
      }
    }
    ```

- [x] Task 8: Build Docker image
  - Update the Jenkinsfile to include a new stage for building the Docker image:
    - Add a new stage called "Build Image" after the "Run Tests" stage.
    - Inside the "Build Image" stage, use the `steps` block to define the steps for building the Docker image.
    - Use the `script` block to write Groovy code for executing shell commands.

      ```groovy
      stage('Build Image') {
        steps {
          script {
            // Docker image build steps will be added here
          }
        }
      }
      ```

  - Build the Docker image:
    - Use the `sh` command to execute the `docker build` command.
    - Specify the path to the `Dockerfile` using the `-f` flag. In this case, the `Dockerfile` is located in the `8 - Build Automation & CI-CD with Jenkins/jenkins-exercises` directory.
    - Use the `-t` flag to provide a tag for the Docker image. The tag should include the Docker Hub username (`${DOCKERHUB_USERNAME}`), the repository name (`${DOCKERHUB_REPO}`), and the version number (`${IMAGE_VERSION}`).
    - The `DOCKERHUB_USERNAME` and `DOCKERHUB_REPO` environment variables are used to dynamically set the Docker Hub username and repository name.

      ```groovy
      sh "docker build -t ${DOCKERHUB_USERNAME}/${DOCKERHUB_REPO}:${IMAGE_VERSION} -f Dockerfile ."
      ```

  - Jenkinsfile configuration for `stage('Build Image')`:

    ```groovy
    stage('Build Image') {
      steps {
        script {
          echo 'Build the Docker image with the incremented version...'
          dir('8 - Build Automation & CI-CD with Jenkins/jenkins-exercises') {
            sh "docker build -t ${DOCKERHUB_USERNAME}/${DOCKERHUB_REPO}:${IMAGE_VERSION} -f Dockerfile ."
          }
        }
      }
    }
    ```

- [x] Task 9: Push Docker image
  - Update the Jenkinsfile to include a new stage for pushing the Docker image to Docker Hub:
    - Add a new stage called "Push Image" after the "Build Image" stage.
    - Inside the "Push Image" stage, use the `steps` block to define the steps for pushing the Docker image.
    - Use the `script` block to write Groovy code for executing shell commands.

      ```groovy
      stage('Push Image') {
        steps {
          script {
            // Docker login and push steps will be added here
          }
        }
      }
      ```

  - Log in to Docker Hub securely:
    - Use the `withCredentials` block to access the stored Docker Hub credentials in Jenkins securely.
    - Inside the `withCredentials` block, use the `sh` command to execute the `docker login` command.
    - Pass the username and password credentials to the `docker login` command using the `$DOCKER_USERNAME` and `$DOCKER_PASSWORD` variables provided by the `withCredentials` block.
    - Use the `--password-stdin` flag to securely pass the password to the `docker login` command through standard input.

      ```groovy
      withCredentials([usernamePassword(credentialsId: 'docker-hub-access', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
        // perform docker login and docker push here
      }
      ```

    - Replace `'docker-hub-access'` with the ID of your Docker Hub credentials stored in Jenkins.

  - Push the Docker image to Docker Hub:
    - Use the `sh` command to execute the `docker push` command.
    - Use a multi-line string (`'''`) to write the shell commands for logging in to Docker Hub and pushing the Docker image.
    - Specify the image tag using the `${DOCKER_USERNAME}`, `${DOCKERHUB_REPO}`, and `${IMAGE_VERSION}` environment variables.

      ```groovy
      sh '''
        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
        docker push ${DOCKER_USERNAME}/${DOCKERHUB_REPO}:${IMAGE_VERSION}
      '''
      ```

  - Best practices:
    - Use the `withCredentials` block to securely access and manage the Docker Hub credentials stored in Jenkins. This ensures that the credentials are not exposed in the pipeline code or logs.
    - Pass the Docker Hub password to the `docker login` command using the `--password-stdin` flag. This prevents the password from being visible in the command line or build logs.
    - Consider using Docker Content Trust (DCT) to sign and verify the integrity of your Docker images. DCT ensures that the images are not tampered with during the push and pull processes.

  - Jenkinsfile configuration for `stage('Push Image')`:

    ```groovy
    stage('Push Image') {
      steps {
        script {
          echo 'Push the Docker image to a registry...'
          withCredentials([usernamePassword(credentialsId: 'docker-hub-access', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
            sh '''
                echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                docker push ${DOCKER_USERNAME}/${DOCKERHUB_REPO}:${IMAGE_VERSION}
            '''
          }
        }
      }
    }
    ```

- [x] Task 10: Commit version changes
  - Update the Jenkinsfile to include a new stage for committing the version changes to GitHub:
    - Add a new stage called "Commit Version" after the "Push Image" stage.
    - Inside the "Commit Version" stage, use the `steps` block to define the steps for committing the changes.
    - Use the `script` block to write Groovy code for executing shell commands and interacting with GitHub.

      ```groovy
      stage('Commit Version') {
        steps {
          script {
            // Git commit and push steps will be added here
          }
        }
      }
      ```

  - Configure Git user name and email:
    - Use the `sh` command to set the Git user name and email configuration.
    - This step is necessary to ensure that the commits are properly attributed to a user.

      ```groovy
      sh 'git config --global user.email "jenkins@example.com"'
      sh 'git config --global user.name "Jenkins"'
      ```

    - Replace `"jenkins@example.com"` with a suitable email address for your Jenkins user and `"Jenkins"` with an appropriate name.

  - Push the changes to GitHub (choose one of the following methods):

    **Method 1: Using `withCredentials` block**
    - Use the `withCredentials` block to securely access the GitHub credentials stored in Jenkins.
    - Inside the `withCredentials` block, use the `sh` command to execute the following steps:

      - Change the credential ID used in the `withCredentials` block to `'github-pat'`.

        ```groovy
        withCredentials([usernamePassword(credentialsId: 'github-pat', usernameVariable: 'GITHUB_USERNAME', passwordVariable: 'GITHUB_PAT')]) {
          // Commit steps
        }
        ```

      - Retrieve the GitHub repository URL from the `GITHUB_REPO_URL` environment variable and store it in a variable named `gitRepoUrl`.

        ```groovy
        def gitRepoUrl = env.GITHUB_REPO_URL
        ```

      - Use the environment variable `GITHUB_REPO_URL` to set the remote URL of the origin repository to use HTTPS protocol and the credentials variables:

        ```groovy
        sh "git remote set-url origin https://${GITHUB_USERNAME}:${GITHUB_PAT}@${gitRepoUrl.replace('https://', '')}"
        ```

      - Stage the `package.json` file using `git add`:

        ```groovy
        dir('8 - Build Automation & CI-CD with Jenkins/jenkins-exercises/app') {
          sh 'git add package.json'
        }
        ```

      - Commit the changes with a meaningful commit message, including the new version number:

        ```groovy
        sh "git commit -m 'Update version to ${IMAGE_VERSION}'"
        ```

      - Push the changes to the desired branch:

        ```groovy
        sh 'git push origin HEAD:main'
        ```

    - Replace `your-username` and `your-repository` with your GitHub username and repository name.

    **Method 2: Using `sshagent` block**
    - Use the `sshagent` block to securely access the SSH key for authentication with GitHub.
    - Inside the `sshagent` block, specify the ID of the SSH credential stored in Jenkins.
    - Use the `sh` command to execute the following steps:
      - Use the environment variable `GITHUB_REPO_URL` to set the remote URL of the origin repository to use SSH protocol:

        ```groovy
        sh "git remote set-url origin git@${GITHUB_REPO_URL}"
        ```

      - Stage the `package.json` file using `git add`:

        ```groovy
        dir('8 - Build Automation & CI-CD with Jenkins/jenkins-exercises/app') {
          sh 'git add package.json'
        }
        ```

      - Commit the changes with a meaningful commit message, including the new version number:

        ```groovy
        sh "git commit -m 'Update version to ${IMAGE_VERSION}'"
        ```

      - Push the changes to the desired branch:

        ```groovy
        sh 'git push origin HEAD:main'
        ```

    - Replace `your-username` and `your-repository` with your GitHub username and repository name.

  - Best practices:
    - Use meaningful commit messages that describe the changes made, including the new version number.
    - Keep the number of files committed in this stage minimal, focusing only on the version change in the `package.json` file.
    - Use either the `withCredentials` block with username and password or the `sshagent` block with SSH key for authentication, depending on your organization's structure and processes.
    - Avoid hardcoding sensitive information, such as credentials or SSH keys, directly in the Jenkinsfile. Instead, store them securely in Jenkins credentials and access them using the appropriate credential binding (`withCredentials` or `sshagent`).

  - Example Jenkinsfile code for Method 1 (`withCredentials`):

    ```groovy
    stage('Commit Version') {
      steps {
        script {
          echo 'Commit the version increment to Git...'
          sh 'git config --global user.email "jenkins@example.com"'
          sh 'git config --global user.name "Jenkins"'
          withCredentials([usernamePassword(credentialsId: 'github-pat', usernameVariable: 'GITHUB_USERNAME', passwordVariable: 'GITHUB_PAT')]) {
            script {
              def gitRepoUrl = env.GITHUB_REPO_URL
              sh "git remote set-url origin https://${GITHUB_USERNAME}:${GITHUB_PAT}@${gitRepoUrl.replace('https://', '')}"
            }
            dir('8 - Build Automation & CI-CD with Jenkins/jenkins-exercises/app') {
              sh 'git add package.json'
            }
            sh "git commit -m 'Update version to ${IMAGE_VERSION}'"
            sh 'git push origin HEAD:main'
          }
        }
      }
    }
    ```

  - Example Jenkinsfile code for Method 2 (`sshagent`):

    ```groovy
    stage('Commit Version') {
      steps {
        script {
          echo 'Commit the version increment to Git...'
          sh 'git config --global user.email "jenkins@example.com"'
          sh 'git config --global user.name "Jenkins"'
          sshagent(['github-ssh-credentials']) {
            sh "git remote set-url origin git@${GITHUB_REPO_URL}"
            dir('8 - Build Automation & CI-CD with Jenkins/jenkins-exercises/app') {
              sh 'git add package.json'
            }
            sh "git commit -m 'Update version to ${IMAGE_VERSION}'"
            sh 'git push origin HEAD:main'
          }
        }
      }
    }
    ```

> [!NOTE]
> **To use the `sshagent` block in your pipeline, ensure that you have the "SSH Agent Plugin" installed in Jenkins. You can install it by following these steps:**
>
> 1. **Navigate to the Jenkins web interface.**
> 2. **Go to "Manage Jenkins" > "Manage Plugins".**
> 3. **Click on the "Available" tab.**
> 4. **Search for "SSH Agent" in the search bar.**
> 5. **Check the checkbox next to the plugin and click on "Install".**
> 6. **Once the installation is complete, you can use the `sshagent` block in your pipeline.**

![sshagent plugin screenshot](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/41fdecc0-15f3-48da-bcf5-da676a910d13)

- [x] Task 11: Save and run the pipeline
  - Save the Jenkinsfile and commit it to your Git repository.
  - In the Jenkins web interface, navigate to your pipeline.
  - Click on "Build Now" to trigger the pipeline execution.
  - Monitor the pipeline stages and verify that each stage runs successfully.

> [!TIP]
> **You can enhance the pipeline further by adding error handling, notifications, or additional stages based on your specific requirements.**

## Exercise 3

- [x] Task 1: Access the DigitalOcean Droplet
  - Open a web browser and log in to your DigitalOcean account.
  - Navigate to the "Droplets" section in the DigitalOcean control panel.
  - Locate the droplet where you want to deploy the new Docker image.

- [x] Task 2: Configure Firewall Rules
  - In the DigitalOcean control panel, navigate to the "Networking" section.
  - Click on "Firewalls" to manage the firewall rules for your droplet.
  - Create a new firewall rule or update an existing one to allow inbound traffic on the necessary ports for your Docker application.
  - Ensure that the firewall rule is applied to the droplet where you will deploy the Docker image.
  - Save the firewall rule configuration.

- [x] Task 3: Connect to the Droplet via SSH
  - Open a terminal or command prompt on your local machine.
  - Use the SSH command with the `-i` flag to specify the path to your SSH private key:

    ```bash
    ssh -i <key-path> <username>@<droplet-ip-address>
    ```

  - Replace `<key-path>` with the path to your SSH private key file, `<username>` with the username for your droplet, and `<droplet-ip-address>` with the IP address of your droplet.
  - If your SSH key has a passphrase, enter it when prompted.

- [x] Task 4: Log in to Docker Hub
  - To log in to Docker Hub securely from inside the droplet, use the `docker login` command with the `--password-stdin` flag. This allows you to provide the password through standard input, avoiding the need to store it in the command history or expose it in the terminal.
  - Run the following command to log in to Docker Hub:

    ```bash
    echo "$DOCKER_HUB_PASSWORD" | docker login -u "<docker-hub-username>" --password-stdin
    ```

  - Replace `$DOCKER_HUB_PASSWORD` with the environment variable storing your Docker Hub password and `<docker-hub-username>` with your Docker Hub username.
  - The command will read the password from the environment variable and securely pass it to the `docker login` command.

> [!CAUTION]
> **Ensure that you have securely set the `DOCKER_HUB_PASSWORD` environment variable with your Docker Hub password before running the command. Avoid storing the password directly in script files or version control repositories.**

- [x] Task 5: Pull the New Docker Image from Private Repository
  - After logging in to Docker Hub, use the `docker pull` command to pull the new Docker image from your private repository:

    ```bash
    docker pull <docker-hub-username>/<repository>:<tag>
    ```

  - Replace `<docker-hub-username>` with your Docker Hub username, `<repository>` with the name of your private image repository, and `<tag>` with the specific tag of the new image you want to deploy.

- [x] Task 6: Stop and Remove the Existing Docker Container (if applicable)
  - If you have an existing Docker container running the previous version of your application, stop and remove it using the following commands:

    ```bash
    docker stop <container-name>
    docker rm <container-name>
    ```

  - Replace `<container-name>` with the name or ID of the existing container.

- [x] Task 7: Run the New Docker Container
  - Use the `docker run` command to start a new container based on the pulled Docker image:

    ```bash
    docker run -d --name <container-name> -p <host-port>:<container-port> <docker-hub-username>/<repository>:<tag>
    ```

  - Replace `<container-name>` with a desired name for the new container, `<host-port>` with the port number on the host machine to map to the container's exposed port, `<container-port>` with the port number exposed by the container, `<docker-hub-username>` with your Docker Hub username, `<repository>` with the name of your private image repository, and `<tag>` with the specific tag of the new image.
  - Adjust any additional configuration options as needed for your specific application.

- [x] Task 8: Verify the Deployment
  - Check the status of the newly created container using the `docker ps` command.
  - Verify that the container is running and mapped to the correct ports.
  - Access your application using the appropriate URL or IP address and port number to ensure it is functioning as expected.

- [x] Task 9: Clean Up (Optional)
  - If you have any old Docker images that are no longer needed, you can remove them to free up disk space:

    ```bash
    docker rmi <image-id>
    ```

  - Replace `<image-id>` with the ID of the Docker image you want to remove.
  - Be cautious when removing images, as they may be used by other containers or have dependencies.

> [!NOTE]
> **It's also important to ensure that your Docker application is properly configured to listen on the appropriate ports and that any required environment variables or configurations are properly set during the container creation process.**

### Jenkins Shared Library

Jenkins Shared Library is a powerful feature that allows you to create reusable code snippets, functions, and classes that can be shared across multiple Jenkins pipelines. It enables you to write common functionality once and use it in different pipelines, promoting code reuse, maintainability, and consistency.

#### Why Use Jenkins Shared Library?

There are several benefits of using Jenkins Shared Library:

1. **Code Reusability:** Instead of duplicating code across multiple pipelines, you can extract common functionality into a shared library and reuse it. This reduces duplication, makes your pipelines more concise, and simplifies maintenance.

2. **Modularity:** Shared libraries enable you to break down your pipeline logic into smaller, modular components. You can create separate functions or classes for specific tasks, making your pipeline code more organized and easier to understand.

3. **Consistency:** By centralizing common code in a shared library, you ensure that all pipelines using that library follow the same logic and behavior. This promotes consistency across your Jenkins pipelines and reduces the chances of errors or discrepancies.

4. **Maintainability:** When you need to update or fix a piece of code, you only need to modify it in the shared library, and all pipelines using that library will automatically inherit the changes. This makes maintaining and updating your pipelines much easier.

#### How Does Jenkins Shared Library Work?

Jenkins Shared Library is typically stored in a separate source code repository, such as Git. The library contains reusable code, usually written in Groovy, that can be called from Jenkins pipelines.

The shared library repository follows a specific directory structure:

```plaintext
jenkins-shared-library/
├── src/
│   └── org/
│       └── example/
│           ├── BuildUtils.groovy
│           ├── DeployUtils.groovy
│           └── ...
├── vars/
│   ├── buildApp.groovy
│   ├── deployApp.groovy
│   └── ...
└── resources/
    └── ...
```

- The `src` directory contains custom Groovy classes or utility functions that can be used in pipelines.
- The `vars` directory contains global variables, which are essentially Groovy scripts that define global functions or variables accessible in pipelines.
- The `resources` directory can contain non-Groovy files, such as configuration files or templates, that can be used in pipelines.

To use a shared library in a Jenkins pipeline, you need to configure Jenkins to recognize the library. This is done by adding the library configuration in the Jenkins system settings or in the pipeline script itself using the `@Library` annotation.

```groovy
@Library('my-shared-library') _
```

Once the library is configured, you can call the functions or classes defined in the library from your pipeline script.

```groovy
stage('Pipeline Initialization') {
    steps {
        script {
            def buildUtils = new org.example.BuildUtils()
            buildUtils.buildApp()
        }
    }
}
```

In this example, we import the `BuildUtils` class from the shared library and call the `buildApp()` function defined in that class.

#### Best Practices

When using Jenkins Shared Library, consider the following best practices:

1. **Version Control:** Store your shared library in a version control system, such as Git, to track changes, collaborate with others, and manage different versions of the library.

2. **Documentation:** Provide clear documentation for your shared library, including usage instructions, function descriptions, and examples. This helps other team members understand and utilize the library effectively.

3. **Testing:** Write unit tests for your shared library code to ensure its correctness and reliability. You can use testing frameworks like JUnit or Spock to test your Groovy code.

4. **Versioning:** Use versioning for your shared library to manage different releases and ensure compatibility with pipelines. You can tag specific versions of the library and reference them in your pipelines.

5. **Modularity:** Design your shared library in a modular way, separating different functionalities into distinct classes or scripts. This promotes reusability and makes it easier to maintain and update the library.

6. **Security:** Be cautious when using shared libraries, especially if they contain sensitive information or perform critical operations. Ensure that the library code is secure, follows best practices, and has appropriate access controls.

By leveraging Jenkins Shared Library, you can create a collection of reusable code that streamlines your pipeline development, promotes code reuse, and enhances the maintainability and consistency of your Jenkins pipelines.

## Exercise 4

- [x] Task 1: Create a new repository for the Jenkins Shared Library
  - Go to your GitHub account and create a new repository for the Jenkins Shared Library.
  - Choose a meaningful name for the repository, such as "jenkins-shared-library".
  - Initialize the repository with a README file.

- [x] Task 2: Set up the directory structure for the Jenkins Shared Library
  - Clone the newly created Jenkins Shared Library repository to your local machine.
  - Create the necessary directory structure for the Jenkins Shared Library:

    ```plaintext
    jenkins-shared-library/
    ├── vars/
    │   └── buildPipeline.groovy
    ├── src/
    │   └── org/
    │       └── example/
    │           ├── BuildStage.groovy
    │           ├── CommitStage.groovy
    │           ├── PushStage.groovy
    │           ├── TestStage.groovy
    │           └── VersioningStage.groovy
    └── README.md
    ```

  - The `vars` directory will contain the global variables and functions that can be called from the pipeline.
  - The `src` directory will contain the reusable code for different stages of the pipeline, organized in a package structure.
  - The `README.md` file will provide documentation and usage instructions for the shared library.

- [x] Task 3: Extract the logic for the versioning stage
  - In the Jenkins Shared Library repository, create a new file named `VersioningStage.groovy` under the `src/org/example` directory.
  - Move the logic for the versioning stage from the Jenkinsfile to `VersioningStage.groovy`.
  - Modify the code to accept parameters and make it reusable.
  - Example:

    ```groovy
    #!/usr/bin/env groovy
    package org.example

    def call() {
      echo 'Increment the application version...'
      dir('8 - Build Automation & CI-CD with Jenkins/jenkins-exercises/app') {
        if (fileExists('package.json')) {
          def versionType = input(
            id: 'versionType',
            message: 'Select the version increment type:',
            ok: 'Increment',
            parameters: [
              choice(name: 'type', choices: ['patch', 'minor', 'major'], description: 'Version increment type')
            ]
          )
          sh "npm version ${versionType}"
          def packageJson = readJSON file: 'package.json'
          def appVersion = packageJson.version
          def buildNumber = env.BUILD_NUMBER
          def imageVersion = "${appVersion}-${buildNumber}"
          env.IMAGE_VERSION = imageVersion
        } else {
          error "package.json file not found in the app directory"
        }
      }
    }
    ```

    Explanation:
    - The script defines a `call` method that takes a `versionIncrement` parameter.
    - It prompts the user to select the version increment type using the `input` step.
    - It executes the `npm version` command with the selected version type.
    - It reads the updated `package.json` file and extracts the app version.
    - It combines the app version and build number to create the image version.
    - The image version is stored in the `env.IMAGE_VERSION` environment variable.

- [x] Task 4: Extract the logic for the test stage
  - In the Jenkins Shared Library repository, create a new file named `TestStage.groovy` under the `src/org/example` directory.
  - Move the logic for the test stage from the Jenkinsfile to `TestStage.groovy`.
  - Modify the code to make it reusable.
  - Example:

    ```groovy
    #!/usr/bin/env groovy
    package org.example

    def call() {
      echo 'Run tests for the application...'
      dir('8 - Build Automation & CI-CD with Jenkins/jenkins-exercises/app') {
        sh 'npm install'
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          script {
            def testResult = sh(script: 'npm test -- --detectOpenHandles', returnStatus: true)
            if (testResult != 0) {
              error "Tests failed. Please fix the failing tests and rerun the pipeline."
            }
          }
        }
      }
    }
    ```

    Explanation:
    - The script defines a `call` method that runs tests for the application.
    - It navigates to the `app` directory and installs dependencies using `npm install`.
    - It executes the `npm test` command within a `catchError` block.
    - If the tests fail, it throws an error with a message indicating the failure.

- [x] Task 5: Extract the logic for the build stage
  - In the Jenkins Shared Library repository, create a new file named `BuildStage.groovy` under the `src/org/example` directory.
  - Move the logic for the build stage from the Jenkinsfile to `BuildStage.groovy`.
  - Modify the code to accept parameters and make it reusable.
  - Example:

    ```groovy
    #!/usr/bin/env groovy
    package org.example

    def call(String dockerhubUsername, String dockerhubRepo, String imageTag) {
      echo 'Build the Docker image with the incremented version...'
      dir('8 - Build Automation & CI-CD with Jenkins/jenkins-exercises') {
        sh "docker build -t ${dockerhubUsername}/${dockerhubRepo}:${imageTag} -f Dockerfile ."
      }
    }
    ```

    Explanation:
    - The script defines a `call` method that takes `dockerhubRepo`, `dockerhubUsername` and `imageTag` parameters.
    - It builds the Docker image using the `docker build` command with the provided repository name and image tag.

- [x] Task 6: Extract the logic for the deploy stage
  - In the Jenkins Shared Library repository, create a new file named `PushStage.groovy` under the `src/org/example` directory.
  - Move the logic for the deploy stage from the Jenkinsfile to `PushStage.groovy`.
  - Modify the code to accept parameters and make it reusable.
  - Example:

    ```groovy
    #!/usr/bin/env groovy
    package org.example

    def call(String dockerhubUsername, String dockerhubRepo, String imageTag) {
      echo 'Push the Docker image to a registry...'
      withCredentials([usernamePassword(credentialsId: 'docker-hub-access', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
        sh '''
          echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
          docker push ${dockerhubUsername}/${dockerhubRepo}:${imageTag}
        '''
      }
    }
    ```

    Explanation:
    - The script defines a `call` method that takes `dockerhubRepo`, `dockerhubUsername` and `imageTag` parameters.
    - It uses the `withCredentials` block to securely access the Docker Hub credentials.
    - It logs in to Docker Hub using the provided credentials.
    - It pushes the Docker image to the specified repository with the provided image tag.

- [x] Task 7: Extract the logic for the commit stage
  - In the Jenkins Shared Library repository, create a new file named `CommitStage.groovy` under the `src/org/example` directory.
  - Move the logic for the commit stage from the Jenkinsfile to `CommitStage.groovy`.
  - Modify the code to accept parameters and make it reusable.
  - Example:

    ```groovy
    #!/usr/bin/env groovy
    package org.example

    def call(String imageVersion, String githubRepoUrl) {
      echo 'Commit the version increment to Git...'
      sh 'git config --global user.email "jenkins@example.com"'
      sh 'git config --global user.name "Jenkins"'
      withCredentials([usernamePassword(credentialsId: 'github-pat', usernameVariable: 'GITHUB_USERNAME', passwordVariable: 'GITHUB_PAT')]) {
        def gitRepoUrl = githubRepoUrl
        sh "git remote set-url origin https://${GITHUB_USERNAME}:${GITHUB_PAT}@${gitRepoUrl.replace('https://', '')}"
        dir('8 - Build Automation & CI-CD with Jenkins/jenkins-exercises/app') {
          sh 'git add package.json'
        }
        sh "git commit -m 'Update version to ${imageVersion}'"
        sh 'git push origin HEAD:main'
      }
    }
    ```

    Explanation:
    - The script defines a `call` method that takes an `imageVersion` parameter.
    - It uses the `withCredentials` block to securely access the GitHub credentials.
    - It sets the Git user email and name.
    - It updates the remote URL of the Git repository with the GitHub credentials.
    - It adds the `package.json` file to the staging area.
    - It commits the changes with a message indicating the version update.
    - It pushes the changes to the `main` branch of the remote repository.

- [x] Task 8: Create a global variable for the pipeline
  - In the Jenkins Shared Library repository, create a new file named `buildPipeline.groovy` under the `vars` directory.
  - Define a global variable that represents the entire pipeline.
  - Call the extracted stage functions from the global variable.
  - `pipelineParams.<parameter_name>` is used for custom parameters passed from the Jenkinsfile to the shared library function.

  - Example:

    ```groovy
    #!/usr/bin/env groovy

    def call(Map pipelineParams) {

      stage('Increment Version') {
        script {
          def versioningStage = new org.example.VersioningStage()
          versioningStage()
        }
      }

      stage('Run Tests') {
        script {
          def testStage = new org.example.TestStage()
          testStage()
        }
      }

      stage('Build Image') {
        script {
          def buildStage = new org.example.BuildStage()
          buildStage(pipelineParams.dockerhubUsername, pipelineParams.dockerhubRepo, env.IMAGE_VERSION)
        }
      }

      stage('Push Image') {
        script {
          def pushStage = new org.example.PushStage()
          pushStage(pipelineParams.dockerhubUsername, pipelineParams.dockerhubRepo, env.IMAGE_VERSION)
        }
      }

      stage('Commit Version') {
        script {
          def commitStage = new org.example.CommitStage()
          commitStage(env.IMAGE_VERSION, pipelineParams.githubRepoUrl)
        }
      }
    }
    ```

    Explanation:
    - The script defines a `call` method that takes a `pipelineParams` map.
    - It uses the declarative pipeline syntax to define the pipeline structure.
    - The pipeline consists of five stages: "Increment Version", "Run Tests", "Build Image", "Push Image", and "Commit Version".
    - Each stage instantiates the corresponding stage class and calls its `call` method with the required parameters.

- [x] Task 9: Update the Jenkinsfile to use the Jenkins Shared Library
  - Open the Jenkinsfile in your application repository.
  - Remove the extracted logic from the Jenkinsfile.
  - Add the necessary configuration to use the Jenkins Shared Library from the separate repository.
  - Call the global pipeline variable from the Jenkinsfile.
  - Example:

    ```groovy
    #!/usr/bin/env groovy

    @Library('jenkins-shared-library') _

    pipeline {
      agent any

      tools {
        nodejs 'node'
      }

      environment {
        DOCKERHUB_REPO = credentials('DOCKERHUB_REPO')
        DOCKERHUB_USERNAME = credentials('DOCKERHUB_USERNAME')
        GITHUB_REPO_URL = credentials('GITHUB_REPO_URL')
      }

      stages {
        stage('Pipeline Initialization') {
          steps {
            script {
              buildPipeline(
                dockerhubRepo: env.DOCKERHUB_REPO,
                dockerhubUsername: env.DOCKERHUB_USERNAME,
                githubRepoUrl: env.GITHUB_REPO_URL
              )
            }
          }
        }
      }
    }
    ```

    Explanation:
    - The `@Library` annotation is used to import the Jenkins Shared Library.
    - The `_` symbol is used as a placeholder to avoid naming conflicts with other annotations or steps.
    - The `DOCKERHUB_REPO` and `DOCKERHUB_USERNAME` environment variables are defined using the `credentials` function to securely fetch the value from Jenkins credentials.
    - The `buildPipeline` global variable is called with the desired version increment type, `DOCKERHUB_REPO` value and `DOCKERHUB_USERNAME` value.

- [x] Task 10: Configure Jenkins to use the Shared Library
  - Open the Jenkins web interface.
  - Go to "Manage Jenkins" > "System Configuration" > "Global Pipeline Libraries".
  - Click on "Add" to add a new library.
  - Provide a name for the library, such as "jenkins-shared-library".
  - In the "Default version" field, specify the branch or tag of your shared library repository to use as the default version (e.g., "main").
  - In the "Retrieval method" section, select "Modern SCM".
  - Choose "Git" as the Source Code Management tool.
  - In the "Project Repository" field, provide the URL of your Jenkins Shared Library repository (e.g., "<https://github.com/username/jenkins-shared-library.git>").
  - In the "Credentials" field, select the appropriate credentials for accessing the shared library repository. If you haven't added the credentials yet, click on the "Add" button and provide the necessary details (e.g., username and password or SSH key).
  - Leave the "Library Path" field as is (the default value is usually sufficient).
  - Optionally, you can choose to "Include @Library changes in job recent changes" by checking the corresponding checkbox.
  - If desired, you can also specify a custom "Changelog URL" and "Behavior" options.
  - Click on "Apply" to save the Global Pipeline Library configuration.
  - Your Jenkins instance is now configured to use the Jenkins Shared Library.

![Jenkins Shared Library Configuration screenshot](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/3c8f1c6e-8953-4acd-bcc2-7d8b04089dc9)

- [x] Task 11: Test the Jenkins Shared Library
  - Push the changes in the Jenkins Shared Library repository.
  - In Jenkins, navigate to your pipeline job.
  - Configure the job to use the updated Jenkinsfile that references the shared library.
  - Trigger a new build of the pipeline.
  - Verify that the pipeline executes successfully using the shared library code.

![Jenkins Pipeline Success Output screenshot](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/9f9295dc-94d4-4187-b474-cbbb596146f0)

### Additional Information

#### Environment Variables and Scope

Environment variables defined in the Jenkinsfile are accessible within the scope of that particular pipeline. They are not directly accessible by the scripts in the Jenkins Shared Library.

To pass environment variables from the Jenkinsfile to the shared library scripts, you can use parameters when calling the shared library functions. For example:

```groovy
// Jenkinsfile
environment {
  DOCKERHUB_REPO = credentials('DOCKERHUB_REPO')
  DOCKERHUB_USERNAME = credentials('DOCKERHUB_USERNAME')
  GITHUB_REPO_URL = credentials('GITHUB_REPO_URL')
}

stages {
  stage('Pipeline Initialization') {
    steps {
      buildPipeline(
        dockerhubRepo: env.DOCKERHUB_REPO
        dockerhubUsername: env.DOCKERHUB_USERNAME
        githubRepoUrl: env.GITHUB_REPO_URL
      )
    }
  }
}
```

In the shared library script (`buildPipeline.groovy`), you can access the passed environment variables using the `pipelineParams` map. For example:

```groovy
// buildPipeline.groovy
def call(Map pipelineParams) {
  pipeline {
    environment {
      IMAGE_NAME = "${pipelineParams.dockerhubRepo}"
      IMAGE_TAG = "${env.IMAGE_VERSION}"
    }

    // ...
  }
}
```

#### Jenkins Environment Variables

For more information about the available Jenkins environment variables that can be used in shell and batch build steps, navigate to the following URL within your Jenkins instance:

`env-vars.html/`

This URL provides details on the various environment variables accessible within Jenkins pipelines and how to use them effectively. Note that the base URL (e.g., `http://34.229.55.186:8080`) may vary depending on your Jenkins server configuration, but the `env-vars.html/` path remains constant.

![Jenkins Environment Variables screenshot](https://github.com/karanthakakr04/devops-bootcamp-exercises/assets/17943347/94bcfa0f-4c73-4485-80cd-b613d27d9cba)

#### Importing the Jenkins Shared Library

There are two common ways to import the Jenkins Shared Library in the Jenkinsfile:

1. Using the `@Library` annotation:

   ```groovy
   @Library('jenkins-shared-library') _
   ```

   This approach is concise and allows you to import the library at the global level in the Jenkinsfile. The `_` symbol is used as a placeholder to avoid naming conflicts with other annotations or steps.

2. Using the `library` step:

   ```groovy
   library identifier: 'jenkins-shared-library@main', retriever: modernSCM(
     [$class: 'GitSCMSource',
     remote: 'https://github.com/your-username/jenkins-shared-library.git',
     credentialsId: 'github-credentials'])
   ```

   This approach provides more flexibility and allows you to specify the library version, retrieval method, and additional configuration options.

Choose the approach that best fits your requirements and Jenkins setup.

#### Post Actions in the Pipeline

The `post` block in the pipeline allows you to define actions that should be executed based on the pipeline's status (success, failure, always, etc.). You can use the `post` block to perform additional actions, such as sending notifications, archiving artifacts, or cleaning up resources.

```groovy
post {
  success {
    echo 'Pipeline executed successfully!'
  }
  failure {
    echo 'Pipeline execution failed!'
  }
}
```

Customize the `post` block according to your specific requirements, such as sending email notifications, updating job status, or triggering downstream jobs.

#### Using Declarative Pipeline Syntax in Shared Libraries

Starting from Jenkins Pipeline 2.5, you can use the declarative pipeline syntax inside the shared library scripts. This allows you to encapsulate the pipeline structure and stages within the shared library, making it reusable across multiple pipelines.

In the `buildPipeline.groovy` script, the declarative pipeline syntax is used to define the pipeline structure and stages. This approach promotes code reusability and maintainability.

```groovy
def call(Map pipelineParams) {

    stage {
      // Pipeline stage
    }

}
```

Using declarative pipeline syntax in shared libraries offers several benefits:

1. **Encapsulation**: By defining the pipeline structure and stages within the shared library, you can encapsulate the logic and make it self-contained. This promotes a modular and reusable approach to pipeline development.

2. **Consistency**: Shared libraries with declarative pipeline syntax ensure that the pipeline structure and stages are consistent across multiple pipelines. This helps maintain uniformity and reduces the chances of errors or discrepancies.

3. **Parameterization**: You can define parameters in the shared library function to customize the behavior of the pipeline. This allows you to create flexible and configurable pipelines that can adapt to different scenarios.

4. **Readability**: Declarative pipeline syntax is more readable and easier to understand compared to scripted pipelines. It provides a clear and concise representation of the pipeline structure and stages.

5. **Maintainability**: With the pipeline logic encapsulated in the shared library, maintenance becomes easier. You can update and enhance the shared library code independently of the individual pipelines, and the changes will be reflected in all pipelines that use the shared library.

When using declarative pipeline syntax in shared libraries, keep in mind the following considerations:

- The shared library function should return a valid declarative pipeline.
- The pipeline configuration, stages, and post actions should be defined within the `pipeline` block.
- Parameters can be defined in the shared library function to customize the pipeline behavior.
- The shared library script should be compatible with the Jenkins Pipeline version and any required plugins.

By leveraging declarative pipeline syntax in shared libraries, you can create reusable and maintainable pipelines that adhere to a consistent structure and promote best practices in pipeline development.
