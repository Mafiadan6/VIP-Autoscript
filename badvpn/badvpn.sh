wget -O /bin/badvpn-udpgw https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/newudpgw
wget -O /etc/systemd/system/badvpn.service https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/newudpgw
chmod 777 /bin/badvpn-udpgw
chmod 777 /etc/systemd/system/badvpn.service

sudo systemctl daemon-reload
sudo systemctl enable badvpn.service
sudo systemctl start badvpn.service
sudo systemctl restart badvpn.service
