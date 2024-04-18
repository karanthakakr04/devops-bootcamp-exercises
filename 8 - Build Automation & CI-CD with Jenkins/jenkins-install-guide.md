# Jenkins Installation Script

This script automates the installation of Jenkins on Ubuntu, Debian, Fedora, Red Hat Enterprise Linux (RHEL), CentOS, AlmaLinux, and Rocky Linux. It provides a convenient way to set up Jenkins with minimal manual intervention.

## Prerequisites

Before running this script, ensure that you have the following:

- A server running one of the supported operating systems:
  - Ubuntu
  - Debian
  - Fedora
  - Red Hat Enterprise Linux (RHEL)
  - CentOS
  - AlmaLinux
  - Rocky Linux
- Sudo privileges on the server

## Usage

1. Download the `jenkins_install.sh` script to your server.

2. Make the script executable by running the following command:

   ```bash
   chmod +x jenkins_install.sh
   ```

3. Execute the script with sudo privileges:

   ```bash
   sudo ./jenkins_install.sh
   ```

4. The script will prompt you to enter the server IP address. Provide the IP address of your server and press Enter.

5. The script will perform the following steps:
   - Update the operating system and installed packages
   - Check if Java 17 is installed and install it if necessary
   - Install Jenkins
   - Start the Jenkins service
   - Check the status of the Jenkins service

6. Once the installation is complete, the script will display the URL to access Jenkins in your web browser.

7. Open the provided URL in your web browser to access the Jenkins web interface.

## Configuration

### Port Configuration

By default, Jenkins listens on port 8080. If this port is already in use, you can change it by following these steps:

1. Run the following command to edit the Jenkins configuration:

   ```bash
   sudo systemctl edit jenkins
   ```

2. Add the following lines to the file:

   ```(systemd config)
   [Service]
   Environment="JENKINS_PORT=8081"
   ```

   Replace `8081` with the desired port number.

3. Save the file and exit the editor.

4. Restart the Jenkins service for the changes to take effect:

   ```bash
   sudo systemctl restart jenkins
   ```

### Firewall Configuration

To access Jenkins from a remote machine, you need to configure the firewall rules to allow incoming traffic on the Jenkins port. If you are using a cloud provider like DigitalOcean, you can configure the firewall rules through their web interface.

Ensure that the firewall allows incoming traffic on the Jenkins port (default: 8080) from the desired IP addresses or networks.

## Troubleshooting

If you encounter any issues during the installation or while running Jenkins, you can use the following commands for troubleshooting:

- To view the Jenkins service details:

  ```bash
  sudo systemctl cat jenkins
  ```

- To view the Jenkins logs:

  ```bash
  sudo journalctl -u jenkins.service
  ```

These commands can provide valuable information for diagnosing and resolving issues.

## Log File

The script logs the installation process and any relevant information to the `/var/log/jenkins_install.log` file. You can review this file for detailed information about the installation.

## Supported Operating Systems

This script supports the following operating systems:

- Ubuntu
- Debian
- Fedora
- Red Hat Enterprise Linux (RHEL)
- CentOS
- AlmaLinux
- Rocky Linux

If you are using an unsupported operating system, the script will display a message indicating that you need to install Jenkins manually.

## Disclaimer

This script is provided as-is and without warranty. Use it at your own risk. Always review and test the script in a non-production environment before running it on a production server.

## License

This script is released under the [MIT License](https://opensource.org/licenses/MIT).

---

Feel free to customize and enhance this script to fit your specific needs. If you have any questions or suggestions, please open an issue on the GitHub repository.

Happy Jenkins installation!
