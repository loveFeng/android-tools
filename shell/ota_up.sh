#!/bin/bash

files="
bootable/recovery/Android.mk
build/target/product/security
build/tools/releasetools
out/host/linux-x86/bin/bsdiff
out/host/linux-x86/bin/fs_config
out/host/linux-x86/bin/imgdiff
out/host/linux-x86/bin/minigzip
out/host/linux-x86/bin/mkbootfs
out/host/linux-x86/bin/mkbootimg
out/host/linux-x86/framework/signapk.jar
mediatek/misc/ota_scatter.txt
"

project_path=""

function do_help(){
    echo "请输入工程路径\n
    例如 ./ota_up ~/project/tj43 \n"
    exit 1
}

function do_copy(){
    path=$1
    
    echo "do_copy path= $path"
    
    if [ -r $project_path/$path ]
    then
        if [ -d $project_path/$path ]
        then
            tmp=${path%/*}
			mkdir -p $tmp
            echo "cp -r folder $project_path/$path $tmp "
            cp -r $project_path/$path $tmp 
        else
            echo "cp file $project_path/$path $path"
			mkdir -p ${path%/*}
            cp $project_path/$path $path 
        fi
    else
        echo " $path 不存在 "
    fi
}

if [ $# != 1 ]
then
    do_help
else
    project_path=$1
fi

project_path=${project_path%\/}
echo "工程路径 = $project_path"


if [ ! -d $project_path ]
then
    do_help
    exit
fi

for file in $files
do
    do_copy $file
done

