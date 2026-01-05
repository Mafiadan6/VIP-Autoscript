#!/bin/bash
BIBlack='\033[1;90m'
BIRed='\033[1;91m'
BIGreen='\033[1;92m'
BIYellow='\033[1;93m'
BIBlue='\033[1;94m'
BIPurple='\033[1;95m'
BICyan='\033[1;96m'
BIWhite='\033[1;97m'
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }

export LANG='en_US.UTF-8'
export LANGUAGE='en_US.UTF-8'

clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "       ${BIWhite}DNS MANAGEMENT${NC}"
echo -e ""
echo -e "     ${BICyan}[${BIWhite}01${BICyan}] Enable DNS Cache (Unbound)"
echo -e "     ${BICyan}[${BIWhite}02${BICyan}] Disable DNS Cache (Unbound)"
echo -e "     ${BICyan}[${BIWhite}03${BICyan}] Enable DNSCrypt-Proxy"
echo -e "     ${BICyan}[${BIWhite}04${BICyan}] Disable DNSCrypt-Proxy"
echo -e "     ${BICyan}[${BIWhite}05${BICyan}] Enable Both DNS Cache & DNSCrypt"
echo -e "     ${BICyan}[${BIWhite}06${BICyan}] Disable Both DNS Cache & DNSCrypt"
echo -e "     ${BICyan}[${BIWhite}07${BICyan}] Check DNS Status"
echo -e ""

echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "     ${BIYellow}Press x or [ Ctrl+C ] • To-${BIWhite}Exit${NC}"
echo ""
read -p " Select menu : " opt
echo -e ""
case $opt in
1)
    clear
    echo -e "${BIGreen}Installing Unbound DNS Cache...${NC}"
    apt-get install -y unbound >/dev/null 2>&1
    cat > /etc/unbound/unbound.conf << 'EOF'
server:
    interface: 127.0.0.1
    access-control: 0.0.0.0/0 allow
    cache-max-ttl: 86400
    hide-identity: yes
    hide-version: yes
    prefetch: yes
EOF
    systemctl enable unbound >/dev/null 2>&1
    systemctl restart unbound >/dev/null 2>&1
    echo -e "${BIGreen}DNS Cache (Unbound) Enabled Successfully!${NC}"
    sleep 2
    bash /root/mastermindvps/VIP-Autoscript/menu/menu-dns.sh ; exit ;;
2)
    clear
    echo -e "${BIRed}Disabling DNS Cache (Unbound)...${NC}"
    systemctl stop unbound >/dev/null 2>&1
    systemctl disable unbound >/dev/null 2>&1
    echo -e "${BIRed}DNS Cache (Unbound) Disabled!${NC}"
    sleep 2
    bash /root/mastermindvps/VIP-Autoscript/menu/menu-dns.sh ; exit ;;
3)
    clear
    echo -e "${BIGreen}Installing DNSCrypt-Proxy...${NC}"
    apt-get install -y dnscrypt-proxy >/dev/null 2>&1
    if [ ! -f /etc/dnscrypt-proxy/dnscrypt-proxy.toml ]; then
        mkdir -p /etc/dnscrypt-proxy
        cat > /etc/dnscrypt-proxy/dnscrypt-proxy.toml << 'EOF'
listen_addresses = ['127.0.0.1:5300']
server_names = ['cloudflare', 'google']
EOF
    fi
    systemctl enable dnscrypt-proxy >/dev/null 2>&1
    systemctl restart dnscrypt-proxy >/dev/null 2>&1
    echo -e "${BIGreen}DNSCrypt-Proxy Enabled Successfully!${NC}"
    sleep 2
    bash /root/mastermindvps/VIP-Autoscript/menu/menu-dns.sh ; exit ;;
4)
    clear
    echo -e "${BIRed}Disabling DNSCrypt-Proxy...${NC}"
    systemctl stop dnscrypt-proxy >/dev/null 2>&1
    systemctl disable dnscrypt-proxy >/dev/null 2>&1
    echo -e "${BIRed}DNSCrypt-Proxy Disabled!${NC}"
    sleep 2
    bash /root/mastermindvps/VIP-Autoscript/menu/menu-dns.sh ; exit ;;
5)
    clear
    echo -e "${BIGreen}Enabling Both DNS Cache & DNSCrypt...${NC}"

    echo -e "${BIGreen}Installing Unbound DNS Cache...${NC}"
    apt-get install -y unbound >/dev/null 2>&1
    cat > /etc/unbound/unbound.conf << 'EOF'
server:
    interface: 127.0.0.1
    access-control: 0.0.0.0/0 allow
    cache-max-ttl: 86400
    hide-identity: yes
    hide-version: yes
    prefetch: yes
EOF
    systemctl enable unbound >/dev/null 2>&1
    systemctl restart unbound >/dev/null 2>&1

    echo -e "${BIGreen}Installing DNSCrypt-Proxy...${NC}"
    apt-get install -y dnscrypt-proxy >/dev/null 2>&1
    if [ ! -f /etc/dnscrypt-proxy/dnscrypt-proxy.toml ]; then
        mkdir -p /etc/dnscrypt-proxy
        cat > /etc/dnscrypt-proxy/dnscrypt-proxy.toml << 'EOF'
listen_addresses = ['127.0.0.1:5300']
server_names = ['cloudflare', 'google']
EOF
    fi
    systemctl enable dnscrypt-proxy >/dev/null 2>&1
    systemctl restart dnscrypt-proxy >/dev/null 2>&1

    echo -e "${BIGreen}Both DNS Cache & DNSCrypt Enabled Successfully!${NC}"
    sleep 2
    bash /root/mastermindvps/VIP-Autoscript/menu/menu-dns.sh ; exit ;;
6)
    clear
    echo -e "${BIRed}Disabling Both DNS Cache & DNSCrypt...${NC}"
    systemctl stop unbound >/dev/null 2>&1
    systemctl disable unbound >/dev/null 2>&1
    systemctl stop dnscrypt-proxy >/dev/null 2>&1
    systemctl disable dnscrypt-proxy >/dev/null 2>&1
    echo -e "${BIRed}Both DNS Cache & DNSCrypt Disabled!${NC}"
    sleep 2
    bash /root/mastermindvps/VIP-Autoscript/menu/menu-dns.sh ; exit ;;
7)
    clear
    echo -e "${BIGreen}DNS Status:${NC}"
    echo ""

    if systemctl is-active unbound >/dev/null 2>&1; then
        echo -e "DNS Cache (Unbound): ${BIGreen}ACTIVE${NC}"
    else
        echo -e "DNS Cache (Unbound): ${BIRed}INACTIVE${NC}"
    fi

    if systemctl is-active dnscrypt-proxy >/dev/null 2>&1; then
        echo -e "DNSCrypt-Proxy:      ${BIGreen}ACTIVE${NC}"
    else
        echo -e "DNSCrypt-Proxy:      ${BIRed}INACTIVE${NC}"
    fi

    echo ""
    read -p "Press Enter to continue..."
    bash /root/mastermindvps/VIP-Autoscript/menu/menu-dns.sh ; exit ;;
0) clear ; bash /root/mastermindvps/VIP-Autoscript/menu/menu-set.sh ; exit ;;
x) exit ;;
*) echo -e "" ; echo "Wrong choice !" ; sleep 1 ; bash /root/mastermindvps/VIP-Autoscript/menu/menu-dns.sh ;;
esac
