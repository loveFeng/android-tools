#! /bin/bash

num=1
cd base
while [ $num -lt 20 ]
do
    echo "num=$num"
	git pull
	num=$(($num + 1))
	sleep 1
done
echo  "123456" |  sudo -S poweroff

