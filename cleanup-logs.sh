#!/bin/bash
# Automatic Log Cleanup Script
# Runs daily to prevent log buildup

# Truncate large logs (>100MB)
find /var/log -name "*.log" -size +100M -exec truncate -s 0 {} \; 2>/dev/null

# Delete old compressed logs (>50MB)
find /var/log -name "*.gz" -size +50M -delete 2>/dev/null

# Clear application logs
truncate -s 0 /var/log/xray/*.log 2>/dev/null
truncate -s 0 /var/log/trojan-go/*.log 2>/dev/null
truncate -s 0 /var/log/stunnel4/*.log 2>/dev/null

# Delete logs older than 7 days
find /var/log -name "*.log.*" -mtime +7 -delete 2>/dev/null
find /var/log -name "*.gz" -mtime +14 -delete 2>/dev/null

# Keep syslog and auth.log under 50MB
[ -f /var/log/syslog ] && [ $(stat -f%z /var/log/syslog 2>/dev/null || stat -c%s /var/log/syslog) -gt 52428800 ] && truncate -s 0 /var/log/syslog
[ -f /var/log/auth.log ] && [ $(stat -f%z /var/log/auth.log 2>/dev/null || stat -c%s /var/log/auth.log) -gt 52428800 ] && truncate -s 0 /var/log/auth.log

# Cleanup systemd journal
journalctl --vacuum-size=50M >/dev/null 2>&1
journalctl --vacuum-time=7d >/dev/null 2>&1

# Restart syslog if logs were cleared
systemctl reload rsyslog >/dev/null 2>&1 || true

echo "Log cleanup completed: $(date)"
