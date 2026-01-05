#!/bin/bash

# =============================================================================
# VIP-Autoscript Tools Installation - Clean Version
# =============================================================================

clear
red='\e[1;31m'
green='\e[1;32m'
yell='\e[1;33m'
NC='\e[0m'

green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }

# Detect OS
if [[ -e /etc/debian_version ]]; then
    source /etc/os-release
    OS=$ID
elif [[ -e /etc/centos-release ]]; then
    source /etc/os-release
    OS=centos
fi

# Update system
green "Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

# Install basic tools
green "Installing basic tools..."
sudo apt install -y \
    screen curl jq bzip2 gzip coreutils rsyslog iftop \
    htop zip unzip net-tools sed gnupg gnupg1 \
    bc sudo apt-transport-https build-essential dirmngr \
    libxml-parser-perl neofetch screenfetch git lsof \
    openssl openvpn easy-rsa fail2ban tmux \
    stunnel4 vnstat squid3 \
    dropbear libsqlite3-dev \
    socat cron bash-completion ntpdate xz-utils \
    apt-transport-https gnupg2 dnsutils lsb-release chrony

# Remove conflicting packages
sudo apt-get remove --purge ufw firewalld exim4 -y

# Install Node.js 18.x
green "Installing Node.js 18.x..."
curl -sSL https://deb.nodesource.com/setup_18.x | bash -
sudo apt-get install nodejs -y

# Install and configure vnstat
green "Installing vnstat..."
if ! command -v vnstat &> /dev/null; then
    wget -q https://humdi.net/vnstat/vnstat-2.6.tar.gz
    tar zxvf vnstat-2.6.tar.gz
    cd vnstat-2.6
    ./configure --prefix=/usr --sysconfdir=/etc >/dev/null 2>&1
    make >/dev/null 2>&1
    make install >/dev/null 2>&1
    cd ..
    rm -f vnstat-2.6.tar.gz
    rm -rf vnstat-2.6
fi

# Start vnstat service
systemctl enable vnstat >/dev/null 2>&1 || true
systemctl start vnstat >/dev/null 2>&1 || true

# Install development libraries
green "Installing development libraries..."
sudo apt install -y \
    libnss3-dev libnspr4-dev pkg-config libpam0g-dev \
    libcap-ng-dev libcap-ng-utils libselinux1-dev \
    libcurl4-nss-dev flex bison make libnss3-tools \
    libevent-dev xl2tpd pptpd

green "Tools installation completed successfully!"
sleep 3
clear