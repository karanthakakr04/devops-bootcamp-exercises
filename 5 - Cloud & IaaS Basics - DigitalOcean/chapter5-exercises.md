# TASK BREAK DOWN

## Exercise 1

- [x] Task 1: Clone the provided git repository

  ```bash
  git clone https://gitlab.com/twn-devops-bootcamp/latest/05-cloud/cloud-basics-exercises
  ```

- [x] Task 2: Push the cloned project to your remote repository

  ```bash
  git push -u origin main
  ```

## Exercise 2

- [x] Task 1: Navigate to the Node.js app directory
- [x] Task 2: Run `npm pack` to package the app into a `.tgz` file

  ```bash
  npm pack
  ```

- [x] Task 3: The command will generate a `.tgz` file with the app name and version
- [x] Task 4: Verify the `.tgz` file was created in the current directory

## Exercise 3

- [x] Task 1: Login to DigitalOcean console
- [x] Task 2: Go to Droplets and click 'Create Droplet'
- [x] Task 3: Choose options for the new droplet, for example:
  - Image (OS) - Ubuntu 22.04
  - Plan type - Basic with 1GB RAM
  - Data center region - Closest to your location
  - Authentication - SSH keys
- [x] Task 4: Assign a hostname like 'webapp1'
- [x] Task 5: Click 'Create Droplet' to launch the new server
- [x] Task 6: Wait for the public IP to be assigned
- [x] Task 7: Note the IP address for later use

## Exercise 4

- [x] Task 1: SSH into the new droplet with `ssh root@IP_ADDRESS`
  - Before this step you need to create a firewall rule to allow access through SSH and attach it to the Droplet
- [x] Task 2: Update apt packages

  ```bash
  apt update
  apt upgrade -y
  ```

- [x] Task 3: Install Node.js and npm

  ```bash
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs
  ```

- [x] Task 4: Check versions

  ```bash
  node --version
  npm --version
  ```

> Command in Task 3 is from this [link](https://github.com/nodesource/distributions?tab=readme-ov-file#ubuntu-versions)

## Exercise 5

- [x] Task 1: On your local machine, you created a artifact in your root folder
- [x] Task 2: Use `scp` to copy that `.tgz` to the droplet

  ```bash
  scp -i /path/to/private/key /path/to/local/file username@IP:/path/to/remote/directory
  ```

- [x] Task 3: SSH into the droplet
- [x] Task 4: Unpack the application

  ```bash
  tar -xvzf <package_name>.tgz
  ```

## Exercise 6

- [x] Task 1: Install dependencies

  ```bash
  npm install
  ```

- [x] Task 2: Start server in detached mode

  ```bash
  node server.js &
  ```

- [x] Task 3: Check process is running

  ```bash
  ps aux | grep node | grep -v grep
  ```

- [x] Task 4: Verify app is reachable on port 3000

  ```bash
  curl -o /dev/null -s -w "%{http_code}\n" http://localhost
  ```

## Exercise 7

- [x] Task 1: Add a custom rule to the firewall allowing all traffic on port 3000
  - > do it from the UI
- [x] Task 2: Get public IP of droplet
- [x] Task 3: Open browser and go to `http://PUBLIC_IP:3000`
- [x] Task 4: Verify you can access the app UI
