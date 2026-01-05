#!/bin/bash
# VPS Startup Script
# Ensures all VPN services are running after reboot

LOG="/var/log/vps-startup.log"
date > "$LOG"

echo "Starting VPS services..." >> "$LOG"

# Wait for network to be ready
sleep 10

# Enable BBR
sysctl -w net.ipv4.tcp_congestion_control=bbr >/dev/null 2>&1
echo "✓ BBR enabled" >> "$LOG"

# Start essential services
services="ssh xray stunnel4 badvpn"
for service in $services; do
    systemctl start $service 2>/dev/null
    if systemctl is-active $service >/dev/null; then
        echo "✓ $service started" >> "$LOG"
    else
        echo "✗ $service failed" >> "$LOG"
    fi
done

# Start WebSocket services
ws_services="WebSocket.SSH.service WebSocket.service WebSocket.OVPN.service"
for service in $ws_services; do
    systemctl start $service 2>/dev/null
    if systemctl is-active $service >/dev/null; then
        echo "✓ $service started" >> "$LOG"
    else
        echo "✗ $service failed" >> "$LOG"
    fi
done

# Ensure DNS cache is disabled
systemctl stop unbound dnscrypt-proxy 2>/dev/null
systemctl disable unbound dnscrypt-proxy 2>/dev/null
echo "✓ DNS cache disabled" >> "$LOG"

# Run log cleanup
/root/cleanup-logs.sh >> "$LOG" 2>&1
echo "✓ Log cleanup completed" >> "$LOG"

# Verify ports
echo "" >> "$LOG"
echo "Listening ports:" >> "$LOG"
ss -tuln | grep -E ":(22|80|443|700|8443|109|143)" >> "$LOG"

echo "" >> "$LOG"
echo "VPS startup completed: $(date)" >> "$LOG"
