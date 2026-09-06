#!/bin/bash
# =============================================================================
# finalize-install.sh - Applies the known-good "working state" to the VPS.
# Idempotent: safe to run on a fresh install OR an already-working box.
# Run via setup.sh, or standalone:  bash /root/mastermindvps/VIP-Autoscript/finalize-install.sh
# =============================================================================
set -u
export DEBIAN_FRONTEND=noninteractive
REPO=/root/mastermindvps/VIP-Autoscript

green(){ echo -e "\\033[32;1m${*}\\033[0m"; }
red(){ echo -e "\\033[31;1m${*}\\033[0m"; }
blue(){ echo -e "\\033[34;1m${*}\\033[0m"; }
yell(){ echo -e "\\033[33;1m${*}\\033[0m"; }

DOMAIN=$(cat /etc/xray/domain 2>/dev/null)
[ -z "$DOMAIN" ] && DOMAIN=$(cat /root/domain 2>/dev/null)
IP=$(curl -s --max-time 5 ipinfo.io/ip 2>/dev/null || hostname -I | awk '{print $1}')

# -----------------------------------------------------------------------------
# 1. Node.js LTS (mirrors the manual tarball install used on this box)
# -----------------------------------------------------------------------------
if ! command -v node >/dev/null 2>&1; then
    blue "---> Installing Node.js LTS (24.x tarball) ..."
    NODE_VER=24.20.0
    curl -fsSL "https://nodejs.org/dist/v${NODE_VER}/node-v${NODE_VER}-linux-x64.tar.xz" -o /tmp/nodejs.tar.xz
    mkdir -p /opt
    tar -C /opt -xJf /tmp/nodejs.tar.xz && rm -f /tmp/nodejs.tar.xz
    ln -sf "/opt/node-v${NODE_VER}-linux-x64/bin/node" /usr/local/bin/node
    ln -sf "/opt/node-v${NODE_VER}-linux-x64/bin/npm" /usr/local/bin/npm
    ln -sf "/opt/node-v${NODE_VER}-linux-x64/bin/npx" /usr/local/bin/npx
    green "Node $(node -v) / npm $(npm -v) installed"
fi

# -----------------------------------------------------------------------------
# 2. WebSocket proxy services (Python 3, correct ports) - units rewritten idempotently
# -----------------------------------------------------------------------------
blue "---> Configuring WebSocket proxy services (py3) ..."
mkdir -p /usr/local/bin /etc/ws
[ -f "$REPO/sshws/WebSocket.py" ] && cp "$REPO"/sshws/WebSocket.py* /usr/local/bin/ 2>/dev/null
chmod +x /usr/local/bin/WebSocket*.py 2>/dev/null

cat > /etc/systemd/system/WebSocket.service <<'EOF'
[Unit]
Description=WebSocket Proxy By mastermind
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
User=root
WorkingDirectory=/usr/local/bin
ExecStart=/usr/bin/python3 /usr/local/bin/WebSocket.py 700
Restart=always
RestartSec=3s
[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/WebSocket.SSH.service <<'EOF'
[Unit]
Description=WebSocket Proxy By mastermind (SSH)
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
User=root
WorkingDirectory=/usr/local/bin
ExecStart=/usr/bin/python3 /usr/local/bin/WebSocket.SSH.py 8080
Restart=always
RestartSec=3s
[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/WebSocket.OVPN.service <<'EOF'
[Unit]
Description=WebSocket Proxy By mastermind (OVPN)
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
User=root
WorkingDirectory=/usr/local/bin
ExecStart=/usr/bin/python3 /usr/local/bin/WebSocket.OVPN.py 2086
Restart=always
RestartSec=3s
[Install]
WantedBy=multi-user.target
EOF

printf 'SSH\n' > /etc/ws/status
printf 'SSH\n' > /etc/ws/status2

systemctl daemon-reload
for s in WebSocket WebSocket.SSH WebSocket.OVPN; do
    systemctl enable $s.service 2>/dev/null
    systemctl restart $s.service 2>/dev/null
done

# -----------------------------------------------------------------------------
# 3. Domain + UUID
# -----------------------------------------------------------------------------
if [ -n "$DOMAIN" ]; then
    mkdir -p /etc/xray /var/lib/scrz-prem
    echo "$DOMAIN" > /etc/xray/domain
    echo "$DOMAIN" > /root/domain
    echo "IP=$DOMAIN" > /var/lib/scrz-prem/ipvps.conf
    green "Domain: $DOMAIN"
fi

if [ ! -s /etc/xray/uuid.txt ]; then
    UUID=$(cat /proc/sys/kernel/random/uuid)
    echo "uuid=$UUID" > /etc/xray/uuid.txt
    green "Generated UUID: $UUID"
fi
UUID=$(sed 's/^uuid=//;s/[[:space:]]//g' /etc/xray/uuid.txt 2>/dev/null)
[ -z "$UUID" ] && UUID=$(cat /proc/sys/kernel/random/uuid)

# -----------------------------------------------------------------------------
# 4. Xray panel configuration (marker comments required by add-* scripts)
# -----------------------------------------------------------------------------
mkdir -p /var/log/xray /var/www/html /home/vps/public_html
chown -R www-data:www-data /var/log/xray /var/www/html 2>/dev/null || true

cat > /etc/xray/config.json <<EOF
{
  "log" : {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "inbounds": [
{
  "listen": "127.0.0.1",
  "port": 10085,
  "protocol": "dokodemo-door",
  "settings": { "address": "127.0.0.1" },
  "tag": "api"
},
{
  "listen": "127.0.0.1",
  "port": 14016,
  "protocol": "vless",
  "settings": {
    "decryption": "none",
    "clients": [
      { "id": "${UUID}"
        #vless
}
    ]
  },
  "streamSettings": { "network": "ws", "wsSettings": { "path": "/vless" } }
},
{
  "listen": "127.0.0.1",
  "port": 23456,
  "protocol": "vmess",
  "settings": {
    "clients": [
      { "id": "${UUID}", "alterId": 0
        #vmess
      }
    ]
  },
  "streamSettings": { "network": "ws", "wsSettings": { "path": "/vmess" } }
},
{
  "listen": "127.0.0.1",
  "port": 25432,
  "protocol": "trojan",
  "settings": {
    "decryption": "none",
    "clients": [
      { "password": "${UUID}"
        #trojanws
      }
    ],
    "udp": true
  },
  "streamSettings": { "network": "ws", "wsSettings": { "path": "/trojan-ws" } }
},
{
  "listen": "127.0.0.1",
  "port": 30300,
  "protocol": "shadowsocks",
  "settings": {
    "clients": [
      { "method": "aes-128-gcm", "password": "${UUID}"
        #ssws
      }
    ],
    "network": "tcp,udp"
  },
  "streamSettings": { "network": "ws", "wsSettings": { "path": "/ss-ws" } }
},
{
  "listen": "127.0.0.1",
  "port": 24456,
  "protocol": "vless",
  "settings": {
    "decryption": "none",
    "clients": [
      { "id": "${UUID}"
        #vlessgrpc
}
    ]
  },
  "streamSettings": { "network": "grpc", "grpcSettings": { "serviceName": "vless-grpc" } }
},
{
  "listen": "127.0.0.1",
  "port": 31234,
  "protocol": "vmess",
  "settings": {
    "clients": [
      { "id": "${UUID}", "alterId": 0
        #vmessgrpc
      }
    ]
  },
  "streamSettings": { "network": "grpc", "grpcSettings": { "serviceName": "vmess-grpc" } }
},
{
  "listen": "127.0.0.1",
  "port": 33456,
  "protocol": "trojan",
  "settings": {
    "decryption": "none",
    "clients": [
      { "password": "${UUID}"
        #trojangrpc
      }
    ]
  },
  "streamSettings": { "network": "grpc", "grpcSettings": { "serviceName": "trojan-grpc" } }
},
{
  "listen": "127.0.0.1",
  "port": 30310,
  "protocol": "shadowsocks",
  "settings": {
    "clients": [
      { "method": "aes-128-gcm", "password": "${UUID}"
        #ssgrpc
      }
    ],
    "network": "tcp,udp"
  },
  "streamSettings": { "network": "grpc", "grpcSettings": { "serviceName": "ss-grpc" } }
}
  ],
  "outbounds": [
    { "protocol": "freedom", "settings": {} },
    { "protocol": "blackhole", "settings": {}, "tag": "blocked" }
  ],
  "routing": {
    "rules": [
      { "type": "field", "ip": ["0.0.0.0/8","10.0.0.0/8","100.64.0.0/10","169.254.0.0/16","172.16.0.0/12","192.0.0.0/24","192.0.2.0/24","192.168.0.0/16","198.18.0.0/15","198.51.100.0/24","203.0.113.0/24","::1/128","fc00::/7","fe80::/10"], "outboundTag": "blocked" },
      { "inboundTag": ["api"], "outboundTag": "api", "type": "field" },
      { "type": "field", "outboundTag": "blocked", "protocol": ["bittorrent"] }
    ]
  },
  "stats": {},
  "api": { "services": ["StatsService"], "tag": "api" },
  "policy": { "levels": { "0": { "statsUserDownlink": true, "statsUserUplink": true } }, "system": { "statsInboundUplink": true, "statsInboundDownlink": true, "statsOutboundUplink": true, "statsOutboundDownlink": true } }
}
EOF
chown www-data:www-data /etc/xray/config.json
green "Xray panel config written (markers preserved)"

# -----------------------------------------------------------------------------
# 5. Xray systemd unit (config.json + www-data)
# -----------------------------------------------------------------------------
rm -rf /etc/systemd/system/xray.service.d
cat > /etc/systemd/system/xray.service <<'EOF'
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable xray.service 2>/dev/null
systemctl restart xray.service 2>/dev/null || true

# -----------------------------------------------------------------------------
# 6. V2Ray placeholder config (menu writes configs into this file)
# -----------------------------------------------------------------------------
mkdir -p /usr/local/etc/v2ray
[ -s /usr/local/etc/v2ray/config.json ] || echo '{}' > /usr/local/etc/v2ray/config.json
systemctl enable v2ray.service 2>/dev/null
systemctl restart v2ray.service 2>/dev/null || true

# -----------------------------------------------------------------------------
# 7. SSL certificate (acme.sh, standalone on :80 like this box) + renewal
# -----------------------------------------------------------------------------
if [ -n "$DOMAIN" ]; then
    if [ ! -f /etc/xray/xray.crt ]; then
        blue "---> Issuing SSL certificate for $DOMAIN (acme.sh) ..."
        if [ ! -d /root/.acme.sh ]; then
            curl -s https://get.acme.sh | sh -s email="admin@$DOMAIN"
        fi
        if ss -tln 2>/dev/null | grep -q ':80 '; then
            ssh_dir=$(mktemp -d); cp /etc/ssh/sshd_config "$ssh_dir/" 2>/dev/null
            systemctl stop nginx 2>/dev/null
        fi
        /root/.acme.sh/acme.sh --issue --standalone -d "$DOMAIN" --keylength ec-256 --server letsencrypt --force 2>/dev/null || true
        /root/.acme.sh/acme.sh --install-cert -d "$DOMAIN" --ecc --key-file /etc/xray/xray.key --fullchain-file /etc/xray/xray.crt 2>/dev/null || true
        systemctl start nginx 2>/dev/null
        [ -f /etc/xray/xray.key ] && chmod 600 /etc/xray/xray.key
        green "Certificate installed to /etc/xray/xray.crt + xray.key"
    fi

    # WebSocket.SSH.shuffled services must release :80 before/renew (ssl_renew handles nginx only)
    cat > /usr/local/bin/ssl_renew.sh <<'EOF'
#!/bin/bash
/usr/bin/systemctl stop nginx
"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" &> /root/renew_ssl.log
/usr/bin/systemctl start nginx
EOF
    chmod +x /usr/local/bin/ssl_renew.sh
    ( crontab -l 2>/dev/null | grep -v 'ssl_renew.sh' ; echo '15 03 */3 * * /usr/local/bin/ssl_renew.sh' ) | crontab -
    ( crontab -l 2>/dev/null | grep -v 'acme.sh --cron' ; echo '25 0,6,12,18 * * * "/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" > /dev/null' ) | crontab -
fi

# -----------------------------------------------------------------------------
# 8. Nginx reverse proxy (protocol.conf + web.conf). Compatible nginx syntax.
# -----------------------------------------------------------------------------
if [ -n "$DOMAIN" ]; then
    blue "---> Writing nginx config ..."
    NGINX_V=$(nginx -v 2>&1 | grep -o '[0-9.]*' | head -1)
    if dpkg --compare-versions "$NGINX_V" ge "1.25.1" 2>/dev/null; then
        LISTEN443=$'listen 443 ssl reuseport;\n    listen [::]:443 ssl reuseport;\n    http2 on;'
    else
        LISTEN443=$'listen 443 ssl http2 reuseport;\n    listen [::]:443 ssl http2 reuseport;'
    fi

    mkdir -p /etc/nginx/conf.d /home/vps/public_html /var/www/html
    printf 'xray over websocket' > /var/www/html/index.html

    cat > /etc/nginx/conf.d/protocol.conf <<EOF
server {
    listen 80;
    listen [::]:80;
    ${LISTEN443}
    server_name ${DOMAIN};
    ssl_certificate /etc/xray/xray.crt;
    ssl_certificate_key /etc/xray/xray.key;
    ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
    ssl_protocols TLSv1.2 TLSv1.3;
    root /home/vps/public_html;

    location = /vless {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:14016;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
    }
    location = /vmess {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:23456;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
    }
    location = /trojan-ws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:25432;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
    }
    location = /trojango {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:2087;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
    }
    location = /ss-ws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:30300;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
    }
    location / {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:700;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
    }
    location ^~ /vless-grpc {
        proxy_redirect off;
        grpc_set_header X-Real-IP \$remote_addr;
        grpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        grpc_set_header Host \$http_host;
        grpc_pass grpc://127.0.0.1:24456;
    }
    location ^~ /vmess-grpc {
        proxy_redirect off;
        grpc_set_header X-Real-IP \$remote_addr;
        grpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        grpc_set_header Host \$http_host;
        grpc_pass grpc://127.0.0.1:31234;
    }
    location ^~ /trojan-grpc {
        proxy_redirect off;
        grpc_set_header X-Real-IP \$remote_addr;
        grpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        grpc_set_header Host \$http_host;
        grpc_pass grpc://127.0.0.1:33456;
    }
}
EOF

    cat > /etc/nginx/conf.d/web.conf <<EOF
server {
    listen 89 ssl;
    server_name ${DOMAIN};

    ssl_certificate /etc/xray/xray.crt;
    ssl_certificate_key /etc/xray/xray.key;
    ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128+AESGCM:EECDH+AES128+AESGCM;
    ssl_protocols TLSv1.2 TLSv1.3;

    location / {
        root   /var/www/html;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF

    if nginx -t 2>/dev/null && [ "$(nginx -t 2>&1 | grep -c 'test is successful')" = "1" ]; then
        systemctl restart nginx 2>/dev/null
        green "nginx reloaded"
    else
        red "nginx config check FAILED:"
        nginx -t
    fi
fi

# -----------------------------------------------------------------------------
# 9. Dropbear (multi-port) + Stunnel
# -----------------------------------------------------------------------------
cat > /etc/default/dropbear <<EOF
NO_START=0
DROPBEAR_PORT=143
DROPBEAR_RECEIVE_WINDOW=65536
DROPBEAR_EXTRA_ARGS="-p 50000 -p 109 -p 110 -p 69"
DROPBEAR_BANNER="/etc/issue.net"
EOF
systemctl enable dropbear.service 2>/dev/null
systemctl restart dropbear.service 2>/dev/null || true

mkdir -p /etc/stunnel
if [ ! -f /etc/stunnel/stunnel.pem ]; then
    openssl req -new -x509 -days 3650 -nodes -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem -subj "/CN=localhost" 2>/dev/null
fi
cat > /etc/stunnel/stunnel.conf <<'EOF'
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
[ssh]
accept = 222
connect = 127.0.0.1:22
[dropbear]
accept = 777
connect = 127.0.0.1:109
[ws-stunnel]
accept = 2096
connect = 700
[openvpn]
accept = 442
connect = 127.0.0.1:1194
EOF
systemctl enable stunnel4.service 2>/dev/null
systemctl restart stunnel4.service 2>/dev/null || true
green "Dropbear + Stunnel configured"

# -----------------------------------------------------------------------------
# 10. SSH banner (HTML banner used by HTML-rendering clients)
# -----------------------------------------------------------------------------
if grep -q '<span' "$REPO/ssh/banner" 2>/dev/null; then
    cp "$REPO/ssh/banner" /etc/ssh/banner
    sed -i 's|^#Banner .*|Banner /etc/ssh/banner|' /etc/ssh/sshd_config 2>/dev/null
    grep -q '^Banner /etc/ssh/banner' /etc/ssh/sshd_config || echo 'Banner /etc/ssh/banner' >> /etc/ssh/sshd_config
    systemctl restart ssh.service 2>/dev/null || systemctl restart sshd.service 2>/dev/null || true
    green "SSH banner installed"
fi

# -----------------------------------------------------------------------------
# 11. Panel port info (grepped by add-ws/add-vless/add-tr/addtrgo scripts)
# -----------------------------------------------------------------------------
cat > /root/log-install.txt <<EOF
- XRAY
Vmess TLS: 443
Vmess None TLS: 80
Vless TLS: 443
Vless None TLS: 80
Trojan WS TLS: 443
Trojan WS None TLS: 80
- SSH
OpenSSH: 22
Dropbear: 143, 109, 110, 69, 50000
SSH-UDP: 61149, 62
SSH-WS: 443, 8080
Ovpn WS: 2086
Stunnel: 222, 777, 442, 2096
UDPGW: 7100, 7200, 7900
- Panel
WEB: 81, 89
EOF

# -----------------------------------------------------------------------------
# 12. Firewall - open everything this stack uses + persist across reboots
# -----------------------------------------------------------------------------
blue "---> Opening firewall ports + persistence ..."
open_port(){ proto=$1; port=$2; iptables -C INPUT -p "$proto" --dport "$port" -j ACCEPT 2>/dev/null || iptables -I INPUT -p "$proto" --dport "$port" -j ACCEPT; }
for port in 22 80 81 89 443 109 110 143 222 442 700 777 8080 2086 2087 2095 2096 8443 14016 23456 25432 30300 24456 31234 33456 30310 10085; do
    open_port tcp "$port"
done
for port in 69 36712 50000 7100 7200 7900 61149 62; do
    open_port udp "$port"
done
mkdir -p /etc/iptables
iptables-save > /etc/iptables/rules.v4
if ! systemctl is-enabled netfilter-persistent 2>/dev/null | grep -q enabled; then
    apt-get install -y -o Dpkg::Options::="--force-confold" iptables-persistent >/dev/null 2>&1 || true
fi
systemctl enable netfilter-persistent.service 2>/dev/null || true
if command -v netfilter-persistent >/dev/null 2>&1; then netfilter-persistent save >/dev/null 2>&1 || true; fi

# -----------------------------------------------------------------------------
# 13. Re-verify everything is enabled for boot
# -----------------------------------------------------------------------------
for s in ssh xray v2ray nginx dropbear stunnel4 fail2ban vnstat squid chrony unbound dnscrypt-proxy badvpn WebSocket WebSocket.SSH WebSocket.OVPN; do
    systemctl enable "$s.service" 2>/dev/null || true
done

blue "---> finalize-install.sh complete"