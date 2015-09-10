#!/bin/sh
# camstartstop.sh
# (C)2015 by Lexandr0s
# License: GPL, v2 or later

PATH=/usr/bin:/bin:/usr/local/bin:/var/bin:/usr/sbin:/sbin
export PATH

emu=$1


case $emu in
	cccam)
		if [ ! -x /var/emu/$emu ]
			then
				msgbox msg="Error! /var/emu/$emu NOT FOUND or NOT EXECUTABLE! Exit"
				exit
		fi
		if [ ! -e /var/keys/CCcam.cfg ]
			then
			msgbox msg="Error! /var/keys/CCcam.cfg NOT FOUND! Exit"
			exit
		fi
		rm -f /var/tuxbox/config/.conf/.emu*
		touch /var/tuxbox/config/.conf/.emu_cccam
		sleep 2
		/etc/init.d/cam restart
	;;
	mgcamd)
		if [ ! -x /var/emu/$emu ]
			then
				msgbox msg="Error! /var/emu/$emu NOT FOUND or NOT EXECUTABLE! Exit"
				exit
		fi
		if [ ! -e /var/keys/mg_cfg ]
			then
			msgbox msg="Error! /var/keys/mg_cfg NOT FOUND! Exit"
			exit
		fi
		rm -f /var/tuxbox/config/.conf/.emu*
		touch /var/tuxbox/config/.conf/.emu_mgcamd
		sleep 2
		/etc/init.d/cam restart
	;;
	oscam)
		if [ ! -x /var/emu/$emu ]
			then
				msgbox msg="Error! /var/emu/$emu NOT FOUND or NOT EXECUTABLE! Exit"
				exit
		fi
		if [ ! -e /var/keys/oscam.conf ]
			then
			msgbox msg="Error! /var/keys/oscam.conf NOT FOUND! Exit"
			exit
		fi
		rm -f /var/tuxbox/config/.conf/.emu*
		touch /var/tuxbox/config/.conf/.emu_oscam
		sleep 2
		/etc/init.d/cam restart
	;;
	wicardd)
		if [ ! -x /var/emu/$emu ]
			then
				msgbox msg="Error! /var/emu/$emu NOT FOUND or NOT EXECUTABLE! Exit"
				exit
		fi
		if [ ! -e /var/keys/wicardd.conf ]
			then
			msgbox msg="Error! /var/keys/wicardd.conf NOT FOUND! Exit"
			exit
		fi
		rm -f /var/tuxbox/config/.conf/.emu*
		touch /var/tuxbox/config/.conf/.emu_wicardd
		sleep 2
		/etc/init.d/cam restart
	;;
	stop)
		rm -f /var/tuxbox/config/.conf/.emu*
		/etc/init.d/cam stop
	;;
esac