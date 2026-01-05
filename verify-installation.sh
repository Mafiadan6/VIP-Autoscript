#!/bin/bash

# Installation Verification Script
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "VIP-Autoscript Installation Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check root
if [[ $EUID -ne 0 ]]; then
    echo "❌ Please run as root"
    exit 1
fi

# Colors
green='\e[1;32m'
red='\e[1;31m'
yell='\e[1;33m'
NC='\e[0m'

PASS=0
FAIL=0

check_pass() {
    echo -e "  ✅ $1"
    ((PASS++))
}

check_fail() {
    echo -e "  ❌ $1"
    ((FAIL++))
    return 1
}

echo -e "${yell}Checking System Files...${NC}"

# Check menu
if [ -f /usr/local/bin/menu ]; then
    check_pass "Main menu script"
else
    echo "DEBUG: /usr/local/bin/menu not found"
    check_fail "Main menu script"
fi


# Check menu symlinks
[ -L /usr/local/bin/menu-ssh ] && check_pass "SSH menu symlink" || check_fail "SSH menu symlink"
[ -L /usr/local/bin/menu-vmess ] && check_pass "Vmess menu symlink" || check_fail "Vmess menu symlink"
[ -L /usr/local/bin/menu-vless ] && check_pass "Vless menu symlink" || check_fail "Vless menu symlink"
[ -L /usr/local/bin/menu-trojan ] && check_pass "Trojan menu symlink" || check_fail "Trojan menu symlink"

# Check SSH scripts
[ -L /usr/local/bin/usernew ] && check_pass "usernew script" || check_fail "usernew script"
[ -L /usr/local/bin/trial ] && check_pass "trial script" || check_fail "trial script"
[ -L /usr/local/bin/renew ] && check_pass "renew script" || check_fail "renew script"
[ -L /usr/local/bin/hapus ] && check_pass "hapus script" || check_fail "hapus script"
[ -L /usr/local/bin/cek ] && check_pass "cek script" || check_fail "cek script"

# Check Xray scripts
[ -L /usr/local/bin/add-ws ] && check_pass "add-ws script" || check_fail "add-ws script"
[ -L /usr/local/bin/add-vless ] && check_pass "add-vless script" || check_fail "add-vless script"
[ -L /usr/local/bin/add-tr ] && check_pass "add-tr script" || check_fail "add-tr script"

# Check system scripts
[ -L /usr/local/bin/running ] && check_pass "running script" || check_fail "running script"
[ -L /usr/local/bin/wsport ] && check_pass "wsport script" || check_fail "wsport script"
[ -L /usr/local/bin/bw ] && check_pass "bw script" || check_fail "bw script"
[ -L /usr/local/bin/custom-banner ] && check_pass "custom-banner script" || check_fail "custom-banner script"

# Check port scripts
[ -L /usr/local/bin/port-change ] && check_pass "port-change script" || check_fail "port-change script"
[ -L /usr/local/bin/port-ws-ssh ] && check_pass "port-ws-ssh script" || check_fail "port-ws-ssh script"

echo ""
echo -e "${yell}Checking Services...${NC}"

# Check services
systemctl is-active --quiet ssh && check_pass "SSH service" || check_fail "SSH service"
systemctl is-active --quiet xray && check_pass "Xray service" || check_fail "Xray service"
systemctl is-active --quiet stunnel4 && check_pass "Stunnel4 service" || check_fail "Stunnel4 service"
systemctl is-active --quiet WebSocket.SSH.service && check_pass "WebSocket SSH service" || check_fail "WebSocket SSH service"

echo ""
echo -e "${yell}Checking Configuration...${NC}"

# Check configs
grep -q "PermitTunnel yes" /etc/ssh/sshd_config 2>/dev/null && check_pass "SSH UDP enabled" || check_fail "SSH UDP not enabled"
[ -f /etc/ssh/banner ] && check_pass "SSH banner exists" || check_fail "SSH banner missing"
[ -f /etc/xray/domain ] && check_pass "Xray domain config" || check_fail "Xray domain config missing"

echo ""
echo -e "${yell}Checking Ports...${NC}"

# Check ports
ss -tln 2>/dev/null | grep -q ":22 " && check_pass "Port 22 open" || check_fail "Port 22 closed"
ss -tln 2>/dev/null | grep -q ":80 " && check_pass "Port 80 open" || check_fail "Port 80 closed"
ss -tln 2>/dev/null | grep -q ":443 " && check_pass "Port 443 open" || check_fail "Port 443 closed"

echo ""
echo -e "${yell}Checking Additional Components...${NC}"

# Check VPS startup script
[ -f /usr/local/bin/vps-startup ] && check_pass "VPS startup script" || check_fail "VPS startup script missing"

# Check cleanup logs script
[ -f /usr/local/bin/cleanup-logs ] && check_pass "Log cleanup script" || check_fail "Log cleanup script missing"

# Check protocol config
[ -f /root/protocol.conf ] && check_pass "Protocol config" || check_fail "Protocol config missing"

# Verify no WebSocket on 8888
if ! ss -tln 2>/dev/null | grep -q ":8888 "; then
    check_pass "Port 8888 closed (correct)"
else
    check_fail "Port 8888 open (should be closed)"
fi

# Verify BadVPN on correct ports (check running processes instead)
if pgrep -f "badvpn-udpgw.*7200" > /dev/null; then
    check_pass "BadVPN port 7200 running"
else
    check_fail "BadVPN port 7200 not running"
fi

# Verify Fail2Ban is running
systemctl is-active --quiet fail2ban && check_pass "Fail2Ban active" || check_fail "Fail2Ban not active"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${green}PASSED: $PASS${NC} | ${red}FAILED: $FAIL${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $FAIL -eq 0 ]; then
    echo -e "${green}✓ All checks passed!${NC}"
    echo ""
    echo "Type 'menu' to start using the system"
    exit 0
else
    echo -e "${red}✗ Some checks failed!${NC}"
    echo ""
    echo "Please review the failed items above"
    exit 1
fi
