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
echo -e "       ${BIWhite}TCP BBR MANAGEMENT${NC}"
echo -e ""
echo -e "     ${BICyan}[${BIWhite}01${BICyan}] Enable TCP BBR"
echo -e "     ${BICyan}[${BIWhite}02${BICyan}] Disable TCP BBR"
echo -e "     ${BICyan}[${BIWhite}03${BICyan}] Check BBR Status"
echo -e ""

echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "     ${BIYellow}Press x or [ Ctrl+C ] • To-${BIWhite}Exit${NC}"
echo ""
read -p " Select menu : " opt
echo -e ""
case $opt in
1)
    clear
    echo -e "${BIGreen}Enabling TCP BBR...${NC}"
    
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    
    sysctl -p >/dev/null 2>&1
    
    sleep 1

    if sysctl net.ipv4.tcp_congestion_control | grep -q "bbr"; then
        echo -e "${BIGreen}TCP BBR Enabled Successfully!${NC}"
        echo -e "${BIGreen}Current congestion control: bbr${NC}"
        echo ""
        echo -e "${BIGreen}Restarting network services...${NC}"
        systemctl restart ssh 2>/dev/null
        systemctl restart WebSocket.SSH.service 2>/dev/null
        systemctl restart xray 2>/dev/null
        systemctl restart stunnel4 2>/dev/null
        echo -e "${BIGreen}Services restarted successfully!${NC}"
    else
        echo -e "${BIRed}Failed to enable TCP BBR!${NC}"
    fi

    sleep 2
    bash /root/mastermindvps/VIP-Autoscript/menu/menu-bbr.sh ; exit ;;
2)
    clear
    echo -e "${BIRed}Disabling TCP BBR...${NC}"
    
    sed -i '/net.core.default_qdisc=fq/d' /etc/sysctl.conf 2>/dev/null
    sed -i '/net.ipv4.tcp_congestion_control=bbr/d' /etc/sysctl.conf 2>/dev/null
    
    echo "net.ipv4.tcp_congestion_control=cubic" >> /etc/sysctl.conf
    
    sysctl -p >/dev/null 2>&1
    
    sleep 1

    if sysctl net.ipv4.tcp_congestion_control | grep -q "cubic"; then
        echo -e "${BIRed}TCP BBR Disabled Successfully!${NC}"
        echo -e "${BIGreen}Current congestion control: cubic${NC}"
        echo ""
        echo -e "${BIGreen}Restarting network services...${NC}"
        systemctl restart ssh 2>/dev/null
        systemctl restart WebSocket.SSH.service 2>/dev/null
        systemctl restart xray 2>/dev/null
        systemctl restart stunnel4 2>/dev/null
        echo -e "${BIGreen}Services restarted successfully!${NC}"
    else
        echo -e "${BIRed}Failed to disable TCP BBR!${NC}"
    fi

    sleep 2
    bash /root/mastermindvps/VIP-Autoscript/menu/menu-bbr.sh ; exit ;;
3)
    clear
    echo -e "${BIGreen}BBR Status:${NC}"
    echo ""
    
    bbr_status=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)
    
    if [[ x"${bbr_status}" == x"bbr" ]]; then
        echo -e "TCP Congestion Control: ${BIGreen}BBR (ACTIVE)${NC}"
    else
        echo -e "TCP Congestion Control: ${BIRed}${bbr_status} (INACTIVE)${NC}"
    fi
    
    if lsmod | grep -q "tcp_bbr"; then
        echo -e "BBR Module:              ${BIGreen}LOADED${NC}"
    else
        echo -e "BBR Module:              ${BIRed}NOT LOADED${NC}"
    fi
    
    if sysctl net.core.default_qdisc | grep -q "fq"; then
        echo -e "QDisc:                   ${BIGreen}fq${NC}"
    else
        qdisc=$(sysctl -n net.core.default_qdisc 2>/dev/null)
        echo -e "QDisc:                   ${BIRed}${qdisc}${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
    bash /root/mastermindvps/VIP-Autoscript/menu/menu-bbr.sh ; exit ;;
0) clear ; bash /root/mastermindvps/VIP-Autoscript/menu/menu-set.sh ; exit ;;
x) exit ;;
*) echo -e "" ; echo "Wrong choice !" ; sleep 1 ; bash /root/mastermindvps/VIP-Autoscript/menu/menu-bbr.sh ;;
esac
