#!/bin/bash

apks=`ls *.apk`

devices=`adb devices | grep "\<device\>" | awk '{print $1}'`
for device in $devices
do
    for apk in $apks
    do
        adb -s $device install -r $apk
    done
    adb -s $device reboot
done


exit

#旧程序
adb devices > phones.txt

function install_app() {
    if [ "device" == "$2" ];
    then
        adb -s $1 install -r $apkpath
        adb -s $1 reboot
    fi
}
while read line
do
    install_app $line
done < phones.txt

rm -f phones.txt
