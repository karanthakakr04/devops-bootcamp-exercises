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

      Replace `<your-repository-url>` with the URL of your repository.

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

      Note: If your default branch is named differently (e.g., `master`), use that instead of `main`.

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

      Replace `your_password`, `your_database`, and `your_username` with your desired values.

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

      Replace `your_username`, `your_password`, and `your_database` with the same values used when starting the MySQL container.
    - Close and reopen the Command Prompt or PowerShell for the changes to take effect.

- [x] Task 3: Build and start the application
  - **Build the JAR file:**
    - Open a new Command Prompt or PowerShell and navigate to the root directory of your Java application.
    - Run the following command to build the JAR file:

      ```bash
      gradle build
      ```

      Note: Make sure you have Gradle installed and configured properly.

  - **Start the application:**
    - Once the build is successful, run the following command to start the application:

      ```bash
      java -jar target/your-application.jar
      ```

      Replace `your-application.jar` with the actual name of your JAR file.

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

Docker Volumes:
Docker volumes are a way to persist data generated and used by Docker containers. They provide a mechanism to store data outside of the container's filesystem, ensuring that the data remains intact even if the container is stopped, restarted, or deleted. Volumes can be used to share data between containers and also between the host machine and containers.

There are two main types of volumes in Docker:

1. Named Volumes: These are volumes that are created and managed by Docker. They are stored in a specific directory on the host machine, typically under `/var/lib/docker/volumes/`. Named volumes can be referenced by their name and can be easily shared between containers.

2. Bind Mounts: These volumes allow you to mount a directory or file from the host machine into a container. The host directory is referenced by its absolute path. Bind mounts are useful when you need to share specific files or directories between the host and the container.

In the Docker Compose file, volumes are defined under the `volumes` section. You can specify named volumes or bind mounts for each service. Named volumes are created if they don't exist and are managed by Docker. Bind mounts, on the other hand, require the specified directory to exist on the host machine.

Volumes are useful in several scenarios:

- Persisting data: Volumes allow you to store data generated by containers, such as database files, application logs, or user uploads, outside of the container's filesystem. This ensures that the data is not lost when the container is removed or recreated.

- Sharing data between containers: Volumes can be shared between multiple containers, allowing them to access and modify the same data. This is particularly useful for scenarios like sharing files between a web server and an application server.

- Accessing data from the host: Bind mounts enable you to access files or directories from the host machine within a container. This can be helpful for development purposes, where you want to modify code or configuration files on the host and have those changes immediately reflected in the container.

- [ ] Task 1: Create a Docker Compose file
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

      volumes:
        db_data:
      ```

Using this `-v mysql:/var/lib/mysql` command to start your MySQL container will create a new Docker volume called `mysql`. It’ll be mounted into the container at `/var/lib/mysql`, where MySQL stores its data files. Any data written to this directory will now be transparently stored in the Docker-managed volume on your host.

- [ ] Task 2: Create an environment file for database credentials
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

      Replace `your_root_password`, `your_database`, `your_username`, and `your_password` with your actual values.

  - **Secure the `db_credentials.env` file:**
    - Make sure to add the `db_credentials.env` file to your `.gitignore` file to prevent it from being committed to version control.
    - Restrict access permissions to the `db_credentials.env` file to protect the sensitive information.

- [ ] Task 3: Start the containers using Docker Compose
  - **Open a command prompt or terminal:**
    - Navigate to the directory where the `compose.yaml` file is located.

  - **Start the containers:**
    - Run the following command to start the containers defined in the Docker Compose file:

      ```bash
      docker compose up -d
      ```

    - The `-d` flag runs the containers in detached mode, allowing them to run in the background.
    - Docker Compose will pull the necessary images (if not already present) and start the containers.

- [ ] Task 4: Test the application and phpMyAdmin
  - **Access the application:**
    - Open a web browser and visit `http://localhost:8080` (or the appropriate URL) to access your application.
    - Verify that the application is running correctly and interacting with the MySQL database.

  - **Access phpMyAdmin:**
    - Open a web browser and visit `http://localhost:8082` to access phpMyAdmin.
    - Log in using the MySQL credentials specified in the `db_credentials.env` file.
    - Verify that you can see and manage your MySQL database through the phpMyAdmin interface.

- [ ] Task 5: Stop and remove the containers (when needed)
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

## Exercise 6

## Exercise 7

## Exercise 8
