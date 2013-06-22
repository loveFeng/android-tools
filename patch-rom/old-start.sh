#! /bin/sh

set -e
#set -o errexit
sourec_file=../独立应用

ROOT_PATH=$(cd "$(dirname "$0")"; pwd)
echo "$0 ROOT_PATH=$ROOT_PATH"
export ROOT_PATH=$ROOT_PATH

zip_path=$ROOT_PATH/zip_source
export zip_path=$zip_path

source_path=$ROOT_PATH/patched/source
realfame_path=$ROOT_PATH/patched/realfame
third_path=$ROOT_PATH/third
	
export source_path=$source_path
export realfame_path=$realfame_path
export third_path=$third_path

chmod 777 $ROOT_PATH/tools -R
#准备工作空间
ready_workspace()
{
    echo "$0 function ready_workspace"
    if [ -d zip_source ]
    then
        is_del=y
        echo -n "zip_source存在，如果是因出错重新运行请输入n,否则回车。是否删除 (y/n)? 默认:y "
        read is_del

        if [ "$is_del" != "n" ]
        then
            rm -rf zip_source
        fi
    fi

    if [ -d zip_source ]
    then
        return
    fi
    mkdir -p zip_source

    cp -r $sourec_file/* $zip_path

    find $zip_path -type d -name ".svn"|xargs rm -rf
	find $zip_path -type d -name ".git"|xargs rm -rf
}

cp_framework_jar()
{
	echo "$0 function cp_framework_jar"
	mkdir -p $realfame_path
	cp $zip_path/system/framework/*.jar $realfame_path/framework
	
}

pull_framework_jar()
{
	echo "$0 function pull_framework_jar"
	mkdir -p $third_path/framework
    adb remount
	for tmp in `find $zip_path/system/framework/ -name "*.jar"`
		do
			tmp1=`basename $tmp`
            adb pull /system/framework/$tmp1 $third_path/framework
		done
}

ready_workspace

#请自行拷贝修改过到jar到$$realfame_path
#cp_framework_jar

pull_framework_jar

./old-framework-patch.sh

is_ok=y
echo -n "确认 $third_path/smali/下到jar文件是否正确 (y/n)? 默认:y "
read is_ok

if [ "$is_ok" != "n" ]
then
    mv $third_path/smali/*.jar $zip_path/system/framework/
fi

./old-create-zip.sh n

is_del=y
echo -n "是否删除中间文件smali tmp (y/n)? 默认删除 :y "
	
read is_del

if [ "$is_del" != "n" ];
then
	find $ROOT_PATH \( -name \tmp -o -name \smali \) -type d|xargs rm -rf
fi




