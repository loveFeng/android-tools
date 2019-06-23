s1=`pwd`
s1=$s1/
echo $s1

s1=/home/chenhe/桌面/AndroidProject/
s2=/work/3050_06_15/trunk/


tmp="libcore/dalvik/src/main/java
dalvik/vm/analysis/DexPrepare.cpp
frameworks/base/services/java/rf
frameworks/base/services/java/com/android/server/SystemServer.java
frameworks/base/core/rf
system/core/debuggerd/debuggerd.c
system/core/include/private/android_filesystem_config.h"

cp_files()
{
folder=$1
folder=${folder%/*}
path="androidchange/$folder"
echo $path
mkdir -p $path
cp $s2$s $path
}

for s in  $tmp
do
	
	#cp_files $s
	tmp1=$s1$s
	#tmp1=${tmp1/\//""}
	echo $tmp1
	#tmp1=${tmp1/\//:\\}
	echo $tmp1
	#tmp1=${tmp1//\//\\}
	tmp1=${tmp1/frameworks/framework}
	echo $tmp1
	tmp2=$s2$s
	#tmp2=${tmp2/\//""}
	#tmp2=${tmp2/\//:\\}
	#tmp2=${tmp2//\//\\}
	
	meld $tmp1 $tmp2
	
done




