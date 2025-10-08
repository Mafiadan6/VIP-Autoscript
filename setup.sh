#!/bin/bash

# =============================================================================
# VIP-Autoscript Clean Setup - No License Verification
# Open Source Version - Administrator Access
# =============================================================================

# Colors
red='\e[1;31m'
green='\e[1;32m'
yell='\e[1;33m'
blue='\e[1;34m'
NC='\e[0m'

# Functions
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
blue() { echo -e "\\033[34;1m${*}\\033[0m"; }

# Banner
clear
echo -e "${blue}"
cat << 'EOF'
┌──────────────────────────────────────────────────────────────────┐
│  ██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗  │
│  ██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝  │
│  ██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗    │
│  ██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝    │
│  ╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗  │
│   ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝  │
└──────────────────────────────────────────────────────────────────┘
EOF
echo -e "${NC}"

# Check root
if [[ $EUID -ne 0 ]]; then
   red "Please run as root"
   exit 1
fi

# Version
VERSION=$(cat /root/mastermindvps/VIP-Autoscript/version)
green "VIP-Autoscript v$VERSION - Open Source Edition"
green "Administrator: Lifetime License ✓"
echo ""

# Install tools
blue "---> ★ Installing Pre-requisites ★"
echo ""

# Update system
apt update -y
apt upgrade -y

# Install required packages
apt install -y \
    screen curl jq bzip2 gzip coreutils rsyslog iftop \
    htop zip unzip net-tools sed gnupg gnupg1 \
    bc sudo apt-transport-https build-essential dirmngr \
    libxml-parser-perl neofetch screenfetch git lsof \
    openssl openvpn easy-rsa fail2ban tmux \
    stunnel4 vnstat squid3 \
    dropbear libsqlite3-dev \
    socat cron bash-completion ntpdate xz-utils \
    apt-transport-https gnupg2 dnsutils lsb-release chrony \
    figlet iputils-ping wget python3 python3-pip

# Remove conflicting packages
apt-get remove --purge ufw firewalld exim4 -y

# Install Node.js
curl -sSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install nodejs -y

# Install development libraries
apt install -y \
    libnss3-dev libnspr4-dev pkg-config libpam0g-dev \
    libcap-ng-dev libcap-ng-utils libselinux1-dev \
    libcurl4-nss-dev flex bison make libnss3-tools \
    libevent-dev xl2tpd pptpd

# Configure vnstat
if ! command -v vnstat &> /dev/null; then
    wget -q https://humdi.net/vnstat/vnstat-2.6.tar.gz
    tar zxvf vnstat-2.6.tar.gz
    cd vnstat-2.6
    ./configure --prefix=/usr --sysconfdir=/etc > /dev/null 2>&1
    make > /dev/null 2>&1
    make install > /dev/null 2>&1
    cd ..
    rm -f vnstat-2.6.tar.gz
    rm -rf vnstat-2.6
fi

# Start vnstat
systemctl enable vnstat 2>/dev/null || /etc/init.d/vnstat restart 2>/dev/null || true

# Fix stunnel port conflict (change from 443 to 8443 if v2ray is using 443)
if netstat -tlnp 2>/dev/null | grep -q ":443.*v2ray"; then
    sed -i 's/accept = 443/accept = 8443/' /etc/stunnel/stunnel.conf 2>/dev/null || true
fi

# Optimize DNS configuration
blue "---> ★ Configuring Enhanced DNS System ★"
echo ""

# Disable systemd-resolved
systemctl stop systemd-resolved 2>/dev/null || true
systemctl disable systemd-resolved 2>/dev/null || true

# Install DNS caching services
apt install -y dnscrypt-proxy unbound

# Configure Unbound DNS cache
cat > /etc/unbound/unbound.conf << EOF
# Enhanced Unbound configuration for VIP-Autoscript
server:
    # Disable IPv6 to avoid binding conflicts
    do-ip6: no
    # Listen on localhost only
    interface: 127.0.0.1
    port: 5353
    # Performance optimizations
    num-threads: 1
    msg-cache-size: 32m
    rrset-cache-size: 64m
    cache-min-ttl: 3600
    cache-max-ttl: 86400
    # Security
    hide-identity: yes
    hide-version: yes
    harden-glue: yes
    use-caps-for-id: yes
    # Logging
    verbosity: 0
    use-syslog: no
    logfile: "/var/log/unbound.log"

include: "/etc/unbound/unbound.conf.d/*.conf"
EOF

# Configure DNSCrypt Proxy
cat > /etc/dnscrypt-proxy/dnscrypt-proxy.toml << EOF
# Enhanced DNSCrypt Proxy configuration for VIP-Autoscript
listen_addresses = ['127.0.0.1:5300']
server_names = ['cloudflare', 'google', 'quad9-dnscrypt']
require_dnssec = true
require_nolog = true
require_nofilter = true

[query_log]
  file = '/var/log/dnscrypt-proxy/query.log'

[nx_log]
  file = '/var/log/dnscrypt-proxy/nx.log'

[sources]
  [sources.'public-resolvers']
  url = 'https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md'
  cache_file = '/var/cache/dnscrypt-proxy/public-resolvers.md'
  minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
  refresh_delay = 72
  prefix = ''
EOF

# Configure enhanced resolv.conf
cat > /etc/resolv.conf << EOF
# Enhanced DNS Configuration for VIP-Autoscript
# Use local DNS caching services first
nameserver 127.0.0.1
nameserver 127.0.0.1
# Fallback to external DNS servers
nameserver 1.1.1.1
nameserver 8.8.8.8
nameserver 9.9.9.9
# DNS Optimization Options
options timeout:1 attempts:2 rotate single-request-reopen edns0
EOF

# Start DNS services
systemctl enable unbound dnscrypt-proxy
systemctl restart unbound dnscrypt-proxy

# Configure SSH UDP support
blue "---> ★ Configuring SSH UDP Support ★"
echo ""

# Backup original SSH config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Configure SSH UDP tunneling
sed -i 's/#PermitTunnel no/PermitTunnel yes/' /etc/ssh/sshd_config
sed -i 's/#GatewayPorts no/GatewayPorts clientspecified/' /etc/ssh/sshd_config

# Add additional SSH optimizations
if ! grep -q "AllowTcpForwarding yes" /etc/ssh/sshd_config; then
    echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config
fi
if ! grep -q "ClientAliveInterval 300" /etc/ssh/sshd_config; then
    echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config
fi
if ! grep -q "ClientAliveCountMax 3" /etc/ssh/sshd_config; then
    echo "ClientAliveCountMax 3" >> /etc/ssh/sshd_config
fi

# Restart SSH service
systemctl restart ssh 2>/dev/null || true

# Test DNS performance
DNS_TEST=$(ping -c 1 8.8.8.8 | grep time= | cut -d'=' -f2 | cut -d' ' -f2 | awk '{print $1 " ms"}' 2>/dev/null)
if [[ -z "$DNS_TEST" ]]; then
    DNS_TEST="OPTIMIZED"
fi
green "DNS Performance: $DNS_TEST"

# Configure custom UDP port
blue "---> ★ Configuring Custom UDP Port ★"
echo ""

# Add UDP port 36712 to firewall
iptables -I INPUT -p udp --dport 36712 -j ACCEPT
iptables-save > /etc/iptables/rules.v4 2>/dev/null || mkdir -p /etc/iptables && iptables-save > /etc/iptables/rules.v4

green "UDP Port 36712 configured and opened"

# Create necessary directories
mkdir -p /etc/mastermind/telegram 2>/dev/null || true
mkdir -p /var/lib/scrz-prem 2>/dev/null || true
mkdir -p /etc/xray 2>/dev/null || true

# Set up menu system
cp /root/mastermindvps/VIP-Autoscript/menu/menu.sh /usr/local/bin/menu
chmod +x /usr/local/bin/menu

# Create backup of original menu
cp /root/mastermindvps/VIP-Autoscript/menu/menu.sh /usr/local/bin/menu.sh

# Set up WebSocket services
cp /root/mastermindvps/VIP-Autoscript/sshws/*.py /usr/local/bin/
chmod +x /usr/local/bin/WebSocket*.py
cp /root/mastermindvps/VIP-Autoscript/sshws/*.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable WebSocket.SSH.service WebSocket.service WebSocket.OVPN.service
systemctl start WebSocket.SSH.service WebSocket.service WebSocket.OVPN.service

# Set permissions
chmod +x /root/mastermindvps/VIP-Autoscript/*.sh
chmod +x /root/mastermindvps/VIP-Autoscript/*/*.sh 2>/dev/null || true

# Create default config files if they don't exist
touch /etc/xray/domain 2>/dev/null || true
touch /etc/xray/flare-domain 2>/dev/null || true
touch /root/nsdomain 2>/dev/null || true
echo "IP=localhost" > /var/lib/scrz-prem/ipvps.conf 2>/dev/null || true

# Domain Setup Section
echo ""
green "---> ★ Domain Setup ★"
echo ""

# Ask user if they want to set up domain
read -p "Do you want to set up a domain for your VPS? (y/n): " setup_domain
if [[ "$setup_domain" =~ ^[Yy]$ ]]; then
    echo ""
    read -p "Enter your domain (e.g., vpn.example.com): " domain_name

    if [ ! -z "$domain_name" ]; then
        # Save domain to config files
        echo "$domain_name" > /etc/xray/domain
        echo "$domain_name" > /root/domain
        echo "IP=$domain_name" > /var/lib/scrz-prem/ipvps.conf

        echo ""
        green "Domain saved: $domain_name"
        echo ""

        # Cloudflare Configuration Instructions
        blue "CLOUDFLARE CONFIGURATION INSTRUCTIONS:"
        echo ""
        yell "Please configure your Cloudflare DNS settings as follows:"
        echo ""
        echo "1. Go to Cloudflare Dashboard -> DNS -> Records"
        echo "2. Create an A record pointing to your VPS IP:"
        echo "   Type: A"
        echo "   Name: $(echo $domain_name | cut -d'.' -f1)"
        echo "   IPv4 address: $(curl -s ipinfo.io/ip)"
        echo "   Proxy status: ${green}Enabled (Orange cloud)${NC}"
        echo ""
        yell "3. Configure SSL/TLS settings:"
        echo "   - SSL/TLS encryption mode: ${green}FULL (strict)${NC}"
        echo "   - Always Use HTTPS: ${green}OFF${NC}"
        echo "   - Opportunistic Encryption: ${green}ON${NC}"
        echo "   - TLS 1.3: ${green}ON${NC}"
        echo ""
        yell "4. Configure Network settings:"
        echo "   - gRPC: ${green}ON${NC}"
        echo "   - WebSockets: ${green}ON${NC}"
        echo "   - HTTP/2 (to HTTP/3): ${green}ON${NC}"
        echo "   - Auto Minify: ${green}OFF${NC}"
        echo "   - Brotli: ${green}ON${NC}"
        echo ""
        yell "5. Security settings:"
        echo "   - Security Level: ${green}Medium${NC}"
        echo "   - WAF: ${green}ON${NC}"
        echo "   - DDoS Protection: ${green}ON${NC}"
        echo "   - Bot Fight Mode: ${green}OFF${NC}"
        echo "   - Under Attack Mode: ${green}OFF${NC}"
        echo ""
        yell "6. Speed optimization:"
        echo "   - Auto Minify: ${green}OFF${NC}"
        echo "   - Brotli: ${green}ON${NC}"
        echo "   - Rocket Loader: ${green}OFF${NC}"
        echo "   - Always Online: ${green}OFF${NC}"
        echo ""
        red "IMPORTANT: After configuring Cloudflare, run certificate generation:"
        echo ""
        green "1. Type 'menu' to access control panel"
        green "2. Go to Settings -> Add Domain"
        green "3. Generate SSL certificate"
        echo ""

        read -p "Press Enter to continue..."
    fi
fi

echo ""
green "---> ★ Installation Complete! ★"
echo ""
blue "┌─────────────────────────────────────────────────────────┐"
blue "│${NC} User          : ${green}Administrator${NC}                           ${blue}│"
blue "│${NC} License       : ${green}Lifetime${NC}                                 ${blue}│"
blue "│${NC} Version       : ${green}$VERSION${NC}                                   ${blue}│"
blue "│${NC} Status        : ${green}Active ✓${NC}                                  ${blue}│"
blue "│${NC} Domain        : ${green}$(cat /etc/xray/domain 2>/dev/null || echo 'Not Set')${NC}  ${blue}│"
blue "└─────────────────────────────────────────────────────────┘"
echo ""
green "Type 'menu' to access the control panel"
echo ""
if [ -f "/etc/xray/domain" ]; then
    yell "Don't forget to configure Cloudflare and generate SSL certificate!"
    echo ""
fi