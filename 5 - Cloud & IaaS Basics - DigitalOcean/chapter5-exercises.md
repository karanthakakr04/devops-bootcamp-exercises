# TASK BREAK DOWN

## Exercise 1

- [x] Task 1: Clone the provided git repository
  - `https://gitlab.com/twn-devops-bootcamp/latest/05-cloud/cloud-basics-exercises`
- [x] Task 2:  Push the cloned project to your remote repository
  - `git push -u origin main`

## Exercise 2

- [] Task 1: Navigate to the Node.js app directory
- [] Task 2: Run `npm pack` to package the app into a `.tgz` file
- [] Task 3: The command will generate a `.tgz` file with the app name and version
- [] Task 4 :Verify the `.tgz` file was created in the current directory
- [] Task 5: Commit the generated artifact:
  - `git add app-name-version.tgz`
  - `git commit -m "Package Node.js app"`

## Exercise 3

- [] Task 1: Login to DigitalOcean console
- [] Task 2: Go to Droplets and click 'Create Droplet'
- [] Task 3: Choose options for the new droplet, for example:
  - Image (OS) - Ubuntu 22.04
  - Plan type - Basic with 1GB RAM
  - Data center region - Closest to your location
  - Authentication - SSH keys
- [] Task 4: Assign a hostname like 'webapp1'
- [] Task 5: Click 'Create Droplet' to launch the new server
- [] Task 6: Wait for the public IP to be assigned
- [] Task 7: Note the IP address for later use
