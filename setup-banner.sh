#!/bin/bash

# Setup SSH Banner
echo "Configuring SSH Banner..."

# Copy banner files
cp /root/mastermindvps/VIP-Autoscript/ssh/banner /etc/ssh/banner
cp /root/mastermindvps/VIP-Autoscript/banner_default /root/mastermindvps/VIP-Autoscript/banner_default

# Add banner to SSH config
if ! grep -q "Banner /etc/ssh/banner" /etc/ssh/sshd_config; then
    echo "Banner /etc/ssh/banner" >> /etc/ssh/sshd_config
fi

# Restart SSH
systemctl restart ssh 2>/dev/null || true

echo "SSH Banner configured successfully"
