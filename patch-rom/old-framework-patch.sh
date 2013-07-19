#! /bin/sh

if [ -n $ROOT_PATH ]
then
	ROOT_PATH=$(cd "$(dirname "$0")"; pwd)
    export ROOT_PATH=$ROOT_PATH
fi
echo "$0 ROOT_PATH=$ROOT_PATH"

if [ -n $source_path ]
then
	source_path=$ROOT_PATH/patched/source
	realfame_path=$ROOT_PATH/patched/realfame
	third_path=$ROOT_PATH/third
fi
TOOL_DIR=$ROOT_PATH/tools
APKTOOL=$TOOL_DIR/apktool
is_encode=y
#echo "APKTOOL=$APKTOOL"
#find . \( -name \*.jar -o -name \*.apk \)

ready_workspace()
{
    echo "$0 function ready_workspace"
	if [ -d $source_path/smali ]
    then
        echo "$source_path/smali 文件存在，将不生成新到smali文件.如果有问题请自行删除此文件夹"
        return
    fi
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
    for tmp2 in `find $third_path/ -name "*.jar"`
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

    for tmp1 in `find $third_path/ -name "*.jar"`
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






