#! /bin/bash

num=1
while [ $num -ls 10 ]
do
	#sudo apt-get install wine kdesvn meld xchm stardict wireshark
	echo "num=$num"
	num=$($num + 1)
	sleep 1
done
