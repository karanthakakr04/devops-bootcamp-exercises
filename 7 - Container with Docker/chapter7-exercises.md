# TASK BREAK DOWN

## Exercise 1

- [x] Task 1: Clone the Git repository
  - **Clone the repository:**
    - Open a terminal or command prompt.
    - Run the following command to clone the repository:

      ```bash
      git clone https://gitlab.com/twn-devops-bootcamp/latest/07-docker/docker-exercises.git
      ```

    - Wait for the cloning process to complete.

  - **Navigate to the cloned directory:**
    - Change your current directory to the cloned repository:

      ```bash
      cd docker-exercises
      ```

- [x] Task 2: Create your own Git repository
  - **Create a new repository:**
    - Go to your preferred Git hosting platform (e.g., GitLab, GitHub).
    - Create a new empty repository for your Docker exercises.
    - Copy the repository URL for later use.

  - **Update the remote URL:**
    - In the terminal, run the following command to remove the existing remote:

      ```bash
      git remote remove origin
      ```

    - Add your newly created repository as the new remote:

      ```bash
      git remote add origin <your-repository-url>
      ```

    - Replace `<your-repository-url>` with the URL of your repository.

- [x] Task 3: Push the code to your repository
  - **Commit the code:**
    - Run the following command to stage all the changes:

      ```bash
      git add .
      ```

    - Commit the changes with a meaningful message:

      ```bash
      git commit -m "Initial commit of Docker exercises"
      ```

  - **Push the code:**
    - Push the code to your repository:

      ```bash
      git push -u origin main
      ```

    - Note: If your default branch is named differently (e.g., `master`), use that instead of `main`.

- [x] Task 4: Review the application code
  - **Inspect the code changes:**
    - Open the cloned repository in your preferred IDE or text editor.
    - Navigate through the files and directories to understand the structure of the application.
    - Pay attention to the Java application code and how it uses environment variables for the database connection.

  - **Understand the importance of environment variables:**
    - Note that using environment variables for sensitive information like database credentials is crucial.
    - It prevents exposing sensitive data by hardcoding it into the application code.
    - Environment variables allow for dynamic configuration based on the deployment environment.

## Exercise 2

- [x] Task 1: Start the MySQL container
  - **Pull the MySQL Docker image:**
    - Open a command prompt or PowerShell.
    - Run the following command to pull the latest MySQL Docker image:

      ```bash
      docker pull mysql:latest
      ```

    - Wait for the image to be downloaded.

  - **Start the MySQL container:**
    - Run the following command to start a new MySQL container:

      ```bash
      docker run --name mysql-container --env MYSQL_ROOT_PASSWORD=your_password --env MYSQL_DATABASE=your_database --env MYSQL_USER=your_username --env MYSQL_PASSWORD=your_password -p 3306:3306 -d mysql:latest
      ```

    - Replace `your_password`, `your_database`, and `your_username` with your desired values.

- [x] Task 2: Set environment variables for the application
  - **Identify the required environment variables:**
    - Based on the `DatabaseConfig` file, the required environment variables are:
      - `DB_USER`
      - `DB_PWD`
      - `DB_SERVER`
      - `DB_NAME`

  - **Set the environment variables:**
    - Open the Command Prompt or PowerShell.
    - Run the following commands to set the environment variables:

      ```bash
      setx DB_USER your_username
      setx DB_PWD your_password
      setx DB_SERVER localhost
      setx DB_NAME your_database
      ```

    - Replace `your_username`, `your_password`, and `your_database` with the same values used when starting the MySQL container.
    - Close and reopen the Command Prompt or PowerShell for the changes to take effect.

- [x] Task 3: Build and start the application
  - **Build the JAR file:**
    - Open a new Command Prompt or PowerShell and navigate to the root directory of your Java application.
    - Run the following command to build the JAR file:

      ```bash
      gradle build
      ```

    - Note: Make sure you have Gradle installed and configured properly.

  - **Start the application:**
    - Once the build is successful, run the following command to start the application:

      ```bash
      java -jar ./build/libs/your-application.jar
      ```

    - Replace `your-application.jar` with the actual name of your JAR file.

- [x] Task 4: Test the application
  - **Access the application in a browser:**
    - Open a web browser on your local machine.
    - Enter the URL `http://localhost:8080`.
    - Verify that the application is accessible and functioning correctly.

  - **Make changes and verify data persistence:**
    - Interact with the application and make some changes (e.g., edit user information).
    - Refresh the page or navigate to different sections of the application to ensure that the changes are persisted in the MySQL database.

## Exercise 3

- [x] Task 1: Start the phpMyAdmin container
  - **Pull the phpMyAdmin Docker image:**
    - Open a command prompt or PowerShell.
    - Run the following command to pull the latest phpMyAdmin Docker image:

      ```bash
      docker pull phpmyadmin:latest
      ```

    - Wait for the image to be downloaded.

  - **Start the phpMyAdmin container:**
    - Run the following command to start a new phpMyAdmin container:

      ```bash
      docker run --name phpmyadmin-container -d --link mysql-container:db -p 8082:80 phpmyadmin:latest
      ```

- [x] Task 2: Access phpMyAdmin from a browser
  - **Open phpMyAdmin in a browser:**
    - Open a web browser on your local machine.
    - Enter the URL `http://localhost:8082` to access phpMyAdmin.

  - **Log in to your MySQL database:**
    - On the phpMyAdmin login page, enter the following details:
      - Server: `db`
      - Username: `your_username`
      - Password: `your_password`
      Replace `your_username` and `your_password` with the same values used when starting the MySQL container.
    - Click on the "Go" button to log in.

- [x] Task 3: Verify database access and data
  - **Explore the database:**
    - Once logged in, you should see your MySQL database listed on the left sidebar.
    - Click on your database name to expand it and view the tables.

  - **Verify data:**
    - Select a table from your database.
    - Browse the table data to ensure that the changes made through your application are reflected correctly.

Remember to replace the placeholders (`your_password`, `your_database`, `your_username`, `your-application.jar`) with the actual values specific to your setup.

## Exercise 4

Docker volumes are a way to persist data generated and used by Docker containers. They provide a mechanism to store data outside of the container's filesystem, ensuring that the data remains intact even if the container is stopped, restarted, or deleted. Volumes can be used to share data between containers and also between the host machine and containers.

There are two main types of volumes in Docker:

1. *Named Volumes*: These are volumes that are created and managed by Docker. They are stored in a specific directory on the host machine, typically under `/var/lib/docker/volumes/`. Named volumes can be referenced by their name and can be easily shared between containers.

2. *Bind Mounts*: These volumes allow you to mount a directory or file from the host machine into a container. The host directory is referenced by its absolute path. Bind mounts are useful when you need to share specific files or directories between the host and the container.

In the Docker Compose file, volumes are defined under the `volumes` section. You can specify named volumes or bind mounts for each service. Named volumes are created if they don't exist and are managed by Docker. Bind mounts, on the other hand, require the specified directory to exist on the host machine.

Volumes are useful in several scenarios:

- *Persisting data*: Volumes allow you to store data generated by containers, such as database files, application logs, or user uploads, outside of the container's filesystem. This ensures that the data is not lost when the container is removed or recreated.

- *Sharing data between containers*: Volumes can be shared between multiple containers, allowing them to access and modify the same data. This is particularly useful for scenarios like sharing files between a web server and an application server.

- *Accessing data from the host*: Bind mounts enable you to access files or directories from the host machine within a container. This can be helpful for development purposes, where you want to modify code or configuration files on the host and have those changes immediately reflected in the container.

- [x] Task 1: Create a Docker Compose file
  - **Create a new file named `compose.yaml`:**
    - Open a text editor or IDE of your choice.
    - Create a new file and save it as `compose.yaml` in your project directory.

  - **Define the services in the Docker Compose file:**
    - Add the following content to the `compose.yaml` file:

      ```yaml
      version: '3'
      services:
        mysql-container:
          image: mysql:latest
          restart: always
          env_file:
            - db_credentials.env
          ports:
            - "3306:3306"
          volumes:
            - db_data:/var/lib/mysql

        phpmyadmin-container:
          image: phpmyadmin:latest
          restart: always
          ports:
            - "8082:80"
          depends_on:
            - mysql-container
          environment:
            PMA_HOST: mysql-container

      volumes:
        db_data:
      ```

    - Using this `-v mysql:/var/lib/mysql` command to start your MySQL container will create a new Docker volume called `mysql`. It’ll be mounted into the container at `/var/lib/mysql`, where MySQL stores its data files. Any data written to this directory will now be transparently stored in the Docker-managed volume on your host.
    - The `PMA_HOST` variable tells phpMyAdmin which MySQL server to connect to. It should match the name of the MySQL service defined in the `compose.yaml` file.

- [x] Task 2: Create an environment file for database credentials
  - **Create a new file named `db_credentials.env`:**
    - In the same directory as the `compose.yaml` file, create a new file named `db_credentials.env`.
    - Open the `db_credentials.env` file in a text editor.

  - **Define the environment variables:**
    - Add the following lines to the `db_credentials.env` file:

      ```bash
      MYSQL_ROOT_PASSWORD=your_root_password
      MYSQL_DATABASE=your_database
      MYSQL_USER=your_username
      MYSQL_PASSWORD=your_password
      ```

    - Replace `your_root_password`, `your_database`, `your_username`, and `your_password` with your actual values.

  - **Secure the `db_credentials.env` file:**
    - Make sure to add the `db_credentials.env` file to your `.gitignore` file to prevent it from being committed to version control.
    - Restrict access permissions to the `db_credentials.env` file to protect the sensitive information.

- [x] Task 3: Start the containers using Docker Compose
  - **Open a command prompt or terminal:**
    - Navigate to the directory where the `compose.yaml` file is located.

  - **Start the containers:**
    - Run the following command to start the containers defined in the Docker Compose file:

      ```bash
      docker compose up -d
      ```

    - The `-d` flag runs the containers in detached mode, allowing them to run in the background.
    - Docker Compose will pull the necessary images (if not already present) and start the containers.

- [x] Task 4: Test the application and phpMyAdmin
  - **Access the application:**
    - Open a web browser and visit `http://localhost:8080` (or the appropriate URL) to access your application.
    - Verify that the application is running correctly and interacting with the MySQL database.

  - **Access phpMyAdmin:**
    - Open a web browser and visit `http://localhost:8082` to access phpMyAdmin.
    - Log in using the MySQL credentials specified in the `db_credentials.env` file.
    - Verify that you can see and manage your MySQL database through the phpMyAdmin interface.

- [x] Task 5: Stop and remove the containers (when needed)
  - **Stop the containers:**
    - When you want to stop the containers, run the following command in the same directory as the `compose.yaml` file:

      ```bash
      docker compose down
      ```

    - This command will stop and remove the containers defined in the Docker Compose file.

  - **Remove the volumes (optional):**
    - If you want to completely remove the data persisted in the volumes, you can add the `-v` flag to the `docker compose down` command:

      ```bash
      docker compose down -v
      ```

    - This will remove the containers and delete the associated volumes.

## Exercise 5

- [x] Task 1: Create a Dockerfile for your Java application
  - Create a new file named `Dockerfile` in the root directory of your Java application.
  - Add the following content to the `Dockerfile`:

    ```Dockerfile
    # Use the amazoncorretto:21-alpine3.19-full base image
    FROM amazoncorretto:21-alpine3.19-full

    # Set the working directory inside the container
    WORKDIR /app

    # Copy the application JAR file to the container and rename it
    COPY ./build/libs/docker-exercises-project-1.0-SNAPSHOT.jar /app/java-project.jar

    # Expose the port on which the application runs
    EXPOSE 8080

    # Specify the entrypoint command to run when the container starts
    ENTRYPOINT ["java", "-jar", "java-project.jar"]
    ```

  - Explanation of the Dockerfile commands:
    - `FROM amazoncorretto:21-alpine3.19-full`: Specifies the base image for the container, which is Amazon Corretto 21 running on Alpine Linux 3.19.
    - `WORKDIR /app`: Sets the working directory inside the container to `/app`. If the directory doesn't exist, it will be created.
    - `COPY ./build/libs/docker-exercises-project-1.0-SNAPSHOT.jar /app/java-project.jar`: Copies the application JAR file from the host machine to the `/app` directory inside the container and renames it to `java-project.jar`.
    - `EXPOSE 8080`: Exposes port 8080 from the container to the host machine. This allows the application to be accessed externally.
    - `ENTRYPOINT ["java", "-jar", "java-project.jar"]`: Specifies the command to run when the container starts. In this case, it runs the Java application using the `java -jar` command with the renamed JAR file.

- [x] Task 2: Build the Docker image for your Java application
  - Open a terminal or command prompt and navigate to the directory containing your `Dockerfile`.
  - Run the following command to build the Docker image:

    ```bash
    docker build -t java-app:1.0 .
    ```

  - This command builds the Docker image using the instructions specified in the `Dockerfile`. The `-t` flag tags the image with the name `my-java-app:1.0`, and the `.` specifies the build context as the current directory.

- [x] Task 3: Update the Docker Compose file (`compose.yaml`)
  - Open the existing `compose.yaml` file.
  - Add the following service configuration for your Java application:

    ```yaml
    app:
      image: java-app:1.0
      restart: always
      ports:
        - "8080:8080"
      depends_on:
        - mysql-container
      env_file:
        - app_credentials.env
      environment:
        DB_SERVER: mysql-container
        DB_PORT: 3306
    ```

  - Update the `phpmyadmin-container` service configuration to include the `app` service in the `depends_on` section:

    ```yaml
    phpmyadmin-container:
      image: phpmyadmin:latest
      restart: always
      ports:
        - "8082:80"
      depends_on:
        - mysql-container
        - app
      environment:
        PMA_HOST: mysql-container
    ```

- [x] Task 4: Create an environment file (`app_credentials.env`) for the application
  - Create a new file named `app_credentials.env` in the same directory as the `compose.yaml` file.
  - Add the following lines to the `app_credentials.env` file:

    ```bash
    DB_NAME=your_database_name
    DB_USER=your_username
    DB_PWD=your_password
    ```

  - Replace `your_database_name`, `your_username`, and `your_password` with your actual database name, username, and password.

- [x] Task 5: Start the application stack using Docker Compose
  - Open a terminal or command prompt and navigate to the directory containing your updated `compose.yaml` file.
  - Run the following command to start all the containers defined in the Docker Compose file:

    ```bash
    docker compose up -d
    ```

  - This command starts the containers in detached mode (`-d`), which means they run in the background.

- [x] Task 6: Verify the containers are running
  - Run the following command to check the status of the containers:

    ```bash
    docker compose ps
    ```

  - This command lists all the containers defined in the Docker Compose file and shows their current status.
  - Ensure that all the containers (Java app, MySQL, and phpMyAdmin) are listed and have the status "Up".

- [x] Task 7: Test the deployed application
  - Access your Java application by opening a web browser and visiting `http://localhost:8080`.
  - Verify that your Java application is accessible and functioning correctly.
  - Access phpMyAdmin by opening a web browser and visiting `http://localhost:8082`.
  - Log in to phpMyAdmin using the MySQL credentials specified in the `db_credentials.env` file.
  - Verify that you can access and manage your application's database through the phpMyAdmin interface.

## Exercise 6

- [x] Task 1: Open the required ports on the remote server
  - Log in to your DigitalOcean account and access the control panel.
  - Navigate to the "Networking" section and select "Firewalls."
  - Create a new firewall rule to allow incoming traffic on the following ports:
    - Port 22 (SSH) - This allows secure remote access to your server.
    - Port 8081 (or the desired port for Nexus) - This allows access to the Nexus web interface.
  - Apply the firewall rules to the remote server where you plan to install Nexus.

- [x] Task 2: Install and start Nexus on the remote server
  - Connect to your remote server using SSH.
  - Create a Docker volume for Nexus data:

    ```bash
    docker volume create --name nexus-data
    ```

  - Start a Nexus container with the specified version and volume:

    ```bash
    docker run -d -p 8081:8081 --name nexus -v nexus-data:/nexus-data sonatype/nexus3:3.67.1-java11
    ```

  - Wait for Nexus to start up and become accessible on `http://<remote-server-ip>:8081`.

- [x] Task 3: Retrieve the default admin password
  - Retrieve the uniquely generated admin password from the `admin.password` file inside the Nexus volume:

    ```bash
    docker exec -it nexus cat /nexus-data/admin.password; echo
    ```

  - Take note of the password for future use.
  
  > Note: Using the default admin credentials is not recommended for production environments. It is advised to change the password and secure the Nexus instance properly.

- [x] Task 4: Configure Nexus Docker repository
  - Access the Nexus web interface at `http://<remote-server-ip>:8081`.
  - Sign in with the admin username and the password obtained from the `admin.password` file.
  - Navigate to the "Server administration and configuration" section.
  - Create a new Docker hosted repository:
    - Name: `<repository-name>`
    - HTTP: `8083` (or the desired port for the Docker repository)
    - Enable Docker V1 API
  - Take note of the repository name and port for later use.
  - Save the repository configuration.

- [x] Task 5: Add Nexus as an insecure registry
  - On your local machine, modify the Docker daemon configuration to allow insecure registries:
    - For Linux:
      - Create or edit the file `/etc/docker/daemon.json`.

        ```bash
        sudo nano /etc/docker/daemon.json
        ```

      - Add the following content:

        ```json
        {
          "insecure-registries": ["<remote-server-ip>:<repository-port>"]
        }
        ```

      - Replace `<remote-server-ip>` with the IP address of your remote server, and `<repository-port>` with the port number you configured for the Docker repository.
      - Restart the Docker daemon for the changes to take effect.

      ```bash
      sudo systemctl restart docker
      ```

- [x] Task 6: Build the Java application Docker image
  - Open a terminal on your local machine and navigate to the directory containing the Dockerfile for your Java application.
  - Build the Docker image with a tag that includes the Nexus repository URL:

    ```bash
    docker build -t <remote-server-ip>:8083/<repository-name>/java-app:1.0 .
    ```

  - Replace `<remote-server-ip>` with the IP address of your remote server, `<repository-name>` with the name of the repository you created in Nexus, and adjust the tag version as needed.

- [ ] Task 7: Push the Docker image to Nexus
  - Log in to the Nexus Docker registry:

    ```bash
    docker login -u <username> -p <password> <remote-server-ip>:8083
    ```

  - Replace `<username>` and `<password>` with the appropriate values, and `<remote-server-ip>` with the IP address of your remote server.

  - Push the Docker image to the Nexus repository:

    ```bash
    docker push <remote-server-ip>:8083/<repository-name>/java-app:1.0
    ```

  - Replace `<remote-server-ip>` with the IP address of your remote server, `<repository-name>` with the name of the repository you created in Nexus, and adjust the tag version as needed.

- [ ] Task 8: Verify the pushed Docker image
  - Access the Nexus web interface at `http://<remote-server-ip>:8081`.
  - Navigate to the "Browse" section and select the repository you created.
  - Verify that the `java-app` image with the specified tag is present in the repository.

Remember to replace `<remote-server-ip>`, `<repository-name>`, `<username>`, and `<password>` with the appropriate values specific to your setup.

## Exercise 7

- [x] Task 1: Update the `compose.yaml` file to use environment variable references
  - Open the `compose.yaml` file in a text editor.
  - Modify the file to use environment variable references for sensitive data and configurable values.
  - Replace hardcoded values with references to environment variables using the `${VARIABLE_NAME}` syntax.

    ```yaml
    services:
      mysql-container:
        image: mysql:latest
        restart: always
        environment:
          MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
          MYSQL_DATABASE: ${MYSQL_DATABASE}
          MYSQL_USER: ${MYSQL_USER}
          MYSQL_PASSWORD: ${MYSQL_PASSWORD}
        ports:
          - "3306:3306"
        volumes:
          - db_data:/var/lib/mysql

      phpmyadmin-container:
        image: phpmyadmin:latest
        restart: always
        ports:
          - "8082:80"
        depends_on:
          - mysql-container
          - app
        environment:
          PMA_HOST: mysql-container
          MYSQL_USER: ${MYSQL_USER}
          MYSQL_PASSWORD: ${MYSQL_PASSWORD}

      app:
        image: localhost:8083/my-java-app:1.0
        restart: always
        ports:
          - "8080:8080"
        depends_on:
          - mysql-container
        environment:
          DB_SERVER: mysql-container
          DB_PORT: 3306
          DB_NAME: ${MYSQL_DATABASE}
          DB_USER: ${MYSQL_USER}
          DB_PWD: ${MYSQL_PASSWORD}

    volumes:
      db_data:
    ```

- [x] Task 2: Create an environment file for production
  - Create a new file named `credentials.env.prod` in the same directory as the `compose.yaml` file.
  - Add the necessary environment variables and their corresponding values to the file.

   ```bash
   MYSQL_ROOT_PASSWORD=your_root_password
   MYSQL_DATABASE=your_database_name
   MYSQL_USER=your_username
   MYSQL_PASSWORD=your_password
   ```

  - Replace `your_root_password`, `your_database_name`, `your_username`, and `your_password` with the appropriate values for your environment.

- [ ] Task 3: Deploy the application on the server
  - Copy the updated `compose.yaml` file and the environment file (`credentials.env.local`) to the server where you want to deploy the application.
  - Ensure that the necessary prerequisites (Docker and Docker Compose) are installed on the server.
  - Open a terminal or SSH session on the server.
  - Navigate to the directory where the `compose.yaml` file is located.

- [ ] Task 4: Load the environment variables and run the application
  - Load the environment variables from the environment file before running the `docker compose up` command.
  - Use the `--env-file` flag to specify the environment file.

    ```bash
    docker compose --env-file credentials.env.local up -d
    ```

  - The `--env-file` flag reads the specified environment file and sets the environment variables for the containers.
  - The `-d` flag runs the containers in detached mode (background).

## Exercise 8

## Exercise 9
