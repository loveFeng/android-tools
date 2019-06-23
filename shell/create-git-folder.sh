#!/bin/bash
root="P29"
folder="mt6755_12patches"

mkdir -p $root
files=`ls $folder`
rm -f  log.txt

function create_git() {
name=$1
path=$folder/$name
if [ -d $path ];
then
echo "$path is folder" >> log.txt
pushd $folder
find $name -name ".gitignore" > $name.ig.txt
while read igf
do
    igp=${igf%\/*}
    echo "igp=$igp,igf=$igf"
    mkdir -p tmp/$igp
    mv $igf tmp/$igp/
done < $name.ig.txt
popd

	pushd $path
	find . -type d -name "*.git" | xargs rm -fr

	git init
	git add .
	git commit -m "first init"
cp -rf ../tmp/$name ../
	git add .
	git commit -m "add gitignore"
	git gc
	mv .git $name.git
rm -rf ../tmp
	popd
mv $path/*.git $root/
fi
}

while read line
do
echo "create git $line" >> log.txt
    create_git $line
done < project.txt



#for file in $files
#do
#echo "create git $file" >> log.txt
#    create_git $file
#done
