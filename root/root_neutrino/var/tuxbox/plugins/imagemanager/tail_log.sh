#!/bin/sh

while :
do
	tail -n 15 /tmp/backup.log > /tmp/msg.log
	sleep 1
done
