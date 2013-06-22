#! /bin/sh

set -o errexit

TOOL_DIR=""

if [ -n $ROOT_PATH ]
then
	TOOL_DIR=$(cd "$(dirname "$0")"; pwd)
else
    TOOL_DIR=$ROOT_PATH/tools
fi
echo "$0 TOOL_DIR=$TOOL_DIR"

file_name=`date +%Y%m%d%H%M`
file_name=file_sys_$file_name.txt

adb remount
adb push $TOOL_DIR/getfilesysteminfo /system/xbin
adb shell chmod 0777 /system/xbin/getfilesysteminfo
adb shell /system/xbin/getfilesysteminfo --info /system >> $file_name
adb shell /system/xbin/getfilesysteminfo --info /data >> $file_name
exit
fs_config=`cat $file_name | col -b | sed -e '/getfilesysteminfo/d'`

for line in $fs_config
do
    echo $line | grep -q -e "\<su\>" && continue
    echo $line | grep -q -e "\<invoke-as\>" && continue
    echo $line >> tmp.txt
done

cat tmp.txt | sort > $file_name
rm tmp.txt



