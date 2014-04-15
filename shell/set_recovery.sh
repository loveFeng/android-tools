#!/bin/bash
folder=/cache/recovery
com_file=$folder/command
log_file=$folder/log
zip_file="--update_package=/sdcard/tj43-ota.zip"

adb shell mkdir -p $folder
adb shell "rm -f $com_file"
adb shell "rm -f $log_file"
adb shell "echo $zip_file > $com_file"
adb shell "echo --locale=zh_CN >> $com_file"
adb reboot recovery


