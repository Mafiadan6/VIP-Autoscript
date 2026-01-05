#!/bin/bash
MYIP=$(wget -qO- ipinfo.io/ip);
echo "Checking VPS"

clear
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[40;1;37m    • CHANGE WEBSOCKET SSH PORT •        \E[0m"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e ""
echo -e " Current Port: \e[36m80\e[0m (WebSocket SSH)"
echo -e ""
read -p " Enter New Port: " newport

if [[ -z "$newport" ]]; then
    echo -e "\e[31mError: Port cannot be empty!\033[0m"
    sleep 2
    menu-set
    exit
fi

# Validate port number
if ! [[ "$newport" =~ ^[0-9]+$ ]] || [ "$newport" -lt 1 ] || [ "$newport" -gt 65535 ]; then
    echo -e "\e[31mError: Invalid port number! (1-65535)\033[0m"
    sleep 2
    menu-set
    exit
fi

# Check if port is already in use
if ss -tln 2>/dev/null | grep -q ":$newport " || netstat -tln 2>/dev/null | grep -q ":$newport "; then
    echo -e "\e[31mError: Port $newport is already in use!\033[0m"
    sleep 2
    menu-set
    exit
fi

echo ""
echo -e "\e[33mChanging WebSocket SSH Port...\033[0m"

# Stop the service first
systemctl stop WebSocket.SSH.service 2>/dev/null

# Update the service file
sed -i "s|ExecStart=/usr/bin/python2 /usr/local/bin/WebSocket.SSH.py 80|ExecStart=/usr/bin/python2 /usr/local/bin/WebSocket.SSH.py $newport|g" /etc/systemd/system/WebSocket.SSH.service

# Reload systemd
systemctl daemon-reload

# Update WebSocket.SSH.py port in WebSocket config if exists
if [ -f /usr/local/bin/WebSocket ]; then
    sed -i "s/DEFAULT_HOST = '127.0.0.1:80'/DEFAULT_HOST = '127.0.0.1:22'/" /usr/local/bin/WebSocket 2>/dev/null
fi

# Start the service
systemctl start WebSocket.SSH.service

# Check if service started successfully
sleep 2
if systemctl is-active --quiet WebSocket.SSH.service; then
    echo -e "\e[32m✓ WebSocket SSH Port changed successfully!\033[0m"
    echo -e "\e[32m✓ New Port: $newport\033[0m"
    echo -e "\e[32m✓ Service restarted\033[0m"
else
    echo -e "\e[31m✗ Failed to start WebSocket SSH service!\033[0m"
    echo -e "\e[31m✗ Reverting changes...\033[0m"
    sed -i "s|ExecStart=/usr/bin/python2 /usr/local/bin/WebSocket.SSH.py $newport|ExecStart=/usr/bin/python2 /usr/local/bin/WebSocket.SSH.py 80|g" /etc/systemd/system/WebSocket.SSH.service
    systemctl daemon-reload
    systemctl start WebSocket.SSH.service
    sleep 2
fi

echo ""
read -n 1 -s -r -p "  Press any key to back on menu"
clear
menu-set
