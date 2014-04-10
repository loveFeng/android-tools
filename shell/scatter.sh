#! /bin/bash

#set -e
set -o errexit
input_text="1.txt"
output_text="scat.txt"

startaddr="start"

#adb shell cat /proc/dumchar_info > 1.txt

deal_line()
{
	name=$1
	size=$2
	addr=$3
	type=$4
	map=$5
	
	tmp=${size:0:2}
	if [ $tmp != "0x" ]
	then
		return 0
	fi
	
	if [ $startaddr = "start" ]
	then
		echo "$name 0x0 $map" > $output_text
		startaddr=$(( $size ))
	else
		
		#10转16 这个方法不知道为啥不能使用变量
		#echo 'ibase=10;obase=16;1234'|bc
		#10 -> 16
		tmpaddr=`printf "%#x" $startaddr`

		echo "$name $tmpaddr $map" >> $output_text
		tmpaddr=$(( $size ))
		startaddr=$(( $tmpaddr + $startaddr ))

	fi
}

while read line
do
	deal_line $line
	#echo "$line"
done < $input_text



