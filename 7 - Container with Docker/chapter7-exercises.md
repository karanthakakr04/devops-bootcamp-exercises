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

## Exercise 3

## Exercise 4

## Exercise 5

## Exercise 6

## Exercise 7

## Exercise 8
