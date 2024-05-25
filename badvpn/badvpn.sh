wget -O /bin/badvpn-udpgw https://github.com/FasterExE/VIP-Autoscript/raw/main/badvpn/badvpn-7100-7900.service
wget -O /etc/systemd/system/badvpn.service https://github.com/FasterExE/VIP-Autoscript/raw/main/badvpn/badvpn-7100-7900.service
chmod 777 /bin/badvpn-udpgw
chmod 777 /etc/systemd/system/badvpn.service

sudo systemctl daemon-reload
sudo systemctl enable badvpn.service
sudo systemctl start badvpn.service
sudo systemctl restart badvpn.service
