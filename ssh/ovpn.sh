#!/bin/bash
MYIP=$(wget -qO- ipv4.icanhazip.com);
echo "Checking VPS"
clear
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";
ANU=$(ip -o $ANU -4 route show to default | awk '{print $5}');

# Install OpenVPN dan Easy-RSA
sudo apt install openvpn easy-rsa unzip -y
sudo apt install openssl iptables iptables-persistent -y
mkdir -p /etc/openvpn/server/easy-rsa/
cd /etc/openvpn/
wget https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/vpn.zip
unzip vpn.zip
rm -f vpn.zip
chown -R root:root /etc/openvpn/server/easy-rsa/

cd
mkdir -p /usr/lib/openvpn/
cp /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so /usr/lib/openvpn/openvpn-plugin-auth-pam.so

# nano /etc/default/openvpn
sed -i 's/#AUTOSTART="all"/AUTOSTART="all"/g' /etc/default/openvpn

# restart openvpn dan cek status openvpn
systemctl enable --now openvpn-server@server-tcp
systemctl enable --now openvpn-server@server-udp
/etc/init.d/openvpn restart
/etc/init.d/openvpn status

# activate ip4 forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

# Make config client TCP 1194
cat > /etc/openvpn/client-tcp-1194.ovpn <<-END
client
dev tun
proto tcp
remote xxxxxxxxx 1194
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END

sed -i $MYIP2 /etc/openvpn/client-tcp-1194.ovpn;

# Make config client UDP 2200
cat > /etc/openvpn/client-udp-2200.ovpn <<-END
client
dev tun
proto udp
remote xxxxxxxxx 2200
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END

sed -i $MYIP2 /etc/openvpn/client-udp-2200.ovpn;

# Make config client SSL
cat > /etc/openvpn/client-ssl-443.ovpn <<-END
client
dev tun
proto tcp
remote xxxxxxxxx 443
resolv-retry infinite
route-method exe
nobind
persist-key
persist-tun
auth-user-pass
comp-lzo
verb 3
END

sed -i $MYIP2 /etc/openvpn/client-ssl-443.ovpn;

cd
# in the text xxx replace it with the IP address of your VPS
/etc/init.d/openvpn restart

# enter the certificate into the TCP 1194 client config
echo '<ca>' >> /etc/openvpn/client-tcp-1194.ovpn
cat /etc/openvpn/server/ca.crt >> /etc/openvpn/client-tcp-1194.ovpn
echo '</ca>' >> /etc/openvpn/client-tcp-1194.ovpn

# Copy config OpenVPN client to home directory root for easy download ( TCP 1194 )
cp /etc/openvpn/tcp.ovpn /home/vps/public_html/client-tcp-1194.ovpn

# enter the certificate into the UDP 2200 client config
echo '<ca>' >> /etc/openvpn/client-udp-2200.ovpn
cat /etc/openvpn/server/ca.crt >> /etc/openvpn/client-udp-2200.ovpn
echo '</ca>' >> /etc/openvpn/client-udp-2200.ovpn
# Copy config OpenVPN client to home directory root for easy download ( UDP 2200 )
cp /etc/openvpn/udp.ovpn /home/vps/public_html/client-udp-2200.ovpn

# enter the certificate into the SSL client config
echo '<ca>' >> /etc/openvpn/client-ssl-443.ovpn
cat /etc/openvpn/server/ca.crt >> /etc/openvpn/client-ssl-443.ovpn
echo '</ca>' >> /etc/openvpn/client-ssl-443.ovpn

# Copy config OpenVPN client to home directory root for easy download (SSL)
cp /etc/openvpn/ssl.ovpn /home/vps/public_html/client-ssl-443.ovpn

#firewall to allow UDP access and TCP path access

iptables -t nat -I POSTROUTING -s 10.6.0.0/24 -o $ANU -j MASQUERADE
iptables -t nat -I POSTROUTING -s 10.7.0.0/24 -o $ANU -j MASQUERADE
iptables-save > /etc/iptables.up.rules
chmod +x /etc/iptables.up.rules

iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# Restart service openvpn
systemctl enable openvpn
systemctl start openvpn
/etc/init.d/openvpn restart

# Delete script
history -c
rm -f /root/vpn.sh
