#! /bin/sh

set -e
if [ -n $ROOT_PATH ]
then
	ROOT_PATH=$(cd "$(dirname "$0")"; pwd)
    export ROOT_PATH=$ROOT_PATH
fi
echo "$0 ROOT_PATH=$ROOT_PATH"

custom_path=""
custom_zip=""
custom_patched=""
custom_tmp=""

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
    custom_path=$ROOT_PATH/$custom_path
    echo "custom_path=$custom_path"
    echo "custom_name=$custom_name"
    custom_patched=$custom_path/patched
    custom_tmp=$custom_path/temp
else
    echo "请输入客户升级包文件路径"
    exit
fi


source_path=$custom_tmp/source
realfame_path=$custom_tmp/realfame
third_path=$custom_tmp/third

TOOL_DIR=$ROOT_PATH/tools
APKTOOL=$TOOL_DIR/apktool
is_encode=y
#echo "APKTOOL=$APKTOOL"
#find . \( -name \*.jar -o -name \*.apk \)

ready_workspace()
{
    echo "$0 function ready_workspace"
    rm -rf $custom_tmp
    mkdir -p $custom_tmp
    mkdir -p $source_path
    mkdir -p $realfame_path
    mkdir -p $third_path

    if [ ! -d $source_path ] 
    then
        echo "$source_path 文件夹不存在 请添加"
        exit
    fi
    if [ ! -d $realfame_path ] 
    then
        echo "$realfame_path 文件夹不存在 请添加"
        exit
    fi
    if [ ! -d $third_path ]
    then
        echo "$third_path 文件夹不存在 请添加"
        exit
    fi

    #cp -r $ROOT_PATH/source/framework/*.jar $source_path
    cp -r $ROOT_PATH/../独立应用/system/framework/*.jar $realfame_path

    for tmp in `find $realfame_path -name "*.jar"`
    do
        jarfile=`basename $tmp`
        cp $ROOT_PATH/source/framework/$jarfile $source_path
        #cp  $ROOT_PATH/../独立应用/system/framework/$jarfile $realfame_path
        unzip -j $custom_path/$custom_zip system/framework/$jarfile -d $third_path/framework
    done


	for tmp in $source_path $realfame_path $third_path
	do
       file_smali=$tmp/smali
		echo "$0 $file_smali"
		rm -rf $file_smali
		mkdir -p $file_smali
		cd $file_smali

		for tmp1 in `find $tmp -name "*.jar"`
		do
            echo "$0 apktool d $tmp1"
			$APKTOOL d $tmp1
		done
        cd $ROOT_PATH
	done
    for tmp2 in `find $third_path -name "*.jar"`
    do
        jarfile=`basename $tmp2`
        echo "tmp=$tmp2 jarfile=$jarfile"
        unzip -d $third_path/tmp $tmp2
        rm -f $third_path/tmp/classes.dex
        mv $third_path/tmp/* $third_path/smali/$jarfile.out
        rm -rf $third_path/tmp/
    done
    #find $zip_path -type d -name ".svn"|xargs rm -rf
	#find $zip_path -type d -name ".git"|xargs rm -rf
}

encode_smali()
{
	echo "$0 function encode_smali"
    #$APKTOOL "if" $third_path/framework/framework-res.apk

    for tmp in `ls $third_path/smali`
	do
        echo "$0 apktool b $third_path/smali/$tmp"
		$APKTOOL b $third_path/smali/$tmp
        mv $third_path/smali/$tmp/dist/* $third_path/smali
	done

    for tmp1 in `find $third_path/framework -name "*.jar"`
    do
        jarfile=`basename $tmp1`
        echo "tmp=$tmp1 jarfile=$jarfile"
        cp $tmp1 $third_path/smali/tmp.jar
        cd $third_path/smali/
        unzip -d . $jarfile
        zip -u tmp.jar classes.dex
        rm -f $jarfile classes.dex
        mv tmp.jar $jarfile
    done
    rm -rf $source_path/smali

    is_ok=y
    echo -n "确认 $third_path/smali/下到jar文件是否正确 (y/n)? 默认:y "
    read is_ok

    if [ "$is_ok" != "n" ]
    then
        mv $third_path/smali/*.jar $custom_path/patched/framework
    else
        mv $third_path/smali/*.jar $custom_path/
    fi
}

deal_smali()
{
	if [ "$is_encode" != "n" ];
	then
		encode_smali
	else
		ask_patch_ok
	fi
}

ask_patch_ok()
{
	is_encode=y
    
	echo -n "patch smali is ok? (y/n)? (default: y):"
	read is_encode
	deal_smali
}

ready_workspace

$TOOL_DIR/patch_realfame_framework.sh $source_path/smali $realfame_path/smali $third_path/smali

ask_patch_ok







