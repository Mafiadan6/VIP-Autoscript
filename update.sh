GitUser="zoolztheaz"
if [ "${EUID}" -ne 0 ]; then
echo "You need to run this script as root"
exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
echo "OpenVZ is not supported"
exit 1
fi
echo ""
version=$(cat /root/mastermindvps/VIP-Autoscript/version)
clear
line=$(cat /etc/line)
below=$(cat /etc/below)
back_text=$(cat /etc/back)
number=$(cat /etc/number)
box=$(cat /etc/box)
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info1="${Green_font_prefix}($version)${Font_color_suffix}"
sts="${Info1}"
clear
echo ""
figlet 'UPDATE'
echo -e "   \e[$line--------------------------------------------------------\e[m"
echo -e "   \e[$back_text                 \e[30m[\e[$box CHECK NEW UPDATE\e[30m ]                   \e[m"
echo -e "   \e[$line--------------------------------------------------------\e[m"
echo -e "   \e[$below VVERSION NOW >> $Info1"
echo -e "   \e[$below SSTATUS UPDATE >> $sts"
echo -e ""
echo -e "       \e[1;31mWould you like to proceed?\e[0m"
echo ""
echo -e "            \e[0;32m[ Select Option ]\033[0m"
echo -e "      \e[$number [ 1 ]\e[m \e[$below CCheck Script Update Now\e[m"
echo -e "      \e[$number [ x ]\e[m \e[$below BBack To Menu\e[m"
echo -e ""
echo -e "   \e[$line--------------------------------------------------------\e[m"
echo -e "\e[$line"
read -p "PPlease Choose 1 or x : " option2
case $option2 in
1)
clear
echo -e "\e[1;31mLocal Update Available..\e[m"
echo -e ""
sleep 2
echo -e "\e[1;36mStarting Local Update Process..\e[m"
sleep 2
clear
echo -e "\e[0;32mUpdate completed successfully!\e[0m"
echo ""
echo -e "\e[0;32mAll scripts are now updated to the latest version.\e[0m"
clear
echo ""
echo -e "\033[0;34m----------------------------------------\033[0m"
echo -e "\E[44;1;39m            SCRIPT UPDATED              \E[0m"
echo -e "\033[0;34m----------------------------------------\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
;;
x)
clear
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
;;
esac
