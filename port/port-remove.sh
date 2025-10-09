#!/bin/bash
MYIP=$(wget -qO- ipinfo.io/ip);
echo "Checking VPS"

clear
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[40;1;37m    • REMOVE/RESET PORT SERVICE •        \E[0m"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
echo -e " [\e[36m•1\e[0m] Reset Stunnel4 Port to Default (447, 778, 779)"
echo -e " [\e[36m•2\e[0m] Reset Dropbear Port to Default (109, 143)"
echo -e " [\e[36m•3\e[0m] Reset WebSocket SSH Port to Default (80)"
echo -e " [\e[36m•4\e[0m] Clear All Custom Port Configurations"
echo -e ""
echo -e " [\e[31m•0\e[0m] \e[31mBACK TO MENU\033[0m"
echo ""
echo -e   "Press x or [ Ctrl+C ] • To-Exit"
echo -e   ""
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
read -p " Select menu : " opt
echo -e ""
case $opt in
1)
    clear
    echo "Resetting Stunnel4 ports to default..."
    # Reset stunnel configuration to default
    cat > /etc/stunnel/stunnel.conf << EOF
pid = /var/run/stunnel4/stunnel.pid
cert = /etc/stunnel/stunnel.pem
client = no
[ssh1]
accept = 447
connect = 127.0.0.1:22
[ssh2]
accept = 778
connect = 127.0.0.1:22
[ssh3]
accept = 779
connect = 127.0.0.1:22
EOF
    systemctl restart stunnel4
    echo "Stunnel4 ports reset to default: 447, 778, 779"
    sleep 2
    clear ; port-remove ; exit ;;
2)
    clear
    echo "Resetting Dropbear ports to default..."
    # Reset dropbear configuration to default
    sed -i 's/DROPBEAR_EXTRA_ARGS=.*/DROPBEAR_EXTRA_ARGS="-p 143"/' /etc/default/dropbear
    systemctl restart dropbear
    echo "Dropbear ports reset to default: 109, 143"
    sleep 2
    clear ; port-remove ; exit ;;
3)
    clear
    echo "Resetting WebSocket SSH port to default..."
    # Reset WebSocket SSH to port 80
    systemctl stop WebSocket.SSH.service
    sed -i 's/ExecStart=.*/ExecStart=\/usr\/bin\/python2 \/usr\/local\/bin\/WebSocket.SSH.py 80/' /etc/systemd/system/WebSocket.SSH.service
    systemctl daemon-reload
    systemctl start WebSocket.SSH.service
    echo "WebSocket SSH port reset to default: 80"
    sleep 2
    clear ; port-remove ; exit ;;
4)
    clear
    echo "Clearing all custom port configurations..."
    # Reset all services to default ports
    echo "Resetting Stunnel4..."
    cat > /etc/stunnel/stunnel.conf << EOF
pid = /var/run/stunnel4/stunnel.pid
cert = /etc/stunnel/stunnel.pem
client = no
[ssh1]
accept = 447
connect = 127.0.0.1:22
[ssh2]
accept = 778
connect = 127.0.0.1:22
[ssh3]
accept = 779
connect = 127.0.0.1:22
EOF
    systemctl restart stunnel4

    echo "Resetting Dropbear..."
    sed -i 's/DROPBEAR_EXTRA_ARGS=.*/DROPBEAR_EXTRA_ARGS="-p 143"/' /etc/default/dropbear
    systemctl restart dropbear

    echo "Resetting WebSocket SSH..."
    systemctl stop WebSocket.SSH.service
    sed -i 's/ExecStart=.*/ExecStart=\/usr\/bin\/python2 \/usr\/local\/bin\/WebSocket.SSH.py 80/' /etc/systemd/system/WebSocket.SSH.service
    systemctl daemon-reload
    systemctl start WebSocket.SSH.service

    echo "All ports reset to default configuration!"
    sleep 3
    clear ; menu ; exit ;;
0) clear ; menu-set ; exit ;;
x) exit ;;
*) echo -e "" ; echo "Invalid option!" ; sleep 1 ; port-remove ;;
esac