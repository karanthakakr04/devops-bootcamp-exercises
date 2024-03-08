# TASK BREAK DOWN

## Exercise 1

- [] Task 1: Clone the provided Git repository
  - Open a terminal or command prompt
  - Navigate to the directory where you want to clone the repository
  - Run the following command:

     ```bash
     git clone https://gitlab.com/twn-devops-bootcamp/latest/07-docker/docker-exercises.git
     ```

- [] Task 2: Create a new repository on your GitLab account
  - Log in to your GitLab account
  - Click on "New project" or "New repository"
  - Choose "Create blank project"
  - Provide a name and description for your repository
  - Set the visibility level (e.g., private or public)
  - Click on "Create project"

- [] Task 3: Change the remote origin URL to your new repository
  - Navigate to the cloned repository directory
  - Run the following command to remove the existing remote origin:

     ```bash
     git remote remove origin
     ```

  - Run the following command to add your new repository as the remote origin:

     ```bash
     git remote add origin https://gitlab.com/<your-username>/<your-repo-name>.git
     ```

- [] Task 4: Push the cloned code to your new repository
  - Run the following command to push the code to your new repository:

     ```bash
     git push -u origin master
     ```

- [] Task 5: Review the code changes and identify the usage of environment variables for database credentials
  - Open the cloned project in your preferred code editor
  - Look for files related to database configuration or connection
  - Identify where environment variables are being used to store database credentials

- [] Task 6: Understand the importance of using environment variables
  - Realize that hardcoding sensitive information like passwords in the codebase is a security risk
    - Understand that if the codebase is compromised, the hardcoded passwords can be easily exposed
    - Recognize that environment variables provide a way to separate sensitive information from the codebase
  - Acknowledge that using environment variables allows for dynamic configuration based on the deployment environment
    - Understand that different environments (e.g., development, staging, production) may have different database credentials
    - Realize that environment variables enable easy configuration changes without modifying the codebase

## Exercise 2

## Exercise 3

## Exercise 4

## Exercise 5

## Exercise 6

## Exercise 7

## Exercise 8
