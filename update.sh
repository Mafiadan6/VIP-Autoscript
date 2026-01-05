#!/bin/bash

# =============================================================================
# VIP-Autoscript Update Script - Clean Version
# Open Source Edition
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

# Check root
if [[ $EUID -ne 0 ]]; then
   red "Please run as root"
   exit 1
fi

# Check if script directory exists
if [ ! -d "/root/mastermindvps/VIP-Autoscript" ]; then
    red "VIP-Autoscript directory not found!"
    exit 1
fi

# Get current version
if [ -f "/root/mastermindvps/VIP-Autoscript/version" ]; then
    CURRENT_VERSION=$(cat /root/mastermindvps/VIP-Autoscript/version)
else
    CURRENT_VERSION="Unknown"
fi

clear
echo -e "${blue}"
figlet 'UPDATE'
echo -e "${NC}"
echo -e "${yell}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${blue}│${NC} ${green}VIP-Autoscript Update Utility${NC} ${blue}│${NC}"
echo -e "${yell}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${blue}Current Version: ${green}$CURRENT_VERSION${NC}"
echo ""

# Show menu options
echo -e "${yell}Would you like to proceed with update?${NC}"
echo ""
echo -e "${green}[1]${NC} Check for updates and update scripts"
echo -e "${green}[2]${NC} Update dependencies only"
echo -e "${green}[3]${NC} Reinstall menu system"
echo -e "${green}[x]${NC} Back to menu"
echo ""
echo -e "${yell}═══════════════════════════════════════════════════════════════${NC}"
echo ""

read -p "Please choose an option [1-3,x]: " option

case $option in
    1)
        clear
        blue "---> ★ Starting Update Process ★"
        echo ""

        # Change to script directory
        cd /root/mastermindvps/VIP-Autoscript

        # Check if git is available
        if command -v git &> /dev/null; then
            green "Pulling latest updates from repository..."
            git pull origin main
        else
            red "Git not found. Skipping repository update."
        fi

        # Update menu system
        green "Updating menu system..."
        cp menu/menu.sh /usr/local/bin/menu
        chmod +x /usr/local/bin/menu

        # Update WebSocket services and scripts
        green "Updating WebSocket services..."
        cp sshws/*.py /usr/local/bin/
        chmod +x /usr/local/bin/WebSocket*.py
        cp sshws/*.service /etc/systemd/system/
        systemctl daemon-reload

        # Enable and start VIP services if not already running
        green "Starting VIP WebSocket services..."

        # Configure firewall for VIP ports
        green "Configuring firewall for VIP ports..."
        
        iptables -I INPUT -p tcp --dport 8443 -j ACCEPT 2>/dev/null || true
        iptables-save > /etc/iptables/rules.v4 2>/dev/null || mkdir -p /etc/iptables && iptables-save > /etc/iptables/rules.v4

        # Set permissions
        green "Setting permissions..."
        chmod +x *.sh
        chmod +x */*.sh 2>/dev/null || true

        sleep 2
        green "---> ★ Update Complete! ★"
        echo ""
        read -n 1 -s -r -p "Press any key to continue"
        menu
        ;;
    2)
        clear
        blue "---> ★ Updating Dependencies ★"
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

        sleep 2
        green "---> ★ Dependencies Updated! ★"
        echo ""
        read -n 1 -s -r -p "Press any key to continue"
        menu
        ;;
    3)
        clear
        blue "---> ★ Reinstalling Menu System ★"
        echo ""

        # Create necessary directories
        mkdir -p /etc/mastermind/telegram 2>/dev/null || true
        mkdir -p /var/lib/scrz-prem 2>/dev/null || true
        mkdir -p /etc/xray 2>/dev/null || true

        # Update menu system with VIP services
        cp /root/mastermindvps/VIP-Autoscript/menu/menu.sh /usr/local/bin/menu
        chmod +x /usr/local/bin/menu

        # Create backup
        cp /root/mastermindvps/VIP-Autoscript/menu/menu.sh /usr/local/bin/menu.sh

        # Update WebSocket services
        cp /root/mastermindvps/VIP-Autoscript/sshws/*.py /usr/local/bin/
        chmod +x /usr/local/bin/WebSocket*.py
        cp /root/mastermindvps/VIP-Autoscript/sshws/*.service /etc/systemd/system/
        systemctl daemon-reload

        # Enable VIP services

        # Set permissions
        chmod +x /root/mastermindvps/VIP-Autoscript/*.sh
        chmod +x /root/mastermindvps/VIP-Autoscript/*/*.sh 2>/dev/null || true

        # Create default config files
        touch /etc/xray/domain 2>/dev/null || true
        touch /etc/xray/flare-domain 2>/dev/null || true
        touch /root/nsdomain 2>/dev/null || true
        echo "IP=localhost" > /var/lib/scrz-prem/ipvps.conf 2>/dev/null || true

        sleep 2
        green "---> ★ Menu System Reinstalled! ★"
        echo ""
        read -n 1 -s -r -p "Press any key to continue"
        menu
        ;;
    x)
        clear
        menu
        ;;
    *)
        red "Invalid option!"
        sleep 1
        menu
        ;;
esac