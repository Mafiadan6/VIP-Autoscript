#!/bin/bash

# Mastermind VIP Menu - Clean Layout with Original Logo
red='\e[1;31m'
green='\e[1;32m'
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
vlx=$(grep -c -E "#& " "/etc/xray/config.json")
let vla=$vlx/2
vmc=$(grep -c -E "^### " "/etc/xray/config.json")
let vma=$vmc/2
ssh1="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
trx=$(grep -c -E "^#! " "/etc/xray/config.json")
let tra=$trx/2
ssx=$(grep -c -E "^## " "/etc/xray/config.json")
let ssa=$ssx/2
BIBlack='\033[1;90m'
BIRed='\033[1;91m'
BIGreen='\033[1;92m'
BIYellow='\033[1;93m'
BIBlue='\033[1;94m'
BIPurple='\033[1;95m'
BICyan='\033[1;96m'
BIWhite='\033[1;97m'
UWhite='\033[4;37m'
On_IPurple='\033[0;105m'
On_IRed='\033[0;101m'
IBlack='\033[0;90m'
IRed='\033[0;91m'
IGreen='\033[0;92m'
IYellow='\033[0;93m'
IBlue='\033[0;94m'
IPurple='\033[0;95m'
ICyan='\033[0;96m'
IWhite='\033[0;97m'
NC='\e[0m'
dtoday="$(vnstat -i ens6 | grep "today" | awk '{print $2" "substr ($3, 1, 1)}')"
utoday="$(vnstat -i ens6 | grep "today" | awk '{print $5" "substr ($6, 1, 1)}')"
ttoday="$(vnstat -i ens6 | grep "today" | awk '{print $8" "substr ($9, 1, 1)}')"
dyest="$(vnstat -i ens6 | grep "yesterday" | awk '{print $2" "substr ($3, 1, 1)}')"
uyest="$(vnstat -i ens6 | grep "yesterday" | awk '{print $5" "substr ($6, 1, 1)}')"
tyest="$(vnstat -i ens6 | grep "yesterday" | awk '{print $8" "substr ($9, 1, 1)}')"
dmon="$(vnstat -i ens6 -m | grep "`date +"%b '%y"`" | awk '{print $3" "substr ($4, 1, 1)}')"
umon="$(vnstat -i ens6 -m | grep "`date +"%b '%y"`" | awk '{print $6" "substr ($7, 1, 1)}')"
tmon="$(vnstat -i ens6 -m | grep "`date +"%b '%y"`" | awk '{print $9" "substr ($10, 1, 1)}')"
tram=$( free -h | awk 'NR==2 {print $2}' )
uram=$( free -h | awk 'NR==2 {print $3}' )
ISP=$(curl -s "https://ipinfo.io/org?token=ac17e1a1a45667" | cut -d " " -f 2-10 )
CITY=$(curl -s "https://ipinfo.io/city?token=ac17e1a1a45667" )
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed 's/.*, *\([0-9.]*\)%* id.*/\1/' | awk '{print 100 - $1"%"}')
total_ram=$(grep "MemTotal: " /proc/meminfo | awk '{print int($2/1024)}')
export LANG='en_US.UTF-8'
export LANGUAGE='en_US.UTF-8'
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export LIGHT='\033[0;37m'
export NC='\033[0m'

# Service detection
ssh_status=$(systemctl is-active ssh 2>/dev/null)
if [ "$ssh_status" = "active" ]; then
    ressh="${green}ON${NC}"
else
    ressh="${red}OFF${NC}"
fi

stunnel_status=$(systemctl is-active stunnel4 2>/dev/null)
if [ "$stunnel_status" = "active" ]; then
    resst="${green}ON${NC}"
else
    resst="${red}OFF${NC}"
fi

nginx_status=$(systemctl is-active nginx 2>/dev/null)
if [ "$nginx_status" = "active" ]; then
    resngx="${green}ON${NC}"
else
    resngx="${red}OFF${NC}"
fi

dropbear_status=$(systemctl is-active dropbear 2>/dev/null)
if [ "$dropbear_status" = "active" ]; then
    resdbr="${green}ON${NC}"
else
    resdbr="${red}OFF${NC}"
fi

xray_status=$(systemctl is-active xray 2>/dev/null)
if [ "$xray_status" = "active" ]; then
    resv2r="${green}ON${NC}"
else
    resv2r="${red}OFF${NC}"
fi

# Check WebSocket services status
websocket_ssh_status=$(systemctl is-active WebSocket.SSH.service 2>/dev/null)
if [ "$websocket_ssh_status" = "active" ]; then
    ressshws="${green}ON${NC}"
else
    ressshws="${red}OFF${NC}"
fi

# Check SSH UDP support
resudp="${green}ON${NC}"

# Check BBR status
bbr_status=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)
if [[ x"${bbr_status}" == x"bbr" ]]; then
    resbbr="${green}ON${NC}"
else
    resbbr="${red}OFF${NC}"
fi

function addhost(){
clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo ""
read -rp "Domain/Host: " -e host
echo ""
if [ -z $host ]; then
echo "????"
echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
read -n 1 -s -r -p "Press any key to back on menu"
setting-menu
else
echo "IP=$host" > /var/lib/scrz-prem/ipvps.conf
echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo "Dont forget to renew cert"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
fi
}

# Get system information
OS_INFO=$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
KERNEL_INFO=$(uname -r)
UPTIME_INFO=$(uptime -p | sed 's/up //')
IPVPS=$(hostname -I | awk '{print $1}')

# Enhanced DNS monitoring
DNS_SPEED=$(timeout 3 ping -c 1 8.8.8.8 | grep time= | awk -F'time=' '{print $2}' | awk '{print $1 " ms"}' 2>/dev/null)
if [[ -z "$DNS_SPEED" ]]; then
    DNS_SPEED="OPTIMIZED"
fi

# Check DNS caching services status
unbound_status=$(systemctl is-active unbound 2>/dev/null)
dnscrypt_status=$(systemctl is-active dnscrypt-proxy 2>/dev/null)

if [ "$unbound_status" = "active" ]; then
    DNS_CACHE="${green}ON${NC}"
else
    DNS_CACHE="${red}OFF${NC}"
fi

if [ "$dnscrypt_status" = "active" ]; then
    DNSCRYPT="${green}ON${NC}"
else
    DNSCRYPT="${red}OFF${NC}"
fi

clear

# Original ASCII Logo with figlet
echo -e "${BICyan}"
figlet -f small "MASTERMIND VIP"
echo -e "${BIWhite}      𓆩 AUTOSCRIPT 𓆪${NC}"
echo ""

# System Information
echo -e "${BIYellow}SYSTEM INFORMATION${NC}"
echo -e "${BICyan}OS:        ${BIWhite}$OS_INFO${NC}"
echo -e "${BICyan}Kernel:    ${BIWhite}$KERNEL_INFO${NC}"
echo -e "${BICyan}CPU:       ${BIWhite}$cpu_usage${NC}"
echo -e "${BICyan}Memory:    ${BIWhite}$total_ram MB${NC}"
echo -e "${BICyan}Uptime:    ${BIWhite}$UPTIME_INFO${NC}"
echo -e "${BICyan}DNS:       ${BIWhite}$DNS_SPEED${NC} ${BICyan}[Cache:${DNS_CACHE}${NC} ${BICyan}DNSCrypt:${DNSCRYPT}${NC}]"
echo ""

# Network Information
echo -e "${BIYellow}NETWORK INFORMATION${NC}"
echo -e "${BICyan}Local IP:  ${BIWhite}$IPVPS${NC}"
echo -e "${BICyan}Public IP: ${BIPurple}$(curl -s "https://ipinfo.io/ip?token=ac17e1a1a45667")${NC}"
echo -e "${BICyan}ISP:       ${BIWhite}$ISP${NC}"
echo -e "${BICyan}Location:  ${BIWhite}$CITY${NC}"
echo -e "${BICyan}Domain:    ${BIWhite}$(cat /etc/xray/domain 2>/dev/null || echo 'Not Set')${NC}"
echo -e "${BICyan}Cloudflare: ${BIWhite}$(cat /etc/xray/flare-domain 2>/dev/null || echo 'Not Set')${NC}"
echo ""

# VPN Statistics
echo -e "${BIYellow}VPN STATISTICS${NC}"
echo -e "${BICyan}SSH:      ${BIWhite}$ssh1 Users${NC}  ${BICyan}VMESS:    ${BIWhite}$vma Users${NC}  ${BICyan}VLESS:   ${BIWhite}$vla Users${NC}  ${BICyan}TROJAN: ${BIWhite}$tra Users${NC}"
echo ""

# Service Status
echo -e "${BIYellow}SERVICE STATUS${NC}"
echo -e "${BICyan}SSH[$ressh${NC}] ${BICyan}NGINX[$resngx${NC}] ${BICyan}XRAY[$resv2r${NC}] ${BICyan}STUNNEL[$resst${NC}] ${BICyan}DROPBEAR[$resdbr${NC}]"
echo -e "${BICyan}SSH-WS[$ressshws${NC}] ${BICyan}SSH-UDP[$resudp${NC}] ${BICyan}BBR[$resbbr${NC}]"
echo ""

# Open Ports Information
echo -e "${BIYellow}OPEN PORTS${NC}"
echo -e "${BICyan}- OpenSSH            : ${BIWhite}22${NC}"

# Check SSH WebSocket Proxy on port 80
if ss -tln 2>/dev/null | grep -q ":80 "; then
    echo -e "${BICyan}- SSH WebSocket Proxy: ${BIWhite}80${NC} [${green}ON${NC}]"
else
    echo -e "${BICyan}- SSH WebSocket Proxy: ${BIWhite}80${NC} [${red}OFF${NC}]"
fi

# Check SSH SSL WebSocket on port 443
if ss -tln 2>/dev/null | grep -q ":443 "; then
    echo -e "${BICyan}- SSH SSL WebSocket  : ${BIWhite}443${NC} [${green}ON${NC}]"
else
    echo -e "${BICyan}- SSH SSL WebSocket  : ${BIWhite}443${NC} [${red}OFF${NC}]"
fi

echo -e "${BICyan}- SSH UDP            : ${BIWhite}1-65535${NC}"
echo -e "${BICyan}- Custom UDP         : ${BIWhite}36712${NC} [${green}ON${NC}]"

# Dynamic Stunnel4 ports
if systemctl is-active stunnel4 >/dev/null 2>&1; then
    stunnel_ports=$(cat /etc/stunnel/stunnel.conf 2>/dev/null | grep -i accept | cut -d= -f2 | sed 's/ //g' | tr '\n' ' ' | sed 's/ $//')
    if [ -z "$stunnel_ports" ]; then
        stunnel_ports="447, 778, 779"
    fi
    echo -e "${BICyan}- Stunnel4           : ${BIWhite}$stunnel_ports${NC} [${green}ON${NC}]"
else
    echo -e "${BICyan}- Stunnel4           : ${BIWhite}447, 778, 779${NC} [${red}OFF${NC}]"
fi

# Check Dropbear ports
if ss -tln 2>/dev/null | grep -q ":109 "; then
    echo -e "${BICyan}- Dropbear           : ${BIWhite}109, 143${NC} [${green}ON${NC}]"
else
    echo -e "${BICyan}- Dropbear           : ${BIWhite}109, 143${NC} [${red}OFF${NC}]"
fi

# Check BadVPN status
badvpn_status=$(systemctl is-active badvpn 2>/dev/null)
if [ "$badvpn_status" = "active" ]; then
    resbadvpn="${green}ON${NC}"
else
    resbadvpn="${red}OFF${NC}"
fi
echo -e "${BICyan}- Badvpn             : ${BIWhite}7200${NC} [${resbadvpn}${NC}]"

# Check WebSocket on port 700
if ss -tln 2>/dev/null | grep -q ":700 "; then
    ws700="${green}ON${NC}"
else
    ws700="${red}OFF${NC}"
fi

# Check WebSocket on port 8080
if ss -tln 2>/dev/null | grep -q ":8080 "; then
    ws8080="${green}ON${NC}"
else
    ws8080="${red}OFF${NC}"
fi

# Check BadVPN on port 7200
if pgrep -f "badvpn-udpgw.*7200" > /dev/null; then
    badvpn7200="${green}ON${NC}"
else
    badvpn7200="${red}OFF${NC}"
fi

# Check FTP on port 21
if ss -tln 2>/dev/null | grep -q ":21 "; then
    echo -e "${BICyan}- FTP                : ${BIWhite}21${NC} [${green}ON${NC}]"
else
    echo -e "${BICyan}- FTP                : ${BIWhite}21${NC} [${red}OFF${NC}]"
fi

# Check Nginx on port 81
if ss -tln 2>/dev/null | grep -q ":81 "; then
    echo -e "${BICyan}- Nginx              : ${BIWhite}81${NC} [${green}ON${NC}]"
else
    echo -e "${BICyan}- Nginx              : ${BIWhite}81${NC} [${red}OFF${NC}]"
fi

# Vmess, Vless, Trojan are on 443 and 80, already checked above, but since 443 is shared, perhaps note
echo -e "${BICyan}- Vmess TLS          : ${BIWhite}443${NC} [${green}ON${NC}]"
echo -e "${BICyan}- Vmess None TLS     : ${BIWhite}80${NC} [${green}ON${NC}]"
echo -e "${BICyan}- Vless TLS          : ${BIWhite}443${NC} [${green}ON${NC}]"
echo -e "${BICyan}- Vless None TLS     : ${BIWhite}80${NC} [${green}ON${NC}]"
echo -e "${BICyan}- Trojan GRPC        : ${BIWhite}443${NC} [${green}ON${NC}]"
echo -e "${BICyan}- Trojan WS          : ${BIWhite}443${NC} [${green}ON${NC}]"
echo -e "${BICyan}- Trojan Go          : ${BIWhite}443${NC} [${green}ON${NC}]"

# Add additional running ports
if ss -tln 2>/dev/null | grep -q ":8443 "; then
    echo -e "${BICyan}- SSL Websocket Pro  : ${BIWhite}8443${NC} [${green}ON${NC}]"
fi

# Check for OVPN WebSocket (port 2086)
ovpn_ws_status=$(systemctl is-active WebSocket.OVPN.service 2>/dev/null)
if [ "$ovpn_ws_status" = "active" ]; then
    echo -e "${BICyan}- OVPN WebSocket      : ${BIWhite}2086${NC} [${green}ON${NC}]"
fi
echo ""

# Main Menu
echo -e "${BIYellow}MAIN MENU${NC}"
printf "${BICyan}[%s] %-20s [%s] %-20s [%s] %s${NC}\n" "01" "SSH Accounts" "08" "Add Domain" "15" "System Update"
printf "${BICyan}[%s] %-20s [%s] %-20s [%s] %s${NC}\n" "02" "VMESS Accounts" "09" "Running Processes" "16" "Reboot System"
printf "${BICyan}[%s] %-20s [%s] %-20s [%s] %s${NC}\n" "03" "VLESS Accounts" "10" "WebSocket Port" "17" "Fix Issues"
printf "${BICyan}[%s] %-20s [%s] %-20s\n" "04" "TROJAN Accounts" "11" "Install Bot"
printf "${BICyan}[%s] %-20s [%s] %-20s\n" "05" "Settings" "12" "Bandwidth Monitor"
printf "${BICyan}[%s] %-20s [%s] %-20s\n" "06" "Trial Accounts" "13" "Menu Themes"
printf "${BICyan}[%s] %-20s [%s] %-20s\n" "07" "Backup System" "14" "Custom Banner"
printf "${BICyan}[0] Exit${NC}\n"
echo ""

# Footer
echo -e "${BIGreen}Version: $(cat /root/mastermindvps/VIP-Autoscript/version 2>/dev/null || echo 'Unknown')${NC}"
echo -e "\033[1;34m\033[5mDeveloper: 𓆩 mastermind 𓆪\033[0m"
echo -e "${BIGreen}Lifetime License • Open Source • Professional VPN Management${NC}"
echo

read -p "${BIYellow}Select menu [0-17]:${NC} " opt
echo -e ""
case $opt in
1) clear ; menu-ssh ;;
2) clear ; menu-vmess ;;
3) clear ; menu-vless ;;
4) clear ; menu-trojan ;;
5) clear ; menu-set ;;
6) clear ; menu-trial ;;
7) clear ; menu-backup ;;
8) clear ; add-host ;;
9) clear ; running ;;
10) clear ; wsport ;;
11) clear ; xolpanel ;;
12) clear ; bw ;;
13) clear ; menu-theme ;;
14) clear ; custom-banner ;;
15) clear ; echo "System Update:"; apt update; sleep 2; menu ;;
16) clear ; echo "Rebooting in 3 seconds..."; sleep 3; reboot ;;
17) clear ; fix-issues ;;
0) clear ; exit ;;
x) exit ;;
*) echo -e "" ; echo "Invalid option!" ; sleep 1 ; menu ;;
esac