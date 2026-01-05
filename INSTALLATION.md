# VIP-Autoscript Installation Guide

## What Has Been Installed

### Core Services
- ✅ SSH Server (with UDP tunneling support)
- ✅ OpenVPN Server
- ✅ Xray/V2Ray (Vmess, Vless, Trojan)
- ✅ Nginx (Port 81)
- ✅ Stunnel4
- ✅ Squid Proxy
- ✅ BadVPN UDP Gateway (Port 7200)
- ✅ WebSocket Services (Port 80, 700, 2086)
- ✅ VNStat Bandwidth Monitor
- ✅ Fail2Ban Security
- ✅ DNSCrypt + Unbound (DNS Cache)

### Menu System
- ✅ Main Menu (type `menu`)
- ✅ SSH Accounts Management
- ✅ Vmess/Vless/Trojan Accounts
- ✅ Port Management (including WebSocket SSH port 80)
- ✅ Bandwidth Monitor
- ✅ Backup System
- ✅ Custom Banner Editor

### Open Ports
- 22 (SSH)
- 80 (WebSocket SSH/Vmess/Vless)
- 443 (SSL/TLStunnel4/Vmess/Vless/Trojan)
- 81 (Nginx)
- 700 (WebSocket)
- 2086 (OpenVPN WebSocket)
- 447, 777, 8443 (Stunnel4)
- 109, 143 (Dropbear - if installed)
- 7200 (BadVPN UDP)
- 36712 (Custom UDP)

## Post-Installation Steps

### 1. Configure Domain (Optional but Recommended)
```bash
menu
# Select: 05 (Settings) → 01 (Panel Domain)
# Enter your domain name
```

### 2. Configure Cloudflare DNS (If using domain)
```
A Record: @ → Your VPS IP
Proxy Status: Orange Cloud (Enabled)
SSL/TLS: Full (Strict)
```

### 3. Generate SSL Certificate (If using domain)
```bash
menu
# Select: 05 (Settings) → 01 (Panel Domain)
# Select: Generate SSL Certificate option
```

### 4. Test Services
```bash
menu
# Select: 09 (Running Processes)
# Check all services are running
```

## Menu Options

### Main Menu (type `menu`)
```
[01] SSH Accounts         [08] Add Domain           [15] System Update
[02] VMESS Accounts       [09] Running Processes    [16] Reboot System
[03] VLESS Accounts       [10] WebSocket Port       [17] Fix Issues
[04] TROJAN Accounts      [11] Install Bot          [18] ASIC Logo Show
[05] Settings             [12] Bandwidth Monitor    [19] Fix Issues
[06] Trial Accounts       [13] Menu Themes          
[07] Backup System        [14] Custom Banner       
[0]  Exit
```

### Settings Menu
```
[01] Panel Domain
[02] Change Port All Account
[03] Change WebSocket SSH Port (80)  ← NEW: Change port 80!
[04] Remove/Reset Port
[05] Edit Proxy Message
[06] Webmin Menu
[07] Speedtest VPS
[08] About Script
[09] Set Auto Reboot
[10] Restart All Service
[11] Change Banner
[12] Check Bandwidth
[13] Menu Themes
```

## Common Commands

### Check Running Services
```bash
menu  # Then select 09 (Running Processes)
```

### Change WebSocket SSH Port (80)
```bash
menu  # Select: 05 (Settings) → 02 (Change Port) → 04 (WebSocket SSH)
# Or: menu  # Select: 05 (Settings) → 03 (Change WebSocket SSH Port)
```

### Check Bandwidth Usage
```bash
vnstat -h
```

### Restart All Services
```bash
menu  # Select: 05 (Settings) → 10 (Restart All Service)
```

### Backup Configuration
```bash
menu  # Select: 07 (Backup System)
```

## Troubleshooting

### Port 80 Not Working
```bash
# Check if WebSocket SSH service is running
systemctl status WebSocket.SSH.service

# Restart if needed
systemctl restart WebSocket.SSH.service
```

### SSH UDP Not Showing
```bash
# Check SSH config
grep "PermitTunnel" /etc/ssh/sshd_config

# Should show: PermitTunnel yes
```

### Menu Not Working
```bash
# Recreate symlinks
bash /root/mastermindvps/VIP-Autoscript/setup-symlinks.sh
```

## Service Commands

### Xray/V2Ray
```bash
systemctl restart xray
systemctl status xray
```

### WebSocket SSH
```bash
systemctl restart WebSocket.SSH.service
systemctl status WebSocket.SSH.service
```

### Stunnel4
```bash
systemctl restart stunnel4
systemctl status stunnel4
```

### BadVPN
```bash
systemctl restart badvpn
systemctl status badvpn
```

## Security

- ✅ SSH UDP tunneling enabled
- ✅ Fail2Ban configured
- ✅ DNSCrypt enabled (encrypted DNS)
- ✅ Unbound DNS cache enabled
- ✅ Firewall rules configured

## Support

For issues or questions:
- Check running processes: menu → 09
- Check system logs: journalctl -xe
- View error logs: tail -f /var/log/syslog

## License
- Type: Open Source
- Access: Administrator (Lifetime)
- Version: 9.9.9 (OPTIMIZED DNS)

---

**Developer:** 𓆩 mastermind 𓆪
**Last Updated:** $(date '+%Y-%m-%d')
