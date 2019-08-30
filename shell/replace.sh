#!/bin/bash

sstr="cn.guyu.android.driver"
rstr="com.guyu.android.morph"
path="/work/GLAPP/RCDForm/Hardwarecode/app/src/main/java"

function replace(){
    num=$1
    old=$2
    new=$3
    file_path=$4
    sed -e "${num}s/$old/$new/g" $file_path > $file_path.tmp
    rm -rf $file_path
    mv $file_path.tmp $file_path
}

pushd $path

grep -rn $sstr > tmp.txt

while read line
do
    echo "line=$line"
    file_path=${line%%:*}
    line_num=${line#*:}
    line_num=${line_num%%:*}
    echo "replace $line_num $sstr $rstr $file_path"
    replace $line_num $sstr $rstr $file_path
done < tmp.txt
rm -f tmp.txt

popd
