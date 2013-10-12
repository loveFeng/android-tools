#!/bin/bash

is_check="false"
path=$1
echo $path
apktool=~/micode/patchrom/tools/apktool
check_file=check.txt



function do_folder(){
    echo "do_folder"
    if [ $1 != "" ]
    then
        do_type=$1
    else
        do_type=apk
    fi
    
    #cd $path
    rm -f $check_file
    pushd $path
    files=`ls *.$do_type`
    popd
    
    for apk in $files
    do
        apk=${apk%.*}
        if [ $do_type = "apk" ]
        then
            $apktool d -t miui -f $path$apk.$do_type $apk
            sed -i "/tag:/d" $apk/apktool.yml
            if [ "$is_check" = "true" ]
            then
                echo "############$apk.apk start#########" >> $check_file
                grep "0x[12][a-z0-9]\{6\}" $apk -rn | sort >> $check_file
                echo "############$apk.apk end#########" >> $check_file
            fi
        else
            $apktool d -f $path$apk.$do_type
        fi
    done
    
}

if [ $# -gt 1 ]
then
    is_check="true"
    echo $is_check
fi

if [ -d $path ]
then
    do_folder apk
    do_folder jar
else
    apk=${path%.*}
    echo $apk
    $apktool d -t miui -f $apk.apk $apk
    sed -i "/tag:/d" $apk/apktool.yml
fi





