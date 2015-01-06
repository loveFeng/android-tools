#!/bin/bash

#需要提交的文件路径
file_list="\
packages/apps/WriteImei \
"

username=xx
password=xx

#提交的日志
message="添加手动修改imei单卡应用"



echo $message > msg_tmp.txt

svn commit --username $username --password $password -F msg_tmp.txt $file_list

rm -f msg_tmp.txt