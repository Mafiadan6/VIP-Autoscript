#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
###########- COLOR CODE -##############
NC="\e[0m"
RED="\033[0;31m" 

BURIQ () {
    curl -sS https://raw.githubusercontent.com/mastermind/permission/main/register > /root/tmp
    data=( `cat /root/tmp | grep -E "^### " | awk '{print $2}'` )
    for user in "${data[@]}"
    do
    exp=( `grep -E "^### $user" "/root/tmp" | awk '{print $3}'` )
    d1=(`date -d "$exp" +%s`)
    d2=(`date -d "$biji" +%s`)
    exp2=$(( (d1 - d2) / 86400 ))
    if [[ "$exp2" -le "0" ]]; then
    echo $user > /etc/.$user.ini
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e "       ${BIWhite}${UWhite}TROJAN ${NC}"
echo -e ""
echo -e "     ${BICyan}[${BIWhite}01${BICyan}] Create Account Trojan    "
echo -e "     ${BICyan}[${BIWhite}02${BICyan}] Trial Account Trojan     "
echo -e "     ${BICyan}[${BIWhite}03${BICyan}] Extending Account Trojan Active Life      "
echo -e "     ${BICyan}[${BIWhite}04${BICyan}] Delete Account Trojan     "
echo -e "     ${BICyan}[${BIWhite}05${BICyan}] Check User Login Trojan     "

echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "     ${BIYellow}Press x or [ Ctrl+C ] • To-${BIWhite}Exit${NC}"
echo ""
read -p " Select menu : " opt
echo -e ""
case $opt in
1) clear ; add-tr ;;
2) clear ; trialtrojan ;;
3) clear ; renew-tr ;;
4) clear ; del-tr ;;
5) clear ; cek-tr ;;
0) clear ; menu ;;
x) exit ;;
*) echo "Wrong choice !" ; sleep 1 ; menu-trojan ;;
esac
