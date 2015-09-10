#!/bin/sh
#########################
# MultiBoot Neutrino #
#########################
#by Lexandros 08.2015 (thanks for j00zek and  Vasiliks)
#


GOTERROR=0
curdir=`dirname $(readlink -f $0))`
MSGBOX="$curdir/msgbox"

$curdir/kill_lock.sh > dev/null &



LANG='en'
if grep -qs 'russkij' /var/tuxbox/config/neutrino.conf ; then LANG='ru' ; fi


if [ -f /tmp/mboot.log ]
	then
		rm -f /tmp/mboot.log
fi

LOG(){
if [ $LANG = "ru" -a -n "$2" ] 
	then
		log_msg=$2
	else
		log_msg=$1
fi

echo "$log_msg"
echo "$log_msg" >> /tmp/mboot.log
}



GOTERROR(){
LOG "$1" "$2"
touch /tmp/mboot.error
exit 1
}





#######################################
########## checking box type ##########
#######################################
if `cat /proc/stb/info/model | grep -q spark7162`; then
	LOG "Spark7162 detected :)" "Spark7162 определен :)"
	setimg="$curdir/setIMG7162.sh"
elif `cat /proc/stb/info/model | grep -q spark`; then
	LOG "Spark detected :)" "Spark определен :)"
	setimg="$curdir/setIMG.sh"
else
	GOTERROR "Unknown box detected :(" ".Неизвестная модель :("
fi


if [ $GOTERROR -eq 1 ]; then
	if [ $LANG = "ru" ]
		then
		$MSGBOX msg=/tmp/mboot.log title="~C!Ошибка подготовки Менеджера имиджей!!!" timeout=20 select="OK" refresh=0
		else
		$MSGBOX msg=/tmp/mboot.log title="~CERROR preparing Image Manager!!!" timeout=20 select="OK" refresh=0
	fi
	rm -f /tmp/rc.locked
	exit 1
fi



NANDIMAGE="Boot Soft in Flash"
LOG "********************************"
LOG "Initialise Neutrino multiboot" "*Подготовка мультибута*"

############################################################
###### Iterate all installed images
############################################################
iindex=0

for file in `echo 'NAND';blkid -c /dev/null -w /dev/null | grep 'TYPE="ext' | grep -v 'swap' | grep -v 'SWAP' | grep -v 'RECORD' | awk '{print $1}' | tr -d ":" | sed 's/\/dev\///'`
do
	iindex=$(($iindex + 1))
	eval img${iindex}="\"$file\""
done
LOG "Number of images: $iindex" "*Количество имиджей: $iindex*"

############################################################
######If there are images, it makes sense to show bootmenu
############################################################
Buttons=`echo "$NANDIMAGE,";blkid -c /dev/null -w /dev/null | grep 'TYPE="ext' | grep -v 'swap' | grep -v 'SWAP' | grep -v 'RECORD' | awk '{print $2 " on "  $1}' | cut -d "=" -f2 | tr -d "\"" | sed 's/\.DBA//' | sed 's;/dev/;;' | sed 's/:/,/'`
Buttons=`echo $Buttons | sed 's/[ ]*,[ ]*/,/' | sed 's/^,//' | sed 's/,$//'`

if [ $LANG = "ru" ]
	then
	$MSGBOX msg="*Выберите раздел для загрузки:" title="~cМенеджер имиджей: мультизагрузка" timeout=90 echo=1 order=1 select="$Buttons" cyclic=0 refresh=0
	else
	$MSGBOX msg="Select partition for boot:" title="~cImageManager multiboot" timeout=90 echo=1 order=1 select="$Buttons" cyclic=0 refresh=0
fi
MENUINDEX=$?
LOG "Selected index: $MENUINDEX" "*Выбран раздел: $MENUINDEX*"
if [ $MENUINDEX -gt $iindex ]; then exit 0; fi
if [ $MENUINDEX -lt 1 ]; then exit 0; fi

ACTIVEIMAGE=$(eval echo \$img${MENUINDEX})
LOG "Selected item index $MENUINDEX => $ACTIVEIMAGE" "*Выбран имидж $MENUINDEX => $ACTIVEIMAGE*"

if [ $LANG = "ru" ]
	then
	$MSGBOX popup=/tmp/mboot.log title="Подготовка перезагрузки с выбранного имиджа!!!" timeout=-1 refresh=0 &
	else
	$MSGBOX popup=/tmp/mboot.log title="Preparing reboot from selected image!!!" timeout=-1 refresh=0 &
fi

############################################################
# for flash image do nothing
############################################################
if [ "$ACTIVEIMAGE" == "NAND" ]; then
	echo "NAND...">/dev/vfd
	LOG "Preparing reboot from NAND Flash..." "*Подготовка перезагрузки из NAND Flash...*"
	$setimg "NAND"
	GOTERROR=$?
elif ``; then
	echo "$ACTIVEIMAGE">/dev/vfd
	LOG "Preparing reboot from $ACTIVEIMAGE..." "*Подготовка перезагрузки из $ACTIVEIMAGE...*"
	$setimg "USB" "$ACTIVEIMAGE"
	GOTERROR=$?
else
	GOTERROR=1
fi

if [ $GOTERROR -gt 0 ]; then
	echo error
	killall -9 msgbox > /dev/null
	$MSGBOX msg=/tmp/mboot.log title="ERROR!!!" timeout=20 select="OK" refresh=0
	exit 1
else
	
	LOG "selected image successfull!" "*Все получилось!*"
	LOG "Press "OK" to reboot BOX or "Cancel" to exit" "*Нажмите "OK" для перезагрузки или "Cancel" для выхода*"
	killall -9 msgbox > /dev/null
	$MSGBOX msg=/tmp/mboot.log title="Success!" select="OK,Cancel" default=2 refresh=0
	sel=$?
	case $sel in
	1)
		init 6
		;;
	*)	
		exit 0
		;;
	esac
	exit 0	
fi


