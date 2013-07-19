#! /bin/bash

#set -o errexit
if [ -n $ROOT_PATH ]
then
	ROOT_PATH=$(cd "$(dirname "$0")"; pwd)
    #ROOT_PATH=${ROOT_PATH%/*}
    export ROOT_PATH=$ROOT_PATH
fi
echo "$0 ROOT_PATH=$ROOT_PATH"

custom_path=""
custom_zip=""
custom_patched=""
custom_tmp=""
tmp_folder=res

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
else
    #echo "请输入客户升级包文件路径"
    #exit
    custom_path=$ROOT_PATH
fi

file_smali_folder="framework-res"
custom_patched=$custom_path/patched
custom_tmp=$custom_path/temp
source_path=$custom_tmp/source
realfame_path=$custom_tmp/realfame
third_path=$custom_tmp/third
third_orig=$third_path/$file_smali_folder.orig
reject_dir=$custom_tmp/reject
temp_dst_smali_patched_dir=$custom_tmp/dst_smali_patched

old_code_noline=$source_path/$file_smali_folder
new_code_noline=$realfame_path/$file_smali_folder
dst_code_noline=$third_path/$file_smali_folder.tmp
dst_code=$third_path/$file_smali_folder
dst_code_orig=$dst_code.orig

TOOL_DIR=$ROOT_PATH/tools
APKTOOL=$TOOL_DIR/apktool


function ready_workspace() {
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

    jarfile=$file_smali_folder.apk
    #cp $ROOT_PATH/../独立应用/system/framework/$jarfile $realfame_path
    #cp $ROOT_PATH/source/framework/$jarfile $source_path
    #unzip -j $custom_path/$custom_zip system/framework/$jarfile -d $third_path
   
	cp $ROOT_PATH/patched/source/$jarfile $source_path
	cp $ROOT_PATH/patched/realfame/$jarfile $realfame_path
	cp $ROOT_PATH/third/$jarfile $third_path
    

	for tmp in $source_path $realfame_path $third_path
	do
        echo "cd $tmp"
		cd $tmp
        rm -rf $file_smali_folder
        echo "$0 apktool d $tmp/$jarfile"
		$APKTOOL d $tmp/$jarfile
        cd $ROOT_PATH
	done

    #find $zip_path -type d -name ".svn"|xargs rm -rf
	#find $zip_path -type d -name ".git"|xargs rm -rf
}

function deal_file_exist_or_not() {
    echo "$0 deal_file_exist_or_not"
    cd $source_path/$file_smali_folder
    for file in `find ./ -name "*.*"`
    do
        #echo "file=$file"
        if [ -f $source_path/$file_smali_folder/$file ]
        then
           	if [ ! -f $realfame_path/$file_smali_folder/$file ]
           	then
                
            	rm $third_path/$file_smali_folder/$file
           	fi
        fi
    done

    cd $realfame_path/$file_smali_folder
    for file in `find ./ -name "*.*"`
    do
        if [ -f $realfame_path/$file_smali_folder/$file ]
        then
           	if [ ! -f $source_path/$file_smali_folder/$file ]
           	then
            	cp $realfame_path/$file_smali_folder/$file $third_path/$file_smali_folder/$file
           	fi
        fi
    done
    cd $ROOT_PATH
}

function apply_realfame_patch() {
    echo "$0 apply_realfame_patch"

	echo "<<< compute the difference between $old_code_noline and $new_code_noline"
    cp -r $dst_code $dst_code.source

	cd $old_code_noline

	for file in `find ./ -name "*.*"`
	do

       	if [ -f $new_code_noline/$file ]
       	then
            #echo "diff $new_code_noline/$file"
        	diff $file $new_code_noline/$file > /dev/null || {
                #当文件是xml到时候，进行比较
               type=${file##*.}
                if [ "$type" = "xml" ]
                then
                    #echo "diff -B -c $file $new_code_noline/$file > $file.diff"
                    diff -B -c $file $new_code_noline/$file > $file.diff
                else
                    #echo "cp $new_code_noline/$file  $dst_code/$file "
                    cp $new_code_noline/$file  $dst_code/$file              
                fi
			}
       	fi
	done

    cp -r $dst_code $dst_code_noline

    echo "mv $dst_code $dst_code_orig"
	mv $dst_code $dst_code_orig
    echo "cp -r $dst_code_noline $dst_code"
	cp -r $dst_code_noline $dst_code

	echo "<<< apply the patch into the $dst_code"
	cd $old_code_noline
	for file in `find ./ -name "*.diff"`
	do
		mkdir -p $reject_dir/`dirname $file`
        echo "patch $dst_code/${file%.diff}"
        patch $dst_code/${file%.diff} -r $reject_dir/${file%.diff}.rej < $file
	done

	cp -r $dst_code $temp_dst_smali_patched_dir

	cd $dst_code_noline
	for file in `find ./ -name "*.*"`
	do
        rm -f $file.diff
        diff -B -c $file $dst_code_orig/$file > $file.diff
        patch -f $dst_code/$file -r /dev/null < $file.diff >/dev/null 2>&1
		rm -f $file.diff
	done

    find $dst_code -name "*.orig" -exec rm {} \;
	find $temp_dst_smali_patched_dir -name "*.orig" -exec rm {} \;
	rm -rf $dst_code_orig
}


function apk_build_sign() {
    echo "patch realfame into target framework_res is done."
    rej_files=`find $reject_dir -name "*.rej"`
    if [ "$rej_files" = "" ]
    then
	    echo ">>> Congratulate realfame into target framework_res is succeed."
    else
	    echo ">>> Sorry some files not patched Please look at $reject_dir to resolve any conflicts!"
	    echo $rej_files > $reject_dir/rej_file
    fi

    is_ok=""
    echo -n "确认 $third_path/$file_smali_folder 文件是否正确 (y/n)? 默认:y "
    read is_ok

    $APKTOOL b $third_path/$file_smali_folder
    echo "mv $third_path/$file_smali_folder/dist/$file_smali_folder.apk $custom_path/patched/framework"
    mv $third_path/$file_smali_folder/dist/$file_smali_folder.apk $custom_path/
    
    file=$custom_path/$file_smali_folder.apk
    tmpapk=`date +%N`
    tmpapk=$tmpzip.apk
    apk_cert=platform

    java -Xmx512m -jar $ROOT_PATH/tools/signapk.jar -w $ROOT_PATH/build/security/$apk_cert.x509.pem $ROOT_PATH/build/security/$apk_cert.pk8 $file $tmpapk
	mv $tmpapk $file 
}

ready_workspace

deal_file_exist_or_not

apply_realfame_patch

apk_build_sign




