#! /bin/sh

set -e
if [ -n $ROOT_PATH ]
then
	ROOT_PATH=`pwd`
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
SIGN_TARGET_FILES_APKS=$ROOT_PATH/tools/releasetools/sign_target_files_apks.py
TARGET_FILES_ZIP=`date +%Y%m%d`
TARGET_FILES_ZIP=realfame_release_$TARGET_FILES_ZIP.zip
ODEXTOOLS=$ROOT_PATH/tools/OdexTools
chmod 777 $ODEXTOOLS

need_create=y
if [ $# -eq 1 ]
then
need_create=$1
fi
echo "$0 need_create=$need_create"

if [ "$need_create" != "n" ]
then
	sourec_file=../独立应用
	zip_path=$ROOT_PATH/zip_source
fi

echo "$0 zip_path=$zip_path"
if [ "$zip_path" = "" ]
then
	zip_path=$ROOT_PATH/zip_source
fi

#######################
#准备工作空间
ready_workspace()
{
    echo "$0 function ready_workspace"
    rm -rf zip_source
    mkdir zip_source

    cp -r $sourec_file/* $zip_path

    find $zip_path -type d -name ".svn"|xargs rm -rf
	find $zip_path -type d -name ".git"|xargs rm -rf
}

#push文件到手机
push_system()
{
    echo "$0 function push_system"
    adb $devices remount
	#adb $devices push $zip_path/system/* /system/
    adb $devices shell rm system/preinstall/*.apk
    adb $devices push $zip_path/system/app /system/app
	adb $devices push $zip_path/system/framework /system/framework
	adb $devices push $zip_path/system/bin/ /system/bin
    adb $devices push $zip_path/system/lib/ /system/lib
}

#产生odex，重新签名apk
odex_apks()
{
    echo "$0 function functodex_apks"
    adb shell chmod 777 /system/bin/dexopt-wrapper
    for file in `ls $zip_path/system/app/*.apk`
    do
        apk=`basename $file`
        apk=${apk%.*}
		
		judge_odex $apk.apk

        echo "$0 apk=$apk is_odex=$need_odex_bool"

        if [ "$need_odex_bool" = "yes" ] ;then

            adb $devices shell dexopt-wrapper /system/app/$apk.apk /system/bin/$apk.odex
            adb $devices pull /system/bin/$apk.odex $zip_path/system/app/
		    adb $devices shell rm /system/bin/$apk.odex
            zip -d $zip_path/system/app/$apk.apk classes.dex
		
		    $ODEXTOOLS $zip_path/system/app/$apk.odex
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
    echo "$0 function sign_zip_file"

	#拷贝data/app 下应用到 system/app
	#mv -f $zip_path/data/app/*.apk $zip_path/system/app
	rm -rf $zip_path/data/

    #拷贝system/preinstall 下应用到 system/app
    mv $zip_path/system/preinstall/*.apk $zip_path/system/app
    rm -rf $zip_path/system/preinstall/
	
	#拷贝升级脚本
    cp -r $ROOT_PATH/META-INF $zip_path
	
	find $zip_path -type d -name ".svn"|xargs rm -rf
	find $zip_path -type d -name ".git"|xargs rm -rf
	
	#压缩升级包
    cd $zip_path
    zip -q -r -y $TARGET_FILES_ZIP *

    #$SIGN_TARGET_FILES_APKS -d $ROOT_PATH/build/security $TARGET_FILES_ZIP temp.zip
    #mv temp.zip $TARGET_FILES_ZIP
    #zip -d $TARGET_FILES_ZIP META
	
	#签名升级包
    java -Xmx512m -Xmx1024m -jar $ROOT_PATH/tools/signapk.jar -w $ROOT_PATH/build/security/testkey.x509.pem $ROOT_PATH/build/security/testkey.pk8 $TARGET_FILES_ZIP update.zip
	rm $TARGET_FILES_ZIP
    mv update.zip ../$TARGET_FILES_ZIP
    cd ..
    rm -rf zip_source
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
    if [ $timeout -eq 0 ];then
        echo "Please ensure adb can find your device and then rerun this script."
        exit 1
    fi
}

if [ "$need_create" != "n" ]
then
    echo "单独运行zip生成脚本"
	ready_workspace
fi

push_system

wait_for_device_online

odex_apks

rm -f $zip_path/system/bin/dexopt-wrapper

sign_zip_file


