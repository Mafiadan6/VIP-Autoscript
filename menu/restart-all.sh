#!/bin/bash
BIRed='\033[1;91m'
BIGreen='\033[1;92m'
BIYellow='\033[1;93m'
BICyan='\033[1;96m'
BIWhite='\033[1;97m'
NC='\e[0m'

clear
echo -e "${BICyan}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BICyan}║${NC}            ${BIWhite}RESTARTING ALL VPN SERVICES${NC}                ${BICyan}║${NC}"
echo -e "${BICyan}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

services=()
status=()

function restart_service() {
    local service=$1
    # Skip if service doesn't exist
    if ! systemctl list-unit-files | grep -q "^${service}" && ! [ -f "/etc/init.d/$service" ]; then
        return 0
    fi
    echo -e "${BIYellow}→${NC} Restarting ${BIWhite}$service${NC}..."
    if systemctl restart $service >/dev/null 2>&1; then
        echo -e "   ${BIGreen}✓${NC} $service ${BIGreen}Restarted Successfully${NC}"
        services+=("$service")
        status+=("OK")
    elif [ -f "/etc/init.d/$service" ] && /etc/init.d/$service restart >/dev/null 2>&1; then
        echo -e "   ${BIGreen}✓${NC} $service ${BIGreen}Restarted Successfully${NC}"
        services+=("$service")
        status+=("OK")
    else
        echo -e "   ${BIRed}✗${NC} $service ${BIRed}Failed to Restart${NC}"
        services+=("$service")
        status+=("FAILED")
    fi
    sleep 0.3
}

restart_service "ssh"
restart_service "dropbear"
restart_service "stunnel4"
restart_service "nginx"
restart_service "xray"
restart_service "WebSocket.SSH.service"
restart_service "WebSocket.SSH-WS.service"
restart_service "WebSocket.Dropbear.service"
restart_service "WebSocket.Stunnel.service"
restart_service "WebSocket.OVPN.service"
restart_service "trojan-go.service"
restart_service "badvpn"
restart_service "fail2ban"
restart_service "cron"
restart_service "unbound"
restart_service "dnscrypt-proxy"
restart_service "squid"
restart_service "openvpn"

echo ""
echo -e "${BICyan}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BICyan}║${NC}                    ${BIWhite}RESTART SUMMARY${NC}                        ${BICyan}║${NC}"
echo -e "${BICyan}╠════════════════════════════════════════════════════════════╣${NC}"

for i in "${!services[@]}"; do
    if [ "${status[$i]}" = "OK" ]; then
        echo -e "${BICyan}║${NC} ${BIGreen}✓${NC} ${BIWhite}${services[$i]}${NC} $(printf '%*s' $((35 - ${#services[$i]})) '') ${BIGreen}[OK]${NC} ${BICyan}║${NC}"
    else
        echo -e "${BICyan}║${NC} ${BIRed}✗${NC} ${BIWhite}${services[$i]}${NC} $(printf '%*s' $((35 - ${#services[$i]})) '') ${BIRed}[FAILED]${NC} ${BICyan}║${NC}"
    fi
done

echo -e "${BICyan}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BIGreen}All VPN & Network services have been restarted!${NC}"
echo ""
