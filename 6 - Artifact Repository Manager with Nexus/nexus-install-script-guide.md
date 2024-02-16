# Instructions for Use

> [!IMPORTANT]
> Use the latest Nexus version from the [Sonatype download page](https://help.sonatype.com/en/download.html). This URL will always point to the most recent release, ensuring anyone using this script in the future installs the then-current version instead of locking to a potentially outdated link target. Always installing the newest Nexus release allows leveraging security updates and new features, facilitating improved stability, compatibility, and capability over time.

1. **Save the script**: Copy the script into a file, for example, named `install_nexus.sh`.

2. **Make the script executable**: Change the script's permissions to make it executable by running:

   ```bash
   chmod +x install_nexus.sh
   ```

3. **Run the script with logging**: Execute the script with `sudo` to ensure it has the necessary permissions:

   ```bash
   sudo ./install_nexus.sh
   ```

   All output and errors will be logged to `/var/log/install_nexus.log`, as defined in the script.

## Important Notes

- **Ensure that writing to `/var/log/` is permissible for your script.** If the script doesn't run with root privileges, you might not have permission to write to this directory. Running the script with `sudo` or elevating privileges for the specific task of writing to the log file can resolve this issue. It's common for system services and scripts executed by the system administrator to write logs to `/var/log/`, but doing so requires appropriate permissions.

- **Consider log rotation.** Logs can grow over time, consuming significant disk space. For scripts or services that generate a lot of output, consider implementing log rotation. This can be done using the `logrotate` utility, which is available on most Linux distributions and allows for automatic rotation, compression, and removal of log files.

- **Security and Privacy.** When writing to system log directories like `/var/log/`, be mindful of the content of your logs. Ensure that sensitive information (e.g., passwords, personal data) is not logged, especially in plaintext. Apply appropriate file permissions to your log files to restrict access to authorized users only.

- **Alternative Log Locations.** If your script is intended to be run by non-root users or you prefer not to write to `/var/log/`, consider specifying a different log file location within the script, such as a directory within `/tmp`, or a user-specific log directory. Ensure that the chosen directory is secure and has the appropriate permissions set up.

Here's an example modification to the script to check for write permissions and choose an alternative log directory if necessary:

```bash
LOG_DIR="/var/log"
LOG_FILE="install_nexus.log"

# Check if the script can write to the log directory
if [ ! -w "$LOG_DIR" ] && [ "$(id -u)" -ne 0 ]; then
    # Fall back to a temporary directory if /var/log is not writable
    LOG_DIR="/tmp"
    echo "Warning: /var/log not writable. Using $LOG_DIR for log output."
fi

FULL_LOG_PATH="$LOG_DIR/$LOG_FILE"

# Redirect all output and errors to the log file
exec > >(tee -a "$FULL_LOG_PATH") 2>&1
```

This adjustment makes the script more flexible and user-friendly by automatically adapting to the environment's permissions, ensuring that the script's logging does not fail due to write permission issues.
