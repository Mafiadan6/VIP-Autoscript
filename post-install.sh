#!/bin/bash

# Post-Installation Configuration for VIP-Autoscript
echo "Running post-installation configuration..."
echo ""

# Enable SSH UDP support
if ! grep -q "PermitTunnel yes" /etc/ssh/sshd_config; then
    echo "PermitTunnel yes" >> /etc/ssh/sshd_config
    systemctl restart ssh
    echo "✓ SSH UDP support enabled"
fi

# Install neofetch if not installed
if ! command -v neofetch &> /dev/null; then
    apt install -y neofetch > /dev/null 2>&1
    echo "✓ neofetch installed"
fi

# Create Xray config directory
mkdir -p /etc/xray

# Create domain files if not exist
touch /etc/xray/domain 2>/dev/null || true
touch /etc/xray/flare-domain 2>/dev/null || true

# Create config directories
mkdir -p /var/lib/scrz-prem 2>/dev/null || true
mkdir -p /etc/mastermind/telegram 2>/dev/null || true

# Set default IP
if [ ! -f /var/lib/scrz-prem/ipvps.conf ]; then
    echo "IP=localhost" > /var/lib/scrz-prem/ipvps.conf
fi

echo ""
echo "✓ Post-installation configuration complete!"
echo ""
echo "Type 'menu' to access the control panel"
