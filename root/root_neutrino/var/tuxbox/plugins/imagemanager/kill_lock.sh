#!/bin/sh

while :
do
	if ps | grep -v grep | grep shellexec > /dev/null
		then
		echo work > /dev/null
		else
		rm -f /tmp/rc.locked
		exit
	fi
	sleep 1
done
