#!/bin/bash
###########- COLOR CODE -##############
NC="\e[0m"
RED="\033[0;31m"

# Get local IP address
MYIP=$(hostname -I | awk '{print $1}')
# Set user name as Administrator
Name="Administrator"

# Export language settings
export LANG='en_US.UTF-8'
export LANGUAGE='en_US.UTF-8'

# Export color variables
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export LIGHT='\033[0;37m'
export NC='\033[0m'

echo "Checking VPS"

BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White
UWhite='\033[4;37m'       # White

green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }

clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "       ${BIWhite}${UWhite}TRIALL ${NC}"
echo -e ""
echo -e "     ${BICyan}[${BIWhite}01${BICyan}] Trial Account SSH & OVPN   "
echo -e "     ${BICyan}[${BIWhite}02${BICyan}] Trial Account VMESS    "
echo -e "     ${BICyan}[${BIWhite}03${BICyan}] Trial Account VLESS     "
echo -e "     ${BICyan}[${BIWhite}04${BICyan}] Trial Account TROJAN   "

echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "     ${BIYellow}Press x or [ Ctrl+C ] • To-${BIWhite}Exit${NC}"
echo ""
read -p " Select menu : " opt
echo -e ""
case $opt in
1) clear ; trial ;;
2) clear ; trialvmess ;;
3) clear ; trialvless ;;
4) clear ; trialtrojan ;;
0) clear ; menu ;;
x) exit ;;
*) echo "Wrong choice !" ; sleep 1 ; menu-trial ;;
esac
