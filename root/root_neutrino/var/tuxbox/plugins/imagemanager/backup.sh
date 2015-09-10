#!/bin/sh
#by Lexandros 08.2015 (thanks for j00zek and  Vasiliks)

TYPE_ARCHIVE=$1



GOTERROR=0
rm -f /tmp/backup.error
curdir=`dirname $(readlink -f $0))`
MSGBOX="$curdir/msgbox"

DATE=`date +%Y%m%d_%H%M`


LANG='en'
if grep -qs 'russkij' /var/tuxbox/config/neutrino.conf ; then LANG='ru' ; fi

if [ -f /tmp/backup.log ]
	then
		rm -f /tmp/backup.log
fi

LOG(){
if [ $LANG = "ru" -a -n "$2" ] 
	then
		log_msg=$2
	else
		log_msg=$1
fi

echo "$log_msg"
echo "$log_msg" >> /tmp/backup.log
}


GOTERROR(){
LOG "$1" "$2"
touch /tmp/backup.error
killall -9 msgbox > /dev/null
if [ $LANG = "ru" ]
	then
	$MSGBOX msg=/tmp/msg.log title="ОШИБКА!!!" timeout=10 refresh=0 select="OK" 
	else
	$MSGBOX msg=/tmp/msg.log title="ERROR!!!" timeout=10 refresh=0 select="OK" 
fi
exit 1
}


if [ $TYPE_ARCHIVE = "IMG" -o $TYPE_ARCHIVE = "TAR" -o $TYPE_ARCHIVE = "TARGZ" ]
	then
		echo ok > /dev/null
	else
		GOTERROR "Parameters incorrect! Param: IMG|TAR|TARGZ"
		exit 1
fi

$curdir/kill_lock.sh &

  if grep -qs 'spark' /proc/stb/info/model ; then
    LOG "SPARK found\n" "*Найдена платформа SPARK*"
  else
    GOTERROR "Box not found !!!" "*Платформа SPARK не найдена!!!*"
    exit 1
  fi

$curdir/tail_log.sh &


############################################################
###### Iterate all partition
############################################################
NANDIMAGE="NAND"
iindex=0

for file in `echo 'NAND';blkid -c /dev/null -w /dev/null | grep -v 'swap' | grep -v 'SWAP' | grep -v 'RECORD' | awk '{print $1}' | tr -d ":" | sed 's/\/dev\///'`
do
	iindex=$(($iindex + 1))
	eval img${iindex}="\"$file\""
done
LOG "Number of partition: $iindex" "*Количество разделов: $iindex*"

############################################################
######Select part from
############################################################
Buttons=`echo "$NANDIMAGE,";blkid -c /dev/null -w /dev/null | grep -v 'swap' | grep -v 'SWAP' | grep -v 'RECORD' | awk '{print $2 " on "  $1}' | cut -d "=" -f2 | tr -d "\"" | sed 's/\.DBA//' | sed 's;/dev/;;' | sed 's/:/,/'`
Buttons=`echo $Buttons | sed 's/[ ]*,[ ]*/,/' | sed 's/^,//' | sed 's/,$//'`

if [ $LANG = "ru" ]
	then
	$MSGBOX msg="~c*Выберите раздел для бэкапа:" title="Бэкап имиджей" timeout=90 echo=1 order=1 select="$Buttons" refresh=0 cyclic=0
	else
	$MSGBOX msg="~cSelect partition for backup-source:" title="ImageManager backup" timeout=90 echo=1 order=1 select="$Buttons" refresh=0 cyclic=0
fi
MENUINDEX=$?
LOG "Selected index: $MENUINDEX" "*Выбран раздел: $MENUINDEX*"
if [ $MENUINDEX -gt $iindex ]; then exit 0; fi
if [ $MENUINDEX -lt 1 ]; then exit 0; fi

ACTIVEIMAGE=$(eval echo \$img${MENUINDEX})
if [ $ACTIVEIMAGE = "NAND" ]
	then
	DEVS_FROM=$ACTIVEIMAGE
	LABEL_FROM=$ACTIVEIMAGE
	else
	LABEL_FROM=`blkid -c /dev/null -w /dev/null | grep $ACTIVEIMAGE | awk '{print $2}' | cut -d "=" -f2 | tr -d \"`   ; DEVS_FROM="/dev/$ACTIVEIMAGE"
fi
LOG "Image for backup-source: $MENUINDEX => $DEVS_FROM" "*Для бэкапа выбран имидж $MENUINDEX => $DEVS_FROM *"

BACKUPIMAGE="e2jffs2.img"
BACKUPTAR="$LABEL_FROM.tar"
BACKUPTARGZ="$LABEL_FROM.tar.gz"

######################################################


############################################################
######Select part to
############################################################
iindex=0

for file in `blkid -c /dev/null -w /dev/null | grep -v $DEVS_FROM | grep -v 'swap' | grep -v 'SWAP' | grep -v 'RECORD' | awk '{print $1}' | tr -d ":" | sed 's/\/dev\///'`
do
	iindex=$(($iindex + 1))
	eval img${iindex}="\"$file\""
done
LOG "Number of partition: $iindex" "*Количество разделов: $iindex*"


Buttons=`blkid -c /dev/null -w /dev/null | grep -v $DEVS_FROM | grep -v 'swap' | grep -v 'SWAP' | grep -v 'RECORD' | awk '{print $2 " on "  $1}' | cut -d "=" -f2 | tr -d "\"" | sed 's/\.DBA//' | sed 's;/dev/;;' | sed 's/:/,/'`
Buttons=`echo $Buttons | sed 's/[ ]*,[ ]*/,/' | sed 's/^,//' | sed 's/,$//'`

if [ $LANG = "ru" ]
	then
	$MSGBOX msg="~c*Выберите расположение бэкапа:" title="Бэкап имиджей" timeout=90 echo=1 order=1 select="$Buttons" refresh=0 cyclic=0
	else
	$MSGBOX msg="~cSelect partition for backup-destination:" title="ImageManager backup" timeout=90 echo=1 order=1 select="$Buttons" refresh=0 cyclic=0
fi
MENUINDEX=$?
LOG "Selected index: $MENUINDEX" "*Выбран раздел: $MENUINDEX*"
if [ $MENUINDEX -gt $iindex ]; then exit 0; fi
if [ $MENUINDEX -lt 1 ]; then exit 0; fi

ACTIVEIMAGE=$(eval echo \$img${MENUINDEX})
LABEL_TO=`blkid -c /dev/null -w /dev/null | grep $ACTIVEIMAGE | awk '{print $2}' | cut -d "=" -f2 | tr -d \"`   ; DEVS_TO="/dev/$ACTIVEIMAGE"
LOG "Partition for backup-destination: $MENUINDEX => $DEVS_TO" "*Для сохранения бэкапа выбран раздел $MENUINDEX => $DEVS_TO *"
#####################################################
echo $DEVS_FROM
echo $DEVS_TO

if [ $LANG = "ru" ]
	then
	$MSGBOX msg="~c*Очистить настройки имиджа?" title="Опции бэкапа" timeout=90 echo=1 order=1 select="Да, Нет" refresh=0 cyclic=0 default=2
	else
	$MSGBOX msg="~cClear setting of image?" title="Backup options" timeout=90 echo=1 order=1 select="Yes,No" refresh=0 cyclic=0 default=2
fi

sel=$?
	case $sel in
	1)
		CLEAR_ARCHIVE=1
		;;
	2)	
		CLEAR_ARCHIVE=0
		;;
	esac

if [ $LANG = "ru" ]
	then
	$MSGBOX msg="~c*Удалить конфиги эмуляторов?*" title="Опции бэкапа" timeout=90 echo=1 order=1 select="Да, Нет" refresh=0 cyclic=0 default=2
	else
	$MSGBOX msg="~cRemove configs of EMU?" title="Backup options" timeout=90 echo=1 order=1 select="Yes,No" refresh=0 cyclic=0 default=2
fi

sel=$?
	case $sel in
	1)
		CLEAR_EMU=1
		;;
	2)	
		CLEAR_EMU=0
		;;
	esac


if [ $LANG = "ru" ]
	then
	$MSGBOX popup=/tmp/msg.log title="Создание бэкапа, пожалуйста, подождите!" timeout=-1 refresh=0 &
	else
	$MSGBOX popup=/tmp/msg.log title="Creating backup, please, wait!" timeout=-1 refresh=0 &
fi

##exit

mount | grep /tmp/im_root > /dev/null
if [ $? -eq 0 ]
	then 
	umount /tmp/im_root
	if [ $? -gt 0 ]
		then
		GOTERROR "Can't unmount /tmp/im_root" "*Не могу отмонтировать /tmp/im_root*"
		exit 1
	fi
fi

rm -rf /tmp/im_root
mkdir -p /tmp/im_root


mount | grep /tmp/dest > /dev/null
if [ $? -eq 0 ]
	then 
	umount /tmp/dest
	if [ $? -gt 0 ]
		then
		GOTERROR "Can't unmount /tmp/dest" "*Не могу отмонтировать /tmp/dest*"
		exit 1
	fi
fi

rm -rf /tmp/dest
mkdir -p /tmp/dest

mount $DEVS_TO /tmp/dest
if [ $? -gt 0 ]
	then
	GOTERROR "Can't mount $DEVS_TO to /tmp/dest" "*Не могу смонтировать $DEVS_TO в /tmp/dest *"
	exit 1
fi
rm -rf /tmp/dest/im_copy	
mkdir -p /tmp/dest/im_copy	



if  [[ "$LABEL_FROM" = "NAND" ]] ; then
	mount -t jffs2 /dev/mtdblock6 /tmp/im_root
	if [ $? -gt 0 ]
		then
		GOTERROR "Can't mount $DEVS_FROM to /tmp/im_root" "*Не могу смонтировать $DEVS_FROM в /tmp/im_root *"
		exit 1
	fi
	if [ ! `ls /tmp/im_root | grep lib` ]
		then
		GOTERROR "On selected partition Enigma2/Neutrino not found" "*В выбранном разделе нет Enigma2/Neutrino*"
		exit 1
	fi
	tar -C /tmp/im_root -cf - . | tar -C /tmp/dest/im_copy -xvf -
	mkdir -p /tmp/dest/im_copy/boot
	LOG "Creating uImage" "Создается uImage"
	set `dd if=/dev/mtd5 bs=4 skip=3 count=1 | $curdir/hexdump -C | head -n1`
	Z=$((64 + `printf "%d" 0x$2$3$4$5`))
	dd if=/dev/mtd5 of=/tmp/dest/im_copy/boot/uImage bs=$Z count=1
else
	mount $DEVS_FROM /tmp/im_root
	if [ $? -gt 0 ]
		then
		GOTERROR "Can't mount $DEVS_FROM to /tmp/im_root" "*Не могу смонтировать $DEVS_FROM в /tmp/im_root *"
		exit 1
	fi
	if [ ! `ls /tmp/im_root | grep lib` ]
		then
		GOTERROR "On selected partition Enigma2/Neutrino not found" "*В выбранном разделе нет Enigma2/Neutrino*"
		exit 1
	fi
	tar -C /tmp/im_root -cf - . | tar -C /tmp/dest/im_copy -xvf -
fi

umount /tmp/im_root
if [ $? -gt 0 ]
	then
	GOTERROR "Can't umount /tmp/im_root" "*Не могу отмонтировать /tmp/im_root *"
	exit 1
fi

rm -rf /tmp/im_root

LOG "Partition $LABEL_FROM copied" "*Раздел $LABEL_FROM скопирован *"

#backup and clear settings enigma
  if [[ $CLEAR_ARCHIVE -eq 1 ]]; then
	rm -f /tmp/dest/im_copy/etc/enigma2/settings
	rm -f /tmp/dest/im_copy/var/tuxbox/config/neutrino.conf
	rm -rf /tmp/dest/im_copy/var/tuxbox/config/.conf
    LOG "Enigma2/Neutrino settings deleted" "*Файл настроек Enigma2/Neutrino удален*"
  fi
#backup and clear EMUsettings
  pathTOfind="/tmp/dest/im_copy/usr /tmp/dest/im_copy/var /tmp/dest/im_copy/etc/tuxbox"
  wicardd=mgcamd=oscam=''
  #backup and clear settings
  if [[ $CLEAR_EMU -eq 1 ]]; then
	rm -rf /tmp/dest/im_copy/var/keys/*
    LOG "Emu config deleted" "*Конфиги эмуляторов удалены!*"
    wicardd=`find $pathTOfind -name 'wicardd.conf'`
    if [[ "$wicardd" != '' ]]; then
    LOG "Wicardd settings deleted" "*Настройки Wicardd удалены*"
    sed "s~.*account.*~account =~" -i $wicardd
    fi
    mgcamd=`find $pathTOfind -name 'newcamd.list'`
    if [[ "$mgcamd" != '' ]]; then
    LOG "MgCamd settings deleted" "*Настройки MgCamd удалены*"
    sed "s~.*CWS = .*$~CWS = server port login parol 01 02 03 04 05 06 07 08 09 10 11 12 13 14~g" -i $mgcamd
    fi
    oscam=`find $pathTOfind -name 'oscam.conf'`
    if [[ "$oscam" != '' ]]; then
    LOG "Oscam settings deleted"  "*Настройки Oscam удалены*"
    sed "s~.*newcamd.*$~[name newcamd server port login parol]~g" -i $oscam
    sed "s~.*cccam.*$~[name cccam server port login parol]~g" -i $oscam
    sed "s~.*cs357x.*$~[name cs357x server port login parol]~g" -i $oscam
    sed "s~.*cs378x.*$~[name cs378x server port login parol]~g" -i $oscam
    fi
  fi


  mkdir -p /tmp/dest/enigma2-$DATE-$LABEL_FROM

  if [[ "$TYPE_ARCHIVE" = "IMG" ]]; then
    BACKUP=$BACKUPIMAGE
    LOG "Copying uImage" "*Копируется uImage*"
    cp -v /tmp//dest/im_copy/boot/uImage /tmp/dest/enigma2-$DATE-$LABEL_FROM >> /tmp/backup.log
    LOG "Please wait, $BACKUP is created" "*Пожалуйста подождите, создается $BACKUP *"
    mkfs.jffs2 -v --root=/tmp/dest/im_copy --faketime --output=/tmp/dest/enigma2-$DATE-$LABEL_FROM/$BACKUP -e 0x20000 -n >> /tmp/backup.log
  elif [[ "$TYPE_ARCHIVE" = "TAR" ]]; then
    BACKUP=$BACKUPTAR
    LOG "Please wait, $BACKUPTAR is created" "*Пожалуйста подождите, создается $BACKUPTAR *"
    cd /tmp/dest/im_copy
    tar -cvf /tmp/dest/enigma2-$DATE-$LABEL_FROM/$BACKUP * >> /tmp/backup.log
  elif [[ "$TYPE_ARCHIVE" = "TARGZ" ]]; then
    BACKUP=$BACKUPTARGZ
    cd /tmp/dest/im_copy
     LOG "Please wait, $BACKUPTARGZ is created" "*Пожалуйста подождите, создается $BACKUPTARGZ *"
    tar -czvf /tmp/dest/enigma2-$DATE-$LABEL_FROM/$BACKUP * >> /tmp/backup.log
  fi


  if [ -f /tmp/dest/enigma2-$DATE-$LABEL_FROM/$BACKUP ] ; then
    LOG "Your $BACKUP can be found in:" "*Ваш $BACKUP находиться в:"
    LOG "$LABEL_TO/enigma2-$DATE-$LABEL_FROM" "*$LABEL_TO/enigma2-$DATE-$LABEL_FROM *"
    else
    LOG "Sorry, Error! Backup not created!" "*Извините, произошла ошибка! Бекап не создан!*"
  fi



killall -9 msgbox > /dev/null

if [ $LANG = "ru" ]
	then
	$MSGBOX msg=/tmp/msg.log title="Создание бэкапа, пожалуйста, подождите!" timeout=-1 refresh=0 select="OK"
	else
	$MSGBOX msg=/tmp/msg.log title="Creating backup, please, wait!" timeout=-1 refresh=0 select="OK"
fi

  cd /
    sync
    rm -rf /tmp/dest/im_copy
    umount /tmp/dest
    LOG "Partition $LABEL_TO unmounted" "*Раздел $LABEL_TO отмонтирован*"
    rm -rf /tmp/dest
    killall  -9 tail_log.sh > /dev/null
exit
