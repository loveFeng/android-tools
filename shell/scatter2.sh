#! /bin/bash

#set -e
set -o errexit
input_text="1.txt"
output_text="scat.txt"

echo " 179        1       1024 mmcblk0p1
 179        2      24576 mmcblk0p2
 179        3        512 mmcblk0p3
 179        4     307200 mmcblk0p4
 179        5      20480 mmcblk0p5
 179        6       1024 mmcblk0p6
 179        7       8192 mmcblk0p7
 179        8      32768 mmcblk0p8
 179        9      32768 mmcblk0p9
 179       10       8192 mmcblk0p10
 179       11      13792 mmcblk0p11
 179       12       8192 mmcblk0p12
 179       13       2048 mmcblk0p13
 179       14       3072 mmcblk0p14
 179       15      24576 mmcblk0p15
 179       16       4096 mmcblk0p16
 179       17       3072 mmcblk0p17
 179       18       5120 mmcblk0p18
 179       19       5120 mmcblk0p19
 179       20       1024 mmcblk0p20
 179       21       1024 mmcblk0p21
 179       22      16384 mmcblk0p22
 179       23       8192 mmcblk0p23
 179       24       5120 mmcblk0p24
 179       25      11264 mmcblk0p25
 179       26    3670016 mmcblk0p26
 179       27     434176 mmcblk0p27
 179       28  117469167 mmcblk0p28
 179       29      16384 mmcblk0p29" > $input_text

total=0
block=1024
startaddr=32768
#adb shell cat /proc/partitions  > 1.txt
rm -f $output_text
deal_line()
{
	num=$2
	size=$3
	name=$4
	
	#10转16 这个方法不知道为啥不能使用变量
	#echo 'ibase=10;obase=16;1234'|bc
	#10 -> 16
    size=$(( $size * $block ))
	tmpsize=`printf "%#x" $size`
    tmpstart=`printf "%#x" $startaddr`

    echo "$num $name $tmpstart $tmpsize"
	echo "$num $name $tmpstart $tmpsize" >> $output_text

	startaddr=$(( $size + $startaddr ))

}

while read line
do
    echo "line=$line"
	deal_line $line
done < $input_text



