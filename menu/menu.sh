red='\e[1;31m'
green='\e[1;32m'
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
vlx=$(grep -c -E "#& " "/etc/xray/config.json")
let vla=$vlx/2
vmc=$(grep -c -E "^### " "/etc/xray/config.json")
let vma=$vmc/2
ssh1="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
trx=$(grep -c -E "^#! " "/etc/xray/config.json")
let tra=$trx/2
ssx=$(grep -c -E "^## " "/etc/xray/config.json")
let ssa=$ssx/2
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White
UWhite='\033[4;37m'       # White
On_IPurple='\033[0;105m'  #
On_IRed='\033[0;101m'
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White
NC='\e[0m'
dtoday="$(vnstat -i eth0 | grep "today" | awk '{print $2" "substr ($3, 1, 1)}')"
utoday="$(vnstat -i eth0 | grep "today" | awk '{print $5" "substr ($6, 1, 1)}')"
ttoday="$(vnstat -i eth0 | grep "today" | awk '{print $8" "substr ($9, 1, 1)}')"
dyest="$(vnstat -i eth0 | grep "yesterday" | awk '{print $2" "substr ($3, 1, 1)}')"
uyest="$(vnstat -i eth0 | grep "yesterday" | awk '{print $5" "substr ($6, 1, 1)}')"
tyest="$(vnstat -i eth0 | grep "yesterday" | awk '{print $8" "substr ($9, 1, 1)}')"
dmon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $3" "substr ($4, 1, 1)}')"
umon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $6" "substr ($7, 1, 1)}')"
tmon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $9" "substr ($10, 1, 1)}')"
clear
tram=$( free -h | awk 'NR==2 {print $2}' )
uram=$( free -h | awk 'NR==2 {print $3}' )
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10 )
CITY=$(curl -s ipinfo.io/city )
# Fix CPU and RAM calculations
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed 's/.*, *\([0-9.]*\)%* id.*/\1/' | awk '{print 100 - $1"%"}')
total_ram=$(grep "MemTotal: " /proc/meminfo | awk '{print int($2/1024)}')
export LANG='en_US.UTF-8'
export LANGUAGE='en_US.UTF-8'
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export LIGHT='\033[0;37m'
export NC='\033[0m'
export EROR="[${RED} EROR ${NC}]"
export INFO="[${YELLOW} INFO ${NC}]"
export OKEY="[${GREEN} OKEY ${NC}]"
export PENDING="[${YELLOW} PENDING ${NC}]"
export SEND="[${YELLOW} SEND ${NC}]"
export RECEIVE="[${YELLOW} RECEIVE ${NC}]"
export BOLD="\e[1m"
export WARNING="${RED}\e[5m"
export UNDERLINE="\e[4m"
clear
clear && clear && clear
clear;clear;clear
# Use systemctl for better service detection
ssh_status=$(systemctl is-active ssh 2>/dev/null)
if [ "$ssh_status" = "active" ]; then
    ressh="${green}ON${NC}"
else
    ressh="${red}OFF${NC}"
fi

stunnel_status=$(systemctl is-active stunnel4 2>/dev/null)
if [ "$stunnel_status" = "active" ]; then
    resst="${green}ON${NC}"
else
    resst="${red}OFF${NC}"
fi

nginx_status=$(systemctl is-active nginx 2>/dev/null)
if [ "$nginx_status" = "active" ]; then
    resngx="${green}ON${NC}"
else
    resngx="${red}OFF${NC}"
fi

dropbear_status=$(systemctl is-active dropbear 2>/dev/null)
if [ "$dropbear_status" = "active" ]; then
    resdbr="${green}ON${NC}"
else
    resdbr="${red}OFF${NC}"
fi

xray_status=$(systemctl is-active xray 2>/dev/null)
if [ "$xray_status" = "active" ]; then
    resv2r="${green}ON${NC}"
else
    resv2r="${red}OFF${NC}"
fi

# WebSocket service doesn't exist by default
ressshws="${red}OFF${NC}"
function addhost(){
clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo ""
read -rp "Domain/Host: " -e host
echo ""
if [ -z $host ]; then
echo "????"
echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
read -n 1 -s -r -p "Press any key to back on menu"
setting-menu
else
echo "IP=$host" > /var/lib/scrz-prem/ipvps.conf
echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo "Dont forget to renew cert"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
fi
}
function genssl(){
clear
systemctl stop nginx
domain=$(cat /var/lib/scrz-prem/ipvps.conf | cut -d'=' -f2)
Cek=$(lsof -i:80 | cut -d' ' -f1 | awk 'NR==2 {print $1}')
if [[ ! -z "$Cek" ]]; then
sleep 1
echo -e "[ ${red}WARNING${NC} ] Detected port 80 used by $Cek "
systemctl stop $Cek
sleep 2
echo -e "[ ${green}INFO${NC} ] Processing to stop $Cek "
sleep 1
fi
echo -e "[ ${green}INFO${NC} ] Starting renew cert... "
sleep 2
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
echo -e "[ ${green}INFO${NC} ] Renew cert done... "
sleep 2
echo -e "[ ${green}INFO${NC} ] Starting service $Cek "
sleep 2
echo $domain > /etc/xray/domain
systemctl restart xray
systemctl restart nginx
echo -e "[ ${green}INFO${NC} ] All finished... "
sleep 0.5
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
}
IPVPS=$(hostname -I | awk '{print $1}')
clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "${BICyan} │                  ${BIWhite}${UWhite}mastermind${NC}"
echo -e "${BICyan} │"
echo -e "${BICyan} │  ${BICyan}OS         :  ${BIYellow}mastermind${NC}"
echo -e "${BICyan} │  ${BICyan}CPU        :  ${BIYellow}$cpu_usage${NC}"
echo -e "${BICyan} │  ${BICyan}DOMAIN     :  ${BIYellow}$(cat /etc/xray/domain)${NC}"
echo -e "${BICyan} │  ${BICyan}CLOUDFLARE :  ${BIYellow}$(cat /etc/xray/flare-domain)${NC}"
echo -e "${BICyan} │  ${BICyan}NS         :  ${BIYellow}$(cat /root/nsdomain)${NC}"
echo -e "${BICyan} │  ${BICyan}RAM        :  ${BIYellow}$totalram MB${NC}"
echo -e "${BICyan} │  ${BICyan}SWAP RAM   :  ${BIYellow}$uram / $tram MB${NC}"
echo -e "${BICyan} │  ${BICyan}IP VPS     :  ${BIPurple}$IPVPS${NC}"
echo -e "${BICyan} │  ${BICyan}REBOOT     :  ${BIYellow}02:00 ( It's 2 p.m )${NC}"
echo -e "${BICyan} │  ${BICyan}DEVELOPER  :  ${BIYellow}𓆩 mastermind 𓆪${NC}"
echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "${BICyan} │  ${BIYellow}SSH         VMESS           VLESS          TROJAN $NC"
echo -e "${BICyan} │  ${Blue} $ssh1            $vma               $vla               $tra $NC"
echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
echo -e "     ${BICyan} SSH ${NC}: $ressh"" ${BICyan} NGINX ${NC}: $resngx"" ${BICyan}  XRAY ${NC}: $resv2r"" ${BICyan} TROJAN ${NC}: $resv2r"
echo -e "   ${BICyan}     STUNNEL ${NC}: $resst" "${BICyan} DROPBEAR ${NC}: $resdbr" "${BICyan} SSH-WS ${NC}: $ressshws"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "${BICyan} │  ${BICyan}[${BIWhite}01${BICyan}] SSH     ${BICyan}[${BIYellow}Menu${BICyan}]${NC}"  "${BICyan}  [${BIWhite}08${BICyan}] ADD-HOST        ${BICyan}[${BIYellow}Menu${BICyan}]${NC}" "${BICyan} │${NC}"
echo -e "${BICyan} │  ${BICyan}[${BIWhite}02${BICyan}] VMESS   ${BICyan}[${BIYellow}Menu${BICyan}]${NC}"  "${BICyan}  [${BIWhite}09${BICyan}] RUNNING         ${BICyan}[${BIYellow}Menu${BICyan}]${NC}" "${BICyan} │${NC}"
echo -e "${BICyan} │  ${BICyan}[${BIWhite}03${BICyan}] VLESS   ${BICyan}[${BIYellow}Menu${BICyan}]${NC}"  "${BICyan}  [${BIWhite}10${BICyan}] WS PORT ${BIPurple}($(cat /etc/ws/status))${NC}  ${BICyan}[${BIYellow}Menu${BICyan}]${NC}" "${BICyan} │${NC}"
echo -e "${BICyan} │  ${BICyan}[${BIWhite}04${BICyan}] TROJAN  ${BICyan}[${BIYellow}Menu${BICyan}]${NC}"  "${BICyan}  [${BIWhite}11${BICyan}] INSTALL BOT     ${BICyan}[${BIYellow}Menu${BICyan}]${NC}" "${BICyan} │${NC}"
echo -e "${BICyan} │  ${BICyan}[${BIWhite}05${BICyan}] SETING  ${BICyan}[${BIYellow}Menu${BICyan}]${NC}"  "${BICyan}  [${BIWhite}12${BICyan}] BANDWITH        ${BICyan}[${BIYellow}Menu${BICyan}]${NC}" "${BICyan} │${NC}"
echo -e "${BICyan} │  ${BICyan}[${BIWhite}06${BICyan}] TRIALL  ${BICyan}[${BIYellow}Menu${BICyan}]${NC}"  "${BICyan}  [${BIWhite}13${BICyan}] MENU THEME      ${BICyan}[${BIYellow}Menu${BICyan}]${NC}" "${BICyan} │${NC}"
echo -e "${BICyan} │  ${BICyan}[${BIWhite}07${BICyan}] BACKUP  ${BICyan}[${BIYellow}Menu${BICyan}]${NC}"  "${BICyan}  [${BIWhite}14${BICyan}] UPDATE SCRIPT   ${BICyan}[${BIYellow}Menu${BICyan}]${NC}" "${BICyan} │${NC}"
echo -e "${BICyan} └─────────────────────────────────────────────────────┘${NC}"
# License verification removed - now open source
echo -e "        ${BICyan}┌─────────────────────────────────────┐${NC}"
echo -e "        ${BICyan}│$NC Version       : $(cat /root/mastermindvps/VIP-Autoscript/version) ${NC}"
echo -e "        ${BICyan}│$NC ${GREEN}User          :\033[1;36m Administrator \e[0m"
echo -e "          $BICyan│$NC License      : ${GREEN}Lifetime$NC Days $NC"
echo -e "        ${BICyan}└─────────────────────────────────────┘${NC}"
echo
read -p " Select menu : " opt
echo -e ""
case $opt in
1) clear ; menu-ssh ;;
2) clear ; menu-vmess ;;
3) clear ; menu-vless ;;
4) clear ; menu-trojan ;;
5) clear ; menu-set ;;
6) clear ; menu-trial ;;
7) clear ; menu-backup ;;
8) clear ; add-host ;;
9) clear ; running ;;
10) clear ; wsport ;;
11) clear ; xolpanel ;;
12) clear ; bw ;;
13) clear ; menu-theme ;;
14) clear ; echo "you have last version!"; sleep 0.5; menu ;;
#14) clear ; update ;;
0) clear ; menu ;;
x) exit ;;
*) echo -e "" ; echo "Press any key to back exit" ; sleep 1 ; exit ;;
esac
