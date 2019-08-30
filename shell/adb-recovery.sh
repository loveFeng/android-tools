#!/bin/bash
zipname="update.zip"
folder=/cache/recovery
com_file=$folder/command
log_file=$folder/log
zip_file="--update_package=/cache/$zipname"
adb root
adb push $zipname /cache/
#adb shell mkdir -p $folder
adb shell "rm -f $com_file"
adb shell "echo $zip_file > $com_file"
adb shell "echo --locale=zh_CN >> $com_file"
adb reboot recovery


