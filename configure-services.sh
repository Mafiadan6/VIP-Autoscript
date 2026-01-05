#!/bin/bash
BIRed='\033[1;91m'
BIGreen='\033[1;92m'
BIYellow='\033[1;93m'
BICyan='\033[1;96m'
BIWhite='\033[1;97m'
NC='\e[0m'

clear
echo -e "${BICyan}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BICyan}║${NC}         ${BIWhite}CONFIGURE FAILED VPN SERVICES${NC}                    ${BICyan}║${NC}"
echo -e "${BICyan}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BIYellow}This script will configure:${NC}"
echo -e "  1. BadVPN (UDP Gateway)"
echo -e "  2. Trojan-Go"
echo -e "  3. Fail2Ban"
echo -e "  4. OpenVPN"
echo -e "  5. WebSocket Services"
echo ""

read -p "Continue? (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo -e "${BIGreen}[1/5]${NC} ${BIWhite}Configuring BadVPN...${NC}"

if [ ! -f "/usr/local/bin/badvpn-udpgw" ]; then
    echo -e "${BIYellow}Installing BadVPN...${NC}"
    apt-get install -y build-essential libssl-dev >/dev/null 2>&1
    cd /tmp
    wget -q https://github.com/ambrop72/badvpn/archive/master.zip -O badvpn.zip
    unzip -q badvpn.zip
    cd badvpn-master
    mkdir -p build && cd build
    cmake .. >/dev/null 2>&1
    make >/dev/null 2>&1
    cp udpgw/badvpn-udpgw /usr/local/bin/
    chmod +x /usr/local/bin/badvpn-udpgw
    cd /
    rm -rf /tmp/badvpn-master /tmp/badvpn.zip
fi

cat > /etc/systemd/system/badvpn.service << EOF
[Unit]
Description=BadVPN UDP Gateway
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 1000 --max-connections-for-client 10
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

pkill -f badvpn-udpgw 2>/dev/null || true
systemctl daemon-reload
systemctl enable badvpn >/dev/null 2>&1
systemctl start badvpn >/dev/null 2>&1
echo -e "${BIGreen}✓ BadVPN configured for port 7200${NC}"

echo ""
echo -e "${BIGreen}[2/5]${NC} ${BIWhite}Configuring Trojan-Go...${NC}"

if [ ! -f "/usr/local/bin/trojan-go" ]; then
    echo -e "${BIYellow}Installing Trojan-Go...${NC}"
    latest_version="0.10.6"
    trojango_link="https://github.com/p4gefau1t/trojan-go/releases/download/v${latest_version}/trojan-go-linux-amd64.zip"
    mkdir -p "/usr/bin/trojan-go" "/etc/trojan-go" "/var/log/trojan-go"
    cd /tmp
    wget -q "${trojango_link}" -o trojan-go.zip
    unzip -q trojan-go.zip && rm -f trojan-go.zip
    mv trojan-go /usr/local/bin/trojan-go
    chmod +x /usr/local/bin/trojan-go
fi

touch /etc/trojan-go/akun.conf /var/log/trojan-go/trojan-go.log
uuid=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || echo "31415926-5358-9793-2384-626433832795")

if [ -f "/etc/xray/domain" ]; then
    domain=$(cat /etc/xray/domain)
else
    domain="example.com"
fi

cat > /etc/trojan-go/config.json << EOF
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": 443,
    "remote_addr": "127.0.0.1",
    "remote_port": 80,
    "password": [
        "$uuid"
    ],
    "ssl": {
        "cert": "/etc/xray/cert.crt",
        "key": "/etc/xray/key.key",
        "fallback_addr": "127.0.0.1",
        "fallback_port": 80
    },
    "router": {
        "enabled": true
    },
    "log_level": 2,
    "log_file": "/var/log/trojan-go/trojan-go.log"
}
EOF

cat > /etc/systemd/system/trojan-go.service << EOF
[Unit]
Description=Trojan-Go Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/trojan-go -config /etc/trojan-go/config.json
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable trojan-go >/dev/null 2>&1
systemctl restart trojan-go >/dev/null 2>&1
echo -e "${BIGreen}✓ Trojan-Go configured${NC}"

echo ""
echo -e "${BIGreen}[3/5]${NC} ${BIWhite}Configuring Fail2Ban...${NC}"

apt-get install -y fail2ban >/dev/null 2>&1

cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
destemail = root@localhost
sendername = Fail2Ban
action = %(action_)s

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 5

[dropbear]
enabled = true
port = 109,143
logpath = /var/log/auth.log
maxretry = 5
EOF

systemctl enable fail2ban >/dev/null 2>&1
systemctl restart fail2ban >/dev/null 2>&1
echo -e "${BIGreen}✓ Fail2Ban configured for SSH/Dropbear${NC}"

echo ""
echo -e "${BIGreen}[4/5]${NC} ${BIWhite}Configuring OpenVPN...${NC}"

apt-get install -y openvpn easy-rsa >/dev/null 2>&1

if [ ! -d "/etc/openvpn/easy-rsa" ]; then
    make-cadir /etc/openvpn/easy-rsa
    cd /etc/openvpn/easy-rsa
    ./easyrsa init-pki
    echo | EASYRSA_CERT_EXPIRE=3650 ./easyrsa build-ca nopass
    echo | EASYRSA_CERT_EXPIRE=3650 ./easyrsa gen-req server nopass
    echo | EASYRSA_CERT_EXPIRE=3650 ./easyrsa sign-req server server
    EASYRSA_CERT_EXPIRE=3650 ./easyrsa gen-dh
    openvpn --genkey secret ta.key
    cp pki/ca.crt pki/private/server.key pki/issued/server.crt pki/dh.pem ta.key /etc/openvpn/server/
    cd /
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
status openvpn.log
verb 3
explicit-exit-notify 1
keepalive 10 120
max-clients 100
user nobody
group nogroup
EOF

systemctl enable openvpn@server >/dev/null 2>&1
systemctl start openvpn@server >/dev/null 2>&1
echo -e "${BIGreen}✓ OpenVPN configured on port 1194${NC}"

echo ""
echo -e "${BIGreen}[5/5]${NC} ${BIWhite}Configuring WebSocket Services...${NC}"

domain=$(cat /etc/xray/domain 2>/dev/null || echo "example.com")

cat > /etc/systemd/system/WebSocket.SSH-WS.service << EOF
[Unit]
Description=SSH WebSocket Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/drops -s 127.0.0.1:22 -p 80 -c "GET / HTTP/1.1\r\nHost: ${domain}\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n"
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
ExecStart=/usr/local/bin/drops -s 127.0.0.1:109 -p 80 -c "GET / HTTP/1.1\r\nHost: ${domain}\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n"
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
ExecStart=/usr/local/bin/drops -s 127.0.0.1:443 -p 80 -c "GET / HTTP/1.1\r\nHost: ${domain}\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n"
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
echo -e "${BIGreen}✓ WebSocket services configured${NC}"

echo ""
echo -e "${BICyan}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BICyan}║${NC}                  ${BIWhite}CONFIGURATION COMPLETE${NC}                    ${BICyan}║${NC}"
echo -e "${BICyan}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BIGreen}Services Configured:${NC}"
echo -e "  ✓ BadVPN (port 7200)"
echo -e "  ✓ Trojan-Go (port 443)"
echo -e "  ✓ Fail2Ban (SSH/Dropbear protection)"
echo -e "  ✓ OpenVPN (port 1194)"
echo -e "  ✓ WebSocket Services"
echo ""

echo -e "${BIYellow}Run 'restart-all' to restart all services${NC}"
echo ""
