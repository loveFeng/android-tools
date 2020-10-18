#!/bin/bash



function startCompile(){

source build/envsetup.sh
lunch sdm845-user
./build.sh dist -j16 2>&1 | tee build_log.txt
ps -ef | grep "jack-server" | grep -v grep | cut -b8-15 | xargs kill -9

}


if [ $# -eq 1 ];then
    echo "休眠$1分钟"
    second=`expr $1 \* 60`
    #echo "second=$second"
    curSec=$(date +%s)
    #echo "curSec=$curSec"
    endSec=`expr $curSec + $second`
    #echo "endSec=$endSec"
    endData=`date --date=@$endSec`
    echo `date` "开始休眠 $second 秒,结束时间-->$endData"
    sleep $second
    echo `date` "休眠结束"
    startCompile
fi




