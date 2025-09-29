#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

SSH_CONFIG="/etc/ssh/sshd_config"
BACKUP_FILE="/etc/ssh/sshd_config.bak.$(date +%F-%T)"

# Backup the current sshd_config
cp "$SSH_CONFIG" "$BACKUP_FILE"
echo "Backup of sshd_config saved as $BACKUP_FILE"

# Check if AllowTcpForwarding exists in the file
if grep -q "^AllowTcpForwarding" "$SSH_CONFIG"; then
    # Replace existing setting
    sed -i 's/^AllowTcpForwarding.*/AllowTcpForwarding yes/' "$SSH_CONFIG"
else
    # Add the setting if it doesn't exist
    echo "AllowTcpForwarding yes" >> "$SSH_CONFIG"
fi

echo "AllowTcpForwarding set to yes in $SSH_CONFIG"

# Restart sshd service
if systemctl restart sshd; then
    echo "sshd service restarted successfully"
else
    echo "Failed to restart sshd service. Please check the service status."
fi
