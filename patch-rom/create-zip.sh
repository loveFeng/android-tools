#! /bin/sh

#set -o errexit
if [ -n $ROOT_PATH ]
then
	ROOT_PATH=$(cd "$(dirname "$0")"; pwd)
    export ROOT_PATH=$ROOT_PATH
fi
echo "$0 ROOT_PATH=$ROOT_PATH"
#放在system/app下到应用如果不进行odex需要将名字写在这
NO_ODEX_APKS="Settings.apk"
need_odex_bool=
#

#默认不签名,platform_apks 使用 platform签名，shared_apks 使用 shared签名，media_apks使用 media签名
shared_apks="Contacts.apk"

media_apks=""

platform_apks=""

apk_cert=
########################

devices=" -d "

TARGET_FILES_ZIP=`date +%Y%m%d`
TARGET_FILES_ZIP=realfame_release_$TARGET_FILES_ZIP.zip
ODEXTOOLS=$ROOT_PATH/tools/OdexTools
chmod 777 $ODEXTOOLS
custom_path=""
custom_zip=""
custom_patched=""

if [ $# -eq 1 ]
then
    custom_path=$1
    echo "输入参数=$custom_path"
    custom_zip=${custom_path##*/}
    if [ "$custom_zip" = "" ]
    then
        custom_zip=update.zip
    fi
    echo "custom_zip=$custom_zip"
    custom_path=${custom_path%/*}
    custom_name=${custom_path##*/}
    echo "custom_path=$custom_path"
    echo "custom_name=$custom_name"
    if [ "$custom_name" != "" ]
    then
        TARGET_FILES_ZIP=${custom_name}_${TARGET_FILES_ZIP}    
    fi
    echo "升级包名字：$TARGET_FILES_ZIP"
    custom_patched=$custom_path/patched
else
    echo "请输入客户升级包文件路径"
    exit
fi

sourec_file=../独立应用

zip_path=$custom_path/zip_source

tmp_path=$custom_path/tmp

export tmp_path=$tmp_path
export zip_path=$zip_path

#######################
#准备工作空间
ready_workspace()
{
    #红色字
    echo "\033[31m请确保当前手机连接到电脑不断开\033[0m"
    echo "$0 function ready_workspace"
    if [ ! -d $custom_patched ]
    then
        echo "不存在patched文件夹"
        exit
    fi
    rm -rf $tmp_path
    mkdir -p $tmp_path
    cp -r $sourec_file/* $tmp_path
    cp -r $custom_patched/framework/* $tmp_path/system/framework/

    if [ -f $ROOT_PATH/$custom_path/custom.sh ]
    then
        chmod 777 $ROOT_PATH/$custom_path/custom.sh
        $ROOT_PATH/$custom_path/custom.sh
    fi

    find $tmp_path -type d -name ".svn"|xargs rm -rf
	find $tmp_path -type d -name ".git"|xargs rm -rf
    
}

#push文件到手机
push_system()
{
    echo "$0 function push_system"
    adb $devices remount

    adb $devices shell rm system/preinstall/*.apk
	adb $devices push $tmp_path/system/framework /system/framework
	adb $devices push $tmp_path/system/bin/ /system/bin
    adb $devices push $tmp_path/system/lib/ /system/lib
    adb $devices push $tmp_path/system/app /system/app
    adb $devices shell rm /system/app/*.odex
}

#产生odex，重新签名apk
odex_apks()
{
    echo "$0 function functodex_apks"
    adb shell chmod 777 /system/bin/dexopt-wrapper
    for file in `ls $tmp_path/system/app/*.apk`
    do
        apk=`basename $file`
        apk=${apk%.*}
		
		judge_odex $apk.apk

        echo "$0 apk=$apk is_odex=$need_odex_bool"

        if [ "$need_odex_bool" = "yes" ] ;then

            adb $devices shell dexopt-wrapper /system/app/$apk.apk /system/bin/$apk.odex
            adb $devices pull /system/bin/$apk.odex $tmp_path/system/app/
		    adb $devices shell rm /system/bin/$apk.odex
            zip -d $tmp_path/system/app/$apk.apk classes.dex
		
		    $ODEXTOOLS $tmp_path/system/app/$apk.odex
        fi
        
        system_apk_cert $apk.apk
		
		if [ "$apk_cert" = "" ] ;then
            echo "$0 $apk.apk not sign"
		else
			java -Xmx512m -jar $ROOT_PATH/tools/signapk.jar -w $ROOT_PATH/build/security/$apk_cert.x509.pem $ROOT_PATH/build/security/$apk_cert.pk8 $file tmp.apk
			mv tmp.apk $file 
        fi
        sleep 1
    done
}
#判断是否需要odex
judge_odex()
{
    apk_name=$1
    need_odex_bool="yes"
    for tmp1 in $NO_ODEX_APKS
    do
        if [ "$tmp1" = "$apk_name" ] ;then
            need_odex_bool="no"
        fi
    done
}
#判断apk使用什么签名
system_apk_cert()
{
    apk_name=$1
    apk_cert=""

    echo "$0 function system_apk_cert apk_name=$apk_name"
	for tmp1 in $platform_apks
    do
        if [ "$tmp1" = "$apk_name" ] ;then
            apk_cert="platform"
        fi
    done
    for tmp2 in $shared_apks
    do
        if [ "$tmp2" = "$apk_name" ] ;then
            apk_cert="shared"
        fi
    done

    for tmp3 in $media_apks
    do
        if [ "$tmp3" = "$apk_name" ] ;then
            apk_cert="media"
        fi
    done
   echo "$0 apk_cert=$apk_cert"
}

#打包到zip，然后签名
sign_zip_file()
{
    #红色字
    echo "\033[31m手机已使用完毕，可以不连接到电脑，或者制作另一个升级包\033[0m"
    echo "$0 function sign_zip_file"

    rm -rf $zip_path

    echo "$0 正在解压$custom_zip 请稍等"
    unzip $custom_path/$custom_zip -d $zip_path >/dev/null

    cp -r $tmp_path/* $zip_path

    if [ -f $ROOT_PATH/$custom_path/zip_custom.sh ]
    then
        chmod 777 $ROOT_PATH/$custom_path/zip_custom.sh
        $ROOT_PATH/$custom_path/zip_custom.sh
    fi

	rm -rf $zip_path/data/

    rm -f $zip_path/system/bin/dexopt-wrapper
    adb shell rm /system/bin/dexopt-wrapper

    #拷贝system/preinstall 下应用到 system/app
    mv $zip_path/system/preinstall/*.apk $zip_path/system/app
    rm -rf $zip_path/system/preinstall/
	
	#拷贝升级脚本
    cp -r $custom_path/META-INF $zip_path
	
	find $zip_path -type d -name ".svn"|xargs rm -rf
	find $zip_path -type d -name ".git"|xargs rm -rf

	echo "$0 正在压缩升级包"
	#压缩升级包
    cd $zip_path
    zip -q -r -y $TARGET_FILES_ZIP *

	
	#签名升级包
    echo "$0 正在签名升级包"
    tmpzip=`date +%N`
    tmpzip=$tmpzip.zip
    java -Xmx4096m -jar $ROOT_PATH/tools/signapk.jar -w $ROOT_PATH/build/security/testkey.x509.pem $ROOT_PATH/build/security/testkey.pk8 $TARGET_FILES_ZIP $tmpzip
	rm $TARGET_FILES_ZIP
    mv $tmpzip ../$TARGET_FILES_ZIP
    cd $ROOT_PATH
    rm -rf $zip_path
    rm -rf $tmp_path
}

wait_for_device_online ()
{
    echo "Wait for the device to be online..."
    adb $devices shell reboot 
    sleep 30
    local timeout=120
    while [ $timeout -gt 0 ]
    do
        if adb $devices shell ls > /dev/null
        then
            break
        fi
        sleep 30
        timeout=$[$timeout - 30]
    done
    #防止第一应用odex生成文件错误，等待1分钟机器全部启动。
    sleep 60
    if [ $timeout -eq 0 ];then
        echo "Please ensure adb can find your device and then rerun this script."
        exit 1
    fi
}


ready_workspace

push_system

wait_for_device_online

odex_apks


sign_zip_file


