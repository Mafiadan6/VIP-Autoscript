apt install apache2 -y
rm /etc/apache2/ports.conf
wget -O /etc/apache2/ports.conf https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/apache2.port
sudo systemctl restart apache2
clear
rm /var/www/html/udp.ovpn
rm /var/www/html/tcp.ovpn
touch /var/www/html/udp.ovpn
touch /var/www/html/tcp.ovpn
clear
rm /var/www/html/index.html
wget -O /var/www/html/index.html https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/ssh/index.html
sudo systemctl restart apache2
rm apache.sh
clear
