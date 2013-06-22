#! /bin/sh

set -o errexit

ROOT_PATH=$(cd "$(dirname "$0")"; pwd)
echo "$0 ROOT_PATH=$ROOT_PATH"
export ROOT_PATH=$ROOT_PATH
chmod 777 $ROOT_PATH/tools -R

for tmp in `ls $ROOT_PATH/custom`
do
    echo "开始进行$tmp升级包制作"
    ./framework-patch.sh custom/$tmp/

    ./create-zip.sh custom/$tmp/
done


is_del=y
echo -n "是否删除中间文件smali temp (y/n)? 默认删除 :y "
	
read is_del

if [ "$is_del" != "n" ];
then
	find $ROOT_PATH \( -name \temp -o -name \smali \) -type d|xargs rm -rf
fi




