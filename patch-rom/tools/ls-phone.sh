#! /bin/sh

set -o errexit

file_name=`date +%Y%m%d%H%M`
file_name=gt-ls_$file_name
tmp="system
system/app
system/bin
system/etc
system/framework
system/lib
system/media
system/preinstall
system/qrd_theme
system/tts
system/usr
system/vendor
system/xbin
data/data
"

for s in  $tmp
do
	echo "ls \"$s\"" >>$file_name
	adb shell ls -la $s >>$file_name
    echo >>$file_name
    echo >>$file_name
done



