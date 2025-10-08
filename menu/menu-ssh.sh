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
echo -e "       ${BIWhite}${UWhite}SSH ${NC}"
echo -e ""
echo -e "     ${BICyan}[${BIWhite}01${BICyan}] Create SSH & OpenVPN Account      "
echo -e "     ${BICyan}[${BIWhite}02${BICyan}] Trial Account SSH & OpenVPN      "
echo -e "     ${BICyan}[${BIWhite}03${BICyan}] Renew SSH & OpenVPN Account      "
echo -e "     ${BICyan}[${BIWhite}04${BICyan}] Delete SSH & OpenVPN Account     "
echo -e "     ${BICyan}[${BIWhite}05${BICyan}] Check User Login SSH & OpenVPN     "
echo -e "     ${BICyan}[${BIWhite}06${BICyan}] List Member SSH & OpenVPN     "
echo -e "     ${BICyan}[${BIWhite}07${BICyan}] Delete User Expired SSH & OpenVPN"
echo -e "     ${BICyan}[${BIWhite}08${BICyan}] Set up Autokill SSH"
echo -e "     ${BICyan}[${BIWhite}09${BICyan}] Cek Users Who Do Multi Login SSH"
echo -e "     ${BICyan}[${BIWhite}10${BICyan}] Locked ssh account"
echo -e "     ${BICyan}[${BIWhite}11${BICyan}] Unlocked ssh account"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "     ${BIYellow}Press x or [ Ctrl+C ] • To-${BIWhite}Exit${NC}"
echo ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in
1) clear ; usernew ; exit ;;
2) clear ; trial ; exit ;;
3) clear ; renew ; exit ;;
4) clear ; hapus ; exit ;;
5) clear ; cek ; exit ;;
6) clear ; member ; exit ;;
7) clear ; delete ; exit ;;
8) clear ; autokill ; exit ;;
9) clear ; ceklim ; exit ;;
10) clear ; lock ; exit ;;
11) clear ; unlock ; exit ;;
0) clear ; menu ; exit ;;
x) exit ;;
*) echo "Wrong choice !" ; sleep 1 ; menu-ssh ;;
esac
