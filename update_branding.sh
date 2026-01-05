#!/bin/bash
 
# Script to update WebSocket branding and restart services
# This fixes the branding issue on proxy ports 80 and 8080
 
echo "Updating WebSocket branding..."
 
# Copy updated scripts to /usr/local/bin/
cp sshws/WebSocket.SSH.py /usr/local/bin/WebSocket.SSH.py
 
# Set permissions
chmod +x /usr/local/bin/WebSocket.SSH.py
 
# Restart services
systemctl restart WebSocket.SSH
 
echo "Branding updated and services restarted."
echo "Port 80 should now show 'Developer: mastermind' instead of 'kingprivatenet'."