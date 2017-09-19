#!/bin/bash

devices=`adb devices | grep "\<device\>" | awk '{print $1}'`
for device in $devices
do
    adb -s $device logcat -s sean Xposed GetFliggyDataResponder System.out FZAutomator xiaobai STFService >$device.txt &
done


exit
adb devices > phones.txt

function install_app() {
    if [ "device" == "$2" ];
    then
        adb -s $1 logcat >$1.txt &
    fi
}
while read line
do
    install_app $line
done < phones.txt

rm -f phones.txt
