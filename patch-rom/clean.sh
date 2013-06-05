#! /bin/sh

set -e
#set -o errexit


ROOT_PATH=$(cd "$(dirname "$0")"; pwd)
echo "$0 ROOT_PATH=$ROOT_PATH"
export ROOT_PATH=$ROOT_PATH
cp_path=/home/joe/project/TJ47_SVN/trunk/patchrom
cp $cp_path/build $ROOT_PATH -r
cp $cp_path/META-INF $ROOT_PATH -r
cp $cp_path/patched $ROOT_PATH -r
cp $cp_path/tools $ROOT_PATH -r
cp $cp_path/*.sh $ROOT_PATH
cp $cp_path/使用方法 $ROOT_PATH

find $ROOT_PATH -type d -name ".svn"|xargs rm -rf
find $ROOT_PATH -type d -name ".git"|xargs rm -rf
find $ROOT_PATH \( -name \tmp -o -name \smali \) -type d|xargs rm -rf




