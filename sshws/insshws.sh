cd
apt install python -y
apt install python3 -y

wget -O /usr/local/bin/WebSocket https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/sshws/WebSocket.py
wget -O /usr/local/bin/WebSocket.SSH https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/sshws/WebSocket.SSH.py
wget -O /usr/local/bin/WebSocket.OVPN https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/sshws/WebSocket.OVPN.py

chmod +x /usr/local/bin/WebSocket
chmod +x /usr/local/bin/WebSocket.SSH
chmod +x /usr/local/bin/WebSocket.OVPN


wget -O /etc/systemd/system/WebSocket.service https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/sshws/WebSocket.service && chmod +x /etc/systemd/system/WebSocket.service

wget -O /etc/systemd/system/WebSocket.SSH.service https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/sshws/WebSocket.SSH.service && chmod +x /etc/systemd/system/WebSocket.SSH.service

wget -O /etc/systemd/system/WebSocket.OVPN.service https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/sshws/WebSocket.OVPN.service && chmod +x /etc/systemd/system/WebSocket.OVPN.service


systemctl daemon-reload

systemctl enable WebSocket.service
systemctl start WebSocket.service
systemctl restart WebSocket.service

systemctl enable WebSocket.SSH.service
systemctl start WebSocket.SSH.service
systemctl restart WebSocket.SSH.service

systemctl enable WebSocket.OVPN.service
systemctl start WebSocket.OVPN.service
systemctl restart WebSocket.OVPN.service

mkdir /etc/ws > /dev/null 2>&1
rm /etc/ws/status
rm /etc/ws/status2
echo 'SSH ' >> /etc/ws/status
echo 'SSH' >> /etc/ws/status2
