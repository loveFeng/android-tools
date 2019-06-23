#! /bin/bash

device=-d
tmp=`date +%F-%R-%S`
echo "将tmp中的:替换为."
name=${tmp/:/-}
text_path=`pwd`
echo "文件保存在$text_path/$name.txt"
echo "时间：$tmp" > $text_path/$name.txt

echo "**********工程版本**********" >> $text_path/$name.txt
adb $device shell getprop ro.build.type >> $text_path/$name.txt
echo >> $text_path/$name.txt
echo >> $text_path/$name.txt

echo "*********命令 cat /proc/meminfo **********" >> $text_path/$name.txt
adb $device  shell cat /proc/meminfo >> $text_path/$name.txt
echo >> $text_path/$name.txt
echo >> $text_path/$name.txt

echo "**********命令 dumpsys meminfo **********" >> $text_path/$name.txt
adb $device  shell dumpsys meminfo >> $text_path/$name.txt
echo >> $text_path/$name.txt
echo >> $text_path/$name.txt

echo "**********命令 ps **********">> $text_path/$name.txt
adb $device  shell ps >> $text_path/$name.txt
echo >> $text_path/$name.txt
echo >> $text_path/$name.txt

echo "**********命令 procrank **********">> $text_path/$name.txt
adb $device  shell procrank >> $text_path/$name.txt

