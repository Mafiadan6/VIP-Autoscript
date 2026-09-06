#!/bin/bash

# Create all necessary symlinks for menu system
echo "Creating menu system symlinks..."

# SSH Menu Scripts
ln -sf /root/mastermindvps/VIP-Autoscript/ssh/usernew.sh /usr/local/bin/usernew
ln -sf /root/mastermindvps/VIP-Autoscript/ssh/trial.sh /usr/local/bin/trial
ln -sf /root/mastermindvps/VIP-Autoscript/ssh/renew.sh /usr/local/bin/renew
ln -sf /root/mastermindvps/VIP-Autoscript/ssh/hapus.sh /usr/local/bin/hapus
ln -sf /root/mastermindvps/VIP-Autoscript/ssh/cek.sh /usr/local/bin/cek
ln -sf /root/mastermindvps/VIP-Autoscript/ssh/member.sh /usr/local/bin/member
ln -sf /root/mastermindvps/VIP-Autoscript/ssh/delete.sh /usr/local/bin/delete
ln -sf /root/mastermindvps/VIP-Autoscript/ssh/autokill.sh /usr/local/bin/autokill
ln -sf /root/mastermindvps/VIP-Autoscript/ssh/ceklim.sh /usr/local/bin/ceklim
ln -sf /root/mastermindvps/VIP-Autoscript/ssh/user-lock.sh /usr/local/bin/lock
ln -sf /root/mastermindvps/VIP-Autoscript/ssh/user-unlock.sh /usr/local/bin/unlock
ln -sf /root/mastermindvps/VIP-Autoscript/ssh/add-host.sh /usr/local/bin/add-host

# Vmess Menu Scripts
ln -sf /root/mastermindvps/VIP-Autoscript/xray/add-ws.sh /usr/local/bin/add-ws
ln -sf /root/mastermindvps/VIP-Autoscript/xray/trialvmess.sh /usr/local/bin/trialvmess
ln -sf /root/mastermindvps/VIP-Autoscript/xray/renew-ws.sh /usr/local/bin/renew-ws
ln -sf /root/mastermindvps/VIP-Autoscript/xray/del-ws.sh /usr/local/bin/del-ws
ln -sf /root/mastermindvps/VIP-Autoscript/xray/cek-ws.sh /usr/local/bin/cek-ws

# Vless Menu Scripts
ln -sf /root/mastermindvps/VIP-Autoscript/xray/add-vless.sh /usr/local/bin/add-vless
ln -sf /root/mastermindvps/VIP-Autoscript/xray/trialvless.sh /usr/local/bin/trialvless
ln -sf /root/mastermindvps/VIP-Autoscript/xray/renew-vless.sh /usr/local/bin/renew-vless
ln -sf /root/mastermindvps/VIP-Autoscript/xray/del-vless.sh /usr/local/bin/del-vless
ln -sf /root/mastermindvps/VIP-Autoscript/xray/cek-vless.sh /usr/local/bin/cek-vless

# Trojan Menu Scripts
ln -sf /root/mastermindvps/VIP-Autoscript/xray/add-tr.sh /usr/local/bin/add-tr
ln -sf /root/mastermindvps/VIP-Autoscript/xray/trialtrojan.sh /usr/local/bin/trialtrojan
ln -sf /root/mastermindvps/VIP-Autoscript/xray/renew-tr.sh /usr/local/bin/renew-tr
ln -sf /root/mastermindvps/VIP-Autoscript/xray/del-tr.sh /usr/local/bin/del-tr
ln -sf /root/mastermindvps/VIP-Autoscript/xray/cek-tr.sh /usr/local/bin/cek-tr

# Menu Scripts (auto-link every sub-menu so new menus work immediately)
for f in /root/mastermindvps/VIP-Autoscript/menu/*.sh; do
    [ -f "$f" ] || continue
    cmd="$(basename "$f")"; cmd="${cmd%.sh}"
    [ "$cmd" = "menu.sh" ] && continue
    ln -sf "$f" "/usr/local/bin/$cmd"
done
ln -sf /root/mastermindvps/VIP-Autoscript/menu/custom-banner /usr/local/bin/custom-banner

# System Scripts
ln -sf /root/mastermindvps/VIP-Autoscript/menu/about.sh /usr/local/bin/about
ln -sf /root/mastermindvps/VIP-Autoscript/menu/auto-reboot.sh /usr/local/bin/auto-reboot
ln -sf /root/mastermindvps/VIP-Autoscript/menu/restart.sh /usr/local/bin/restart
ln -sf /root/mastermindvps/VIP-Autoscript/jam.sh /usr/local/bin/jam
ln -sf /root/mastermindvps/VIP-Autoscript/menu/fix-issues.sh /usr/local/bin/fix-issues

# Port Scripts
ln -sf /root/mastermindvps/VIP-Autoscript/port/port-change.sh /usr/local/bin/port-change
ln -sf /root/mastermindvps/VIP-Autoscript/port/port-ws-ssh.sh /usr/local/bin/port-ws-ssh
ln -sf /root/mastermindvps/VIP-Autoscript/port/port-ssl.sh /usr/local/bin/port-ssl
ln -sf /root/mastermindvps/VIP-Autoscript/port/port-ovpn.sh /usr/local/bin/port-ovpn
ln -sf /root/mastermindvps/VIP-Autoscript/port/port-tr.sh /usr/local/bin/port-tr

# Backup Scripts
ln -sf /root/mastermindvps/VIP-Autoscript/backup/backup.sh /usr/local/bin/backup
ln -sf /root/mastermindvps/VIP-Autoscript/backup/restore.sh /usr/local/bin/restore
ln -sf /root/mastermindvps/VIP-Autoscript/backup/limitspeed.sh /usr/local/bin/limitspeed
ln -sf /root/mastermindvps/VIP-Autoscript/backup/autobackup.sh /usr/local/bin/autobackup

# Xolpanel
ln -sf /root/mastermindvps/VIP-Autoscript/xolpanel/xolpanel.sh /usr/local/bin/xolpanel

# VPS Management Scripts
ln -sf /root/mastermindvps/VIP-Autoscript/vps-startup.sh /usr/local/bin/vps-startup
ln -sf /root/mastermindvps/VIP-Autoscript/cleanup-logs.sh /usr/local/bin/cleanup-logs

# Make all scripts executable
chmod +x /usr/local/bin/* 2>/dev/null || true

echo "All menu symlinks created successfully"
