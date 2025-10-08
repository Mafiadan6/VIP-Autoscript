#!/bin/bash
###########- COLOR CODE -##############
NC="\e[0m"
RED="\033[0;31m"

# Get local IP address
MYIP=$(hostname -I | awk '{print $1}')
# Set user name as Administrator
Name="Administrator"

BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White
UWhite='\033[4;37m'       # White
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "       ${BIWhite}${UWhite}VLESS ${NC}"
echo -e ""
echo -e "     ${BICyan}[${BIWhite}01${BICyan}] Create Account XRAY Vless Websocket  "
echo -e "     ${BICyan}[${BIWhite}02${BICyan}] Trial Account XRAY Vless   "
echo -e "     ${BICyan}[${BIWhite}03${BICyan}] Extending Account XRAY Vless Active "
echo -e "     ${BICyan}[${BIWhite}04${BICyan}] Delete Account XRAY Vless Websocket    "
echo -e "     ${BICyan}[${BIWhite}05${BICyan}] Check User Login XRAY Vless     "

echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "     ${BIYellow}Press x or [ Ctrl+C ] • To-${BIWhite}Exit${NC}"
echo ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in
1) clear ; add-vless ; exit ;;
2) clear ; trialvless ; exit ;;
3) clear ; renew-vless ; exit ;;
4) clear ; del-vless ; exit ;;
5) clear ; cek-vless ; exit ;;
0) clear ; menu ; exit ;;
x) exit ;;
*) echo "Wrong choice !" ; sleep 1 ; menu-vless ;;
esac
