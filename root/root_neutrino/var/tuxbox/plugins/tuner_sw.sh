#!/bin/sh
# tuner_sw.sh
# (C)2015 by Lexandr0s
# License: GPL, v2 or later

PATH=/usr/bin:/bin:/usr/local/bin:/var/bin:/usr/sbin:/sbin
export PATH

mode=$1
cat /var/tuxbox/config/neutrino.conf | grep russkij > /dev/null
if [ $? -eq 0 ]
	then
		boxtitle="Подтверждение"
		boxmsg="~SПереключить режим тюнера и перезагрузить ресивер?"
		buttons="Да,Нет"
	else
		boxtitle="Confirm"
		boxmsg="Switch DVB-T mode and reboot box?"
		buttons="OK,Cancel"
fi


msgbox title=$boxtitle msg="$boxmsg" select=$buttons default=2

sel=$?

case $sel in
	1)
		rm -f /var/tuxbox/config/.conf/.tuner*
		touch /var/tuxbox/config/.conf/.tuner_$mode
		reboot
		;;
	2)
		exit
		;;
esac



