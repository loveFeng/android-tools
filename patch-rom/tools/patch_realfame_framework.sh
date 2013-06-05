#!/bin/bash

# $1: the old smali code  $2: the new smali code $3: the destination smali code

if [ $# -ne 3 ];then
	echo "Usage: patchrealfame.sh old_smali_dir new_smali_dir dst_smali_dir"
fi

if [ -n $ROOT_PATH ]
then
	PWD=$ROOT_PATH
else
    PWD=`pwd`
fi

old_smali_dir=$1
new_smali_dir=$2
dst_smali_dir=$3
temp_dir=$PWD/temp
temp_old_smali_dir=$temp_dir/old_smali
temp_new_smali_dir=$temp_dir/new_smali
temp_dst_smali_orig_dir=$temp_dir/dst_smali_orig
temp_dst_smali_patched_dir=$temp_dir/dst_smali_patched
reject_dir=$temp_dir/reject

rm -rf $temp_dir

echo "<<< create temp directory to store the old, new source and destination smali code with .line removed"
mkdir -p $temp_old_smali_dir
mkdir -p $temp_new_smali_dir
mkdir -p $temp_dst_smali_orig_dir
mkdir -p $temp_dst_smali_patched_dir
mkdir -p $reject_dir

cp -r $old_smali_dir/*.jar.out $temp_old_smali_dir
cp -r $new_smali_dir/*.jar.out $temp_new_smali_dir
cp -r $dst_smali_dir/*.jar.out $temp_dst_smali_orig_dir


jar_list=`ls $temp_old_smali_dir`

$PWD/tools/rmline.sh $temp_dir

function cp_no_exist_file() {
    old_smali_add=$old_smali_dir/$1
    new_smali_add=$new_smali_dir/$1
    dst_smali_add=$dst_smali_dir/$1
    echo "old_smali_add=$old_smali_add "
	echo "new_smali_add=$new_smali_add "
	echo "dst_smali_add=$dst_smali_add "
    cd $new_smali_add
    for file in `find ./ -name "*.smali"`
	    do
           	if [ -f $old_smali_add/$file ]
           	then
                echo "exist $old_smali_add/$file" > /dev/null
            else
                echo "file is not exist $file"
                folder=${file%/*}
                folder=${folder#/./}
                echo "creat folder $dst_smali_add/$folder"
            	mkdir -p $dst_smali_add/$folder
                cp $new_smali_add/$file $dst_smali_add/$file 
           	fi
	    done
}

function apply_realfame_patch() {
	old_code_noline=$temp_old_smali_dir/$1
	new_code_noline=$temp_new_smali_dir/$1
	dst_code_noline=$temp_dst_smali_orig_dir/$1
	dst_code=$dst_smali_dir/$1
	dst_code_orig=$dst_code.orig

	echo "<<< compute the difference between $old_code_noline and $new_code_noline"
	cd $old_code_noline
	for file in `find ./ -name "*.smali"`
	do
       	if [ -f $new_code_noline/$file ]
       	then
        	diff $file $new_code_noline/$file > /dev/null || {
					diff -B -c $file $new_code_noline/$file > $file.diff
			}
       	else
        	echo "$file does not exist at $new_code_noline"
       	fi
	done

	cd $dst_smali_dir
	mv $dst_code $dst_code_orig
	cp -r $dst_code_noline $dst_code

	echo "<<< apply the patch into the $dst_code"
	cd $old_code_noline
	for file in `find ./ -name "*.smali.diff"`
	do
		mkdir -p $reject_dir/$1/`dirname $file`
        patch $dst_code/${file%.diff} -r $reject_dir/$1/${file%.diff}.rej < $file
	done

	cp -r $dst_code $temp_dst_smali_patched_dir

	cd $dst_code_noline
	for file in `find ./ -name "*.smali"`
	do
        rm -f $file.diff
        diff -B -c $file $dst_code_orig/$file > $file.diff
        patch -f $dst_code/$file -r /dev/null < $file.diff >/dev/null 2>&1
		rm -f $file.diff
	done

    find $dst_code -name "*.smali.orig" -exec rm {} \;
	find $temp_dst_smali_patched_dir -name "*.smali.orig" -exec rm {} \;
	rm -rf $dst_code_orig
}

for tmp in $jar_list
do
  apply_realfame_patch $tmp
  cp_no_exist_file $tmp
done

echo
echo
echo "patch realfame into target framework is done."
rej_files=`find $reject_dir -name "*.rej"`
if [ "$rej_files" = "" ]
then
	echo ">>> Congratulate realfame into target framework is succeed."
else
	echo ">>> Sorry some files not patched Please look at $reject_dir to resolve any conflicts!"
	echo $rej_files > $reject_dir/rej_file
fi
