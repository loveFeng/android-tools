#!/bin/bash
# 这个脚本必须在每天的 00:00 运行

# tomcat 日志文件的存放路径
logs_target_path="/data/envar/tomcatTarget/logs"
logs_user_path="/data/envar/tomcatUser/logs"

yesterday=$(date -d "yesterday" +"%Y-%m-%d")
month=$(date -d "yesterday" +"%Y")/$(date -d "yesterday" +"%m")

function backLog() {
logs_path=$1
month_path=${logs_path}/$month
yesterday_path=${logs_path}/$yesterday
mkdir -p $month_path
mkdir -p $yesterday_path
pushd $logs_path
mv *$yesterday.* $yesterday_path
mv catalina.out $yesterday_path
popd
}

function tarLog() {
logs_path=$1
month_path=${logs_path}/$month
yesterday_path=${logs_path}/$yesterday
mkdir -p $month_path
mkdir -p $yesterday_path
pushd $logs_path
tar -cz  -f $yesterday.tgz $yesterday
mv $yesterday.tgz $month_path
rm -rf $yesterday_path
popd
}

backLog $logs_target_path
backLog $logs_user_path

tarLog $logs_target_path
tarLog $logs_user_path

