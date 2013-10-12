#! /bin/sh

num=0

while [ $num -le 10 ]
do
    adb reboot
    num=`expr $num + 1`
    echo "num=$num"
    sleep 30
done

