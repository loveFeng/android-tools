#!/bin/bash
root="k06"
mkdir -p $root
while read line
do
	echo $line
	name=`basename $line`
	test=${line%%/*}

	echo "line=$line,name=$name, test=$test"
	if [ "$test" = "packages" ];then
		folder=${line%/*}
		echo "folder=$folder"
		mkdir -p $root/$folder	
	fi

	pushd $line
	rm -rf .git
	git init
	git add .
	git commit -m "init"
	git gc
	mv .git $name.git
	popd
	if [ "$test" = "packages" ];then
		folder=${line%/*}
		echo "folder=$folder"
		mv $line/*.git $root/$folder/
	else
		mv $line/*.git $root/
	fi
done < project.list
