#!/bin/bash
###########- COLOR CODE -##############
NC="\e[0m"
RED="\033[0;31m"
GREEN="\033[0;32m"

echo -e "${GREEN} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "         ${GREEN}AUTO FIX ISSUES - PORT CONFLICTS${NC}"
echo -e " ${GREEN}└─────────────────────────────────────────────────────┘${NC}"
echo ""

# Function to check and fix service
check_service() {
    local service=$1
    local port=$2
    local expected_process=$3

    echo -e "Checking ${service} on port ${port}..."

    # Check if service is active
    if systemctl is-active --quiet ${service}; then
        echo -e "${GREEN}✓ Service ${service} is running${NC}"
    else
        echo -e "${RED}✗ Service ${service} is not running, starting...${NC}"
        systemctl start ${service}
        sleep 2
        if systemctl is-active --quiet ${service}; then
            echo -e "${GREEN}✓ Service ${service} started successfully${NC}"
        else
            echo -e "${RED}✗ Failed to start ${service}${NC}"
        fi
    fi

    # Check if port is listening with expected process
    if netstat -tlnp 2>/dev/null | grep ":${port} " | grep -q "${expected_process}"; then
        echo -e "${GREEN}✓ Port ${port} is listening correctly${NC}"
    else
        echo -e "${RED}✗ Port ${port} not listening or wrong process, restarting service...${NC}"
        systemctl restart ${service}
        sleep 3
        if netstat -tlnp 2>/dev/null | grep ":${port} " | grep -q "${expected_process}"; then
            echo -e "${GREEN}✓ Port ${port} fixed${NC}"
        else
            echo -e "${RED}✗ Port ${port} still not working${NC}"
        fi
    fi
    echo ""
}

# Check SSH WebSocket on port 80
check_service "WebSocket.SSH.service" "80" "python2"

# Check other WebSocket services
check_service "WebSocket.service" "700" "python2"
check_service "WebSocket.OVPN.service" "2086" "python2"

# Check FTP service on port 21
check_service "vsftpd.service" "21" "vsftpd"

# Check main services
echo "Checking main services..."
services=("ssh.service" "dropbear.service" "stunnel4.service" "xray.service")

for svc in "${services[@]}"; do
    if systemctl is-active --quiet ${svc}; then
        echo -e "${GREEN}✓ ${svc} is running${NC}"
    else
        echo -e "${RED}✗ ${svc} is not running, starting...${NC}"
        systemctl start ${svc}
        sleep 1
        if systemctl is-active --quiet ${svc}; then
            echo -e "${GREEN}✓ ${svc} started${NC}"
        else
            echo -e "${RED}✗ Failed to start ${svc}${NC}"
        fi
    fi
done

echo ""
echo -e "${GREEN}Auto-fix completed. Press any key to return to menu.${NC}"
read -n 1 -s -r
menu