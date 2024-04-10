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
      docker run --name mysql-container -e MYSQL_ROOT_PASSWORD=your_password -e MYSQL_DATABASE=your_database -e MYSQL_USER=your_username -e MYSQL_PASSWORD=your_password -p 3306:3306 -d mysql:latest
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
    - To set environment variables in Linux run the following commands:

      ```bash
      export DB_USER=your_username
      export DB_PWD=your_password
      export DB_SERVER=localhost
      export DB_NAME=your_database
      ```

- [x] Task 3: Build and start the application
  - **Build the JAR file:**
    - Open a new Command Prompt or PowerShell and navigate to the root directory of your Java application.
    - Run the following command to build the JAR file:

      ```bash
      gradle build
      ```

      Note: Make sure you have Maven installed and configured properly.

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

## Exercise 4

## Exercise 5

## Exercise 6

## Exercise 7

## Exercise 8
