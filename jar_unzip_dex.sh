#! /bin/bash

if [ ! $# -eq 1 ]
then
echo "参数个数错误"
else
echo "参数=$@"
fi

PORT_ROOT=$(cd "$(dirname "$0")"; pwd)
file_folder=$1
tmp_folder="tmp"
cd $file_folder
for file in `ls`
do
	file_name=`basename $file`
	file_name=${file_name%.*}
	#echo "file_name=$file_name file=$file"
	unzip $file -d $tmp_folder
	#echo "$PORT_ROOT/dex2jar/dex2jar.sh $tmp_folder/classes.dex"
	$PORT_ROOT/dex2jar/dex2jar.sh $tmp_folder/classes.dex
	#echo "$tmp_folder/classes_dex2jar.jar"
	if [ -f "$tmp_folder/classes_dex2jar.jar" ]
	then
		rm -f $file_name.jar
		mv $tmp_folder/classes_dex2jar.jar $file_name.jar
	fi
	rm -rf $tmp_folder
done