#!/bin/bash
BIRed='\033[1;91m'
BIGreen='\033[1;92m'
BIYellow='\033[1;93m'
BICyan='\033[1;96m'
BIWhite='\033[1;97m'
NC='\e[0m'

clear
echo -e "${BICyan}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BICyan}║${NC}         ${BIWhite}INSTALL & CONFIGURE VPN SERVICES${NC}               ${BICyan}║${NC}"
echo -e "${BICyan}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Install Fail2Ban
echo -e "${BIGreen}[1/4]${NC} ${BIWhite}Configuring Fail2Ban...${NC}"
apt-get install -y fail2ban >/dev/null 2>&1

cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 5
EOF

systemctl enable fail2ban >/dev/null 2>&1
systemctl restart fail2ban >/dev/null 2>&1
echo -e "${BIGreen}✓${NC} Fail2Ban configured for SSH protection"

# Install & Configure OpenVPN
echo ""
echo -e "${BIGreen}[2/4]${NC} ${BIWhite}Configuring OpenVPN...${NC}"
apt-get install -y openvpn >/dev/null 2>&1

if [ ! -d "/etc/openvpn/server" ]; then
    mkdir -p /etc/openvpn/server
fi

# Generate simple certificates
cd /etc/openvpn/server
if [ ! -f "ca.crt" ]; then
    openssl genrsa -out ca.key 2048 >/dev/null 2>&1
    openssl req -new -x509 -days 3650 -key ca.key -out ca.crt -subj "/C=US/ST=State/L=City/O=Org/CN=VPN-CA" >/dev/null 2>&1
    openssl genrsa -out server.key 2048 >/dev/null 2>&1
    openssl req -new -key server.key -out server.csr -subj "/C=US/ST=State/L=City/O=Org/CN=VPN-Server" >/dev/null 2>&1
    openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt >/dev/null 2>&1
    openssl dhparam -out dh.pem 2048 >/dev/null 2>&1
    openvpn --genkey secret ta.key >/dev/null 2>&1
fi

cat > /etc/openvpn/server.conf << EOF
port 1194
proto tcp
dev tun
ca /etc/openvpn/server/ca.crt
cert /etc/openvpn/server/server.crt
key /etc/openvpn/server/server.key
dh /etc/openvpn/server/dh.pem
tls-auth /etc/openvpn/server/ta.key 0
cipher AES-256-CBC
auth SHA256
persist-key
persist-tun
status /var/log/openvpn.log
verb 3
keepalive 10 120
max-clients 100
user nobody
group nogroup
EOF

systemctl enable openvpn@server >/dev/null 2>&1
systemctl restart openvpn@server >/dev/null 2>&1
echo -e "${BIGreen}✓${NC} OpenVPN configured on port 1194"

# Install BadVPN
echo ""
echo -e "${BIGreen}[3/4]${NC} ${BIWhite}Configuring BadVPN...${NC}"

if [ ! -f "/usr/local/bin/badvpn-udpgw" ]; then
    echo -e "${BIYellow}Installing BadVPN from source...${NC}"
    apt-get install -y build-essential libssl-dev >/dev/null 2>&1
    cd /tmp
    if [ ! -d "badvpn" ]; then
        git clone https://github.com/ambrop72/badvpn.git >/dev/null 2>&1
    fi
    cd badvpn
    mkdir -p build && cd build
    cmake .. >/dev/null 2>&1
    make >/dev/null 2>&1
    cp udpgw/badvpn-udpgw /usr/local/bin/
    chmod +x /usr/local/bin/badvpn-udpgw
    cd /
fi

cat > /etc/systemd/system/badvpn.service << EOF
[Unit]
Description=BadVPN UDP Gateway
After=network.target

[Service]
Type=simple
User=root
ExecStart=/bin/bash -c 'for port in 7100 7900; do /usr/local/bin/badvpn-udpgw --listen-addr 127.0.0.1:$port --max-clients 1000 --max-connections-for-client 10 & done; wait'
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable badvpn >/dev/null 2>&1
systemctl restart badvpn >/dev/null 2>&1
echo -e "${BIGreen}✓${NC} BadVPN configured for ports 7100 and 7900"

# Configure WebSocket Services
echo ""
echo -e "${BIGreen}[4/4]${NC} ${BIWhite}Configuring WebSocket Services...${NC}"

domain=$(cat /etc/xray/domain 2>/dev/null || echo "localhost")

# Create drops utility if not exists
if [ ! -f "/usr/local/bin/drops" ]; then
    cat > /usr/local/bin/drops << 'EOF'
#!/bin/bash
while true; do
    nc -l -p $2 -e "echo -e \"HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n\"; nc $1 $3"
done
EOF
    chmod +x /usr/local/bin/drops
fi

cat > /etc/systemd/system/WebSocket.SSH-WS.service << EOF
[Unit]
Description=SSH WebSocket Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/drops 127.0.0.1 80 22
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/WebSocket.Dropbear.service << EOF
[Unit]
Description=Dropbear WebSocket Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/drops 127.0.0.1 80 109
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/WebSocket.Stunnel.service << EOF
[Unit]
Description=Stunnel WebSocket Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/drops 127.0.0.1 80 443
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
echo -e "${BIGreen}✓${NC} WebSocket services configured"

echo ""
echo -e "${BICyan}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BICyan}║${NC}                  ${BIWhite}CONFIGURATION COMPLETE${NC}                    ${BICyan}║${NC}"
echo -e "${BICyan}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BIGreen}Services Configured:${NC}"
echo -e "  ✓ Fail2Ban (SSH protection)"
echo -e "  ✓ OpenVPN (port 1194)"
echo -e "  ✓ BadVPN (ports 7100-7900)"
echo -e "  ✓ WebSocket Services"
echo ""

echo -e "${BIYellow}Run 'restart-all' to restart all services${NC}"
echo ""
