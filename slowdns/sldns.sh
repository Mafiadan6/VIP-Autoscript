apt install ncurses-utils -y
mkdir /etc/slowdns
cd /etc/slowdns

wget - O /etc/slowdns/dns-server https://raw.githubusercontent.com/FasterExE/VIP-Autoscript/main/slowdns/dns-server; chmod +x dns-server




apt install firewalld -y && sudo firewall-cmd --zone=public --permanent --add-port=80/tcp && sudo firewall-cmd --zone=public --permanent --add-port=8080/tcp && sudo firewall-cmd --zone=public --permanent --add-port=443/tcp && sudo firewall-cmd && sudo firewall-cmd --zone=public --permanent --add-port=53/udp && sudo firewall-cmd --zone=public --permanent --add-port=5300/udp && sudo firewall-cmd && sudo firewall-cmd --zone=public --permanent --add-port=2222/tcp && sudo firewall-cmd --reload
