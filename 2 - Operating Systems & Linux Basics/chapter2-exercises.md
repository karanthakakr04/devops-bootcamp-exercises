# TASK BREAK DOWN

## EXERCISE 1

- [x] Task 1: Create a Linux Mint Virtual Machine
- [x] Task 2: Identify Package Manager
  - Linux Mint is a Debian-based Linux distribution that uses the APT package manager and apt/apt-get command for software installation and updates.
- [x] Task 3: Check Linux Version
  - There are a couple of ways to check your system's Linux version:
    - **lsb_release -a**
    - **cat /etc/os-release**
    - **uname -a**
    - **hostnamectl**
    - **cat /proc/version**
- [x] Task 4: Identify CLI Editor
  - The default CLI text editor included in Linux Mint is Nano, but Vi and Vim editors can also be installed.
- [x] Task 5: Explore Software Center/Software Manager
  - Linux Mint has a Software Manager graphical application for installing and managing software.
- [x] Task 6: Identify Configured Shell
  - The default shell for new user accounts in Linux Mint is bash (Bourne Again SHell).

## EXERCISE 2

- [x] Task 1: Create Bash script to install latest Java version and verify installation

## EXERCISE 3

- [x] Task 1: Create Bash script to print current user's running processes

## EXERCISE 4

- [x] Task 1: Extend script to sort processes by memory/CPU based on user input

## EXERCISE 5

- [x] Task 1: Further extend script to limit number of sorted processes printed based on user input

## EXERCISE 6

- [x] Task 1: Install NodeJS and NPM, print versions
- [x] Task 2: Download artifact file using curl/wget
- [x] Task 3: Unzip downloaded file
- [x] Task 4: Set environment variables: `APP_ENV`, `DB_USER`, `DB_PWD`
- [x] Task 5: Change to unzipped directory
- [x] Task 6: Run npm install
- [x] Task 7: Run node `server.js` to start app

## EXERCISE 7

- [x] Task 1: Extend script to check app status and print process & port info

## EXERCISE 8

- [x] Task 1: Accept log_directory parameter and handle logging:
  - Check if directory exists, create if needed
  - Set LOG_DIR environment variable
  - Check app.log in provided LOG_DIR

## EXERCISE 9

- [x] Task 1: Create myapp service user
  - Create myapp user
  - Run application as myapp user
  